
local player = {
	x = 0,
	y = 0,
	chr = nil,
	type = 1,
	vx = 3,
	vy = 3,
	fire = false
}

function player.spawn(self, x, y, engine)
	player.x = x
	player.y = y
	player.chr = engine:spawn_character(x, y, 1)
end

function player.update(self, scrn_w, scrn_h, npc, engine, render)
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
	self.x = self.x + self.vx * pdx
	self.y = self.y + self.vy * pdy
	local img_x, img_y, img_w, img_h = render.bullets[self.type]:getViewport()
	self.x = math.min(math.max(self.x, -scrn_w / 2 + img_w / 2), scrn_w / 2 - img_w / 2)
	self.y = math.min(math.max(self.y, -scrn_h / 2 + img_h / 2), scrn_h / 2 - img_h / 2)
	if self.chr then
		engine.characters[self.chr].x = self.x
		engine.characters[self.chr].y = self.y - 10
	end

	--if love.keyboard.isDown("space") then
	if npc:is_fighting() then
		if not self.fire then
			local slaves, slaves_text = engine:parse_slaves("player2.json")
			engine:spawn_slaves(slaves, self.chr)
			self.fire = true
		end
	else
		if self.fire then
			engine:delete_slaves(self.chr)
			self.fire = false
		end
	end
end

return player