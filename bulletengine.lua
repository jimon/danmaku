--[[
simple danmaku bullet engine
inspired by bullet pattern studio

api :

engine = require("bulletengine")
chr_index = engine:spawn_character(x, y, type, enemy)
engine:spawn_slaves(slaves, chr_index)
slaves, slaves_text = engine:parse_slaves(name)
engine:delete_slaves(chr_index)
engine:delete_bullets(bullet_type)
engine:update(scrn_w, scrn_h)
]]--

local engine = {
	bullets = {
		--[[
		x, y = position
		vx, vy = velocity
		t = type
		a = angle
		life = left lifetime in frames
		]]--
	},
	slaves = {
		--[[
		chr = character index
		distance = distance from character in pixels
		angle = angle to character
		velocity = angular velocity in frames
		fire = {
			type = burst, stream, tristream, mirror, buble, sinwave or spray (all as string)
			bullet = bullet type
			count = bullet count
			velocity = bullet velocity
			offset = offset angle
			rate = fire rate in frames
			counter = fire counter in frames (or nil)
			radius = buble radius
			sin_a, sin_w, sin_t = sinwave amplitude, frequency and counter (counter increases here)
			angle = spray angle
		}
		mod = {
			type = friction, turn or gravity (all as string)
			bullet = bullet type to influence
			amount = number
		}
		]]--
	},
	slaves_json = "", -- TODO hot reloading
	characters = {
		--[[
		x, y = position
		type = type
		enemy = index of enemy character (or nil)
		]]--
	},
	bullets_to_delete = {
		-- key is bullet index, value is true for removal
	}
}

