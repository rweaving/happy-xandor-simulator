library xandorcode;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;

part 'logic_circuit.dart';
part 'logic.dart';
part 'device_input.dart';
part 'device_output.dart';
part 'logic_device.dart';
part 'circuit.dart';
part 'circuit_view.dart';
part 'circuit_draw.dart';
part 'circuit_wires.dart';
part 'device_types.dart';
part 'device_map.dart';
part 'wire.dart';
part 'wire_creator.dart';
part 'canvas_menu.dart';
part 'sidebar.dart';

num drawScale = 1.0;
String? userID;
bool userAnonymous = true;
String circuitName = 'default';
Point<num> uiPointUnscaled = const Point<num>(0, 0);
Point<num> uiPoint = const Point<num>(0, 0);

final List<LogicDevice> logicDevices = <LogicDevice>[];
final List<LogicDevice> deviceButtons = <LogicDevice>[];
final Map<String, LogicDevice> logicDevicesMap = <String, LogicDevice>{};
final List<LogicDevice> selectedDevices = <LogicDevice>[];
final Map<String, Wire> wiresMap = <String, Wire>{};
final List<Wire> wires = <Wire>[];
final List<Wire> selectedWires = <Wire>[];
final List<SelectedWirePoint> selectedWirePoints = <SelectedWirePoint>[];
final List<WireGroup> wireGroups = <WireGroup>[];

final CanvasElement canvas = document.querySelector('#canvas') as CanvasElement;
final CircuitView circuitView = CircuitView();
final CircuitDraw circuitDraw = CircuitDraw();
final Circuit circuit = Circuit();
final LogicDeviceTypes deviceTypes = LogicDeviceTypes();
final Wires circuitWires = Wires();
final WireCreator wireCreator = WireCreator();
final CanvasMenu contextMenu = CanvasMenu();
final SideBar sideBar = SideBar();
