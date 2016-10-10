bump = require 'bump'
gamera = require 'gamera'
timer = require 'timer'
v2 = require 'v2'
require 'util'

gravity = v2(0, 300)
maxV = 1000

local world = bump.newWorld()
local player = require("player"):init(world)
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

function love.load()
    love.graphics.setBackgroundColor(100, 100, 100)
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
