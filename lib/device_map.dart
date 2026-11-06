part of xandorcode;

/// Used to map internal inputs/outputs to displayable image overlays
class ImageMap {
  final int id;
  String? type;
  OffsetImage? highImage;
  OffsetImage? lowImage;

  ImageMap(
    this.id,
    String? mapLowImage,
    String? mapHighImage,
    int offsetX,
    int offsetY,
  ) {
    if (mapLowImage != null) {
      lowImage = OffsetImage(mapLowImage, offsetX, offsetY);
    }
    if (mapHighImage != null) {
      highImage = OffsetImage(mapHighImage, offsetX, offsetY);
    }
  }
}

class SubLogicGate {
  final String gateType;
  final int connection1;
  final int connection2;

  SubLogicGate(this.gateType, this.connection1, this.connection2);
}

/// Used to map external events (e.g. KeyPress or Mouse Click) to device outputs
class OutputMap {
  final int id;
  final String type;
  final dynamic value;

  OutputMap(this.id, this.type, this.value);
}

/// Used to map internal inputs to external events (e.g. sound effects)
class InputMap {
  final int id;
  final String type;
  final String value;

  InputMap(this.id, this.type, this.value);
}
