bump = require 'bump'
gamera = require 'gamera'
timer = require 'timer'
v2 = require 'v2'
require 'util'

local world = bump.newWorld()
local cam = gamera.new(-200, -200, 2200, 2200)
cam.goal = v2(0)

local player = {
    v = v2(0),
    maxJumps = 2,
    jumpsLeft = 0,
    trail = { -- yuck for a reason
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0),
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0),
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0),
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0),
        v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0), v2(0)
    }
}

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

level:addElem(0, 600, 1000, 300, function(self, x, y, w, h)
    love.graphics.rectangle('line', x, y, w, h)
end)

function player:getRect()
    return world:getRect(self)
end

function player:getPos()
    local x, y, _, _ = self:getRect()
    return v2(x, y)
end

function player:update(dt)
    local x, y, w, h = self:getRect()
    -- apply gravity
    self.v.y = self.v.y + 7.8

    local x, y, cols, cols_len = world:move(self, x + self.v.x * dt, y + self.v.y * dt)

    -- TODO: wall jump
    if cols_len > 0 then -- TODO: assert that the collision comes from below
        self.v.y = 0 -- reset y acceleration when hit the ground
        self.jumpsLeft = self.maxJumps
    end

    table.insert(player.trail, 1, x + 10)
    table.insert(player.trail, 2, y + 10)
    table.remove(player.trail, #player.trail)
    table.remove(player.trail, #player.trail)

    self.v.x = 0
end

function player:jump()
    if self.jumpsLeft > 0 then
        player:setForce(nil, -300)
        self.jumpsLeft = self.jumpsLeft - 1
    end
end

function player:attack()
    t = {}
    print(player:getRect())
    print(rectDir(player:getRect(), 'r'))
    world:add(t, rectDir(player:getRect(), 'r'))
    timer.create(1, function()
        world:remove(t)
    end)
end

function player:setForce(x, y)
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
    elseif k == "a" then
        player:attack()
    end
end

function love.update(dt)
    timer.update(dt)

    cam.goal = player:getPos()
    cam:setPosition(cam.goal:unpack())

    if love.keyboard.isDown("left") then
        player:setForce(-300)
    end

    if love.keyboard.isDown("right") then
        player:setForce(300)
    end

    player:update(dt)
end

function love.draw()
    cam:draw(function(l,t,w,h)
        level:draw()
        player:draw()
    end)
end
