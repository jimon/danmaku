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
			a = a,
			life = 500
		}
	end
end

function emit_spray(x, y, t, num, v, a, delta)
	for i = a - delta / 2, a + delta / 2, delta / num do
		local a = math.rad(i)
		local dx = math.cos(a)
		local dy = math.sin(a)
		bullets[#bullets + 1] = {
			x = x,
			y = y,
			vx = dx * v,
			vy = dy * v,
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

	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 2, fire = {t = "burst", bullet = 3, offset = 0, rate = 20, c = 10, num = 100, v = 3}}
	--slaves[#slaves + 1] = {chr = #characters, d = 64, a = 45, va = 2, fire = {t = "stream", bullet = 3, offset = 0, rate = 10, c = 10, num = 15, v = 15, directed = true}}
	--slaves[#slaves + 1] = {chr = #characters, d = 64, a = 45, va = 2, fire = {t = "stream", bullet = 3, offset = 0, rate = 10, c = 10, num = 15, v = 15}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 2, fire = {t = "tristream", bullet = 3, offset = 0, rate = 20, c = 10, num = 15, v = 15}}
	--slaves[#slaves + 1] = {chr = #characters, d = 0, a = 0, va = 0, fire = {t = "mirror", bullet = 2, offset = 0, rate = 40, c = 10, num = 15, v = 15}}
	--slaves[#slaves + 1] = {chr = #characters, d = 64, a = 45, va = 1, fire = {t = "buble", bullet = 3, offset = 0, rate = 20, c = 10, num = 15, v = 15, r = 50}}
	--slaves[#slaves + 1] = {chr = #characters, d = 64, a = 45, va = 0, fire = {t = "sinwave", bullet = 3, offset = 0, rate = 0, c = 0, num = 1, v = 15, sin_t = 0, sin_w = 10, sin_a = 30, directed = true}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, fire = {t = "spray", bullet = 1, offset = 0, rate = 20, c = 10, num = 100, v = 3, angle = 90, directed = true}}

	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, mod = {t = "friction", bullet = 3, v = 0.3}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, mod = {t = "turn", bullet = 2, v = 1}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, mod = {t = "gravity", bullet = 2, v = 0.1}}

	slaves[#slaves + 1] = {chr = #characters, d = 64, a = 180, va = 3, fire = {t = "stream", bullet = 3, offset = 0, rate = 5, c = 10, num = 1, v = 10}}
	slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, mod = {t = "friction", bullet = 3, v = 0.3}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 1, fire = {t = "burst", omni = 3, destroy = true, bullet = 1, offset = 0, rate = 120, c = 60, num = 100, v = 5}}
	slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, fire = {t = "stream", omni = 3, destroy = true, bullet = 1, offset = 0, rate = 60, c = 60, num = 100, v = 50, directed = true}}
end

function love.update(dt)
	local scrn_w = love.graphics.getWidth()
	local scrn_h = love.graphics.getHeight()
	local delete_later = {} -- bullets

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

		if slave.fire then
			if slave.fire.c then
				slave.fire.c = slave.fire.c - 1
				if slave.fire.c <= 0 then
					local spawn = {}
					if slave.fire.omni then
						for kb, bullet in pairs(bullets) do
							if bullet.t == slave.fire.omni then
								spawn[#spawn + 1] = {x = bullet.x, y = bullet.y}
								if slave.fire.destroy then
									delete_later[kb] = true
								end
							end
						end
					else
						spawn[#spawn + 1] = {x = slave.x, y = slave.y}
					end
					for ks, point in pairs(spawn) do
						local x = point.x
						local y = point.y
						local bullet = slave.fire.bullet
						local num = slave.fire.num
						local v = slave.fire.v
						local a = slave.a + slave.fire.offset
						if slave.fire.directed and player then
							a = math.deg(math.atan2(player.y - point.y, player.x - point.x))
						end

						if slave.fire.t == "burst" then
							emit_burst(x, y, bullet, num, v)
						elseif slave.fire.t == "stream" then
							emit_stream(x, y, bullet, num, v, a)
						elseif slave.fire.t == "tristream" then
							emit_stream(x, y, bullet, num, v, a + 20)
							emit_stream(x, y, bullet, num, v, a - 20)
							emit_stream(x, y, bullet, num, v, a)
						elseif slave.fire.t == "mirror" then
							emit_stream(x, y, bullet, num, v, a)
							emit_stream(x, y, bullet, num, v, a - 180)
						elseif slave.fire.t == "buble" then
							emit_burst(x, y, bullet, num, 0, math.cos(math.rad(a)) * v, math.sin(math.rad(a)) * v, slave.fire.r)
						elseif slave.fire.t == "sinwave" then
							slave.fire.sin_t = slave.fire.sin_t or 0
							emit_stream(x, y, bullet, num, v, a + math.sin(slave.fire.sin_t * math.rad(slave.fire.sin_w)) * slave.fire.sin_a)
							slave.fire.sin_t = slave.fire.sin_t + 1
						elseif slave.fire.t == "spray" then
							emit_spray(x, y, bullet, num, v, a, slave.fire.angle)
						end
					end
					slave.fire.c = slave.fire.rate
				end
			else
				slave.fire.c = slave.fire.rate
			end
		elseif slave.mod then
			if slave.mod.t == "friction" then
				for k, bullet in pairs(bullets) do
					local v = slave.mod.v
					if bullet.t == slave.mod.bullet then
						local bv = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
						if bv > 0 or v < 0 then
							local bv2 = bv - v
							if v > 0 and bv2 < 0 then bv2 = 0 end
							bullet.vx = bullet.vx * bv2 / bv
							bullet.vy = bullet.vy * bv2 / bv
						end
					end
				end
			elseif slave.mod.t == "turn" then
				for k, bullet in pairs(bullets) do
					if bullet.t == slave.mod.bullet then
						local bv = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
						local a = math.atan2(bullet.vy, bullet.vx) + math.rad(slave.mod.v)
						bullet.vx = math.cos(a) * bv
						bullet.vy = math.sin(a) * bv
					end
				end
			elseif slave.mod.t == "gravity" then
				for k, bullet in pairs(bullets) do
					if bullet.t == slave.mod.bullet then
						bullet.vy = bullet.vy + slave.mod.v
					end
				end
			end
		end
	end

	-- update bullets
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

	if next(delete_later) then
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
	local scrn_w = love.graphics.getWidth()
	local scrn_h = love.graphics.getHeight()

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
		--emit_burst(0, 0, 4, 150, 5)--, 10, 10, 150)
		
		pprint(bullets)
	end
end
