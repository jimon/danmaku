-- danmaku sandbox

require("strict")
--local pprint = require("pprint"); pprint.setup {show_all = true, wrap_array = true}

local engine = require("bulletengine")
local render = require("render")
local player = require("player")
local npc = require("npc")
local dialog = require("dialog")

function love.load(args)
	render:load()
	player:spawn(0, 300, engine)

	if args[2] == "--edit" then
		npc:edit_mode(0, -200, engine, player, args[3])
	else
		npc:spawn(0, -500, engine, player)
		--npc:fast_spawn(0, -250, engine, player)
	end
end

function love.update(dt)
	local scrn_w = love.graphics.getWidth()
	local scrn_h = love.graphics.getHeight()
	dialog:update(engine, render)
	if not dialog:is_active() then
		player:update(scrn_w, scrn_h, npc, engine, render)
		npc:update(engine, player, dialog)
		engine:update(scrn_w, scrn_h)
	end
end

function love.draw()
	render:render(engine, player, npc)
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
	--[[if key == "q" then
		engine:delete_slaves()
		engine:delete_bullets()
	end]]--
end
