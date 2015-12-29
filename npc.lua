
local npc = {
	chr = nil
}

function npc.spawn(self, x, y, engine, player)
	self.chr = engine:spawn_character(x, y, 2, player.chr)

	local slaves, slaves_text = engine:parse_slaves("test2.json")
	engine:spawn_slaves(slaves, self.chr)
end

function npc.update(self, engine, player)
end

return npc