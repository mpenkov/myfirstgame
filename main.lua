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
    if false then
        player.sprite = love.graphics.newImage("sprites/samolet-32.png")
        player.spriteWidth = 32
        player.spriteHeight = 32
        player.health = 10000
    end

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
        -- forces enemies to GTFO early, making for a more interesting scene
        player.x = love.graphics.getWidth() / 2
        player.y = love.graphics.getHeight() / 4
    end

    --respawn enemies
    --[[
    if activeEnemies == 0 then
        _G.enemies = {}
        spawnMany(math.random(1, 10))
    end
    ]]
end

function love.draw()
    ground:draw()
    air.draw()
    -- cloud shadows
    --[[
    for i = 1, #clouds do
        local c = clouds[i]
        local width = clouds[i].scale * cloud.width
        local cx, cy = c.x + width / 2, c.y + width / 2
        local offset = clouds[i].scale * cloud.width / 16
        love.graphics.setColor(75/255, 105/255, 47/255)
        love.graphics.circle("fill", cx - offset, c.x + offset / 2, 15 * c.scale)
    end
    --]]
end

function destroy(thing)
    local offset = thing.width / 2
    for k = 1, math.random(1, 5) do
        if thing == player then
            color = {1, 1, 0.85}
        else
            color = {1, 0.85, 0.85}
        end

        -- set the center of the explosion to the enemy
        air:markExplosion(
            thing.x + offset * (0.5 + math.random()),
            thing.y + offset * (0.5 + math.random()),
            color
        )
    end

    if thing ~= player then
        ground:markCrashSite(thing.x, thing.y, offset / 4)
    end

    thing.active = false
end
