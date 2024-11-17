import pyxel

class CPU:
    def __init__(self):
        self.opcode = 0
        self.memory = [0] * 4096
        self.V = [0] * 16
        self.I = 0
        self.pc = 0
        self.display_change = False
        self.keys_dict = {
            0x0: pyxel.KEY_0,
            0x1: pyxel.KEY_1,
            0x2: pyxel.KEY_2,
            0x3: pyxel.KEY_3,
            0x4: pyxel.KEY_4,
            0x5: pyxel.KEY_5,
            0x6: pyxel.KEY_6,
            0x7: pyxel.KEY_7,
            0x8: pyxel.KEY_8,
            0x9: pyxel.KEY_9,
            0xA: pyxel.KEY_A,
            0xB: pyxel.KEY_B,
            0xC: pyxel.KEY_C,
            0xD: pyxel.KEY_D,
            0xE: pyxel.KEY_E,
        }

    def update(self):
        self.display_change = False
        self.fetch()
        self.decode()
        self.execute()

    def fetch(self):
        self.opcode = self.memory[self.pc] << 8 | self.memory[self.pc + 1]

    def decode(self):
        self.arg_x = (self.opcode & 0x0F00) >> 8
        self.arg_y = (self.opcode & 0x00F0) >> 4
        self.arg_xnnn = self.opcode & 0xfff
        self.arg_xxnn = self.opcode & 0x00ff
        self.arg_xxxn = self.opcode & 0x000f


    def execute(self):
        pass

    def load_rom(self, rom):
        pass