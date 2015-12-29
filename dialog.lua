
local dialog = {
	phrases = {
		--[[
		chr = character
		text = text
		duration = in frames
		]]--
	},
	counter = 0,
	first = false
}

function dialog.update(self, engine, render)
	if not self:is_active() then return end

	if self.counter > 0 then
		self.counter = self.counter - 1
	else
		if self.first then
			self.first = false
		else
			table.remove(self.phrases, 1)
		end
		if next(self.phrases) then
			local phrase = self.phrases[1]
			self.counter = phrase.duration
			render.text = phrase.text
			render.text_x = engine.characters[phrase.chr].x
			render.text_y = engine.characters[phrase.chr].y
		else
			render.text = nil
		end
	end
end

function dialog.add(self, chr, phrase, duration)
	if #self.phrases == 0 then self.first = true end
	self.phrases[#self.phrases + 1] = {chr = chr, text = phrase, duration = duration or 60}
	self.counter = 0
end

function dialog.is_active(self)
	return next(self.phrases)
end

return dialog