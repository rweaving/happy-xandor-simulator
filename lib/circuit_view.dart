part of xandorcode;

class CircuitView {
  final SelectElement? selectElement =
      querySelector('#select_circuit') as SelectElement?;
  final ButtonElement? buttonZoomIn =
      querySelector('#button_zoomIn') as ButtonElement?;
  final ButtonElement? buttonZoomOut =
      querySelector('#button_zoomOut') as ButtonElement?;
  final InputElement? checkBoxGridSnap =
      querySelector('#checkbox_gridsnap') as InputElement?;

  Element? topBar;
  int width = 1000;
  int height = 600;

  LogicDevice? moveDevice;
  LogicDevice? editLabelDevice;
  Point<num> deviceMoveOffset = const Point<num>(0, 0);
  Wire? selectedWire;

  bool gridSnap = false;
  int gridSize = 10;

  CircuitView() {
    topBar = querySelector('#top-bar');

    selectElement?.onChange.listen(selectCircuit);
    buttonZoomIn?.onClick.listen(onZoomInClick);
    buttonZoomOut?.onClick.listen(onZoomOutClick);

    checkBoxGridSnap?.onChange.listen(onCheckBoxGridSnap);
    if (checkBoxGridSnap != null) {
      checkBoxGridSnap!.checked = gridSnap;
    }

    width = canvas.width ?? 1000;
    height = canvas.height ?? 600;

    canvas.onMouseDown.listen(onMouseDown);
    canvas.onMouseUp.listen(onMouseUp);
    canvas.onDoubleClick.listen(onMouseDoubleClick);
    canvas.onMouseMove.listen(onMouseMove);
    canvas.onContextMenu.listen(onContextMenu);
    canvas.onMouseWheel.listen(onMouseWheel);

    document.onKeyDown.listen(onKeyDown);
    document.onKeyUp.listen(onKeyUp);
  }

  void onZoomInClick(Event e) {
    drawScale = (drawScale + 0.1).clamp(0.3, 3.0);
  }

  void onZoomOutClick(Event e) {
    drawScale = (drawScale - 0.1).clamp(0.3, 3.0);
  }

  void onCheckBoxGridSnap(Event e) {
    gridSnap = checkBoxGridSnap?.checked ?? false;
  }

  void addingNewDevice(LogicDevice d) {
    moveDevice = d;
    deviceMoveOffset = d.deviceType.centerPoint;
  }

  void selectCircuit(Event e) {
    final selectedCircuit = selectElement?.selectedOptions.first.value;
    if (selectedCircuit != null) {
      circuit.loadCircuit(selectedCircuit);
    }
  }

  void start() {
    circuit.run = true;
    circuitDraw.start();
    sideBar.start();
  }

  void stop() {
    circuit.run = false;
  }

  void onContextMenu(MouseEvent e) {
    e.preventDefault();
  }

  void onKeyDown(KeyboardEvent e) {
    final code = e.keyCode;
    final shift = e.shiftKey;

    if (editLabelDevice != null) {
      e.preventDefault();
      if (code == KeyCode.ENTER) {
        editLabelDevice = null;
        return;
      }
      if (code == KeyCode.DELETE) {
        editLabelDevice!.label = '';
        editLabelDevice = null;
        return;
      }
      if (code == KeyCode.ESC) {
        editLabelDevice = null;
        return;
      }
      if (code == KeyCode.BACKSPACE) {
        final current = editLabelDevice!.label ?? '';
        if (current.isNotEmpty) {
          editLabelDevice!.label = current.substring(0, current.length - 1);
        }
        return;
      }
      if (code >= 32 && code <= 126) {
        final key = utf8.decode([code]);
        final current = editLabelDevice!.label ?? '';
        editLabelDevice!.label =
            shift ? '$current$key' : '$current${key.toLowerCase()}';
      }
      return;
    }

    circuit.keyDown(code);
  }

  void onKeyUp(KeyboardEvent e) {
    final code = e.keyCode;
    if (editLabelDevice != null) return;

    circuit.keyUp(code);

    if (code == KeyCode.ESC && wireCreator.creatingWire) {
      wireCreator.abort();
      return;
    }

    if (code == KeyCode.DELETE || code == KeyCode.BACKSPACE) {
      if (wireCreator.creatingWire) {
        wireCreator.abort();
        return;
      }
      if (circuitWires.wiresSelected) {
        circuitWires.deleteSelectedWires();
        return;
      }
      if (selectedDevices.isNotEmpty) {
        circuit.deleteSelectedDevices();
      }
    }
  }

