-- danmaku sandbox

require("strict")

local pprint = require("pprint")
pprint.setup {show_all = true, wrap_array = true}

local engine = require("bulletengine")

local img_bg = nil
local img_bullets_atlas = nil
local img_characters_atlas = nil
local img_bullets = nil
local img_characters = nil

--local player = nil
local player = {x = 0, y = 300, chr = 1, t = 1, vx = 3, vy = 3}

function love.load(args)
	print("hello")
	pprint(args)

	img_bg = love.graphics.newImage("bg.jpg")
	img_bullets_atlas = love.graphics.newImage("bullets.png")
	img_characters_atlas = love.graphics.newImage("characters.png")

	img_bullets = {}
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(4 * 9 + 1, 1, 8, 8, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(0 * 9 + 1, 1, 8, 8, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(0 * 10 + 681, 1, 9, 15, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(4 * 10 + 681, 1, 9, 15, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(1 * 9 + 1, 1, 8, 8, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())

	img_characters = {}
	img_characters[#img_characters + 1] = love.graphics.newQuad(0 * 64, 4 * 64, 64, 64, img_characters_atlas:getWidth(), img_characters_atlas:getHeight())
	img_characters[#img_characters + 1] = love.graphics.newQuad(0 * 64, 3 * 64, 64, 64, img_characters_atlas:getWidth(), img_characters_atlas:getHeight())

	engine:spawn_character()
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
		local img_x, img_y, img_w, img_h = img_bullets[player.t]:getViewport()
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
	local scrn_w = love.graphics.getWidth()
	local scrn_h = love.graphics.getHeight()

	love.graphics.setColor(64, 64, 64)
	love.graphics.draw(img_bg, 0, 0)

	love.graphics.setColor(255, 255, 255)
	-- render characters
	for k, chr in pairs(engine.characters) do
		local img_x, img_y, img_w, img_h = img_characters[chr.t]:getViewport()
		love.graphics.draw(
			img_characters_atlas,
			img_characters[chr.t],
			chr.x + scrn_w / 2,
			chr.y + scrn_h / 2 - 7,
			chr.a, 1, 1, img_w / 2, img_h / 2)
	end

	-- render bullets
	for k, bullet in pairs(engine.bullets) do
		local img_x, img_y, img_w, img_h = img_bullets[bullet.t]:getViewport()
		love.graphics.draw(
			img_bullets_atlas,
			img_bullets[bullet.t],
			bullet.x + scrn_w / 2,
			bullet.y + scrn_h / 2,
			bullet.a - math.pi / 2.0,
			1, 1, img_w / 2, img_h / 2)
	end

	-- render slaves
	for k, slave in pairs(engine.slaves) do
		local img_x, img_y, img_w, img_h = img_bullets[5]:getViewport()
		love.graphics.draw(
			img_bullets_atlas,
			img_bullets[5],
			slave.x + scrn_w / 2,
			slave.y + scrn_h / 2,
			0, 1, 1, img_w / 2, img_h / 2)
	end

	-- render player
	if player then
		local img_x, img_y, img_w, img_h = img_bullets[player.t]:getViewport()
		love.graphics.draw(
			img_bullets_atlas,
			img_bullets[player.t],
			player.x + scrn_w / 2,
			player.y + scrn_h / 2,
			0, 1, 1, img_w / 2, img_h / 2)
	end

	love.graphics.print("bullets " .. #engine.bullets, 2, 2)
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
end
