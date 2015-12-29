-- simple danmaku bullet engine
-- inspired by bullet pattern studio

-- burst
-- stream
-- tristream (-20, 0, 20)
-- sinwave stream
-- mirror stream
-- buble
-- spray (segment of burst)

-- modifiers :
-- gravity
-- rotate
-- friction

-- omni (spawns bullets from bullets) :
-- burst
-- streams
-- mirror streams
-- optional : destroy original

-- slave :
-- firing offset
-- directed


local engine = {
	bullets = {},
	slaves = {},
	slaves_json = "",
	characters = {}
}

engine.characters[#engine.characters + 1] = {x = 0, y = 300, t = 1}

function engine.emit_burst(self, x, y, t, count, v, vx, vy, start_radius)
	vx = vx or 0
	vy = vy or 0
	start_radius = start_radius or 0
	for i = 1, 360, 360 / count do
		local a = math.rad(i)
		local dx = math.cos(a)
		local dy = math.sin(a)
		self.bullets[#self.bullets + 1] = {
			x = x + dx * start_radius,
			y = y + dy * start_radius,
			vx = dx * v + vx,
			vy = dy * v + vy,
			t = t,
			a = a
		}
	end
end

function engine.emit_spray(self, x, y, t, count, v, a, delta)
	count = count or 1
	if delta < 2 then delta = 2 end
	for i = a - delta / 2, a + delta / 2, delta / count do
		local a = math.rad(i)
		local dx = math.cos(a)
		local dy = math.sin(a)
		self.bullets[#self.bullets + 1] = {
			x = x,
			y = y,
			vx = dx * v,
			vy = dy * v,
			t = t,
			a = a
		}
	end
end

function engine.emit_stream(self, x, y, t, count, v, a)
	a = math.rad(a)
	local spd = v
	for i = 1, count do
		self.bullets[#self.bullets + 1] = {
			x = x,
			y = y,
			vx = math.cos(a) * spd,
			vy = math.sin(a) * spd,
			t = t,
			a = a
		}
		spd = spd - v / (count * 1.2)
	end
end

function engine.spawn_character(self)
	self.characters[#self.characters + 1] = {x = 0, y = 0, t = 2}

	--slaves[#slaves + 1] = {chr = #characters, distance = 32, angle = 45, velocity = 2, fire = {type = "burst", bullet = 3, offset = 0, rate = 20, counter = 10, count = 100, velocity = 3}}
	--slaves[#slaves + 1] = {chr = #characters, distance = 64, angle = 45, velocity = 2, fire = {type = "stream", bullet = 3, offset = 0, rate = 10, counter = 10, count = 15, velocity = 15, directed = true}}
	--slaves[#slaves + 1] = {chr = #characters, d = 64, a = 45, va = 2, fire = {type = "stream", bullet = 3, offset = 0, rate = 10, c = 10, count = 15, v = 15}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 2, fire = {type = "tristream", bullet = 3, offset = 0, rate = 20, c = 10, count = 15, v = 15}}
	--slaves[#slaves + 1] = {chr = #characters, d = 0, a = 0, va = 0, fire = {type = "mirror", bullet = 2, offset = 0, rate = 40, c = 10, count = 15, v = 15}}
	--slaves[#slaves + 1] = {chr = #characters, d = 64, a = 45, va = 1, fire = {type = "buble", bullet = 3, offset = 0, rate = 20, c = 10, count = 15, v = 15, r = 50}}
	--slaves[#slaves + 1] = {chr = #characters, d = 64, a = 45, va = 0, fire = {type = "sinwave", bullet = 3, offset = 0, rate = 0, c = 0, count = 1, v = 15, sin_t = 0, sin_w = 10, sin_a = 30, directed = true}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, fire = {type = "spray", bullet = 1, offset = 0, rate = 20, c = 10, count = 100, v = 3, angle = 90, directed = true}}

	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, mod = {type = "friction", bullet = 3, v = 0.3}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, mod = {type = "turn", bullet = 2, v = 1}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, mod = {type = "gravity", bullet = 2, v = 0.1}}

	--slaves[#slaves + 1] = {chr = #characters, d = 64, a = 180, va = 3, fire = {type = "stream", bullet = 3, offset = 0, rate = 5, c = 10, count = 1, v = 10}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, mod = {type = "friction", bullet = 3, v = 0.3}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 1, fire = {type = "burst", omni = 3, destroy = true, bullet = 1, offset = 0, rate = 120, c = 60, count = 100, v = 5}}
	--slaves[#slaves + 1] = {chr = #characters, d = 32, a = 45, va = 0, fire = {type = "stream", omni = 3, destroy = true, bullet = 1, offset = 0, rate = 60, c = 60, count = 100, v = 50, directed = true}}
end


local JSON = require("json")

function engine.hotreload(self)
	local effect_text, effect_size = love.filesystem.read("test.json")
	if effect_text ~= nil and effect_size > 0 then
		local slaves_new = JSON:decode(effect_text)
		if slaves_new ~= nil then
			local slaves_json_new = JSON:encode(slaves_new)
			if self.slaves_json ~= slaves_json_new then
				self.slaves = slaves_new
				self.slaves_json = slaves_json_new
				self.bullets = {}
			end
		end
	end
end

function engine.update(self, scrn_w, scrn_h)
	self:hotreload()

	local delete_later = {} -- bullets

	for k, slave in pairs(self.slaves) do
		local a = math.rad(slave.angle)
		slave.chr = slave.chr or 2
		slave.x = self.characters[slave.chr].x + math.cos(a) * slave.distance
		slave.y = self.characters[slave.chr].y + math.sin(a) * slave.distance
		slave.angle = slave.angle + slave.velocity

		if slave.fire then
			if slave.fire.counter then
				slave.fire.counter = slave.fire.counter - 1
				if slave.fire.counter <= 0 then
					local spawn = {}
					if slave.fire.omni then
						for kb, bullet in pairs(self.bullets) do
							if bullet.t == slave.fire.omni then
								spawn[#spawn + 1] = {x = bullet.x, y = bullet.y}
								if slave.fire.destroy then
									delete_later[kb] = true
								end
							end
						end
					else
						spawn[#spawn + 1] = {x = slave.x, y = slave.y}
					end
					for ks, point in pairs(spawn) do
						local x = point.x
						local y = point.y
						local bullet = slave.fire.bullet
						local count = slave.fire.count
						local v = slave.fire.velocity
						local a = slave.angle + slave.fire.offset
						if slave.fire.directed and player then
							a = math.deg(math.atan2(player.y - point.y, player.x - point.x))
						end

						if slave.fire.type == "burst" then
							self:emit_burst(x, y, bullet, count, v)
						elseif slave.fire.type == "stream" then
							self:emit_stream(x, y, bullet, count, v, a)
						elseif slave.fire.type == "tristream" then
							self:emit_stream(x, y, bullet, count, v, a + 20)
							self:emit_stream(x, y, bullet, count, v, a - 20)
							self:emit_stream(x, y, bullet, count, v, a)
						elseif slave.fire.type == "mirror" then
							self:emit_stream(x, y, bullet, count, v, a)
							self:emit_stream(x, y, bullet, count, v, a - 180)
						elseif slave.fire.type == "buble" then
							self:emit_burst(x, y, bullet, count, 0, math.cos(math.rad(a)) * v, math.sin(math.rad(a)) * v, slave.fire.radius)
						elseif slave.fire.type == "sinwave" then
							slave.fire.sin_t = slave.fire.sin_t or 0
							self:emit_stream(x, y, bullet, count, v, a + math.sin(slave.fire.sin_t * math.rad(slave.fire.sin_w)) * slave.fire.sin_a)
							slave.fire.sin_t = slave.fire.sin_t + 1
						elseif slave.fire.type == "spray" then
							self:emit_spray(x, y, bullet, count, v, a, slave.fire.angle)
						end
					end
					slave.fire.counter = slave.fire.rate
				end
			else
				slave.fire.counter = slave.fire.rate
			end
		elseif slave.mod then
			if slave.mod.type == "friction" then
				for k, bullet in pairs(self.bullets) do
					local v = slave.mod.amount
					if bullet.t == slave.mod.bullet then
						local bv = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
						if bv > 0 or v < 0 then
							local bv2 = bv - v
							if v > 0 and bv2 < 0 then bv2 = 0 end
							bullet.vx = bullet.vx * bv2 / bv
							bullet.vy = bullet.vy * bv2 / bv
						end
					end
				end
			elseif slave.mod.type == "turn" then
				for k, bullet in pairs(self.bullets) do
					if bullet.t == slave.mod.bullet then
						local bv = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
						local a = math.atan2(bullet.vy, bullet.vx) + math.rad(slave.mod.amount)
						bullet.vx = math.cos(a) * bv
						bullet.vy = math.sin(a) * bv
					end
				end
			elseif slave.mod.type == "gravity" then
				for k, bullet in pairs(self.bullets) do
					if bullet.t == slave.mod.bullet then
						bullet.vy = bullet.vy + slave.mod.amount
					end
				end
			end
		end
	end

	-- update bullets
	for k, bullet in pairs(self.bullets) do
		bullet.x = bullet.x + bullet.vx
		bullet.y = bullet.y + bullet.vy
		if bullet.life ~= nil then
			bullet.life = bullet.life - 1
		end

		local img_w = 32
		local img_h = 32
		if (bullet.life ~= nil and bullet.life <= 0) or
			(bullet.x + img_w / 2 < -scrn_w / 2) or
			(bullet.x - img_w / 2 >  scrn_w / 2) or
			(bullet.y + img_h / 2 < -scrn_h / 2) or
			(bullet.y - img_h / 2 >  scrn_h / 2)
			then
			delete_later[k] = true
		end
	end

	if next(delete_later) then
		local new_bullets = {}
		for k, bullet in pairs(self.bullets) do
			if not delete_later[k] then
				new_bullets[#new_bullets + 1] = bullet
			end
		end
		self.bullets = new_bullets
	end

end

return engine