  void onMouseWheel(WheelEvent e) {
    e.preventDefault();
    drawScale = (drawScale - e.deltaY / 1000).clamp(0.3, 3.0);
  }

  void _updateUiPoint(MouseEvent e) {
    if (gridSnap) {
      final x = (e.offset.x / gridSize).toInt();
      final y = (e.offset.y / gridSize).toInt();
      uiPoint = Point<num>(x * gridSize / drawScale, y * gridSize / drawScale);
      uiPointUnscaled = Point<num>(x * gridSize, y * gridSize);
    } else {
      uiPoint = drawScale != 1.0
          ? Point<num>(e.offset.x / drawScale, e.offset.y / drawScale)
          : e.offset;
      uiPointUnscaled = e.offset;
    }
  }

  void onMouseDown(MouseEvent e) {
    e.preventDefault();
    _updateUiPoint(e);

    if (e.button == 0) {
      if (contextMenu.visible) {
        if (contextMenu.contains(uiPoint)) {
          contextMenu.hide();
          final action = contextMenu.menuClick(uiPoint);
          switch (action) {
            case 2:
              editLabelDevice = contextMenu.device;
              editLabelDevice?.label ??= '';
              break;
            case 3:
              circuit.deleteDevice(contextMenu.device);
              break;
          }
        } else {
          contextMenu.location = null;
        }
        return;
      }

      if (wireCreator.creatingWire) {
        wireCreator.addWirePoint(uiPoint);
        return;
      } else if (wireCreator.createWire(uiPoint)) {
        return;
      }

      if (moveDevice != null) {
        moveDevice = null;
        return;
      }

      if (circuit.trySelectDevices(uiPoint)) {
        selectedDevices.first.clicked(uiPoint);
        if (selectedDevices.first.locked) return;
        moveDevice = selectedDevices.first;
        deviceMoveOffset = moveDevice!.position - uiPoint;
        return;
      }

      if (circuitWires.selectWirePoints(uiPoint) > 0) {
        return;
      }

      if (circuit.tryWireSelect(uiPoint) > 0) {
        selectedWire = circuitWires.firstSelectedWire();
        return;
      }
    } else if (e.button == 2) {
      if (contextMenu.visible) {
        contextMenu.hide();
      } else if (circuit.trySelectDevices(uiPoint)) {
        contextMenu.buildMenu(selectedDevices.first);
        contextMenu.location = uiPoint;
      }
    }
  }

  void onMouseUp(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();

    if (moveDevice != null) {
      moveDevice!.stopMove();
      moveDevice = null;
      return;
    }

    if (circuitWires.pointsSelected) {
      circuitWires.deselectWirePoints();
    }

    circuit.movingWirePoint = null;
  }

  void onMouseDoubleClick(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
  }

  void onMouseMove(MouseEvent e) {
    _updateUiPoint(e);

    if (selectedWirePoints.isNotEmpty) {
      circuitWires.moveSelectedPoints(uiPoint);
      return;
    }

    if (contextMenu.visible) {
      if (contextMenu.contains(uiPoint)) {
        contextMenu.selectItem(uiPoint);
      }
      return;
    }

    if (moveDevice != null) {
      if (gridSnap) {
        final x = ((uiPoint.x + deviceMoveOffset.x) / gridSize).toInt();
        final y = ((uiPoint.y + deviceMoveOffset.y) / gridSize).toInt();
        moveDevice!.moveDevice(Point<num>(x * gridSize, y * gridSize));
      } else {
        moveDevice!.moveDevice(uiPoint + deviceMoveOffset);
      }
      return;
    }

    if (circuit.movingWirePoint != null) {
      circuit.movingWirePoint!.point = uiPoint;
      return;
    }

    if (wireCreator.creatingWire) {
      if (circuit.checkConnection(uiPoint)) {
        return;
      }
      if (wireCreator.needOutput) {
        circuit.selectedWirePoint = circuitWires.selectWirePoint(uiPoint);
        if (circuit.selectedWirePoint?.point != null) {
          uiPoint = circuit.selectedWirePoint!.point!;
        } else {
          selectedWire = circuitWires.wireHit(uiPoint);
          if (selectedWire != null) {
            final p = selectedWire!.getWireSnapPoint(uiPoint);
            if (p != null) uiPoint = p;
          }
        }
        return;
      }
    }

    if (circuit.checkValid(uiPoint)) return;

    circuit.selectedWirePoint = circuitWires.selectWirePoint(uiPoint);
    if (circuit.selectedWirePoint != null) return;

    circuit.trySelectDevices(uiPoint);
  }
}
