part of xandorcode;

class LogicCircuit {
  LogicCircuit() {
    circuitName = Uri.base.queryParameters['circuit'] ?? 'default';
    print(
        'Starting Unified HappyLogic + XAndOrCode Simulator (circuit: $circuitName)');
    deviceTypes.loadDevices();
  }
}