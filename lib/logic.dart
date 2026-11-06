part of xandorcode;

/// Base logic class for devices. All composite devices are evaluated using
/// 2-input primitive logic gates with configurable propagation delay.
class Logic {
  static const int NC = -1;
  static const int OUTPUT_DELAY = 3;

  int duration = 50;
  int delay = 50;
  int ticks = 0;

  String name = 'logic';
  bool calculated = false;

  int ig1 = NC;
  int ig2 = NC;

  bool in1 = false;
  bool in2 = false;
  bool out = false;

  Logic? inGate1;
  Logic? inGate2;

  Logic();

  void calc() {
    calculated = true;
    inGate1?.calc();
    inGate2?.calc();
  }

  /// Apply propagation delay to rising output transitions to prevent zero-delay
  /// combinational feedback oscillation in flip-flops and ring oscillators.
  void setOut(bool outVal) {
    if (out == outVal) return;

    if (outVal) {
      ticks++;
      if (ticks >= OUTPUT_DELAY) {
        ticks = OUTPUT_DELAY;
        out = true;
      }
      return;
    }

    ticks = 0;
    out = false;
  }
}

/// External input
class pIn extends Logic {
  pIn() {
    name = 'input';
  }
  @override
  void calc() {
    calculated = true;
  }
}

/// External output
class pOut extends Logic {
  pOut() {
    name = 'output';
  }
  @override
  void calc() {
    calculated = true;
    setOut(inGate1?.out ?? false);
  }
}

/// PRIMARY AND (2 in - 1 out)
class pAnd extends Logic {
  pAnd() {
    name = 'and';
  }
  @override
  void calc() {
    calculated = true;
    setOut((inGate1?.out ?? false) && (inGate2?.out ?? false));
  }
}

/// PRIMARY NAND (2 in - 1 out)
class pNand extends Logic {
  pNand() {
    name = 'nand';
  }
  @override
  void calc() {
    calculated = true;
    setOut(!((inGate1?.out ?? false) && (inGate2?.out ?? false)));
  }
}

/// PRIMARY OR (2 in - 1 out)
class pOr extends Logic {
  pOr() {
    name = 'or';
  }
  @override
  void calc() {
    calculated = true;
    setOut((inGate1?.out ?? false) || (inGate2?.out ?? false));
  }
}

/// PRIMARY NOR (2 in - 1 out)
class pNor extends Logic {
  pNor() {
    name = 'nor';
  }
  @override
  void calc() {
    calculated = true;
    setOut(!((inGate1?.out ?? false) || (inGate2?.out ?? false)));
  }
}

/// PRIMARY XOR (2 in - 1 out)
class pXor extends Logic {
  pXor() {
    name = 'xor';
  }
  @override
  void calc() {
    calculated = true;
    setOut((inGate1?.out ?? false) != (inGate2?.out ?? false));
  }
}

/// PRIMARY XNOR (2 in - 1 out) — Fixed constructor name from pXNor to pXnor
class pXnor extends Logic {
  pXnor() {
    name = 'xnor';
  }
  @override
  void calc() {
    calculated = true;
    setOut(!((inGate1?.out ?? false) != (inGate2?.out ?? false)));
  }
}

/// PRIMARY NOT (1 in - 1 out) — Fixed constructor name from pXNot to pNot
class pNot extends Logic {
  pNot() {
    name = 'not';
  }
  @override
  void calc() {
    calculated = true;
    setOut(!(inGate1?.out ?? false));
  }
}

/// PRIMARY Buffer (1 in - 1 out)
class pBuffer extends Logic {
  pBuffer() {
    name = 'buffer';
  }
  @override
  void calc() {
    calculated = true;
    setOut(inGate1?.out ?? false);
  }
}

/// PRIMARY Switch (1 in - 1 out)
class pSwitch extends Logic {
  pSwitch() {
    name = 'switch';
  }
  @override
  void calc() {
    calculated = true;
    setOut(in1);
  }
}

/// PRIMARY CLOCK (0 in - 1 out)
class pClock extends Logic {
  pClock() {
    name = 'clock';
    duration = 50;
    delay = 50;
    ticks = 0;
  }
  @override
  void calc() {
    calculated = true;
    ticks++;

    if (out && ticks > duration) {
      out = false;
      ticks = 0;
      return;
    }

    if (!out && ticks > delay) {
      out = true;
      ticks = 0;
      return;
    }
  }
}
