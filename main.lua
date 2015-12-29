-- danmaku sandbox

require("strict")
local pprint = require("pprint"); pprint.setup {show_all = true, wrap_array = true}
local json = require("json")

local engine = require("bulletengine")
local render = require("render")

--local player = nil
engine.characters[#engine.characters + 1] = {x = 0, y = 300, type = 1}
local player = {x = 0, y = 300, chr = 1, type = 1, vx = 3, vy = 3}

--[[

function engine.hotreload(self)
	local effect_text, effect_size = love.filesystem.read("test2.json")
	if effect_text ~= nil and effect_size > 0 then
		local slaves_new = JSON:decode(effect_text)
		if slaves_new ~= nil then
			local slaves_json_new = JSON:encode(slaves_new)
			if self.slaves_json ~= slaves_json_new then
				self.slaves = slaves_new
				self.slaves_json = slaves_json_new
				self.bullets = {}
			end
		end
	end
end]]--


function love.load(args)
	print("hello")
	pprint(args)

	render:load()
	engine:spawn_character(0, 0, 2)
	
end

function love.update(dt)
	local scrn_w = love.graphics.getWidth()
	local scrn_h = love.graphics.getHeight()

	-- update player input
	if player then
		local pdx = 0
		local pdy = 0
		if love.keyboard.isDown("left") then  pdx = -1 end
		if love.keyboard.isDown("right") then pdx =  1 end
		if love.keyboard.isDown("up") then    pdy = -1 end
		if love.keyboard.isDown("down") then  pdy =  1 end
		if pdx * pdx + pdy * pdy > 1 then
			pdx = pdx / math.sqrt(2)
			pdy = pdy / math.sqrt(2)
		end
		player.x = player.x + player.vx * pdx
		player.y = player.y + player.vy * pdy
		local img_x, img_y, img_w, img_h = render.img_bullets[player.type]:getViewport()
		player.x = math.min(math.max(player.x, -scrn_w / 2 + img_w / 2), scrn_w / 2 - img_w / 2)
		player.y = math.min(math.max(player.y, -scrn_h / 2 + img_h / 2), scrn_h / 2 - img_h / 2)
		if player.chr then
			engine.characters[player.chr].x = player.x
			engine.characters[player.chr].y = player.y - 10
		end
	end

	engine:update(scrn_w, scrn_h)
end

function love.draw()
	render:render(engine, player)
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
end
