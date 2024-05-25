--[[pod_format="raw",created="2024-05-24 08:18:32",modified="2024-05-25 20:32:35",revision=1261]]
--[[

	Configuration variables

]]

-- System informations

SCREEN_WIDTH = 480
SCREEN_HEIGHT = 270

DEBUG = true

-- Game modes

MODE_SOLO_ENDLESS = 1
MODE_P_VS_AI = 2
MODE_P_VS_P = 3

-- Buttons codes

BTN_P1_LEFT = 0
BTN_P1_RIGHT = 1
BTN_P1_UP = 2
BTN_P1_DOWN = 3
BTN_P1_LROT = 4
BTN_P1_RROT = 5

BTN_P2_LEFT = 9
BTN_P2_RIGHT = 10
BTN_P2_UP = 11
BTN_P2_DOWN = 12
BTN_P2_LROT = 13
BTN_P2_RROT = 14

-- Board rendering tweeks

GEM_SIZE = 16

BOARD_X_MARGIN = 20
BOARD_WIDTH = 6
BOARD_HEIGHT = 13

-- Gems

GREEN_GEM = 1
BLUE_GEM = 2
RED_GEM = 3
YELLOW_GEM = 4
GREEN_CRASHER = 5
BLUE_CRASHER = 6
RED_CRASHER = 7
YELLOW_CRASHER = 8
RAINBOW_CRASHER = 9

-- Game configuration

GRACE_DELAY = 3
BASE_SPEED = 0.01
FAST_SPEED = 0.4

-- Secondary drop position

TOP = 1
RIGHT = 2
BOTTOM = 3
LEFT = 4

-- Board side

LEFT_SIDE = 1
RIGHT_SIDE = 2

-- GAME_STATE internal states

BOARD_STATE_RUNNING = 1 -- Standard state, the player can control the drop
BOARD_STATE_AUTO_FALL = 2 -- Make gems with empty space under falling
BOARD_STATE_EXPLODING = 3  -- Frozen state, can't move until animations ended