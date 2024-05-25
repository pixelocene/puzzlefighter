--[[pod_format="raw",created="2024-05-24 19:25:58",modified="2024-05-25 20:32:35",revision=1534]]
--[[
	
	Drop management
	
	There is a main and a secondary gem for each drop.
	The player control the main gem movement and the secondary gem position:
	TOP, BOTTOM, LEFT, RIGHT.

]]

Drop = {}

function pick_random_gem_or_crasher()
	return rnd({
		GREEN_GEM, BLUE_GEM, RED_GEM, YELLOW_GEM,
		GREEN_CRASHER, BLUE_CRASHER, RED_CRASHER, YELLOW_CRASHER,
	})
end

function Drop:new(board)
	local o = {
		board = board,
		faster = false,
		grace = false, -- A short period of time where you can move even if blocked
		grace_delay = 0,
		main = Gem:new(pick_random_gem_or_crasher()),
		secondary = (board.drop_counter % 25 == 0) and Gem:new(RAINBOW_CRASHER) or Gem:new(pick_random_gem_or_crasher()),
		secondary_position = TOP,
		x = board.drop_start_position,
		y = 1,
	}
	
	setmetatable(o, self)
	self.__index = self
	
	return o
end

function Drop:fall()
	local speed = self.faster and FAST_SPEED or BASE_SPEED + self.board.drop_speed

	local main_new_x = self.x
	local main_new_y = ceil(self.y + speed)

	local x, y = self:secondary_coords()
	local secondary_new_x = x
	local secondary_new_y = ceil(y + speed)
	
	if self.board:position_is_valid(main_new_x, main_new_y) and self.board:position_is_valid(secondary_new_x, secondary_new_y) then
		self.grace = false -- If we are able to go down after a grace started, we must cancel it
		self.y += speed
	else
		self.y = ceil(self.y) -- Ensure the grace is visualy complete (no 1px remaining)
		if not self.grace then
			self.grace = true
			self.grace_delay = GRACE_DELAY
		end
	end
end

function Drop:secondary_coords()
	local x = self.x
	local y = self.y

	if self.secondary_position == TOP then
		y -= 1
	end
	
	if self.secondary_position == BOTTOM then
		y += 1
	end

	if self.secondary_position == LEFT then
		x += 1
 	end

	if self.secondary_position == RIGHT then
		x -= 1
	end

	return x, y
end

function Drop:move_left()
	local sec_x, sec_y = self:secondary_coords()
	
	if self.x > 1 and sec_x > 1 then
		self.x -= 1
	end
end

function Drop:move_right()
	local sec_x, sec_y = self:secondary_coords()
		
	if self.x < self.board.board_width and sec_x < self.board.board_width then
		self.x += 1
	end
end

function Drop:run_grace_delay()
	if not self.grace then return end
		
	self.grace_delay -= 0.1
end

function Drop:rotate_clockwise()
	local ori = self.secondary_position
	
	self.secondary_position += 1
	if self.secondary_position > 4 then self.secondary_position = 1 end
	
	-- @TODO Smart repositioning : slide on the opposite side if possible
	
	local x, y = self:secondary_coords()

	if not self.board:position_is_valid(flr(x), flr(y)) then
		self.secondary_position = ori
	end
end

function Drop:rotate_counter_clockwise()
	local ori = self.secondary_position
	
	self.secondary_position -= 1
	if self.secondary_position < 1 then self.secondary_position = 4 end
	
	-- @TODO Smart repositioning : slide on the opposite side if possible
	
	local x, y = self:secondary_coords()

	if not self.board:position_is_valid(flr(x), flr(y)) then
		self.secondary_position = ori
	end
end

function Drop:go_faster()
	self.faster = true
end

function Drop:go_normal()
	self.faster = false
end