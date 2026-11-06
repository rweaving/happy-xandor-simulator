part of xandorcode;

class DeviceInput {
  static const int IO_HIT_RADIUS = 9;

  final LogicDevice device;
  final int id;

  Logic? subLogicGate;
  ImageMap? imageMap;
  InputMap? inputMap;
  bool connectable = true;
  bool triggered = false;
  bool updated = false;
  bool previous_value = false;

  DeviceOutput? connectedOutput;
  Wire? connectedWire;

  DeviceInput(this.device, this.id) {
    final pin = device.deviceType.inputPoint[id];
    if (pin != null && pin.x < 0) {
      connectable = false;
    }
  }

  Point<num> get offset =>
      (device.deviceType.inputPoint[id] ?? const Point<num>(0, 0)) +
      device.position;

  OffsetImage? get mappedImage {
    if (imageMap != null) {
      return value ? imageMap!.highImage : imageMap!.lowImage;
    }
    return null;
  }

  bool pinHit(Point<num> p) => p.distanceTo(offset) <= IO_HIT_RADIUS;

  void checkUpdate() {
    if (connectedWire?.output != null) {
      updated = connectedWire!.output!.updated;
    } else if (connectedOutput != null) {
      updated = connectedOutput!.updated;
    } else {
      updated = false;
    }
  }

  bool get calculated => connectedWire?.output?.device.calculated ?? false;

  bool get connected => connectedWire?.output != null;

  bool get value {
    final out = connectedWire?.output;
    if (out == null) return false;
    if (!out.calculated) {
      out.calculate();
    }
    return out.value;
  }
}
