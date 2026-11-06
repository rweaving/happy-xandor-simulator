part of xandorcode;

class SideBar {
  final Element? bar = document.querySelector('#side-bar');
  final int top = 15;
  final int width = 125;
  final List<ImageElement> buttons = <ImageElement>[];

  SideBar();

  void start() {
    window.onResize.listen((_) => resizeButtons());
    createSelectorBar();
    resizeButtons();
  }

  void addButton(String type) {
    final deviceType = deviceTypes.getDeviceType(type);
    if (deviceType != null && deviceType.iconImage != null) {
      final newButton = ImageElement(src: deviceType.iconImage!.image.src)
        ..style.cssText = 'position: absolute; cursor: pointer;'
        ..attributes['icon'] = deviceType.iconImage!.image.src ?? ''
        ..attributes['base'] = deviceType.baseImage?.image.src ?? ''
        ..attributes['type'] = type
        ..title = type.toUpperCase();

      newButton.onClick.listen(onButtonClick);
      newButton.onLoad.listen((_) => resizeButtons());

      buttons.add(newButton);
      bar?.children.add(newButton);
    }
  }

  void onButtonClick(MouseEvent e) {
    final target = e.currentTarget as ImageElement?;
    if (target == null) return;
    final type = target.attributes['type'];
    if (type == null) return;

    final p = Point<num>(target.offsetLeft - width, target.offsetTop);
    circuit.addLogicDevice(type, p + e.offset);
  }

  void resizeButtons() {
    num position = top;
    for (final btn in buttons) {
      final bw = btn.width ?? 68;
      final bh = btn.height ?? 43;
      if (bw == 0 || bh == 0) continue;
      final w = (width - bw) / 2;
      btn.style
        ..setProperty('left', '${w}px')
        ..setProperty('top', '${position}px');
      position += bh + 10;
    }
  }

  void createSelectorBar() {
    for (final type in <String>[
      'clock',
      'input',
      'switch',
      'output',
      'binary',
      'buffer',
      'not',
      'and',
      'nand',
      'or',
      'nor',
      'xor',
      'xnor',
      'tff',
      'jkff',
      'rsff',
      'fadder',
      'makey',
      'arrowpad',
      'soundtrigger_4bit',
    ]) {
      addButton(type);
    }
  }
}