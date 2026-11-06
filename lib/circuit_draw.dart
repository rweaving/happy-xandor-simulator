part of xandorcode;

class CircuitDraw {
  static const double PI2 = math.pi * 2;

  final Stopwatch stopwatch = Stopwatch();
  num totalDrawTime = 0;
  num framesDrawn = 0;
  num lastDrawTime = 0;

  int width = canvas.width ?? 1000;
  int height = canvas.height ?? 600;
  num lastDrawScale = 1;
  bool showGrid = true;

  final CanvasRenderingContext2D context =
      canvas.getContext('2d') as CanvasRenderingContext2D;

  late final ImageElement backgroundImage;
  CanvasPattern? backgroundPattern;

  CircuitDraw() {
    backgroundImage = ImageElement(src: 'images/GridBackground.png');
    backgroundImage.onLoad.listen((_) {
      backgroundPattern =
          context.createPatternFromImage(backgroundImage, 'repeat');
    });
    window.onResize.listen((_) => onResize());
  }

  void start() {
    onResize();
    window.requestAnimationFrame(animate);
  }

  void draw() {
    if (lastDrawScale != drawScale) {
      lastDrawScale = drawScale;
    }

    context
      ..lineCap = 'round'
      ..lineJoin = 'round'
      ..miterLimit = 10;

    stopwatch
      ..reset()
      ..start();

    clearCanvas();
    drawBorder();
    drawSelectedWires();
    drawWires();
    drawSelectedDevices();
    drawDevices();
    drawWireCreator();
    drawPinSelectors();
    drawLabelEditor();

    if (contextMenu.visible) {
      drawContextMenu(contextMenu);
    }

    stopwatch.stop();
    totalDrawTime += stopwatch.elapsedMicroseconds;
    framesDrawn++;
  }

  void animate(num highResTime) {
    if (highResTime - lastDrawTime >= 20) {
      draw();
      lastDrawTime = highResTime;
    }
    window.requestAnimationFrame(animate);
  }

  void onResize() {
    height = (window.innerHeight ?? 700) - 50;
    width = (window.innerWidth ?? 1200) - sideBar.width - 15;
    canvas
      ..height = height
      ..width = width;
    draw();
  }

  void clearCanvas() {
    context.clearRect(0, 0, width, height);
  }

  void drawBorder() {
    context
      ..save()
      ..clearRect(0, 0, width, height)
      ..scale(drawScale, drawScale)
      ..beginPath()
      ..fillStyle = backgroundPattern ?? Style.GRID_BACKGROUND_COLOR
      ..lineWidth = Style.BORDER_LINE_WIDTH
      ..strokeStyle = Style.GRID_BACKGROUND_COLOR
      ..rect(0, 0, width / drawScale, height / drawScale)
      ..fillRect(0, 0, width / drawScale, height / drawScale)
      ..stroke()
      ..closePath()
      ..restore();
  }

  void drawContextMenu(CanvasMenu menu) {
    final loc = menu.location;
    if (loc == null) return;

    context
      ..save()
      ..beginPath()
      ..shadowBlur = 25
      ..shadowColor = Style.ShadowColor
      ..fillStyle = '#CCCCCC'
      ..strokeStyle = 'Black'
      ..shadowOffsetX = 7
      ..shadowOffsetY = 7
      ..rect(loc.x, loc.y, menu.width, menu.height)
      ..fillRect(loc.x, loc.y, menu.width, menu.height)
      ..stroke()
      ..closePath()
      ..restore();

    context
      ..save()
      ..fillStyle = 'Black'
      ..font = '12px Arial';

    for (int t = 0; t < menu.items.length; t++) {
      if (menu.items[t] == menu.selectedItem) {
        context
          ..fillStyle = 'Blue'
          ..fillRect(loc.x + 1, loc.y + 1 + (t * menu.itemHeight),
              menu.width - 2, menu.itemHeight - 2)
          ..fillStyle = 'White'
          ..fillText(menu.items[t], loc.x + 10,
              loc.y + (t * menu.itemHeight) + 17, menu.itemWidth);
      } else {
        context
          ..fillStyle = 'Black'
          ..fillText(menu.items[t], loc.x + 10,
              loc.y + (t * menu.itemHeight) + 17, menu.itemWidth);
      }
    }
    context.restore();
  }

