part of xandorcode;

class SelectedWirePoint {
  Point<num>? point;
  Wire? wire;
  int pointIndex = -1;

  SelectedWirePoint([this.point, this.wire]) {
    if (wire != null && point != null) {
      pointIndex = wire!.wirePoints.indexOf(point!);
    }
  }

  Point<num>? get indexedPoint {
    if (wire == null ||
        pointIndex < 0 ||
        pointIndex >= wire!.wirePoints.length) {
      return null;
    }
    return wire!.wirePoints[pointIndex];
  }
}

class Wires {
  int _nextWireId = 1;

  Wires();

  void clearAll() {
    for (final w in wires) {
      w.input?.connectedWire = null;
    }
    wiresMap.clear();
    wires.clear();
    selectedWires.clear();
    selectedWirePoints.clear();
    wireGroups.clear();
  }

  int get count => wires.length;
  int get selectedCount => selectedWires.length;
  int get selectedWirePointsCount => selectedWirePoints.length;

  Wire? addWireFromMap(Map<String, dynamic> map, [String? id]) {
    final newWire = Wire();
    final wireId = id ?? 'w_${_nextWireId++}';

    final inputID = map['input'].toString();
    final outputID = map['output'].toString();
    final inPin = int.parse(map['inputPin'].toString());
    final outPin = int.parse(map['outputPin'].toString());

    final inDevice = logicDevicesMap[inputID];
    final outDevice = logicDevicesMap[outputID];
    if (inDevice == null || outDevice == null) {
      return null;
    }

    for (final i in inDevice.inputs) {
      if (i.id == inPin) {
        newWire.input = i;
        i.connectedWire = newWire;
        break;
      }
    }

    for (final o in outDevice.outputs) {
      if (o.id == outPin) {
        newWire.output = o;
        break;
      }
    }

    final rawPoints = map['points'];
    final List<dynamic> decodedPoints = rawPoints is String
        ? (jsonDecode(rawPoints) as List<dynamic>)
        : (rawPoints as List<dynamic>? ?? <dynamic>[]);

    newWire.updateWirePoints(decodedPoints);
    newWire.valid = newWire.input != null && newWire.output != null;
    newWire.id = wireId;

    wires.add(newWire);
    wiresMap[wireId] = newWire;
    addWireToGroup(newWire);
    return newWire;
  }

  void addWireToGroup(Wire wire) {
    for (final group in wireGroups) {
      if (wire.output == group.connectedOutput) {
        group.addWire(wire);
        return;
      }
    }
    wireGroups.add(WireGroup(wire));
  }

  void removeWireFromGroup(Wire wire) {
    WireGroup? removeGroup;
    for (final group in wireGroups) {
      if (group.hasWire(wire)) {
        group.removeWire(wire);
        if (group.wires.isEmpty) {
          removeGroup = group;
        }
        break;
      }
    }
    if (removeGroup != null) {
      wireGroups.remove(removeGroup);
    }
  }

  void removeWire(Wire w) {
    w.input?.connectedWire = null;
    wires.remove(w);
    if (w.id != null) {
      wiresMap.remove(w.id);
    }
    removeWireFromGroup(w);
  }

  void deleteDeviceWires(LogicDevice device) {
    final toDelete = wires
        .where((w) => w.input?.device == device || w.output?.device == device)
        .toList();
    for (final w in toDelete) {
      removeWire(w);
    }
  }

  void deleteSelectedWires() {
    for (final w in List<Wire>.from(selectedWires)) {
      removeWire(w);
    }
    selectedWires.clear();
  }

  bool get pointsSelected => selectedWirePoints.isNotEmpty;
  bool get wiresSelected => selectedWires.isNotEmpty;

  SelectedWirePoint? selectWirePoint(Point<num> p) {
    for (final wire in wires) {
      final wp = wire.getWirePoint(p);
      if (wp != null) {
        return SelectedWirePoint(wp, wire);
      }
    }
    return null;
  }

  int selectWirePoints(Point<num> p) {
    selectedWirePoints.clear();
    SelectedWirePoint? firstPoint;

    for (final wire in wires) {
      if (wire.wirePoints.length <= 2) continue;
      for (int idx = 1; idx < wire.wirePoints.length - 1; idx++) {
        final point = wire.wirePoints[idx];
        if (point.distanceTo(p) <= Wire.WIREPOINT_HIT_RADIUS) {
          if (firstPoint == null) {
            firstPoint = SelectedWirePoint(point, wire);
            selectedWirePoints.add(firstPoint);
            if (wire.wireKnot == point) wire.wireKnot = null;
          } else if (point == firstPoint.point) {
            selectedWirePoints.add(SelectedWirePoint(point, wire));
            if (wire.wireKnot == point) wire.wireKnot = null;
          }
        }
      }
    }
    return selectedWirePoints.length;
  }

  void deselectWirePoints() {
    for (final wp in selectedWirePoints) {
      wp.wire?.group?.findKnots();
    }
    selectedWirePoints.clear();
  }

  void moveSelectedPoints(Point<num> p) {
    for (final wp in selectedWirePoints) {
      final wpi = wp.pointIndex;
      if (wp.wire != null && wpi > 0 && wpi < wp.wire!.wirePoints.length - 1) {
        wp.wire!.wirePoints[wpi] = p;
      }
    }
  }

  Wire? wireHit(Point<num> p) {
    for (final wire in wires) {
      if (wire.contains(p) != null) return wire;
    }
    return null;
  }

  List<Wire> wiresHit(Point<num> p) {
    return wires.where((w) => w.contains(p) != null).toList();
  }

  int selectWire(Point<num> p) {
    selectedWires.clear();
    for (final wire in wires) {
      if (wire.contains(p) != null) {
        selectedWires.add(wire);
      }
    }
    return selectedWires.length;
  }

  Wire? firstSelectedWire() =>
      selectedWires.isEmpty ? null : selectedWires.first;
}
