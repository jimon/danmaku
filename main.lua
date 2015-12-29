-- danmaku sandbox

require("strict")
local pprint = require("pprint"); pprint.setup {show_all = true, wrap_array = true}

local engine = require("bulletengine")
local render = require("render")
local player = require("player")
local npc = require("npc")

function love.load(args)
	pprint(args)

	render:load()

	player:spawn(0, 300, engine)
	npc:spawn(0, 0, engine, player)
end

function love.update(dt)
	local scrn_w = love.graphics.getWidth()
	local scrn_h = love.graphics.getHeight()
	player:update(scrn_w, scrn_h, engine, render)
	npc:update(engine, player)
	engine:update(scrn_w, scrn_h)
end

function love.draw()
	render:render(engine, player)
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
	if key == "c" then
		engine:delete_slaves()
		engine:delete_bullets()
	end
end
