
local render = {
	bg = nil,
	bullets_atlas = nil,
	characters_atlas = nil,
	bullets = nil,
	characters = nil,
	speech_buble = nil,
	main_font = nil,

	text = nil,
	text_x = 0, text_y = 0
}

function render.load(self)
	self.bg = love.graphics.newImage("bg.jpg")
	self.bullets_atlas = love.graphics.newImage("bullets.png")
	self.characters_atlas = love.graphics.newImage("characters.png")

	self.bullets = {}
	self.bullets[#self.bullets + 1] = love.graphics.newQuad(4 * 9 + 1, 1, 8, 8,		self.bullets_atlas:getWidth(), self.bullets_atlas:getHeight())
	self.bullets[#self.bullets + 1] = love.graphics.newQuad(0 * 9 + 1, 1, 8, 8,		self.bullets_atlas:getWidth(), self.bullets_atlas:getHeight())
	self.bullets[#self.bullets + 1] = love.graphics.newQuad(0 * 10 + 681, 1, 9, 15,	self.bullets_atlas:getWidth(), self.bullets_atlas:getHeight())
	self.bullets[#self.bullets + 1] = love.graphics.newQuad(4 * 10 + 681, 1, 9, 15,	self.bullets_atlas:getWidth(), self.bullets_atlas:getHeight())
	self.bullets[#self.bullets + 1] = love.graphics.newQuad(1 * 9 + 1, 1, 8, 8,		self.bullets_atlas:getWidth(), self.bullets_atlas:getHeight())

	self.characters = {}
	self.characters[#self.characters + 1] = love.graphics.newQuad(0 * 64, 4 * 64, 64, 64, self.characters_atlas:getWidth(), self.characters_atlas:getHeight())
	self.characters[#self.characters + 1] = love.graphics.newQuad(0 * 64, 3 * 64, 64, 64, self.characters_atlas:getWidth(), self.characters_atlas:getHeight())

	self.speech_buble = love.graphics.newImage("speech.png")
	self.speech_buble:setFilter("nearest", "nearest")

	self.main_font = love.graphics.newFont("coders_crux.ttf", 32);
	self.main_font:setFilter("nearest", "nearest")
end

function render.render(self, engine, player)
	local scrn_w = love.graphics.getWidth()
	local scrn_h = love.graphics.getHeight()

	love.graphics.setColor(64, 64, 64)
	love.graphics.draw(self.bg, 0, 0)

	love.graphics.setColor(255, 255, 255)
	-- render characters
	for k, chr in pairs(engine.characters) do
		local img_x, img_y, img_w, img_h = self.characters[chr.type]:getViewport()
		love.graphics.draw(
			self.characters_atlas,
			self.characters[chr.type],
			chr.x + scrn_w / 2,
			chr.y + scrn_h / 2 - 7,
			chr.a, 1, 1, img_w / 2, img_h / 2)
	end

	-- render bullets
	for k, bullet in pairs(engine.bullets) do
		local img_x, img_y, img_w, img_h = self.bullets[bullet.t]:getViewport()
		love.graphics.draw(
			self.bullets_atlas,
			self.bullets[bullet.t],
			bullet.x + scrn_w / 2,
			bullet.y + scrn_h / 2,
			bullet.a - math.pi / 2.0,
			1, 1, img_w / 2, img_h / 2)
	end

	-- render slaves
	for k, slave in pairs(engine.slaves) do
		local img_x, img_y, img_w, img_h = self.bullets[5]:getViewport()
		love.graphics.draw(
			self.bullets_atlas,
			self.bullets[5],
			slave.x + scrn_w / 2,
			slave.y + scrn_h / 2,
			0, 1, 1, img_w / 2, img_h / 2)
	end

	-- render player
	if player then
		local img_x, img_y, img_w, img_h = self.bullets[player.type]:getViewport()
		love.graphics.draw(
			self.bullets_atlas,
			self.bullets[player.type],
			player.x + scrn_w / 2,
			player.y + scrn_h / 2,
			0, 1, 1, img_w / 2, img_h / 2)
	end

	-- text stuff
	love.graphics.setFont(self.main_font);
	if self.text then
		local img_w = self.speech_buble:getWidth()
		local img_h = self.speech_buble:getHeight()
		love.graphics.draw(
			self.speech_buble,
			math.min(self.text_x + 25 + scrn_w / 2, scrn_w - img_w * 4 + 30),
			self.text_y + scrn_h / 2 - 12,
			0, 4, 4, 10, img_h - 9)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(
			self.text,
			math.min(self.text_x + 45 + scrn_w / 2, scrn_w - img_w * 4 + 45),
			self.text_y - img_h * 4 + 48 + scrn_h / 2
		)
		love.graphics.setColor(255, 255, 255)
	end

	love.graphics.print("bullets " .. #engine.bullets, 2, 2)
end

return render