part of xandorcode;

/// Contains an ImageElement with an offset point
class OffsetImage {
  final Point<num> offsetPoint;
  final ImageElement image;

  OffsetImage(String imageSrc, num offsetLeft, num offsetTop)
      : offsetPoint = Point<num>(offsetLeft, offsetTop),
        image = ImageElement(src: imageSrc);
}

class LogicDeviceType {
  bool updatable = false;
  bool hasOutputMaps = false;
  bool hasInputMaps = false;

  final List<ImageElement> images = <ImageElement>[];
  final List<SubLogicGate> subLogicGates = <SubLogicGate>[];
  final List<OutputMap> outputMaps = <OutputMap>[];
  final List<InputMap> inputMaps = <InputMap>[];
  final List<ImageMap> inputImages = <ImageMap>[];
  final List<ImageMap> outputImages = <ImageMap>[];
  final Map<int, Point<num>> inputPoint = <int, Point<num>>{};
  final Map<int, Point<num>> outputPoint = <int, Point<num>>{};

  OffsetImage? baseImage;
  OffsetImage? iconImage;
  OffsetImage? disabledImage;
  OffsetImage? selectedImage;

  final String type;

  LogicDeviceType(this.type);

  int get inputCount => inputPoint.length;
  int get outputCount => outputPoint.length;
  int get gateCount => subLogicGates.length;

  Point<num> get centerPoint {
    final w = baseImage?.image.width ?? 80;
    final h = baseImage?.image.height ?? 45;
    return Point<num>(-w / 2, -h / 2);
  }

  void addInput(int id, int x, int y) {
    inputPoint[id] = Point<num>(x, y);
  }

  void addOutput(int id, int x, int y) {
    outputPoint[id] = Point<num>(x, y);
  }

  void mapOutput(int mapId, String mapType, dynamic mapValue) {
    outputMaps.add(OutputMap(mapId, mapType.toLowerCase(), mapValue));
    hasOutputMaps = true;
  }

  void mapInput(int mapId, String mapType, String mapValue) {
    inputMaps.add(InputMap(mapId, mapType.toLowerCase(), mapValue));
    hasInputMaps = true;
  }

  void addInputImage(
      int inputID, String? lowImage, String? highImage, int offsetX, int offsetY) {
    inputImages.add(ImageMap(inputID, lowImage, highImage, offsetX, offsetY));
    updatable = true;
  }

  void addOutputImage(
      int outputID, String? lowImage, String? highImage, int offsetX, int offsetY) {
    outputImages.add(ImageMap(outputID, lowImage, highImage, offsetX, offsetY));
    updatable = true;
  }

  void addSubLogicGate(String gateType, int connection1, int connection2) {
    subLogicGates.add(SubLogicGate(gateType.toLowerCase(), connection1, connection2));
  }

  void setBaseImage(String imageSrc) {
    baseImage = OffsetImage(imageSrc, 0, 0);
  }

  void setIconImage(String imageSrc) {
    iconImage = OffsetImage(imageSrc, 0, 0);
  }

  void setDisabledImage(String imageSrc) {
    disabledImage = OffsetImage(imageSrc, 0, 0);
  }

  void setSelectedImage(String imageSrc) {
    selectedImage = OffsetImage(imageSrc, 0, 0);
  }
}

class LogicDeviceTypes {
  final List<LogicDeviceType> deviceTypes = <LogicDeviceType>[];

  LogicDeviceTypes();

  LogicDeviceType addNewType(String type) {
    final normalized = type.toLowerCase();
    final existing = getDeviceType(normalized);
    if (existing != null) return existing;
    final newType = LogicDeviceType(normalized);
    deviceTypes.add(newType);
    return newType;
  }

  LogicDeviceType? getDeviceType(String type) {
    final lType = type.toLowerCase();
    for (final deviceType in deviceTypes) {
      if (deviceType.type == lType) {
        return deviceType;
      }
    }
    return null;
  }

