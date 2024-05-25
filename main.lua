--[[pod_format="raw",created="2024-05-23 17:40:17",modified="2024-05-25 20:32:35",revision=1935]]
--[[

	Pico Puzzle Fighter
	
	by P-Rex for Pixelocene

]]

include "src/debug.lua"
include "src/data_tree.lua"
include "src/conf.lua"
include "src/state/main_menu.lua"
include "src/state/game.lua"

_state = nil

function _init()
	game_state:init()
	_state = game_state
end

function _draw()
	_state:draw()
	_debug:draw()
end

function _update()
	_state:update()
end