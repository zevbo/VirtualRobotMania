from engine import View, Move, Invalid, play
import random
from simplish_protocol import simplish_protocol
from simple_protocol import simple_protocol

def first_protocol(view: View) -> Move:
    total_empty = 0
    for r in range(0, 3):
        for c in range(0, 3):
            p = view.view[r][c]
            if isinstance(p, Invalid):
                continue 
            total_empty += p.value == 0 
    farm_size = int(total_empty / 2)
    if farm_size == 0 or view.this_piece().value == 1: 
        return Move(0, 0, 0)
    else: 
        return simplish_protocol(view)


        
if __name__ == "__main__":
    play(first_protocol, simplish_protocol, 5, 5)