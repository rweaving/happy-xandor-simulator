part of xandorcode;

class CanvasMenu {
  Point<num>? location;
  num height = 0;
  num width = 100;

  final num itemHeight = 25;
  final num itemWidth = 100;

  bool get visible => location != null;
  final List<String> items = <String>[];

  String? selectedItem;
  LogicDevice? device;

  CanvasMenu();

  void hide() => location = null;

  bool contains(Point<num> p) {
    final loc = location;
    if (loc == null) return false;
    return p.x >= loc.x &&
        p.x <= loc.x + width &&
        p.y >= loc.y &&
        p.y <= loc.y + height;
  }

  String? selectItem(Point<num> p) {
    final loc = location;
    if (loc == null) return null;
    final yPos = p.y - loc.y;
    final index = (yPos / itemHeight).floor();

    if (index >= 0 && index < items.length) {
      selectedItem = items[index];
    }
    return selectedItem;
  }

  void buildMenu(LogicDevice? d) {
    if (d == null) return;
    device = d;
    items
      ..clear()
      ..add(d.locked ? 'Unlock' : 'Lock')
      ..add('Edit Label')
      ..add('Delete');

    width = itemWidth;
    height = itemHeight * items.length;
  }

  int menuClick(Point<num> p) {
    if (device == null) return 0;

    switch (selectedItem) {
      case 'Lock':
        device!.locked = true;
        return 1;
      case 'Unlock':
        device!.locked = false;
        return 1;
      case 'Edit Label':
        return 2;
      case 'Delete':
        return 3;
      default:
        return 0;
    }
  }
}