  void drawLabelEditor() {
    final dev = circuitView.editLabelDevice;
    if (dev == null) return;

    final txt = '${dev.label ?? ''}_';
    context
      ..save()
      ..font = 'bold 12px Arial';

    final tm = context.measureText(txt);
    final p = dev.position;
    final boxLeft = p.x - 10;
    final boxWidth = (tm.width ?? 40) + 35;
    final boxTop = p.y - 20;
    const num boxHeight = 25;

    context
      ..beginPath()
      ..shadowColor = '#303030'
      ..shadowOffsetX = 5
      ..shadowOffsetY = 5
      ..shadowBlur = 10
      ..fillStyle = '#ffffff'
      ..fillRect(boxLeft, boxTop, boxWidth, boxHeight)
      ..stroke()
      ..closePath()
      ..restore();

    context
      ..save()
      ..fillStyle = 'DarkViolet'
      ..fillText(txt, p.x, p.y)
      ..restore();
  }

  void drawDevices() {
    context
      ..save()
      ..scale(drawScale, drawScale);

    for (final device in logicDevices) {
      drawDevice(device);
    }

    context
      ..lineWidth = 1
      ..strokeStyle = Style.DEVICE_LABEL_COLOR
      ..fillStyle = Style.DEVICE_LABEL_COLOR
      ..font = 'bold 12px Arial';

    for (final device in logicDevices) {
      if (device.label != null && device.label!.isNotEmpty) {
        context.fillText(device.label!, device.position.x, device.position.y - 5);
      }
    }

    context.restore();
  }

  void drawDevice(LogicDevice device) {
    for (final img in device.images) {
      context.drawImage(img.image, device.position.x + img.offsetPoint.x,
          device.position.y + img.offsetPoint.y);
    }
  }

  void drawSelectedDevices() {
    if (selectedDevices.isEmpty) return;

    context
      ..save()
      ..scale(drawScale, drawScale)
      ..shadowBlur = 15;

    for (final device in selectedDevices) {
      if (device.images.isEmpty) continue;
      context.shadowColor = device.locked ? 'red' : 'green';
      context.drawImage(
          device.images.first.image,
          device.position.x + device.images.first.offsetPoint.x,
          device.position.y + device.images.first.offsetPoint.y);
    }
    context.restore();
  }

  void drawWireCreator() {
    if (!wireCreator.creatingWire) return;

    context
      ..save()
      ..scale(drawScale, drawScale)
      ..beginPath()
      ..lineWidth = Style.WIRE_WIDTH
      ..strokeStyle = Style.WIRE_INVALID
      ..fillStyle = Style.WIRE_INVALID;

    if (wireCreator.input != null) {
      context.moveTo(wireCreator.wireInput.x, wireCreator.wireInput.y);
    } else if (wireCreator.output != null) {
      context.moveTo(wireCreator.wireOutput.x, wireCreator.wireOutput.y);
    } else {
      context.restore();
      return;
    }

    for (final p in wireCreator.points) {
      context.lineTo(p.x, p.y);
    }
    context
      ..lineTo(uiPoint.x, uiPoint.y)
      ..stroke()
      ..closePath()
      ..restore();
  }

  void drawSelectedWires() {
    context
      ..save()
      ..scale(drawScale, drawScale)
      ..strokeStyle = Style.WIRE_SELECT_STYLE
      ..fillStyle = Style.WIRE_SELECT_STYLE
      ..lineWidth = 10;

    for (final wire in selectedWires) {
      drawWire(wire);
    }
    context.restore();
  }

  void drawWires() {
    context
      ..save()
      ..scale(drawScale, drawScale)
      ..lineWidth = Style.WIRE_WIDTH;

    for (final wire in wires) {
      context
        ..strokeStyle = wire.strokeStyle
        ..fillStyle = wire.strokeStyle;
      drawWire(wire);
    }
    context.restore();
  }

  void drawWire(Wire wire) {
    if (wire.wirePoints.isEmpty || wire.input == null || wire.output == null) {
      return;
    }

    context
      ..beginPath()
      ..moveTo(wire.input!.offset.x, wire.input!.offset.y);

    if (wire.wirePoints.length > 2) {
      for (final point in wire.wirePoints.getRange(1, wire.wirePoints.length - 1)) {
        context.lineTo(point.x, point.y);
      }
    }

    context
      ..lineTo(wire.output!.offset.x, wire.output!.offset.y)
      ..stroke()
      ..closePath();

    if (wire.wireKnot != null) {
      drawKnot(wire.wireKnot!.x, wire.wireKnot!.y);
    }
  }

  void drawKnot(num x, num y) {
    context
      ..beginPath()
      ..arc(x, y, 5, 0, PI2, false)
      ..fill()
      ..stroke()
      ..closePath();
  }

