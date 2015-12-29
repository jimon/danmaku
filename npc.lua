
local npc = {
	chr = nil,
	ai_mode = "disabled",
	counter = 0,
	offset = 0,
	fight_lvl = 0,

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
end

function npc.fast_spawn(self, x, y, engine, player)
	self.chr = engine:spawn_character(x, y, 2, player.chr)
	self.ai_mode = "next_fight"
end

function npc.is_fighting(self)
	return self.ai_mode ~= "disabled" and self.ai_mode ~= "intro" and self.ai_mode ~= "outro"
end

function npc.update(self, engine, player, dialog)
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
		local vy = 3
		local y = engine.characters[self.chr].y
		y = y + vy
		if y > -250 then
			y = -250
			dialog:add(self.chr, "yo there")
			dialog:add(player.chr, "'sup")
			dialog:add(self.chr, "how about", 40)
			dialog:add(self.chr, "how about\na fight?", 80)
			dialog:add(player.chr, "sounds", 30)
			dialog:add(player.chr, "sounds d", 10)
			dialog:add(player.chr, "sounds de", 9)
			dialog:add(player.chr, "sounds dea", 7)
			dialog:add(player.chr, "sounds dead", 6)
			dialog:add(player.chr, "sounds deadl", 5)
			dialog:add(player.chr, "sounds deadly", 4)
			dialog:add(player.chr, "sounds deadly!", 80)
			self.ai_mode = "next_fight"
		end
		engine.characters[self.chr].y = y
	elseif self.ai_mode == "outro" then
		local vy = 4
		local y = engine.characters[self.chr].y
		y = y - vy
		if y < -450 then
			y = -450
			self.ai_mode = "disabled"
		end
		engine.characters[self.chr].y = y
	elseif self.ai_mode == "next_fight" then
		self.ai_mode = "fight"
		if self.fight_lvl == 0 then
			local slaves, slaves_text = engine:parse_slaves("test2.json")
			engine:spawn_slaves(slaves, self.chr)
			self.counter = 360
		elseif self.fight_lvl == 1 then
			dialog:add(self.chr, "ok\nu won")
			dialog:add(player.chr, "yay")
			self.ai_mode = "outro"
		end
	elseif self.ai_mode == "fight" then
		self.counter = self.counter - 1
		if self.counter <= 0 then
			self.fight_lvl = self.fight_lvl + 1
			self.ai_mode = "next_fight"
			engine:delete_bullets()
			engine:delete_slaves()
		end
	elseif self.ai_mode == "stay" then
	elseif self.ai_mode == "sin_x" then
		--engine.characters[self.chr].x = math.sin(self.counter * 0.01) * 100 + self.offset
		--self.counter = self.counter + 1
	end
end

return npc