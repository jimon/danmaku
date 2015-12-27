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

	bullets[#bullets + 1] = {x = 1}
	bullets[#bullets + 1] = {x = 1}

	pprint(bullets)
end

function love.draw()
	love.graphics.draw(img_bg, 0, 0)
	love.graphics.draw(img_bullets_atlas, img_bullets[1], 400, 500)
	love.graphics.draw(img_bullets_atlas, img_bullets[2], 400, 505)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
