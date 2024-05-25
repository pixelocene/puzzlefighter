--[[pod_format="raw",created="2024-05-24 08:10:07",modified="2024-05-24 08:22:48",revision=71]]
main_menu_state = {}

function main_menu_state:init()

end

function main_menu_state:draw()
	cls(6)
end

function main_menu_state:update()
	if btnp(BTN_P1_LROT) or btnp(BTN_P1_RROT) then
		game_state:init()
		_state = game_state
	end
end