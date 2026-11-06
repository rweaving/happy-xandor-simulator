part of xandorcode;

class Circuit {
  DeviceInput? selectedInput;
  DeviceOutput? selectedOutput;
  SelectedWirePoint? selectedWirePoint;
  SelectedWirePoint? movingWirePoint;

  bool run = false;
  bool devicesLoaded = false;
  bool circuitLoaded = false;
  bool devicesSelected = false;

  final Stopwatch stopwatch = Stopwatch();
  num calculationTime = 0;
  num tickCount = 0;
  Timer? simTimer;
  int _nextDeviceId = 100;

  Circuit();

  void afterDeviceTypesLoaded() {
    if (devicesLoaded) return;
    devicesLoaded = true;

    circuitView.start();
    loadCircuit(circuitName);

    simTimer =
        Timer.periodic(const Duration(milliseconds: 10), (Timer t) => tick(t));
  }

  void loadCircuit([String? name]) {
    if (name != null) circuitName = name;
    run = false;

    logicDevices.clear();
    logicDevicesMap.clear();
    selectedDevices.clear();
    circuitWires.clearAll();

    _loadPresetCircuit(circuitName);

    circuitLoaded = true;
    run = true;
  }

  void _loadPresetCircuit(String name) {
    switch (name) {
      case 'Not':
        newDeviceAt('input', '0', const Point<num>(176, 142));
        newDeviceAt('not', '1', const Point<num>(309, 141));
        newDeviceAt('output', '2', const Point<num>(460, 142));
        circuitWires.addWireFromMap({
          'input': '1',
          'inputPin': 0,
          'output': '0',
          'outputPin': 0,
          'points': <Map<String, num>>[]
        });
        circuitWires.addWireFromMap({
          'input': '2',
          'inputPin': 0,
          'output': '1',
          'outputPin': 0,
          'points': <Map<String, num>>[]
        });
        break;
      case 'And3':
      default:
        newDeviceAt('input', '0', const Point<num>(233, 85));
        newDeviceAt('input', '1', const Point<num>(234, 140));
        newDeviceAt('input', '2', const Point<num>(235, 194));
        newDeviceAt('and', '3', const Point<num>(340, 109));
        newDeviceAt('and', '4', const Point<num>(342, 180));
        newDeviceAt('output', '5', const Point<num>(539, 121));
        circuitWires.addWireFromMap({
          'input': '3',
          'inputPin': 0,
          'output': '0',
          'outputPin': 0,
          'points': <Map<String, num>>[]
        });
        circuitWires.addWireFromMap({
          'input': '3',
          'inputPin': 1,
          'output': '1',
          'outputPin': 0,
          'points': <Map<String, num>>[]
        });
        circuitWires.addWireFromMap({
          'input': '4',
          'inputPin': 1,
          'output': '2',
          'outputPin': 0,
          'points': <Map<String, num>>[]
        });
        circuitWires.addWireFromMap({
          'input': '4',
          'inputPin': 0,
          'output': '3',
          'outputPin': 0,
          'points': [
            {'x': 343, 'y': 170},
            {'x': 430, 'y': 168},
          ]
        });
        circuitWires.addWireFromMap({
          'input': '5',
          'inputPin': 0,
          'output': '4',
          'outputPin': 0,
          'points': [
            {'x': 464, 'y': 143},
            {'x': 465, 'y': 202},
          ]
        });
        break;
    }
  }

  void _syncAttachedWires(LogicDevice device) {
    for (final wire in wires) {
      for (final input in device.inputs) {
        if (wire.input == input) wire.adjustInputWirePoint();
      }
      for (final output in device.outputs) {
        if (wire.output == output) wire.adjustOutputWirePoint();
      }
    }
  }

  void addLogicDevice(String type, Point<num> position) {
    final id = 'dev_${_nextDeviceId++}';
    final dev = newDeviceAt(type, id, Point<num>(position.x + 100, position.y));
    if (dev != null) {
      circuitView.addingNewDevice(dev);
    }
  }

  LogicDevice? newDeviceAt(String type, String id, Point<num> position) {
    final deviceType = deviceTypes.getDeviceType(type);
    if (deviceType != null) {
      final newDevice = LogicDevice(deviceType, id);
      newDevice.onDeviceMove = _syncAttachedWires;
      logicDevices.add(newDevice);
      logicDevicesMap[id] = newDevice;
      newDevice.moveDevice(position);
      return newDevice;
    }
    return null;
  }

  void tick(Timer t) {
    if (!run) return;
    stopwatch
      ..reset()
      ..start();
    tickCount++;
    for (final device in logicDevices) {
      device.calculated = false;
    }
    for (final device in logicDevices) {
      device.calculate();
    }
    stopwatch.stop();
    calculationTime += stopwatch.elapsedMicroseconds;
  }

  void keyDown(int keyCode) {
    for (final device in logicDevices) {
      if (device.hasOutputMaps) {
        device.keyDown(keyCode);
      }
    }
  }

  void keyUp(int keyCode) {
    for (final device in logicDevices) {
      if (device.hasOutputMaps) {
        device.keyUp(keyCode);
      }
    }
  }

  LogicDevice? tryDeviceSelect(Point<num> p) {
    for (final device in logicDevices) {
      if (device.contains(p)) return device;
    }
    return null;
  }

  DeviceInput? tryInputSelect(Point<num> p) {
    for (final device in logicDevices) {
      final hit = device.InputPinHit(p);
      if (hit != null) return hit;
    }
    return null;
  }

  DeviceOutput? tryOutputSelect(Point<num> p) {
    for (final device in logicDevices) {
      final hit = device.OutputPinHit(p);
      if (hit != null) return hit;
    }
    return null;
  }

  bool checkConnection(Point<num> p) {
    selectedInput = null;
    selectedOutput = null;

    if (wireCreator.needInput) {
      final input = tryInputSelect(p);
      selectedInput = input;
      if (selectedInput != null && !selectedInput!.connected) {
        uiPoint = input!.offset;
        return true;
      }
    }

    if (wireCreator.needOutput) {
      final output = tryOutputSelect(p);
      selectedOutput = output;
      if (selectedOutput != null) {
        uiPoint = output!.offset;
        return true;
      }
    }
    return false;
  }

  bool checkValid(Point<num> p) {
    if (wireCreator.creatingWire) {
      return checkConnection(p);
    }
    selectedInput = tryInputSelect(p);
    if (selectedInput != null) return true;
    selectedOutput = tryOutputSelect(p);
    if (selectedOutput != null) return true;
    return false;
  }

  bool trySelectDevices(Point<num> p) {
    selectedDevices.clear();
    for (final d in logicDevices.reversed) {
      if (d.contains(p)) {
        selectedDevices.add(d);
        break;
      }
    }
    return selectedDevices.isNotEmpty;
  }

  void deleteSelectedDevices() {
    for (final d in List<LogicDevice>.from(selectedDevices)) {
      deleteDevice(d);
    }
    selectedDevices.clear();
    devicesSelected = false;
  }

  void deleteDevice(LogicDevice? d) {
    if (d == null) return;
    circuitWires.deleteDeviceWires(d);
    logicDevices.remove(d);
    logicDevicesMap.remove(d.key);
  }
}
