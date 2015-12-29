
local npc = {
	chr = nil,
	ai_mode = "disabled",
	counter = 0,
	offset = 0,

	-- edit mode
	edit_file = nil,
	edit_slaves_text = nil
}

function npc.edit_mode(self, x, y, engine, player, file)
	self.chr = engine:spawn_character(x, y, 2, player.chr)
	self.edit_file = file
	self.ai_mode = "disabled"
	print("edit mode will hot reload '" .. self.edit_file .. "' slaves file on the fly")
end

function npc.spawn(self, x, y, engine, player)
	self.chr = engine:spawn_character(x, y, 2, player.chr)
	self.ai_mode = "intro"

	--local slaves, slaves_text = engine:parse_slaves("test1.json")
	--engine:spawn_slaves(slaves, self.chr)
end

function npc.update(self, engine, player)
	if self.edit_file then
		local slaves, slaves_text = engine:parse_slaves(self.edit_file)
		if slaves and slaves_text and self.edit_slaves_text ~= slaves_text then
			engine:delete_bullets()
			engine:delete_slaves(self.chr)
			engine:spawn_slaves(slaves, self.chr)
			self.edit_slaves_text = slaves_text
		end
	end
	
	if self.ai_mode == "disabled" then
	elseif self.ai_mode == "intro" then
		local vy = 2
		local y = engine.characters[self.chr].y
		y = y + vy
		if y > -250 then
			y = -250
			self.ai_mode = "stay"
			local slaves, slaves_text = engine:parse_slaves("test1.json")
			engine:spawn_slaves(slaves, self.chr)
		end
		engine.characters[self.chr].y = y
	elseif self.ai_mode == "stay" then
	elseif self.ai_mode == "sin_x" then
		--engine.characters[self.chr].x = math.sin(self.counter * 0.01) * 100 + self.offset
		--self.counter = self.counter + 1
	end

end

return npc