from engine import View, Move, Invalid, play
import random

def simple_protocol(view: View) -> Move:
    print(f"{view.view = }")
    while True: 
        r = random.randint(-1, 1)
        c = random.randint(-1, 1)
        if r == 0 and c == 0: 
            continue 
        if view.view[r + 1][c + 1] != Invalid.S: 
            return Move(view.this_piece().value, r, c)
        
if __name__ == "__main__":
    play(simple_protocol, simple_protocol)