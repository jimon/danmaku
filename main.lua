function love.load()
	test = love.graphics.newImage("bullets.png")
	print("hello")
end

function love.draw()
	love.graphics.draw(test, 0, 0)
end