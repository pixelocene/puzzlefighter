--[[pod_format="raw",created="2024-05-23 17:41:23",modified="2024-05-25 20:32:47",revision=2272]]
--[[

 Board management

]]

Board = {}

function Board:new(side, width, height)

	side = side or 0
	board_width = width or BOARD_WIDTH
	board_height = height or BOARD_HEIGHT
	drop_start_position = ceil(board_width / 2)
	grid_width = GEM_SIZE * board_width
	grid_height = GEM_SIZE * board_height
	
	left_margin = (SCREEN_WIDTH - grid_width) / 2
	top_margin = (SCREEN_HEIGHT - grid_height) / 2

	if side == 1 then
		left_margin = BOARD_X_MARGIN
	elseif side == 2 then
		left_margin = SCREEN_WIDTH - BOARD_X_MARGIN - BOARD_WIDTH * GEM_SIZE
	end

	-- Build the board
	
	local grid = {}
	for i=1, board_height do
		local grid_line = {}
		for i=1, board_width do
			add(grid_line, 0)
		end
		add(grid, grid_line)
	end
	
	o = {
		drop_counter = 0, -- The number of drops (get a rainbow gem each 25 drops)
		drop = nil,
		next_drop = nil,
		drop_speed = 0, -- Modification of the BASE SPEED (increase while playing)
		grid = grid,
		state = BOARD_STATE_RUNNING,
		side = side,
		board_width = board_width,
		board_height = board_height,
		drop_start_position = drop_start_position,
		grid_width = grid_width,
		grid_height = grid_height,
		left_margin = left_margin,
		top_margin = top_margin,
		explosion_counter = 0,
		chain_counter = 0,
	}
	
	setmetatable(o, self)
	self.__index = self
	
	return o
end

function Board:draw(side)
	
	-- Draw the board and next drop background
	 
	--poke(0x550b, 0x3f)
	--palt()
	fillp(0xa5a5) -- 1x1px grid
	
	rectfill(
		left_margin,
		top_margin,
		left_margin + grid_width - 1, -- There is an extra pixel we want to remove
		top_margin + grid_height - 1,
		1
	)
		
	rectfill(
		left_margin + grid_width + 10,
		top_margin,
		left_margin + grid_width + 26 - 1,
		top_margin + 32 - 1,
		1
	)

	fillp() -- Reset the fill pattern (applied on sprites too)
	
	-- Draw the next drop

	self.next_drop.secondary:draw(left_margin + grid_width + 10, top_margin)
	self.next_drop.main:draw(left_margin + grid_width + 10, top_margin + 16)
		
	-- Draw the gems
	
	for i, lin in pairs(self.grid) do
		for j, col in pairs(lin) do
			local gem = Gem:new(RED_GEM)
			if self.grid[i][j] != 0 then
				self.grid[i][j]:draw(self:coords_to_pixels(j, i))
			end
		end
	end	
	
	-- Draw the drop
		
	self.drop.main:draw(self:coords_to_pixels(self.drop.x, self.drop.y))
	
	-- Draw the main gem outline
	
	if self.drop.main.type < 5 then
		spr(5, self:coords_to_pixels(self.drop.x, self.drop.y))
	elseif self.drop.main.type != RAINBOW_CRASHER then
		spr(13, self:coords_to_pixels(self.drop.x, self.drop.y))
	end

	-- Draw the secondary gem

	self.drop.secondary:draw(self:coords_to_pixels(self.drop:secondary_coords()))
	
end

--- Check if the given position is valid or not.
-- It checks if we are out of boundaries or if the grid is full at this position.
function Board:position_is_valid(x, y)

	if y > self.board_height then return false end
	if x > self.board_width then return false end
	if x < 1 then return false end

	return self.grid[y][x] == 0
	
end

--- Everything must no escape gravity.
function Board:apply_physics()
	if self.state == BOARD_STATE_RUNNING then
		self.chain_counter = 0
		self.drop:fall()
	end
	if self.state == BOARD_STATE_AUTO_FALL then
		self:auto_fall()
	end
	if self.state == BOARD_STATE_EXPLODING then
		self:auto_explode()
	end
end

