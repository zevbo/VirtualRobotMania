from collections.abc import Callable
from dataclasses import dataclass
from enum import Enum
from typing import TypeAlias

class Invalid(Enum):
    S = 0

class Color(Enum):
    WHITE = 0 
    BLACK = 1

@dataclass
class Piece:
    value: int
    def __str__(self) -> str:
        return f"P:{self.value}"
    
    def __repr__(self) -> str:
        return f"P:{self.value}"

@dataclass 
class Move: 
    value: int 
    row_move: int 
    col_move: int

ViewPiece: TypeAlias = Piece | Invalid

@dataclass 
class View: 
    view: list[list[ViewPiece]]

    def this_piece(self) -> Piece: 
        p = self.view[1][1]
        assert not isinstance(p, Invalid)
        return p

ProtocolT = Callable[[View], Move]

class Board: 
    board: list[list[Piece]]

    def __init__(self, board: list[list[Piece]]) -> None:
        self.board = board

    @property 
    def width(self) -> int: 
        return len(self.board[0])
    
    @property 
    def height(self) -> int: 
        return len(self.board)
    
    def is_valid(self, row: int, col: int) -> bool:
        return row >= 0 and col >= 0 and row < self.height and col < self.width
    
    def call_protocol(self, protocol: ProtocolT, row: int, col: int) -> Move:
        underlying_view: list[list[ViewPiece]] = [[Invalid.S for _ in range(3)] for _ in range(3)]
        move_piece = self.board[row][col]
        assert move_piece.value != 0 
        sign = int(move_piece.value / abs(move_piece.value))
        for r_i in range(-1, 2):
            for c_i in range(-1, 2):
                r = row + r_i 
                c = col + c_i
                if self.is_valid(r, c):
                    underlying_view[r_i + 1][c_i + 1] = Piece(self.board[r][c].value * sign)
        assert not isinstance(underlying_view[1][1], Invalid)
        view = View(underlying_view)
        return protocol(view)

    @staticmethod 
    def construct(width: int, height: int) -> "Board":
        underlying_board = [[Piece(0) for r in range(height)] for c in range(width)]
        underlying_board[0][0].value = 1
        underlying_board[height - 1][width - 1].value = -1
        return Board(underlying_board)


def get_moves(board: Board, white_protocol: ProtocolT, black_protocol: ProtocolT) -> list[list[Move | None]]:

    def get_move(r: int, c: int) -> Move | None: 
        piece = board.board[r][c]
        if piece.value == 0:
            return None
        protocol = white_protocol if piece.value > 0 else black_protocol
        move = board.call_protocol(protocol, r, c)
        sign = int(piece.value / abs(piece.value))
        assert move.value <= abs(piece.value), f"{move.value = }, {piece.value = }"
        move.value *= sign
        return move

    return [[get_move(r, c) for c in range(board.width)] for r in range(board.height)] 

def count_empty_adjacent(board: Board, r: int, c: int) -> int: 
    count = 0
    for r_adj in range(r - 1, r + 2):
        for c_adj in range(c - 1, c + 2):
            if (r_adj != r or c_adj != c) and board.is_valid(r_adj, c_adj):
                count += board.board[r_adj][c_adj].value == 0 
    return count

def farm(board: Board, moves: list[list[Move | None]]) -> None:
   for r in range(board.height): 
       for c in range(board.width):
           piece = board.board[r][c]
           move = moves[r][c]
           if move is not None and move.value == 0:
               sign = int(piece.value / abs(piece.value))
               piece.value += count_empty_adjacent(board, r, c) * sign

def split(board: Board, moves: list[list[Move | None]]) -> None: 
   for r in range(board.height): 
       for c in range(board.width):
           piece = board.board[r][c]
           move = moves[r][c]
           if move is not None and move.value != 0:
               assert -1 <= move.col_move and move.col_move <= 1
               assert -1 <= move.row_move and move.row_move <= 1
            #    assert move.value <= abs(piece.value)
               r_split = r + move.row_move 
               c_split = c + move.col_move 
               assert board.is_valid(r_split, c_split), f"{r = }, {c = }, {move.col_move = }, {move.row_move = }"
               board.board[r_split][c_split].value += move.value
               piece.value -= move.value

def print_board(board: Board) -> None: 
    print("BOARD: ")
    for r in range(board.height): 
        piece_strings: list[str] = []
        for c in range(board.width):
            piece = board.board[r][c]
            extras = int(abs(piece.value) < 10) + int(piece.value > 0)
            extra_space = " " * extras
            s = f"{extra_space}{piece.value}" if piece.value != 0 else "   "
            piece_strings.append(s)
        row_s = "|".join(piece_strings)
        print(row_s)
        if r != board.height - 1:
            print("-" * len(row_s))

def color_in(board: Board, color: Color) -> bool: 
    for r in range(board.height): 
        for c in range(board.width):
            piece = board.board[r][c]
            if (piece.value > 0 and color == Color.WHITE) or (piece.value < 0 and color == Color.BLACK):
                return True 
    return False


def step(board: Board, white_protocol: ProtocolT, black_protocol: ProtocolT) -> bool:
    moves = get_moves(board, white_protocol, black_protocol)
    farm(board, moves)
    split(board, moves)
    print_board(board)
    w_in = color_in(board, Color.WHITE)
    b_in = color_in(board, Color.BLACK)
    if w_in and not b_in:
        print("White won!")
    elif not w_in and b_in:
        print("Black won!")
    elif not w_in and not b_in:
        print("Its a tie!")
    return w_in and b_in

def wait_on_enter() -> None: 
    input()

def play(white_protocol: ProtocolT, black_protocol: ProtocolT, width: int = 4, height: int = 4):
    board = Board.construct(width, height)
    print_board(board)
    print("Welcome! Press enter to see the next move")
    wait_on_enter()
    while step(board, white_protocol, black_protocol):
        wait_on_enter()