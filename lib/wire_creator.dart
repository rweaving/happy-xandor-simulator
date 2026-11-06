part of xandorcode;

class WireCreator {
  DeviceInput? input;
  DeviceOutput? output;

  Point<num> get wireInput => input!.offset;
  Point<num> get wireOutput => output!.offset;

  final List<Point<num>> points = <Point<num>>[];
  bool creatingWire = false;

  WireCreator();

  Map<String, dynamic> toMap([bool reversePoints = false]) {
    final pointsMapList = <Map<String, num>>[];
    final iterable = reversePoints ? points.reversed : points;
    for (final p in iterable) {
      pointsMapList.add({'x': p.x, 'y': p.y});
    }
    return <String, dynamic>{
      'input': input!.device.key,
      'inputPin': input!.id,
      'output': output!.device.key,
      'outputPin': output!.id,
      'points': jsonEncode(pointsMapList),
    };
  }

  void start() {
    creatingWire = true;
  }

  void abort() {
    creatingWire = false;
    input = null;
    output = null;
    points.clear();
  }

  void finish(bool reversePoints) {
    if (input != null && output != null) {
      circuitWires.addWireFromMap(toMap(reversePoints));
    }
    abort();
  }

  bool get needInput => input == null;
  bool get needOutput => output == null;

  Point<num> addPoint(Point<num> p) {
    final cp = Point<num>(p.x, p.y);
    points.add(cp);
    return cp;
  }

  void addWire(List<Point<num>>? newWire) {
    if (newWire == null) return;
    for (final wp in newWire) {
      points.add(Point<num>(wp.x, wp.y));
    }
  }

  bool createWire(Point<num> p) {
    input = null;
    output = null;

    input = circuit.tryInputSelect(p);
    if (input != null && !input!.connected) {
      start();
      return true;
    }
    input = null;

    output = circuit.tryOutputSelect(p);
    if (output != null) {
      start();
      return true;
    }
    return false;
  }

  bool addWirePoint(Point<num> p) {
    if (!creatingWire) return false;

    if (input == null) {
      final hitInput = circuit.tryInputSelect(p);
      if (hitInput != null && !hitInput.connected) {
        input = hitInput;
        finish(true);
        return false;
      }
    }

    if (output == null) {
      output = circuit.tryOutputSelect(p);
      if (output != null) {
        finish(false);
        return false;
      }

      final selectedPoint = circuitWires.selectWirePoint(p);
      if (selectedPoint != null &&
          selectedPoint.wire != null &&
          selectedPoint.point != null) {
        output = selectedPoint.wire!.output;
        addWire(selectedPoint.wire!.getWireEnd(selectedPoint.point!));
        finish(false);
        return false;
      }

      final w = circuitWires.wireHit(p);
      if (w != null) {
        final sp = w.getWireSnapPoint(p);
        if (sp != null) {
          output = w.output;
          addPoint(sp);

          List<Point<num>>? endWire;
          final wiresHit = circuitWires.wiresHit(sp);
          for (final wire in wiresHit) {
            final ws = wire.getSegment(sp);
            if (ws != null) {
              endWire = wire.insertPoint(ws, sp);
            }
          }
          addWire(endWire);
          finish(false);
          return false;
        }
      }
    }

    final device = circuit.tryDeviceSelect(p);
    if (device != null) return false;

    addPoint(p);
    return true;
  }
}
