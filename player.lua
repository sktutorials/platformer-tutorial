local player = {
    v = v2(0),
    a = v2(0),
    running = false,
    walling = false,
    world = nil,
    maxJumps = 1,
    jumpsLeft = 0,
    jumpV = v2(0, 300),
    airDrag = 0.8,
    acc = 30,
    dec = 50,
    fric = 25,
    maxRunV = 400,
    maxWalkV = 200,
    runDir = 0,
    lastNorm = v2(0),
    trail = { -- yuck for a reason
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0),
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0),
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0),
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0),
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0)
    }
}

function player:getRect()
    return self.world:getRect(self)
end

function player:getPos()
    local x, y, _, _ = self:getRect()
    return v2(x, y)
end

function player:setVel(x, y)
    self.v.x = x or self.v.x
    self.v.y = y or self.v.y
end

function player:handleCollisions(cols)
    for _, c in pairs(cols) do
        if(c.type == "slide") then
            self.lastNorm = v2(c.normal.x, c.normal.y)
            if(c.normal.x ~= 0) then
                self.walling = true
            end
        end
    end
end

function player:update(dt)
    self.a = gravity -- reset acceleration
    if self.runDir ~= 0 then
        -- get the max movement speed
        local m = self.maxWalkV
        if self.running then m = self.maxRunV end

        local standstill = self.v.x == 0
        local accelerating = math.sign(self.runDir) == math.sign(self.v.x)
        local decelerating = math.sign(self.runDir) ~= math.sign(self.v.x)
        if (standstill or accelerating) and math.abs(self.v.x) < m then
            self.v.x = self.v.x + self.runDir * self.acc
        elseif decelerating then
            self.v.x = self.v.x + self.runDir * self.dec
        end
    else -- apply friction
        if math.abs(self.v.x) < self.acc then -- clamp if velocity is small
            self.v.x = 0
        else
            local grounded = self.jumpsLeft == self.maxJumps
            if grounded then -- friction
                self.v.x = self.v.x + -1 * math.sign(self.v.x) * self.fric
            end
        end
    end

    self.v = self.v + (dt * self.a)

    local pos = self:getPos()
    local newPos = pos + dt * self.v
    local x, y, cols, cols_len = self.world:move(self, newPos.x, newPos.y)
    self.walling = false
    self:handleCollisions(cols)

    if cols_len > 0 then
        if self.lastNorm.y == -1 then -- hit the floor
            self.v.y = 0 -- reset y acceleration when hit the ground
        end
        self.jumpsLeft = self.maxJumps
    end

    -- gross trail stuff
    table.insert(player.trail, 1, x + 10)
    table.insert(player.trail, 2, y + 10)
    table.remove(player.trail, #player.trail)
    table.remove(player.trail, #player.trail)
end

function player:jump()
    if self.jumpsLeft > 0 then
        if self.lastNorm.x ~= 0 and self.walling then
            local v = self.jumpV:rotate(-self.lastNorm.x * (math.pi / 4))
            player:setVel(v.x, v.y)
            self.jumpsLeft = self.jumpsLeft - 1
        elseif self.lastNorm.y == -1 then
            player:setVel(nil, -self.jumpV.y)
            self.jumpsLeft = self.jumpsLeft - 1
        end
    end
end

function player:draw()
    love.graphics.rectangle('fill', self:getRect())
    love.graphics.line(self.trail)
end

function player:init(world)
  self.world = world
  self.world:add(self, 0, 0, 20, 20)
  return self
end

return player
