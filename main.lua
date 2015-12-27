-- danmaku sandbox
-- bullet engine inspired by bullet pattern studio

local pprint = require("pprint")
pprint.setup {show_all = true, wrap_array = true}

local bullets = {}
local slaves = {}
local characters = {}
characters[#characters + 1] = {x = 0, y = 300, t = 1}
local player = {x = 0, y = 300, chr = 1, t = 1, vx = 3, vy = 3}

-- burst
-- stream
-- tristream (-20, 0, 20)
-- directed stream
-- sinwave stream
-- mirror stream
-- buble
-- spray (segment of burst)

-- modifiers :
-- gravity
-- rotate
-- friction

-- omni (spawns bullets from bullets) :
-- burst
-- streams
-- mirror streams
-- optional : destroy original

-- slave :
-- firing offset
-- directed


function emit_burst(x, y, t, num, v, vx, vy, start_radius)
	vx = vx or 0
	vy = vy or 0
	start_radius = start_radius or 0
	for i = 1, 360, 360 / num do
		local a = math.rad(i)
		local dx = math.cos(a)
		local dy = math.sin(a)
		bullets[#bullets + 1] = {
			x = x + dx * start_radius,
			y = y + dy * start_radius,
			vx = dx * v + vx,
			vy = dy * v + vy,
			t = t,
			a = a
		}
	end
end

function emit_stream(x, y, t, num, v, a)
	a = math.rad(a)
	local spd = v
	for i = 1, num do
		bullets[#bullets + 1] = {
			x = x,
			y = y,
			vx = math.cos(a) * spd,
			vy = math.sin(a) * spd,
			t = t,
			a = a
		}
		spd = spd - v / (num * 1.2)
	end
end

function love.load()
	print("hello")

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

	characters[#characters + 1] = {x = 0, y = 0, t = 2}

	slaves[#slaves + 1] = {chr = 2, d = 32, a = 45, va = 2, bullet = 1, fire_offset = 0, fire_rate = 10, fire_num = 60, fire_v = 15}
end

function love.update(dt)
	scrn_w = love.graphics.getWidth()
	scrn_h = love.graphics.getHeight()

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
		img_x, img_y, img_w, img_h = img_bullets[player.t]:getViewport()
		player.x = math.min(math.max(player.x, -scrn_w / 2 + img_w / 2), scrn_w / 2 - img_w / 2)
		player.y = math.min(math.max(player.y, -scrn_h / 2 + img_h / 2), scrn_h / 2 - img_h / 2)
		if player.chr then
			characters[player.chr].x = player.x
			characters[player.chr].y = player.y - 10
		end
	end

	for k, slave in pairs(slaves) do
		local a = math.rad(slave.a)
		slave.x = characters[slave.chr].x + math.cos(a) * slave.d
		slave.y = characters[slave.chr].y + math.sin(a) * slave.d
		slave.a = slave.a + slave.va

		if slave.fire_rate then
			if slave.c then
				slave.c = slave.c - 1
				if slave.c <= 0 then
					emit_stream(slave.x, slave.y, slave.bullet, slave.fire_num, slave.fire_v, slave.a + slave.fire_offset)
					slave.c = slave.fire_rate
				end
			else
				slave.c = slave.fire_rate
			end
		end
	end

	-- update bullets
	delete_later = {}
	for k, bullet in pairs(bullets) do
		bullet.x = bullet.x + bullet.vx
		bullet.y = bullet.y + bullet.vy
		if bullet.life ~= nil then
			bullet.life = bullet.life - 1
		end

		img_x, img_y, img_w, img_h = img_bullets[bullet.t]:getViewport()
		if (bullet.life ~= nil and bullet.life <= 0) or
			(bullet.x + img_w / 2 < -scrn_w / 2) or
			(bullet.x - img_w / 2 >  scrn_w / 2) or
			(bullet.y + img_h / 2 < -scrn_h / 2) or
			(bullet.y - img_h / 2 >  scrn_h / 2)
			then
			delete_later[k] = true
		end
	end

	if #delete_later > 0 then
		local new_bullets = {}
		for k, bullet in pairs(bullets) do
			if not delete_later[k] then
				new_bullets[#new_bullets + 1] = bullet
			end
		end
		bullets = new_bullets
	end
end

function love.draw()
	scrn_w = love.graphics.getWidth()
	scrn_h = love.graphics.getHeight()

	love.graphics.setColor(64, 64, 64)
	love.graphics.draw(img_bg, 0, 0)

	love.graphics.setColor(255, 255, 255)
	-- render characters
	for k, chr in pairs(characters) do
		img_x, img_y, img_w, img_h = img_characters[chr.t]:getViewport()
		love.graphics.draw(
			img_characters_atlas,
			img_characters[chr.t],
			chr.x + scrn_w / 2,
			chr.y + scrn_h / 2 - 7,
			chr.a, 1, 1, img_w / 2, img_h / 2)
	end

	-- render bullets
	for k, bullet in pairs(bullets) do
		img_x, img_y, img_w, img_h = img_bullets[bullet.t]:getViewport()
		love.graphics.draw(
			img_bullets_atlas,
			img_bullets[bullet.t],
			bullet.x + scrn_w / 2,
			bullet.y + scrn_h / 2,
			bullet.a - math.pi / 2.0,
			1, 1, img_w / 2, img_h / 2)
	end

	-- render slaves
	for k, slave in pairs(slaves) do
		img_x, img_y, img_w, img_h = img_bullets[5]:getViewport()
		love.graphics.draw(
			img_bullets_atlas,
			img_bullets[5],
			slave.x + scrn_w / 2,
			slave.y + scrn_h / 2,
			0, 1, 1, img_w / 2, img_h / 2)
	end

	-- render player
	if player then
		img_x, img_y, img_w, img_h = img_bullets[player.t]:getViewport()
		love.graphics.draw(
			img_bullets_atlas,
			img_bullets[player.t],
			player.x + scrn_w / 2,
			player.y + scrn_h / 2,
			0, 1, 1, img_w / 2, img_h / 2)
	end

	love.graphics.print("bullets " .. #bullets, 2, 2)
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
	if key == "space" then
		emit_burst(0, 0, 4, 150, 5)--, 10, 10, 150)
	end
end
