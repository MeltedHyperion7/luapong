TILE_SIZE = 32
WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080
FONT_SIZE = 32

MAX_TILES_X = math.ceil(WINDOW_WIDTH / TILE_SIZE)
MAX_TILES_Y = math.ceil(WINDOW_HEIGHT / TILE_SIZE)

EMPTY = 0
PADDLE = 1
BALL = 2

PADDLE_SIZE = 5

P1_KEY_UP = "w"
P1_KEY_DOWN = "s"
P2_KEY_UP = "up"
P2_KEY_DOWN = "down"

-- directions
UP = -1
DOWN = 1
NONE = 0

-- time delta between two game states
BALL_TICK = 0.04
PADDLE_TICK = 0.05

-- TODO choose font