part of xandorcode;

/// Represents an instance of a logic device placed on the circuit canvas
class LogicDevice {
  Point<num> position = const Point<num>(0, 0);

  bool selectable = true;
  bool calculated = false;
  bool updated = false;
  bool hasOutputMaps = false;
  bool hasInputMaps = false;

  bool _locked = false;
  bool get locked => _locked;
  set locked(bool value) => _locked = value;

  void Function(LogicDevice)? onDeviceMove;
  void Function(LogicDevice)? onDeviceMoveEnd;
  void Function(LogicDevice)? onDeviceStateChange;

  final List<DeviceInput> inputs = <DeviceInput>[];
  final List<DeviceOutput> outputs = <DeviceOutput>[];
  final List<Logic> subLogic = <Logic>[];
  final List<OffsetImage> images = <OffsetImage>[];

  String key;
  String? label;
  final LogicDeviceType deviceType;

  Timer? updateLagTimer;
  bool allowPositionUpdate = true;

  LogicDevice(this.deviceType, this.key) {
    for (final id in deviceType.inputPoint.keys) {
      inputs.add(DeviceInput(this, id));
    }

    for (final id in deviceType.outputPoint.keys) {
      outputs.add(DeviceOutput(this, id));
    }

    for (final outImage in deviceType.outputImages) {
      for (final output in outputs) {
        if (output.id == outImage.id) {
          output.imageMap = outImage;
        }
      }
    }

    for (final inImage in deviceType.inputImages) {
      for (final input in inputs) {
        if (input.id == inImage.id) {
          input.imageMap = inImage;
        }
      }
    }

    for (final outMap in deviceType.outputMaps) {
      for (final output in outputs) {
        if (output.id == outMap.id) {
          output.outputMap = outMap;
          hasOutputMaps = true;
        }
      }
    }

    for (final inMap in deviceType.inputMaps) {
      for (final input in inputs) {
        if (input.id == inMap.id) {
          input.inputMap = inMap;
          hasInputMaps = true;
        }
      }
    }

    loadSublogic();
    buildImageList();
  }

  void lagTimer() {
    allowPositionUpdate = true;
  }

  void buildImageList() {
    images.clear();

    if (deviceType.baseImage != null) {
      images.add(deviceType.baseImage!);
    }

    for (final input in inputs) {
      if (input.mappedImage != null) {
        images.add(input.mappedImage!);
      }
    }

    for (final output in outputs) {
      if (output.mappedImage != null) {
        images.add(output.mappedImage!);
      }
    }
  }

  /// Trigger mapped audio clips on rising input transitions (SOUNDTRIGGER_4BIT)
  void checkSoundEvents() {
    if (!hasInputMaps) return;
    for (final input in inputs) {
      final map = input.inputMap;
      if (map != null && map.type == 'sound') {
        if (input.value) {
          if (!input.triggered) {
            input.triggered = true;
            AudioElement(map.value).play();
          }
        } else {
          input.triggered = false;
        }
      }
    }
  }

  DeviceInput? InputPinHit(Point<num> p) {
    for (final input in inputs) {
      if (input.connectable && input.pinHit(p)) {
        return input;
      }
    }
    return null;
  }

  DeviceOutput? OutputPinHit(Point<num> p) {
    for (final output in outputs) {
      if (output.connectable && output.pinHit(p)) {
        return output;
      }
    }
    return null;
  }

  bool deviceHit(Point<num> p) => contains(p);

  void moveDevice(Point<num> p) {
    position = p;

    if (allowPositionUpdate) {
      onDeviceMove?.call(this);
      allowPositionUpdate = false;
      updateLagTimer = Timer(const Duration(milliseconds: 100), lagTimer);
    }
  }

  void stopMove() {
    onDeviceMoveEnd?.call(this);
  }

  void clicked([Point<num>? clickPoint]) {
    if (outputs.isEmpty) return;
    switch (deviceType.type) {
      case 'input':
      case 'switch':
        outputs[0].value = !outputs[0].value;
        updated = true;
        break;
      case 'arrowpad':
        if (clickPoint != null) {
          final relX = clickPoint.x - position.x;
          final relY = clickPoint.y - position.y;
          if (relX < 65 && relY > 55 && relY < 125) {
            outputs[0].value = !outputs[0].value;
          } else if (relX > 115 && relY > 55 && relY < 125) {
            outputs[1].value = !outputs[1].value;
          } else if (relY < 65 && relX > 55 && relX < 125) {
            outputs[2].value = !outputs[2].value;
          } else if (relY > 115 && relX > 55 && relX < 125) {
            outputs[3].value = !outputs[3].value;
          }
          updated = true;
        }
        break;
    }
    buildImageList();

    if (updated) {
      onDeviceStateChange?.call(this);
    }
  }