  void drawPinSelectors() {
    context
      ..save()
      ..scale(drawScale, drawScale);

    if (circuit.selectedOutput != null) {
      drawHighlightPin(circuit.selectedOutput!.offset.x,
          circuit.selectedOutput!.offset.y, 'VALID');
    }

    if (circuit.selectedInput != null) {
      drawHighlightPin(
          circuit.selectedInput!.offset.x,
          circuit.selectedInput!.offset.y,
          circuit.selectedInput!.connected ? 'CONNECTED' : 'VALID');
    }

    if (circuit.selectedWirePoint?.indexedPoint != null) {
      drawSelectedWirePoint(circuit.selectedWirePoint!);
    }

    if (wireCreator.creatingWire) {
      if (wireCreator.needInput) {
        drawConnectableInputPins();
      }
      if (wireCreator.needOutput) {
        drawConnectableOutputPins();
      }
    }

    context.restore();
  }

  void drawSelectedWirePoint(SelectedWirePoint wp) {
    final pt = wp.indexedPoint;
    if (pt == null) return;
    context
      ..save()
      ..strokeStyle = 'hsla(240, 100%, 50%, 1)'
      ..fillStyle = 'hsla(240, 100%, 50%, 0.25)'
      ..beginPath()
      ..lineWidth = 1
      ..arc(pt.x, pt.y, 8.1, 0, PI2, false)
      ..fill()
      ..stroke()
      ..closePath()
      ..restore();
  }

  void drawConnectableOutputPins() {
    for (final device in logicDevices) {
      for (final output in device.outputs) {
        if (output.connectable) {
          drawHighlightPin(output.offset.x, output.offset.y, 'CONNECTABLE');
        }
      }
    }
  }

  void drawConnectableInputPins() {
    for (final device in logicDevices) {
      for (final input in device.inputs) {
        if (!input.connected && input.connectable) {
          drawHighlightPin(input.offset.x, input.offset.y, 'CONNECTABLE');
        }
      }
    }
  }

  void drawHighlightPin(num x, num y, String highlightMode) {
    switch (highlightMode) {
      case 'VALID':
        context.strokeStyle = '#00AA00';
        context.fillStyle = 'rgba(0, 170, 0, 0.25)';
        break;
      case 'INVALID':
        context.strokeStyle = '#999999';
        context.fillStyle = 'rgba(153, 153, 153, 0.50)';
        break;
      case 'WIRECONNECT':
        context.strokeStyle = '#00AA00';
        context.fillStyle = 'rgba(0, 170, 0, 0.5)';
        break;
      case 'CONNECTED':
        context.strokeStyle = '#FFFF00';
        context.fillStyle = 'rgba(0, 170, 0, 0.5)';
        break;
      case 'WIREPOINT':
        context.strokeStyle = 'hsla(240, 100%, 50%, 1)';
        context.fillStyle = 'hsla(240, 100%, 50%, 0.25)';
        break;
      case 'CONNECTABLE':
        context.strokeStyle = 'hsla(270, 75%, 50%, 1)';
        context.fillStyle = 'hsla(270, 75%, 50%, 0.25)';
        break;
      default:
        context.strokeStyle = '#000000';
        context.fillStyle = 'rgba(255, 0, 0, 0.5)';
        break;
    }

    context
      ..beginPath()
      ..lineWidth = 1
      ..arc(x, y, 8.1, 0, PI2, false)
      ..fill()
      ..stroke()
      ..closePath();
  }
}

class Style {
  static const int BORDER_LINE_WIDTH = 1;
  static const String BORDER_LINE_COLOR = '#000000';
  static const int NEW_WIRE_WIDTH = 3;
  static const String NEW_WIRE_COLOR = '#990000';
  static const String NEW_WIRE_VALID = '#009900';
  static const String NEW_WIRE_INVALID = '#999999';
  static const String WIRE_HIGH = 'hsl(0, 100%, 50%)';
  static const String WIRE_LOW = 'hsl(0, 100%, 5%)';
  static const String WIRE_SELECT_STYLE = 'hsla(270, 100%, 60%, 0.75)';
  static const String WIRE_INVALID = '#999999';
  static const int WIRE_WIDTH = 4;
  static const int GRID_SIZE = 10;
  static const int GRID_POINT_SIZE = 1;
  static const String GRID_COLOR = '#999493';
  static const String GRID_BACKGROUND_COLOR = '#eeeeee';
  static const String DEVICE_LABEL_COLOR = '#000099';
  static const String ShadowColor = '#303030';
}