--- Store the drop in the grid and require a new Drop
function Board:persist_drop()
	if self.drop.grace and self.drop.grace_delay <= 0 then
		local x, y = self.drop:secondary_coords()
		
		local main_x = flr(self.drop.x)
		local main_y = ceil(self.drop.y)
		local secondary_x = flr(x)
		local secondary_y = ceil(y)

		self:set_gem(main_x, main_y, self.drop.main)
		self:set_gem(secondary_x, secondary_y, self.drop.secondary)

		self.state = BOARD_STATE_AUTO_FALL
		self:new_drop()
	end
end

--- Get a new drop
-- The next_drop is moved to drop if existing.
-- If next_drop is nil, we create a new Drop instead.
-- It also ensure that next_drop has a new Drop inside.
function Board:new_drop()
	self.drop_counter += 1

	if self.next_drop == nil then self.next_drop = Drop:new(self) end	

	self.drop = self.next_drop
	self.next_drop = Drop:new(self)
end

--- Set the Gem to the given position.
function Board:set_gem(x, y, gem)
	self.grid[y][x] = gem
end

--- Convert a "grid position" to a "screen position" by applying margins.
function Board:coords_to_pixels(x, y)
	local x = self.left_margin + (x - 1) * GEM_SIZE
	local y = self.top_margin + (y - 1) * GEM_SIZE
	
	return x, y
end

--- Automatically make gems with empty spaces under falling
function Board:auto_fall()
	local falling = false
	
	for i=#self.grid-1,1,-1 do
		for j,gem in ipairs(self.grid[i]) do
			if self.grid[i][j] != 0 and self.grid[i+1][j] == 0 then
				self.grid[i+1][j] = gem
				self.grid[i][j] = 0
				falling = true
			end
		end
	end
	
	if not falling then self.state = BOARD_STATE_EXPLODING end 
end

function Board:auto_explode()
	-- Increment the chain counter to increase points
	self.explosion_counter = 0
	self.chain_counter += 1
	
	-- Look for all crashers and recursively look at neighboors to mark them for explosion
	for i,lin in ipairs(self.grid) do
		for j,gem in ipairs(self.grid[i]) do
			if gem != 0 then
				if gem.type >= 5 and gem.type <= 8 then
					-- It's a crasher
					self:mark_gems_for_explosion(j, i, gem)
				end
			end
		end
	end	
	
	-- Explode all the marked gems
	for i,lin in ipairs(self.grid) do
		for j,gem in ipairs(self.grid[i]) do
			if gem != 0 then
				if gem.exploding then
					self:set_gem(j, i, 0)
				end
			end
		end
	end	

	if self.explosion_counter == 0 then 
		self.state = BOARD_STATE_RUNNING 
	else 
		self.state = BOARD_STATE_AUTO_FALL 
	end

end

function Board:mark_gems_for_explosion(x, y, gem)
	
	-- Upper gem
	if y > 1 then
		local top = self.grid[y - 1][x]
		if top != 0 and not top.exploding and gem:color_match(top.type) then
			gem.exploding = true
			top.exploding = true
			self.explosion_counter += 1
			self:mark_gems_for_explosion(x, y - 1, top)
		end
	end
	
	-- Lower gem
	if y < #self.grid then
		local bottom = self.grid[y + 1][x]
		if bottom != 0 and not bottom.exploding and gem:color_match(bottom.type) then
			gem.exploding = true
			bottom.exploding = true
			self.explosion_counter += 1
			self:mark_gems_for_explosion(x, y + 1, bottom)
		end
	end
	
	-- Left gem
	if x > 1 then
		local left = self.grid[y][x - 1]
		if left != 0 and not left.exploding and gem:color_match(left.type) then
			gem.exploding = true
			left.exploding = true
			self.explosion_counter += 1
			self:mark_gems_for_explosion(x - 1, y, left)
		end
	end
	
	-- Right gem
	if x < #self.grid[1] then
		local right = self.grid[y][x + 1]
		if right != 0 and not right.exploding and gem:color_match(right.type) then
			gem.exploding = true
			right.exploding = true
			self.explosion_counter += 1
			self:mark_gems_for_explosion(x + 1, y, right)
		end
	end
	
end