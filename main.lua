local love = require "love"
Player = require("Player")
Ground = require("Ground")
Air = require("Air")

require "core"


function love.load()
    love.math.setRandomSeed(love.timer.getTime())
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    love.mouse.setVisible(false)

    _G.player = Player()
    _G.ground = Ground()
    _G.air = Air()

    if false then
        local enemy = air:addEnemy()
        enemy.x = love.graphics.getWidth() / 2
    else
        air:addEnemies(math.random(1, 5))
    end
end

function love.update(dt)
    ground:update(dt)
    air:update(dt)

    if player.active then
        player:update(dt)
    elseif love.keyboard.isDown("return") then
        player.x = love.graphics.getWidth() / 2
        player.y = love.graphics.getHeight() - 2*player.width
        player.active = true
        player.health = 5
        player.lastMissile = love.timer.getTime()
    else
        --
        -- forces enemies to GTFO early, making for a more interesting scene
        --
        player.x = love.graphics.getWidth() / 2
        player.y = love.graphics.getHeight() / 4
    end
end

function love.draw()
    ground:draw()
    air:draw()
end

function destroy(thing)
    local color = {1, 0.85, 0.85}
    if thing == player then
        color = {1, 1, 0.85}
    end

    for k = 1, math.random(1, 5) do
        -- set the center of the explosion to center of the thing that exploded
        local x = thing.x + thing.width * math.random(-1, 1)
        local y = thing.y + thing.height * math.random(-1, 1)
        air:addExplosion(x, y, color)
    end

    if thing == player then
        --
        -- the player leaves a crater closer to the top of the screen, otherwise
        -- we don't see it because of the scrolling
        --
        ground:addCraters(thing.x, thing.y - 750, thing.width / 4)
    else
        ground:addCraters(thing.x, thing.y, thing.width / 4)
    end

    thing.active = false
end
