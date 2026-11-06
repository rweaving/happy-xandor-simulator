part of xandorcode;

/// Holds all wires connected to the same DeviceOutput and calculates wire-to-wire junction knots
class WireGroup {
  static const double TAU = math.pi * 2;
  static const String WIRE_HIGH = '#ff4444';
  static const String WIRE_LOW = '#101010';

  final List<Wire> wires = <Wire>[];
  final DeviceOutput? connectedOutput;
  Path2D? path;

  WireGroup(Wire wire) : connectedOutput = wire.output {
    wire.group = this;
    wires.add(wire);
  }

  int get wireCount => wires.length;

  void addWire(Wire newWire) {
    newWire.group = this;
    int? insertPosition;
    for (final w in wires) {
      if (newWire.wirePoints.length <= w.wirePoints.length) {
        insertPosition = wires.indexOf(w);
        break;
      }
    }
    if (insertPosition != null) {
      wires.insert(insertPosition, newWire);
    } else {
      wires.add(newWire);
    }
    findKnots();
  }

  bool hasWire(Wire wire) => wires.contains(wire);

  void removeWire(Wire wire) {
    wires.remove(wire);
    findKnots();
  }

  void findKnots() {
    final count = wireCount;
    if (count < 1) return;

    for (final w in wires) {
      w.wireKnot = null;
    }

    for (int t = 0; t < count - 1; t++) {
      final w1 = wires[t];
      for (final p1 in w1.wirePoints) {
        for (int x = t + 1; x < count; x++) {
          final w2 = wires[x];
          if (w2.wirePoints.length > 2) {
            for (final p2 in w2.wirePoints.sublist(1, w2.wirePoints.length - 1)) {
              if (p1 == p2) {
                w1.wireKnot = p2;
                break;
              }
            }
          }
          if (w1.wireKnot != null) break;
        }
        if (w1.wireKnot != null) break;
      }
    }
  }

  String get strokeStyle =>
      (connectedOutput?.value ?? false) ? WIRE_HIGH : WIRE_LOW;
}

class WireSegment {
  final Point<num> inputSide;
  final Point<num> outputSide;

  WireSegment(this.inputSide, this.outputSide);
}

class Wire {
  static const int WIRE_HIT_RADIUS = 2;
  static const int WIREPOINT_HIT_RADIUS = 10;
  static const int WIRE_WIDTH = 3;
  static const String WIRE_INVALID = '#999999';
  static const String WIRE_HIGH = '#ff4444';
  static const String WIRE_LOW = '#101010';

  String? id;
  DeviceInput? input;
  DeviceOutput? output;
  WireGroup? group;
  Point<num>? wireKnot;
  final List<Point<num>> wirePoints = <Point<num>>[];
  bool valid = false;

  Wire();

  Map<String, dynamic> toMap() {
    final pointsMapList = <Map<String, num>>[];
    if (wirePoints.length > 2) {
      for (final p in wirePoints.getRange(1, wirePoints.length - 1)) {
        pointsMapList.add({'x': p.x, 'y': p.y});
      }
    }
    return <String, dynamic>{
      'input': input?.device.key,
      'inputPin': input?.id,
      'output': output?.device.key,
      'outputPin': output?.id,
      'points': jsonEncode(pointsMapList),
      if (wireKnot != null)
        'knot': jsonEncode({'x': wireKnot!.x, 'y': wireKnot!.y}),
    };
  }

  Point<num>? getWireSnapPoint(Point<num> p) {
    final wp1 = contains(p);
    if (wp1 != null) {
      final i = wirePoints.indexOf(wp1);
      if (i >= 0 && i + 1 < wirePoints.length) {
        final wp2 = wirePoints[i + 1];
        final length = p.distanceTo(wp1);
        final angle = math.atan2(wp2.y - wp1.y, wp2.x - wp1.x);
        final xp = length * math.cos(angle) + wp1.x;
        final yp = length * math.sin(angle) + wp1.y;
        return Point<num>(xp.floor(), yp.floor());
      }
    }
    return null;
  }

  Point<num>? getWirePoint(Point<num> p) {
    if (wirePoints.length <= 2) return null;
    for (final point in wirePoints.getRange(1, wirePoints.length - 1)) {
      if (p.distanceTo(point) <= WIREPOINT_HIT_RADIUS) return point;
    }
    return null;
  }

  void updateWirePoints(List<dynamic> pointsList) {
    wirePoints.clear();
    if (input != null) {
      wirePoints.add(input!.offset);
    }
    for (final wpMap in pointsList) {
      if (wpMap is Map) {
        wirePoints.add(Point<num>(wpMap['x'] as num, wpMap['y'] as num));
      }
    }
    if (output != null) {
      wirePoints.add(output!.offset);
    }
    group?.findKnots();
  }

  void adjustInputWirePoint() {
    if (wirePoints.isNotEmpty && input != null) {
      wirePoints[0] = input!.offset;
    }
  }

  void adjustOutputWirePoint() {
    if (wirePoints.isNotEmpty && output != null) {
      wirePoints[wirePoints.length - 1] = output!.offset;
    }
  }

  WireSegment? getSegment(Point<num> p) {
    final wp1 = contains(p);
    if (wp1 == null) return null;
    final wpi1 = wirePoints.indexOf(wp1);
    if (wpi1 >= 0 && wpi1 + 1 < wirePoints.length) {
      final wp2 = wirePoints[wpi1 + 1];
      return WireSegment(wp2, wp1);
    }
    return null;
  }

  List<Point<num>>? insertPoint(WireSegment? ws, Point<num>? p) {
    if (ws == null || p == null) return null;
    final wi = wirePoints.indexOf(ws.inputSide);
    if (wi < 0) return null;
    final endWire = wirePoints.sublist(wi);
    if (endWire.isNotEmpty) endWire.removeLast();
    final wp = Point<num>(p.x.floor(), p.y.floor());
    wirePoints.insert(wi, wp);
    return endWire;
  }

  List<Point<num>> getWireEnd(Point<num> p) {
    final idx = wirePoints.indexOf(p);
    if (idx < 0 || idx >= wirePoints.length - 1) return <Point<num>>[];
    return wirePoints.sublist(idx, wirePoints.length - 1);
  }

  Point<num>? contains(Point<num> p) {
    if (wirePoints.length >= 2) {
      for (int t = 0; t < wirePoints.length - 1; t++) {
        final p1 = wirePoints[t];
        final p2 = wirePoints[t + 1];
        final distance = p.distanceTo(p1) + p.distanceTo(p2) - p2.distanceTo(p1);
        if (distance <= WIRE_HIT_RADIUS) {
          return wirePoints[t];
        }
      }
    }
    return null;
  }

  String get strokeStyle {
    if (!valid) return WIRE_INVALID;
    return (output?.value ?? false) ? WIRE_HIGH : WIRE_LOW;
  }
}