  void setClock(int? delay, int? duration) {
    if (delay == null || duration == null) return;
    final safeDelay = delay < 5 ? 5 : delay;
    final safeDuration = duration < 5 ? 5 : duration;

    for (final logic in subLogic) {
      logic.delay = safeDelay;
      logic.duration = safeDuration;
    }
  }

  void setState(bool value) {
    if (outputs.isEmpty) return;
    switch (deviceType.type) {
      case 'input':
      case 'switch':
        outputs[0].value = value;
        updated = true;
        break;
    }
    buildImageList();
  }

  void keyDown(int keyCode) {
    for (final output in outputs) {
      if (output.outputMap?.type == 'key' &&
          output.outputMap?.value == keyCode) {
        output.value = true;
      }
    }
    buildImageList();
  }

  void keyUp(int keyCode) {
    for (final output in outputs) {
      if (output.outputMap?.type == 'key' &&
          output.outputMap?.value == keyCode) {
        output.value = false;
      }
    }
    buildImageList();
  }

  bool contains(Point<num> p) {
    final img = deviceType.baseImage?.image;
    final w = (img != null && img.width! > 0) ? img.width! : 93;
    final h = (img != null && img.height! > 0) ? img.height! : 48;
    return p.x > position.x &&
        p.x < position.x + w &&
        p.y > position.y &&
        p.y < position.y + h;
  }

  void calculate() {
    if (calculated) return;

    calculated = true;
    updated = false;

    for (final input in inputs) {
      input.updated = false;
    }

    for (final output in outputs) {
      output.previous_value = output.value;
    }

    subCalc();
    checkSoundEvents();

    for (final input in inputs) {
      input.checkUpdate();
      if (input.updated) {
        updated = true;
        break;
      }
    }

    for (final output in outputs) {
      if (output.previous_value != output.value) {
        updated = true;
        break;
      }
    }

    if (updated && deviceType.updatable) {
      buildImageList();
    }
  }

  void subCalc() {
    if (subLogic.isEmpty) return;

    for (final gate in subLogic) {
      gate.calculated = false;
    }

    for (final input in inputs) {
      if (input.subLogicGate != null) {
        input.subLogicGate!.out = input.value;
      }
    }

    for (final gate in subLogic) {
      gate.calc();
    }

    for (final output in outputs) {
      if (output.subLogicGate != null) {
        output.value = output.subLogicGate!.out;
      }
    }
  }

  void setConnections() {
    for (final sl in subLogic) {
      if (sl.ig1 >= 0 && sl.ig1 < subLogic.length) {
        sl.inGate1 = subLogic[sl.ig1];
      }
      if (sl.ig2 >= 0 && sl.ig2 < subLogic.length) {
        sl.inGate2 = subLogic[sl.ig2];
      }
    }
  }

  Logic? addGate(String gateType, int inGate1, int inGate2) {
    Logic? newGate;

    switch (gateType.toLowerCase()) {
      case 'input':
      case 'in':
        newGate = pIn();
        break;
      case 'output':
      case 'out':
        newGate = pOut();
        break;
      case 'and':
        newGate = pAnd();
        break;
      case 'nand':
        newGate = pNand();
        break;
      case 'or':
        newGate = pOr();
        break;
      case 'nor':
        newGate = pNor();
        break;
      case 'xor':
        newGate = pXor();
        break;
      case 'xnor':
        newGate = pXnor();
        break;
      case 'not':
        newGate = pNot();
        break;
      case 'buffer':
        newGate = pBuffer();
        break;
      case 'switch':
        newGate = pSwitch();
        break;
      case 'clock':
        newGate = pClock();
        break;
    }

    if (newGate != null) {
      newGate.ig1 = inGate1;
      newGate.ig2 = inGate2;
      newGate.inGate1 = newGate;
      newGate.inGate2 = newGate;
      newGate.out = false;
      subLogic.add(newGate);
    }
    return newGate;
  }

  void loadSublogic() {
    subLogic.clear();

    for (final gate in deviceType.subLogicGates) {
      if (gate.gateType == 'input' || gate.gateType == 'in') {
        if (gate.connection2 >= 0 && gate.connection2 < inputs.length) {
          inputs[gate.connection2].subLogicGate = addGate('input', -1, -1);
        }
        continue;
      }
      if (gate.gateType == 'output' || gate.gateType == 'out') {
        if (gate.connection2 >= 0 && gate.connection2 < outputs.length) {
          outputs[gate.connection2].subLogicGate =
              addGate('output', gate.connection1, -1);
        }
        continue;
      }
      addGate(gate.gateType, gate.connection1, gate.connection2);
    }
    setConnections();
  }
}
