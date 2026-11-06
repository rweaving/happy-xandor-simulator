part of xandorcode;

class DeviceOutput {
  static const int IO_HIT_RADIUS = 9;

  final LogicDevice device;
  final int id;

  Logic? subLogicGate;
  int? subLogicPin;
  OutputMap? outputMap;
  ImageMap? imageMap;

  bool mapped = false;
  bool value = false;
  bool previous_value = false;
  bool connectable = true;

  DeviceOutput(this.device, this.id) {
    final pin = device.deviceType.outputPoint[id];
    if (pin != null && pin.x < 0) {
      connectable = false;
    }
  }

  bool get updated => value != previous_value;

  OffsetImage? get mappedImage {
    if (imageMap != null) {
      return value ? imageMap!.highImage : imageMap!.lowImage;
    }
    return null;
  }

  Point<num> get offset =>
      (device.deviceType.outputPoint[id] ?? const Point<num>(0, 0)) +
      device.position;

  bool pinHit(Point<num> p) => p.distanceTo(offset) <= IO_HIT_RADIUS;

  bool get calculated => device.calculated;

  void calculate() => device.calculate();
}