function engine.spawn_character(self, x, y, type, enemy)
	self.characters[#self.characters + 1] = {x = x, y = y, type = type, enemy = enemy}
	return #self.characters
end

function engine.spawn_slaves(self, slaves, chr_index)
	for k, slave in pairs(slaves) do
		slave.chr = chr_index
		self.slaves[#self.slaves + 1] = slave
	end
end

function engine.delete_slaves(self, chr_index)
	local slaves_to_delete = {}
	for k, slave in pairs(self.slaves) do
		if chr_index == nil or slave.chr == chr_index then
			slaves_to_delete[k] = true
		end
	end
	if next(slaves_to_delete) then
		local new_slaves = {}
		for k, slave in pairs(self.slaves) do
			if not slaves_to_delete[k] then
				new_slaves[#new_slaves + 1] = slave
			end
		end
		self.slaves = new_slaves
	end
end

function engine.delete_bullets(self, bullet_type)
	for k, bullet in pairs(self.bullets) do
		if bullet_type == nil or bullet.t == bullet_type then
			self.bullets_to_delete[k] = true
		end
	end
	self:remove_marked_bullets()
end

local json = require("json")
function engine.parse_slaves(self, name)
	local slaves_text, slaves_size = love.filesystem.read(name)
	if slaves_text ~= nil and slaves_size > 0 then
		local slaves = json:decode(slaves_text)
		if slaves ~= nil then
			return slaves, json:encode(slaves)
		end
	end
	return nil, nil
end

function engine.emit_burst(self, x, y, bullet, count, velocity, velocity_x, velocity_y, start_radius)
	velocity_x = velocity_x or 0
	velocity_y = velocity_y or 0
	start_radius = start_radius or 0
	for i = 1, 360, 360 / count do
		local angle = math.rad(i)
		local dx = math.cos(angle)
		local dy = math.sin(angle)
		self.bullets[#self.bullets + 1] = {
			x = x + dx * start_radius,
			y = y + dy * start_radius,
			vx = dx * velocity + velocity_x,
			vy = dy * velocity + velocity_y,
			t = bullet,
			a = angle
		}
	end
end

function engine.emit_spray(self, x, y, bullet, count, velocity, angle, delta)
	count = count or 1
	if delta < 2 then delta = 2 end
	for i = angle - delta / 2, angle + delta / 2, delta / count do
		local angle = math.rad(i)
		local dx = math.cos(angle)
		local dy = math.sin(angle)
		self.bullets[#self.bullets + 1] = {
			x = x,
			y = y,
			vx = dx * velocity,
			vy = dy * velocity,
			t = bullet,
			a = angle
		}
	end
end

function engine.emit_stream(self, x, y, bullet, count, velocity_max, angle)
	angle = math.rad(angle)
	local velocity = velocity_max
	for i = 1, count do
		self.bullets[#self.bullets + 1] = {
			x = x,
			y = y,
			vx = math.cos(angle) * velocity,
			vy = math.sin(angle) * velocity,
			t = bullet,
			a = angle
		}
		velocity = velocity - velocity_max / (count * 1.2)
	end
end

function engine.slave_fire(self, slave)
	local spawn = {} -- list of points to spawn at
	if slave.fire.omni then
		for kb, bullet in pairs(self.bullets) do
			if bullet.t == slave.fire.omni then
				spawn[#spawn + 1] = {x = bullet.x, y = bullet.y}
				if slave.fire.destroy then
					self.bullets_to_delete[kb] = true
				end
			end
		end
	else
		spawn[#spawn + 1] = {x = slave.x, y = slave.y}
	end

	for ks, point in pairs(spawn) do
		local x = point.x
		local y = point.y
		local t = slave.fire.bullet
		local c = slave.fire.count
		local v = slave.fire.velocity
		local a = slave.angle
		if slave.fire.directed and slave.chr and self.characters[slave.chr].enemy then
			local enemy = self.characters[self.characters[slave.chr].enemy]
			a = math.deg(math.atan2(enemy.y - point.y, enemy.x - point.x))
		end
		a = a + slave.fire.offset -- apply offset angle afterwards (this is important!)

		if slave.fire.type == "burst" then
			self:emit_burst(x, y, t, c, v)
		elseif slave.fire.type == "stream" then
			self:emit_stream(x, y, t, c, v, a)
		elseif slave.fire.type == "tristream" then
			self:emit_stream(x, y, t, c, v, a + 20)
			self:emit_stream(x, y, t, c, v, a - 20)
			self:emit_stream(x, y, t, c, v, a)
		elseif slave.fire.type == "mirror" then
			self:emit_stream(x, y, t, c, v, a)
			self:emit_stream(x, y, t, c, v, a - 180)
		elseif slave.fire.type == "buble" then
			self:emit_burst(x, y, t, c, 0, math.cos(math.rad(a)) * v, math.sin(math.rad(a)) * v, slave.fire.radius)
		elseif slave.fire.type == "sinwave" then
			slave.fire.sin_t = slave.fire.sin_t or 0
			self:emit_stream(x, y, t, c, v, a + math.sin(slave.fire.sin_t * math.rad(slave.fire.sin_w)) * slave.fire.sin_a)
			slave.fire.sin_t = slave.fire.sin_t + 1
		elseif slave.fire.type == "spray" then
			self:emit_spray(x, y, t, c, v, a, slave.fire.angle)
		end
	end
end

function engine.slave_friction(self, slave)
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
end

function engine.slave_turn(self, slave)
	for k, bullet in pairs(self.bullets) do
		if bullet.t == slave.mod.bullet then
			local bv = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
			local a = math.atan2(bullet.vy, bullet.vx) + math.rad(slave.mod.amount)
			bullet.vx = math.cos(a) * bv
			bullet.vy = math.sin(a) * bv
		end
	end
end

function engine.slave_gravity(self, slave)
	for k, bullet in pairs(self.bullets) do
		if bullet.t == slave.mod.bullet then
			bullet.vy = bullet.vy + slave.mod.amount
		end
	end
end

function engine.remove_marked_bullets(self)
	-- delete bullets
	if next(self.bullets_to_delete) then
		local new_bullets = {}
		for k, bullet in pairs(self.bullets) do
			if not self.bullets_to_delete[k] then
				new_bullets[#new_bullets + 1] = bullet
			end
		end
		self.bullets = new_bullets
		self.bullets_to_delete = {}
	end
end

function engine.update(self, scrn_w, scrn_h)
	-- update slaves
	for k, slave in pairs(self.slaves) do
		local angle = math.rad(slave.angle)
		slave.x = self.characters[slave.chr].x + math.cos(angle) * slave.distance
		slave.y = self.characters[slave.chr].y + math.sin(angle) * slave.distance
		slave.angle = slave.angle + slave.velocity

		if slave.fire then
			if slave.fire.counter then
				slave.fire.counter = slave.fire.counter - 1
				if slave.fire.counter <= 0 then
					self:slave_fire(slave)
					slave.fire.counter = slave.fire.rate
				end
			else
				slave.fire.counter = slave.fire.rate
			end
		elseif slave.mod then
			if slave.mod.type == "friction" then
				self:slave_friction(slave)
			elseif slave.mod.type == "turn" then
				self:slave_turn(slave)
			elseif slave.mod.type == "gravity" then
				self:slave_gravity(slave)
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
			self.bullets_to_delete[k] = true
		end
	end

	self:remove_marked_bullets()
end

return engine