--[[pod_format="raw",created="2024-05-25 14:23:26",modified="2024-05-25 18:38:51",revision=549]]
--[[

	Debug utilities

]]

_debug = {
	vars = {},
}

function _debug:push(var)
	if var == nil then var = "nil" end
	if var == true then var = "true" end
	if var == false then var = "false" end
	
	var = ""..var -- force string
	
	add(self.vars, var)
	
	if #self.vars > 10 then deli(self.vars, 1) end
end

function _debug:draw()
	local char_width = 4
	local char_height = 9
	
	if not DEBUG then return end
	
	for i, entry in ipairs(self.vars) do
		local x = SCREEN_WIDTH - (#entry + 1) * char_width
		local y = (i - 1) * char_height
		
		rectfill(x, y, x + (#entry + 1) * char_width, y + char_height, 0)
		print(entry, x, y, 7)
	end
end