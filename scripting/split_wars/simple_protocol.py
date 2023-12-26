from engine import View, Move, Invalid, play
import random

def simple_protocol(view: View) -> Move:
    while True: 
        r = random.randint(-1, 1)
        c = random.randint(-1, 1)
        if r == 0 and c == 0: 
            continue 
        if view.view[r + 1][c + 1] != Invalid.S: 
            return Move(int(view.this_piece().value / 2) + 1, r, c)
        
if __name__ == "__main__":
    play(simple_protocol, simple_protocol)