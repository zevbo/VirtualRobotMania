from engine import View, Move, Invalid, play
import random
from simple_protocol import simple_protocol

def simplish_protocol(view: View) -> Move:
    if random.random() < 0.5: 
        return Move(0, 0, 0)
    else: 
        return simple_protocol(view)
        
if __name__ == "__main__":
    play(simplish_protocol, simplish_protocol, 5, 5)