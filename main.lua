-- danmaku sandbox

pprint = require("pprint")
pprint.setup {show_all = true, wrap_array = true}

bullets = {}

function love.load()
	print("hello")

	img_bg = love.graphics.newImage("bg.jpg")
	img_bullets_atlas = love.graphics.newImage("bullets.png")

	img_bullets = {}
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(4 * 9 + 1, 1, 8, 8, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(0 * 9 + 1, 1, 8, 8, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())
	img_bullets[#img_bullets + 1] = love.graphics.newQuad(0 * 9 + 681, 1, 9, 15, img_bullets_atlas:getWidth(), img_bullets_atlas:getHeight())

	bullets[#bullets + 1] = {x = 0, y = 0, t = 1, vx = 1, vy = 0}
	bullets[#bullets + 1] = {x = 0, y = 50, t = 2, vx = 0, vy = 1}
	bullets[#bullets + 1] = {x = 50, y = 50, t = 3, vx = 0, vy = 1, a = math.pi * 45 / 180}

	pprint(bullets)
end

function love.update(dt)
	for k, bullet in pairs(bullets) do
		bullet.x = bullet.x + bullet.vx
		bullet.y = bullet.y + bullet.vy
	end
end

function love.draw()
	scrn_w = love.graphics.getWidth()
	scrn_h = love.graphics.getHeight()

	love.graphics.setColor(64, 64, 64)
	love.graphics.draw(img_bg, 0, 0)

	love.graphics.setColor(255, 255, 255)
	for k, bullet in pairs(bullets) do
		love.graphics.draw(
			img_bullets_atlas,
			img_bullets[bullet.t],
			bullet.x + scrn_w / 2,
			bullet.y + scrn_h / 2,
			bullet.a)
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
