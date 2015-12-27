-- danmaku sandbox
-- bullet engine inspired by bullet pattern studio v1.8.0

pprint = require("pprint")
pprint.setup {show_all = true, wrap_array = true}

bullets = {}

function emit_burst(x, y, t, num, v, vx, vy, start_radius)
	vx = vx or 0
	vy = vy or 0
	start_radius = start_radius or 0
	for i = 1, 360, 360 / num do
		local a = math.pi * i / 180
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
	a = math.pi * a / 180
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

function love.load()
	print("hello")

	img_bg = love.graphics.newImage("bg.jpg")
	img_bullets_atlas = love.graphics.newImage("bullets.png")

	img_bullets = {}
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(4 * 9 + 1, 1, 8, 8, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(0 * 9 + 1, 1, 8, 8, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(0 * 10 + 681, 1, 9, 15, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(4 * 10 + 681, 1, 9, 15, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())

	emit_burst(0, 0, 4, 150, 5)--, 10, 10, 150)
	emit_stream(0, 0, 2, 15, 5, 45)
end

function love.update(dt)
	scrn_w = love.graphics.getWidth()
	scrn_h = love.graphics.getHeight()

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
			bullets[k] = nil
		end

	end
end

function love.draw()
	scrn_w = love.graphics.getWidth()
	scrn_h = love.graphics.getHeight()

	love.graphics.setColor(64, 64, 64)
	love.graphics.draw(img_bg, 0, 0)

	love.graphics.setColor(255, 255, 255)
	for k, bullet in pairs(bullets) do
		img_x, img_y, img_w, img_h = img_bullets[bullet.t]:getViewport()

		love.graphics.draw(
			img_bullets_atlas,
			img_bullets[bullet.t],
			bullet.x + scrn_w / 2 - img_w / 2,
			bullet.y + scrn_h / 2 - img_h / 2,
			bullet.a - math.pi / 2.0)
	end

	love.graphics.print("bullets " .. #bullets, 0, 0)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if key == "space" then
		emit_burst(0, 0, 4, 150, 5)--, 10, 10, 150)
	end
end
