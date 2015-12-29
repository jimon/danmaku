
local npc = {
	chr = nil,
	counter = 0,

	-- edit mode
	edit_file = nil,
	edit_slaves_text = nil
}

function npc.edit_mode(self, x, y, engine, player, file)
	self.chr = engine:spawn_character(x, y, 2, player.chr)
	self.edit_file = file
	print("edit mode will hot reload '" .. self.edit_file .. "' slaves file on the fly")
end

function npc.spawn(self, x, y, engine, player)
	self.chr = engine:spawn_character(x, y, 2, player.chr)

	local slaves, slaves_text = engine:parse_slaves("test1.json")
	engine:spawn_slaves(slaves, self.chr)
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

	engine.characters[self.chr].x = math.sin(self.counter * 0.01) * 100
	self.counter = self.counter + 1
end

return npc