import pyxel

class App:
    def __init__(self):
        pyxel.init(160, 120)
        pyxel.run(self.update, self.draw)

    def update(self):
        if pyxel.btnp(pyxel.KEY_Q):
            pyxel.quit()

    def draw(self):
        pyxel.cls(0)
        pyxel.text(55, 41, "Hello world!", 5)

def init_io():
    pass

def main():
    k = 0;

if __name__ == "__main__":
    main()
    App()
