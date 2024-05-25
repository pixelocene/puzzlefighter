--[[pod_format="raw",created="2024-05-24 07:55:17",modified="2024-05-25 20:32:35",revision=1823]]
--[[
	
	(in) Game state

]]

include "src/gem.lua"
include "src/drop.lua"
include "src/board.lua"

game_state = {
	board1 = nil,
	board2 = nil,
	score1 = 0,
	score2 = 0,
	mode = MODE_SOLO_ENDLESS,
}

function game_state:init(options)

	local options = options or {
		mode = MODE_SOLO_ENDLESS,
		score1 = 0,
		score2 = 0,
	}
	
	self.mode = options.mode
	self.score1 = options.score1
	self.score2 = options.score2
	
	self.board1 = Board:new()
	self.board1:new_drop()

	-- Activate the second board when not playing SOLO mode
	if self.mode != MODE_SOLO_ENDLESS then
		self.board1.side = LEFT_SIDE
		self.board2 = Board:new(RIGHT_SIDE)
		self.board2:new_drop()
	end
	
end

function game_state:draw()

	cls(2)
	
	-- Display ugly background
	spr(192, 0, 0)

	if self.mode == MODE_SOLO_ENDLESS then
		self.board1:draw()
	else
		self.board1:draw(LEFT_SIDE)
		self.board2:draw(RIGHT_SIDE)
	end

end

function game_state:update()

	self:update_board(self.board1)
	self:update_board(self.board2)

end

function game_state:update_board(board)
	if board == nil then return end
	
	board:apply_physics()
	board.drop:run_grace_delay()
	board:persist_drop()
	
	if board.state == BOARD_STATE_RUNNING then
		if btn(BTN_P1_DOWN) then board.drop:go_faster() else board.drop:go_normal() end
		if btnp(BTN_P1_LEFT) then board.drop:move_left() end
		if btnp(BTN_P1_RIGHT) then board.drop:move_right() end
		if btnp(BTN_P1_LROT) then board.drop:rotate_counter_clockwise() end
		if btnp(BTN_P1_RROT) then board.drop:rotate_clockwise() end
	end
end

function game_state:draw_board(board)

end