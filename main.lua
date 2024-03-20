--[[

Ideas:

- Different weapons: single fire, alternate fire, double fire, triple fire...
- Dead enemies sometimes drop a weapons bonus
- Fuel dynamic: must destroy enemy wave before fuel runs out, and an Il-78 tanker comes to refuel you between attack waves
- Health dynamic: dead enemies sometimes drop health bonus
- Increase enemy difficulty after each wave (less stupid, more evasive) 
- Boss fights (F-35, F-22, B-1, B-52)
- More enemy aircraft (F-14, F-16, F-18, F-117, Mirage-2000, Rafale)
- Ground fire from SAMs
- Maverick-like canyon game mode
- Tu-22 backfire game mode (fighters attacking from behind, SAMs from ahead)
- Su-25 attack mode (attacking ground targets only)
- Different terrain (snow, water, desert)
- Menu to select planes, terrain, game mode

--]]
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
        -- Keep some enemies on the screen to keep it interesting
        --
        local counter = 0
        for key, enemy in pairs(air.enemies) do
            if enemy and enemy.active then
                counter = counter + 1
            end
        end

        air:addEnemies(5 - counter)

        for key, enemy in pairs(air.enemies) do
            if enemy and enemy.active then
                enemy.stupid = false
                enemy.stalker = false
            end
        end

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
        local x = thing.x + thing.width * math.random(0.35, 0.65)
        local y = thing.y + thing.height * math.random(0.35, 0.65)
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