  /// Loads all built-in devices combining HappyLogicSimulator and XAndOrCode
  Future<void> loadDevices() async {
    deviceTypes.clear();

    // 1. INPUT (Toggle Button)
    final input = addNewType('input')
      ..setBaseImage('images/125dpi/input_low.png')
      ..setIconImage('images/125dpi/input_low.png')
      ..addOutputImage(
          0, 'images/125dpi/input_low.png', 'images/125dpi/input_high.png', 0, 0)
      ..addOutput(0, 68, 22);

    // 2. SWITCH (0/1 Toggle Switch)
    final sw = addNewType('switch')
      ..setBaseImage('images/01Switch_Low.png')
      ..setIconImage('images/01Switch_Low.png')
      ..addOutputImage(
          0, 'images/01Switch_Low.png', 'images/01Switch_High.png', 0, 0)
      ..addOutput(0, 21, 1);

    // 3. OUTPUT (LED Indicator)
    final output = addNewType('output')
      ..setBaseImage('images/125dpi/output_low.png')
      ..setIconImage('images/125dpi/output_low.png')
      ..addOutputImage(0, null, 'images/125dpi/output_high.png', 0, 0)
      ..addInput(0, 2, 22)
      ..addOutput(0, -1, -1)
      ..addSubLogicGate('input', -1, 0)
      ..addSubLogicGate('output', 0, 0);

    // 4. BINARY (0/1 Numeric Display)
    final binary = addNewType('binary')
      ..setBaseImage('images/01Disp_Low.png')
      ..setIconImage('images/01Disp_Low.png')
      ..addOutputImage(0, 'images/01Disp_Low.png', 'images/01Disp_High.png', 0, 0)
      ..addInput(0, 21, 9)
      ..addOutput(0, -1, -1)
      ..addSubLogicGate('input', -1, 0)
      ..addSubLogicGate('output', 0, 0);

    // 5. CLOCK (Pulse Generator)
    final clock = addNewType('clock')
      ..setBaseImage('images/125dpi/clock_low.png')
      ..setIconImage('images/125dpi/clock_low.png')
      ..addOutputImage(
          0, 'images/125dpi/clock_low.png', 'images/125dpi/clock_high.png', 0, 0)
      ..addOutput(0, 68, 22)
      ..addSubLogicGate('clock', -1, -1)
      ..addSubLogicGate('output', 0, 0);

    // 6. BUFFER
    final buffer = addNewType('buffer')
      ..setBaseImage('images/125dpi/buffer.png')
      ..setIconImage('images/125dpi/buffer_d.png')
      ..setSelectedImage('images/125dpi/buffer_s.png')
      ..addInput(0, 2, 24)
      ..addOutput(0, 90, 24)
      ..addSubLogicGate('input', -1, 0)
      ..addSubLogicGate('buffer', 0, 0)
      ..addSubLogicGate('output', 1, 0);

    // 7. NOT (Inverter)
    final notGate = addNewType('not')
      ..setBaseImage('images/125dpi/not.png')
      ..setIconImage('images/125dpi/not_d.png')
      ..setSelectedImage('images/125dpi/not_s.png')
      ..addInput(0, 2, 24)
      ..addOutput(0, 90, 24)
      ..addSubLogicGate('input', -1, 0)
      ..addSubLogicGate('not', 0, 0)
      ..addSubLogicGate('output', 1, 0);

    // 8-13. 2-Input Standard Logic Gates (AND, NAND, OR, NOR, XOR, XNOR)
    for (final g in ['and', 'nand', 'or', 'nor', 'xor', 'xnor']) {
      addNewType(g)
        ..setBaseImage('images/125dpi/$g.png')
        ..setIconImage('images/125dpi/${g}_d.png')
        ..setSelectedImage('images/125dpi/${g}_s.png')
        ..addInput(0, 2, 12)
        ..addInput(1, 2, 32)
        ..addOutput(0, 90, 22)
        ..addSubLogicGate('input', -1, 0)
        ..addSubLogicGate('input', -1, 1)
        ..addSubLogicGate(g, 0, 1)
        ..addSubLogicGate('output', 2, 0);
    }

    // 14. TFF (Master-Slave Toggle Flip-Flop)
    final tff = addNewType('tff')
      ..setBaseImage('images/125dpi/tff.png')
      ..setIconImage('images/125dpi/tff.png')
      ..addInput(0, 2, 44)
      ..addOutput(0, 93, 15)
      ..addOutput(1, 93, 72)
      ..addSubLogicGate('input', -1, 0) // 0: T
      ..addSubLogicGate('not', 0, 0) // 1: !T
      ..addSubLogicGate('output', 10, 0) // 2: Q
      ..addSubLogicGate('output', 11, 1) // 3: !Q
      ..addSubLogicGate('nand', 11, 0) // 4
      ..addSubLogicGate('nand', 0, 10) // 5
      ..addSubLogicGate('nand', 4, 7) // 6
      ..addSubLogicGate('nand', 6, 5) // 7
      ..addSubLogicGate('nand', 1, 6) // 8
      ..addSubLogicGate('nand', 7, 1) // 9
      ..addSubLogicGate('nand', 8, 11) // 10: Q gate
      ..addSubLogicGate('nand', 10, 9); // 11: !Q gate

    // 15. JKFF (Master-Slave Negative-Edge JK Flip-Flop)
    final jkff = addNewType('jkff')
      ..setBaseImage('images/125dpi/jkff.png')
      ..setIconImage('images/125dpi/jkff.png')
      ..addInput(0, 2, 15) // J
      ..addInput(1, 2, 44) // CLK
      ..addInput(2, 2, 72) // K
      ..addOutput(0, 93, 15) // Q
      ..addOutput(1, 93, 72) // !Q
      ..addSubLogicGate('input', -1, 0) // 0: J
      ..addSubLogicGate('input', -1, 1) // 1: CLK
      ..addSubLogicGate('input', -1, 2) // 2: K
      ..addSubLogicGate('not', 1, 1) // 3: !CLK
      ..addSubLogicGate('and', 0, 1) // 4: J & CLK
      ..addSubLogicGate('nand', 4, 13) // 5: !(J & CLK & !Q)
      ..addSubLogicGate('and', 2, 1) // 6: K & CLK
      ..addSubLogicGate('nand', 6, 12) // 7: !(K & CLK & Q)
      ..addSubLogicGate('nand', 5, 9) // 8: Master Q
      ..addSubLogicGate('nand', 7, 8) // 9: Master !Q
      ..addSubLogicGate('nand', 8, 3) // 10: Slave S_bar
      ..addSubLogicGate('nand', 9, 3) // 11: Slave R_bar
      ..addSubLogicGate('nand', 10, 13) // 12: Slave Q
      ..addSubLogicGate('nand', 11, 12) // 13: Slave !Q
      ..addSubLogicGate('output', 12, 0) // 14: Q
      ..addSubLogicGate('output', 13, 1); // 15: !Q

    // 16. RSFF (Clocked RS Flip-Flop from HappyLogicSimulator)
    final rsff = addNewType('rsff')
      ..setBaseImage('images/125dpi/rsff.png')
      ..setIconImage('images/125dpi/rsff.png')
      ..addInput(0, 2, 15) // S
      ..addInput(1, 2, 44) // CLK
      ..addInput(2, 2, 72) // R
      ..addOutput(0, 93, 15) // Q
      ..addOutput(1, 93, 72) // !Q
      ..addSubLogicGate('nand', 4, 5) // 0
      ..addSubLogicGate('nand', 6, 5) // 1
      ..addSubLogicGate('nand', 0, 3) // 2: Q
      ..addSubLogicGate('nand', 1, 2) // 3: !Q
      ..addSubLogicGate('input', -1, 0) // 4: S
      ..addSubLogicGate('input', -1, 1) // 5: CLK
      ..addSubLogicGate('input', -1, 2) // 6: R
      ..addSubLogicGate('output', 2, 0) // 7: Out Q
      ..addSubLogicGate('output', 3, 1); // 8: Out !Q

    // 17. FADDER (1-Bit Full Adder from XAndOrCode)
    final fadder = addNewType('fadder')
      ..setBaseImage('images/125dpi/fadder.png')
      ..setIconImage('images/125dpi/fadder.png')
      ..addInput(0, 2, 15) // A
      ..addInput(1, 2, 44) // B
      ..addInput(2, 2, 72) // Cin
      ..addOutput(0, 93, 15) // Sum
      ..addOutput(1, 93, 72) // Cout
      ..addSubLogicGate('input', -1, 0) // 0: A
      ..addSubLogicGate('input', -1, 1) // 1: B
      ..addSubLogicGate('input', -1, 2) // 2: Cin
      ..addSubLogicGate('xor', 0, 1) // 3: A ^ B
      ..addSubLogicGate('xor', 3, 2) // 4: Sum = (A ^ B) ^ Cin
      ..addSubLogicGate('and', 0, 1) // 5: A & B
      ..addSubLogicGate('and', 3, 2) // 6: (A ^ B) & Cin
      ..addSubLogicGate('or', 5, 6) // 7: Cout
      ..addSubLogicGate('output', 4, 0) // 8: Out Sum
      ..addSubLogicGate('output', 7, 1); // 9: Out Cout

    // 18. MAKEY (MaKey MaKey Board from HappyLogicSimulator)
    final makey = addNewType('makey')
      ..setBaseImage('images/makey/makey_base.png')
      ..setIconImage('images/makey/makey_icon.png')
      ..addOutput(0, 35, 78) // Left
      ..addOutput(1, 177, 78) // Right
      ..addOutput(2, 106, 7) // Up
      ..addOutput(3, 106, 149) // Down
      ..addOutput(4, 238, 37) // Space
      ..addOutput(5, 313, 37) // Click
      ..mapOutput(0, 'key', 37)
      ..mapOutput(1, 'key', 39)
      ..mapOutput(2, 'key', 38)
      ..mapOutput(3, 'key', 40)
      ..mapOutput(4, 'key', 32)
      ..mapOutput(5, 'key', 87)
      ..addOutputImage(0, null, 'images/makey/makey_left.png', 0, 0)
      ..addOutputImage(1, null, 'images/makey/makey_right.png', 0, 0)
      ..addOutputImage(2, null, 'images/makey/makey_up.png', 0, 0)
      ..addOutputImage(3, null, 'images/makey/makey_down.png', 0, 0)
      ..addOutputImage(4, null, 'images/makey/makey_space.png', 0, 0)
      ..addOutputImage(5, null, 'images/makey/makey_mouse.png', 0, 0);

    // 19. ARROWPAD (Arrow Pad from HappyLogicSimulator)
    final arrowpad = addNewType('arrowpad')
      ..setBaseImage('images/arrowpad/arrow_pad.png')
      ..setIconImage('images/arrowpad/arrow_pad.png')
      ..addOutput(0, 1, 91) // Left
      ..addOutput(1, 181, 91) // Right
      ..addOutput(2, 91, 1) // Up
      ..addOutput(3, 91, 181) // Down
      ..mapOutput(0, 'key', 37)
      ..mapOutput(1, 'key', 39)
      ..mapOutput(2, 'key', 38)
      ..mapOutput(3, 'key', 40)
      ..addOutputImage(0, 'images/arrowpad/arrow_left_low.png',
          'images/arrowpad/arrow_left_high.png', 18, 71)
      ..addOutputImage(1, 'images/arrowpad/arrow_right_low.png',
          'images/arrowpad/arrow_right_high.png', 109, 71)
      ..addOutputImage(2, 'images/arrowpad/arrow_up_low.png',
          'images/arrowpad/arrow_up_high.png', 72, 18)
      ..addOutputImage(3, 'images/arrowpad/arrow_down_low.png',
          'images/arrowpad/arrow_down_high.png', 73, 108);

    // 20. SOUNDTRIGGER_4BIT (4-Bit Sound Synthesizer from HappyLogicSimulator)
    final soundTrigger = addNewType('soundtrigger_4bit')
      ..setBaseImage('images/soundtrigger/soundtrigger_4bit.png')
      ..setIconImage('images/soundtrigger/soundtrigger_4bit.png')
      ..addInput(0, 1, 11)
      ..addInput(1, 1, 31)
      ..addInput(2, 1, 51)
      ..addInput(3, 1, 71)
      ..addOutput(0, -1, -1)
      ..addOutput(1, -1, -1)
      ..addOutput(2, -1, -1)
      ..addOutput(3, -1, -1)
      ..addOutputImage(0, null, 'images/soundtrigger/sound_high.png', 16, 3)
      ..addOutputImage(1, null, 'images/soundtrigger/sound_high.png', 16, 23)
      ..addOutputImage(2, null, 'images/soundtrigger/sound_high.png', 16, 43)
      ..addOutputImage(3, null, 'images/soundtrigger/sound_high.png', 16, 63)
      ..mapInput(0, 'sound', 'sounds/beep1000.wav')
      ..mapInput(1, 'sound', 'sounds/drip1.wav')
      ..mapInput(2, 'sound', 'sounds/drip1.wav')
      ..mapInput(3, 'sound', 'sounds/poke-pikachuhappy.ogg')
      ..addSubLogicGate('input', -1, 0)
      ..addSubLogicGate('input', -1, 1)
      ..addSubLogicGate('input', -1, 2)
      ..addSubLogicGate('input', -1, 3)
      ..addSubLogicGate('output', 0, 0)
      ..addSubLogicGate('output', 1, 1)
      ..addSubLogicGate('output', 2, 2)
      ..addSubLogicGate('output', 3, 3);

    // Prevent unused local variable warnings
    <LogicDeviceType>[
      input,
      sw,
      output,
      binary,
      clock,
      buffer,
      notGate,
      tff,
      jkff,
      rsff,
      fadder,
      makey,
      arrowpad,
      soundTrigger,
    ];

    circuit.afterDeviceTypesLoaded();
  }
}
