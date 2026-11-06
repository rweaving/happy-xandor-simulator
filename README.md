# Happy XAndOr Logic Simulator

A unified, modernized digital logic circuit simulator combining **HappyLogicSimulator** and **XAndOrCode** into a single codebase.

## Overview

This repository provides two ready-to-use targets:

1. **Self-Contained Interactive HTML5 Canvas Web App** ([`dist/index.html`](dist/index.html) & [`web/index.html`](web/index.html)) — Runs immediately in any modern browser with zero build steps or external dependencies, bundling all 65 original 125dpi PNG sprites and 3 audio effects (`beep1000.wav`, `drip1.wav`, `poke-pikachuhappy.ogg`).
2. **Modernized Dart 3 Source Package** ([`pubspec.yaml`](pubspec.yaml), [`lib/`](lib/), [`web/index.dart`](web/index.dart)) — Migrated from legacy Dart 1.x to Dart 3 (`sdk: '>=3.0.0 <4.0.0'`) with null safety, modern syntax, and all simulation bugs fixed.

## Features

- **20 Logic Devices across 3 Palettes**:
  - **Logic Gates**: `BUFFER`, `NOT`, `AND`, `NAND`, `OR`, `NOR`, `XOR`, `XNOR`
  - **Flip-Flops & Subcircuits**: `RSFF` (RS Flip-Flop), `TFF` (Toggle Flip-Flop), `JKFF` (JK Flip-Flop), `FADDER` (1-Bit Full Adder)
  - **I/O, Clocks & Audio**: `INPUT`, `OUTPUT`, `SWITCH` (toggle), `CLOCK` (auto-pulsing), `BINARY` (4-bit counter `[8,4,2,1]`), `ARROW PAD`, `MAKEY` (`W/A/S/D/SPACE/CLICK`), `SOUND 4-BIT`
- **9 Built-in Preset Circuits**:
  - **Full Adder + 4-Bit Binary Counter** (`XAndOrCode` default)
  - **T-FlipFlop Ripple Counter + Sound** (`HappyLogicSimulator` `CounterTest`)
  - **1-Bit Full Adder (Gate-Level)**
  - **JK Flip-Flop (Gate-Level)**
  - **T Flip-Flop (Gate-Level)**
  - **RS Flip-Flop Latch (Gate-Level)**
  - **XOR from NAND Gates**
  - **Makey Makey + Arrow Pad Synth**
  - **Empty Canvas**
- **Custom IC Chip Creator & Sublogic Inspector**:
  - Package any circuit with `INPUT` and `OUTPUT` pins into a reusable custom IC chip.
  - Select any subcircuit (`RSFF`, `TFF`, `JKFF`, `FADDER`, or custom IC) and click **Inspect Sublogic** to view its internal gate-level schematic.
- **Interactive Controls**:
  - Play / Pause, single-step tick, simulation speed slider, zoom & pan, keyboard bindings (`Arrow keys`, `W/A/S/D`, `Space`), and JSON circuit Import/Export.

## Key Bug Fixes Over Original Projects

- Fixed constructor typos (`new Logic.pXNor()` -> `Logic.pXnor()`, `new Logic.pXNot()` -> `Logic.pNot()`) in [`lib/logic.dart`](lib/logic.dart) that caused runtime `NoSuchMethodError` crashes when instantiating `TFF` or `JKFF`.
- Fixed inverted null-check in `Logic.calc()` (`if (inGate2 == null) { inGate2.calc(); }` -> `inGate2?.calc()`) and unified the `OUTPUT_DELAY = 3` tick gate propagation model so ring oscillators and flip-flop feedback loops oscillate and latch deterministically without stack overflow.
- Implemented `checkSoundEvents()` in [`lib/logic_device.dart`](lib/logic_device.dart) to trigger audio playback on `SOUNDTRIGGER_4BIT` rising edges.
- Generated missing 125dpi device sprites (`jkff.png`, `rsff.png`, `fadder.png`) in [`web/images/125dpi/`](web/images/125dpi/) matching the exact dimensions (`95x88`) and pin layout of `tff.png`.

## Running the Project

### Option 1: Instant Browser Launch (Zero Dependencies)
Open [`dist/index.html`](dist/index.html) directly in any modern web browser, or serve it with any static file server:
```bash
python3 -m http.server 8080 --directory dist
```

### Option 2: Dart 3 Web Build
With the Dart 3 SDK installed:
```bash
dart pub get
dart run build_runner serve web
```

## License

Released under the [GNU General Public License v3.0](LICENSE.txt).
