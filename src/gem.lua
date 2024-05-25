--[[pod_format="raw",created="2024-05-24 19:41:08",modified="2024-05-25 20:32:35",revision=1391]]
--[[

	GEMS

]]

Gem = {}

function Gem:new(type)
	o = {
		type = type,
		exploding = false,
		frozen = false, -- If frozen, the gem will not move even if empty spaces are under
	}
	setmetatable(o, self)
	self.__index = self
	
	return o
end

function Gem:draw(x, y)

	-- 1..4 are "standard" gems with no animations
	-- they are also stored in the sprite sheet at the same index than their value	
	if self.type < 5 then
		spr(self.type, x, y)
	end
	
	-- Others are crashers and need to be animated (in the futur).
	-- And the sprite index doesn't correspond to the value.
	if self.type == RAINBOW_CRASHER then
		spr(8, x, y)
	elseif self.type == GREEN_CRASHER then
		spr(9, x, y)
	elseif self.type == BLUE_CRASHER then
		spr(10, x, y)
	elseif self.type == RED_CRASHER then
		spr(11, x, y)
	elseif self.type == YELLOW_CRASHER then
		spr(12, x, y)
	end
	
end

function Gem:color_match(type)
	if (self.type == GREEN_GEM or self.type == GREEN_CRASHER) and (type == GREEN_GEM or type == GREEN_CRASHER) then return true end
	if (self.type == BLUE_GEM or self.type == BLUE_CRASHER) and (type == BLUE_GEM or type == BLUE_CRASHER) then return true end
	if (self.type == RED_GEM or self.type == RED_CRASHER) and (type == RED_GEM or type == RED_CRASHER) then return true end
	if (self.type == YELLOW_GEM or self.type == YELLOW_CRASHER) and (type == YELLOW_GEM or type == YELLOW_CRASHER) then return true end

	return false
end