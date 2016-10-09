bump = require 'bump'
gamera = require 'gamera'
timer = require 'timer'
v2 = require 'v2'
require 'util'

gravity = v2(0, 300)
maxV = 1000

local world = bump.newWorld()
local cam = gamera.new(-200, -200, 2200, 2200)
cam.goal = v2(0)

local level = {elems = {}}

function level:addElem(x, y, w, h, drawLambda) -- TODO: update lambda
    local t = {draw = drawLambda}
    world:add(t, x, y, w, h)
    table.insert(self.elems, t)
end

function level:draw()
    for _, e in ipairs(self.elems) do
        e:draw(world:getRect(e))
    end
end

level:addElem(0, 600, 100, 300,
function(self, x, y, w, h)
    love.graphics.rectangle('line', x, y, w, h)
end)

level:addElem(200, 600, 100, 300,
function(self, x, y, w, h)
    love.graphics.rectangle('line', x, y, w, h)
end)

level:addElem(400, 600, 100, 300,
function(self, x, y, w, h)
    love.graphics.rectangle('line', x, y, w, h)
end)

level:addElem(600, 600, 100, 300,
function(self, x, y, w, h)
    love.graphics.rectangle('line', x, y, w, h)
end)


local player = {
    v = v2(0),
    a = v2(0),
    running = false,
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
    return world:getRect(self)
end

function player:getPos()
    local x, y, _, _ = self:getRect()
    return v2(x, y)
end

function player:handleCollisions(cols)
    for _, c in pairs(cols) do
        if(c.type == "slide") then
            self.lastNorm = v2(c.normal.x, c.normal.y)
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
    local x, y, cols, cols_len = world:move(self, newPos.x, newPos.y)
    self:handleCollisions(cols)

    -- TODO: wall jump
    -- TODO: assert that the collision comes from below
    if cols_len > 0 then
        self.v.y = 0 -- reset y acceleration when hit the ground
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
        print(self.lastNorm)
        if self.lastNorm.x ~= 0 then
            self.jumpsLeft = self.maxJumps
            local v = self.jumpV:rotate(-self.lastNorm.x * (math.pi / 4))
            player:setVel(v.x, v.y)
        elseif self.lastNorm.y == -1 then
            player:setVel(nil, -self.jumpV.y)
            self.jumpsLeft = self.jumpsLeft - 1
        end
    end
end

function player:setVel(x, y)
    self.v.x = x or self.v.x
    self.v.y = y or self.v.y
end

function player:draw()
    love.graphics.rectangle('fill', self:getRect())
    love.graphics.line(self.trail)
    if t then
        love.graphics.rectangle('line', world:getRect(t))
    end
end

function love.load()
    love.graphics.setBackgroundColor(100, 100, 100)
    world:add(player, 0, 0, 20, 20)
end

function love.keypressed(k, scancode, isrepeat)
    if k == "up" then
        player:jump()
    end
end

function love.keyreleased(k, scancode, isrepeat)
    if k == "up" then
        if player.v.y < 0 then
            player:setVel(nil, math.max(0, player.v.y))
        end
    end

    if k == "left" or k == "right" then
        player.runDir = 0
    end
end

function love.update(dt)
    timer.update(dt)

    cam.goal = player:getPos()
    cam:setPosition(cam.goal:unpack())

    if love.keyboard.isDown("left") then
        player.runDir = -1
    end

    if love.keyboard.isDown("right") then
        player.runDir = 1
    end

    if love.keyboard.isDown("lshift") then
        player.running = true
    else
        player.running = false
    end

    player:update(dt)
end

function love.draw()
    cam:draw(function(l,t,w,h)
        level:draw()
        player:draw()
    end)
end
