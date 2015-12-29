
local render = {
	img_bg = nil,
	img_bullets_atlas = nil,
	img_characters_atlas = nil,
	img_bullets = nil,
	img_characters = nil
}

function render.load(self)
	self.img_bg = love.graphics.newImage("bg.jpg")
	self.img_bullets_atlas = love.graphics.newImage("bullets.png")
	self.img_characters_atlas = love.graphics.newImage("characters.png")

	self.img_bullets = {}
	self.img_bullets[#self.img_bullets + 1] = love.graphics.newQuad(4 * 9 + 1, 1, 8, 8,		self.img_bullets_atlas:getWidth(), self.img_bullets_atlas:getHeight())
	self.img_bullets[#self.img_bullets + 1] = love.graphics.newQuad(0 * 9 + 1, 1, 8, 8,		self.img_bullets_atlas:getWidth(), self.img_bullets_atlas:getHeight())
	self.img_bullets[#self.img_bullets + 1] = love.graphics.newQuad(0 * 10 + 681, 1, 9, 15,	self.img_bullets_atlas:getWidth(), self.img_bullets_atlas:getHeight())
	self.img_bullets[#self.img_bullets + 1] = love.graphics.newQuad(4 * 10 + 681, 1, 9, 15,	self.img_bullets_atlas:getWidth(), self.img_bullets_atlas:getHeight())
	self.img_bullets[#self.img_bullets + 1] = love.graphics.newQuad(1 * 9 + 1, 1, 8, 8,		self.img_bullets_atlas:getWidth(), self.img_bullets_atlas:getHeight())

	self.img_characters = {}
	self.img_characters[#self.img_characters + 1] = love.graphics.newQuad(0 * 64, 4 * 64, 64, 64, self.img_characters_atlas:getWidth(), self.img_characters_atlas:getHeight())
	self.img_characters[#self.img_characters + 1] = love.graphics.newQuad(0 * 64, 3 * 64, 64, 64, self.img_characters_atlas:getWidth(), self.img_characters_atlas:getHeight())
end

function render.render(self, engine, player)
	local scrn_w = love.graphics.getWidth()
	local scrn_h = love.graphics.getHeight()

	love.graphics.setColor(64, 64, 64)
	love.graphics.draw(self.img_bg, 0, 0)

	love.graphics.setColor(255, 255, 255)
	-- render characters
	for k, chr in pairs(engine.characters) do
		local img_x, img_y, img_w, img_h = self.img_characters[chr.type]:getViewport()
		love.graphics.draw(
			self.img_characters_atlas,
			self.img_characters[chr.type],
			chr.x + scrn_w / 2,
			chr.y + scrn_h / 2 - 7,
			chr.a, 1, 1, img_w / 2, img_h / 2)
	end

	-- render bullets
	for k, bullet in pairs(engine.bullets) do
		local img_x, img_y, img_w, img_h = self.img_bullets[bullet.t]:getViewport()
		love.graphics.draw(
			self.img_bullets_atlas,
			self.img_bullets[bullet.t],
			bullet.x + scrn_w / 2,
			bullet.y + scrn_h / 2,
			bullet.a - math.pi / 2.0,
			1, 1, img_w / 2, img_h / 2)
	end

	-- render slaves
	for k, slave in pairs(engine.slaves) do
		local img_x, img_y, img_w, img_h = self.img_bullets[5]:getViewport()
		love.graphics.draw(
			self.img_bullets_atlas,
			self.img_bullets[5],
			slave.x + scrn_w / 2,
			slave.y + scrn_h / 2,
			0, 1, 1, img_w / 2, img_h / 2)
	end

	-- render player
	if player then
		local img_x, img_y, img_w, img_h = self.img_bullets[player.type]:getViewport()
		love.graphics.draw(
			self.img_bullets_atlas,
			self.img_bullets[player.type],
			player.x + scrn_w / 2,
			player.y + scrn_h / 2,
			0, 1, 1, img_w / 2, img_h / 2)
	end

	love.graphics.print("bullets " .. #engine.bullets, 2, 2)
end

return render