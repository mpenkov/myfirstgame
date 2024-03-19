local love = require "love"

require "core"

function love.load()
    love.math.setRandomSeed(love.timer.getTime())
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    love.mouse.setVisible(false)

    _G.player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() - 128,
        width = 128,
        height = 128,
        speed = 500,
        sprite = love.graphics.newImage("sprites/su27-64-camo.png"),
        spriteWidth = 64,
        spriteHeight = 64,
        hardpoint = 0,
        lastMissile = 0,
        reloadTime = 0.1,
        health = 5,
        active = true,
    }
    if false then
        player.sprite = love.graphics.newImage("sprites/samolet-32.png")
        player.spriteWidth = 32
        player.spriteHeight = 32
        player.health = 10000
    end

    _G.boomSprite = {
        image = love.graphics.newImage("sprites/boom.png"),
        quads = {},
        width = 128,
        height = 32,
        quadSize = 32,
    }
    for i = 1, 4 do
        boomSprite.quads[i] = love.graphics.newQuad(
            (i - 1) * boomSprite.quadSize,
            0,
            boomSprite.quadSize,
            boomSprite.quadSize,
            boomSprite.width,
            boomSprite.height
        )
    end

    _G.bg = {
        image = love.graphics.newImage("sprites/green.png"),
        y = 0,
        speed = 500,
    }
    bg.batch = love.graphics.newSpriteBatch(bg.image)
    for i = 1, 16 do
        for j = 1, 16 do
            bg.batch:add((i - 1) * 128, (j - 1) * 128)
        end
    end

    _G.cloud = {
        image = love.graphics.newImage("sprites/cloud.png"),
        width = 64,
        height = 64,
        count = 8,
    }

    _G.clouds = {}

    for i = 1, _G.cloud.count do
        local c = {
            x = math.random(love.graphics.getWidth()),
            y = math.random(love.graphics.getHeight()),
            speed = math.random(512, 1536), 
            scale = math.random(2, 4),
        }
        table.insert(clouds, c)
    end

    _G.ground_explosions = {}

    _G.explosions = {}
    _G.missiles = {}
    _G.enemies = {}

    if false then
        local enemy = spawn()
        enemy.x = love.graphics.getWidth() / 2,
        table.insert(enemies, enemy)
    else
        spawnMany(math.random(1, 5))
    end
end

function love.update(dt)
    updateBackground(dt)

    if player.active then
        movePlayer(dt)
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

    local activeEnemies = 0
    for i = 1, #enemies do
        local e = enemies[i]
        if e.active then
            moveEnemy(i, dt)
            activeEnemies = activeEnemies + 1
        end
    end

    -- respawn enemies
    if activeEnemies == 0 then
        _G.enemies = {}
        spawnMany(math.random(1, 10))
    end

    -- handle explosions
    local numActive = 0
    for i = 1, #explosions do
        local e = explosions[i]
        if e.active then
            numActive = numActive + 1
            e.frame = e.frame + e.speed * dt
            if e.frame > #_G.boomSprite.quads then
                -- show's over, hide and disable whatever exploded
                e.active = false
                e.thing.active = false
            end
        end
    end
    if numActive == 0 then
        _G.explosions = {}
    end

    -- todo handle the two types of explosion together somehow?
    numActive = 0
    for i = 1, #ground_explosions do
        local e = ground_explosions[i]
        if e.active then
            numActive = numActive + 1
            e.frame = e.frame + e.speed * dt
            if e.frame > #_G.boomSprite.quads then
                -- show's over, hide and disable whatever exploded
                e.active = false
            end
        end
    end
    if numActive == 0 then
        _G.ground_explosions = {}
    end

    -- move existing missiles
    numActive = 0
    for i = 1, #missiles do
        local m = missiles[i]
        if m.active then
            numActive = numActive + 1
            m.y = m.y + m.speed * dt

            -- collision detection
            if m.ours then
                for j = 1, #enemies do
                    if enemies[j].active and collision(m, enemies[j]) then
                        registerPlayerHit(m, enemies[j])
                    end
                end
            else
                if collision(m, player) then
                    registerEnemyHit(m)
                end
            end
        end
    end
    if numActive == 0 then
        _G.missiles = {}
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    -- the -128 is so that part of the background is always off-screen, otherwise
    -- we get a flickering black band
    love.graphics.draw(bg.batch, 0, bg.y - 128)

    for i = 1, #ground_explosions do
        local e = ground_explosions[i]
        if e.active and e.frame >= 1 then
            love.graphics.draw(
                boomSprite.image,
                boomSprite.quads[math.floor(e.frame)],
                e.x - 32,
                e.y - 32,
                0,
                2
            )
        end
    end

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

    if player.active then
        love.graphics.setColor(1, 1, 1)
        local sx = player.width / player.spriteWidth
        local sy = player.height / player.spriteHeight
        love.graphics.draw(player.sprite, player.x, player.y, 0, sx, sy)
    end

    love.graphics.setColor(1, 1, 1)
    for i = 1, #clouds do
        love.graphics.draw(cloud.image, clouds[i].x, clouds[i].y, 0, clouds[i].scale)
    end

    for i = 1, #enemies do
        local e = enemies[i]
        if e.active then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(e.sprite, e.x, e.y, math.pi, 2, 2, e.width/2, e.height/2)
        end
    end

    for i = 1, #missiles do
        local m = missiles[i]
        if m.active then
            if m.ours then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", m.x, m.y, m.width, m.height)
            else
                love.graphics.setColor(1, 1, 0)
                love.graphics.rectangle("fill", m.x, m.y, m.width, m.height)
            end
        end
    end

    for i = 1, #explosions do
        local e = explosions[i]
        if e.active then
            love.graphics.setColor(e.color[1], e.color[2], e.color[3])
            love.graphics.draw(
                boomSprite.image,
                boomSprite.quads[math.floor(e.frame)],
                e.x - 5 * 32,
                e.y - 5 * 32,
                0,
                10
            )
        end
    end
end

function boom(thing)
    return {
        x = thing.x,
        y = thing.y,
        thing = thing,
        active = true,
        frame = 1,
        speed = 30,
        color = {1, 0.8, 0.8},
    }
end

function spawn()
    --
    -- spawn a new enemy; location is off-screen to prevent them "popping up"
    -- out of nowhere
    --
    return {
        x = love.graphics.getWidth() / 2,
        y = math.random(-512, -256),
        width = 128,
        height = 128,
        sprite = love.graphics.newImage("sprites/f15-64.png"),
        spriteWidth = 64,
        spriteHeight = 64,
        lastMissile = 0,
        reloadTime = 0.5,
        triggerHappiness = 0.25,
        active = true,
        health = 5,
        speed = math.random(100, 250),
        stalker = math.random() > 0.25,
    }
end

function spawnMany(enemyCount)
    local spacing = love.graphics.getWidth() / (enemyCount + 1)
    for i = 1, enemyCount do
        local enemy = spawn()
        enemy.x = i * spacing + math.random(-32, 32)
        enemy.triggerHappiness = love.math.random()
        table.insert(enemies, enemy)
    end
end

function updateBackground(dt)
    bg.y = (bg.y + bg.speed * dt) % 128
    for i = 1, #ground_explosions do
        local gex = ground_explosions[i]
        if gex.active then
            gex.frame = gex.frame + gex.speed * dt
            gex.y = gex.y + bg.speed * dt
            if gex.y > love.graphics.getHeight() then
                gex.active = false
            end
        end
    end

    for i = 1, #clouds do
        clouds[i].y = clouds[i].y + clouds[i].speed * dt
        if clouds[i].y > love.graphics.getHeight() then
            clouds[i].x = math.random(love.graphics.getWidth() - cloud.width * clouds[i].scale)
            clouds[i].y = math.random(-love.graphics.getHeight(), - cloud.height * clouds[i].scale)
        end
    end
end


function movePlayer(dt)
    if love.keyboard.isDown("left") then
        player.x = player.x - dt * player.speed
    end

    if love.keyboard.isDown("right") then
        player.x = player.x + dt * player.speed
    end

    player.x = math.max(player.x, 0)
    player.x = math.min(player.x, love.graphics.getWidth() - player.width)

    if love.keyboard.isDown("up") then
        player.y = player.y - dt * player.speed
    end

    if love.keyboard.isDown("down") then
        player.y = player.y + dt * player.speed
    end

    player.y = math.max(player.y, 0)
    player.y = math.min(player.y, love.graphics.getHeight() - player.height)

    -- fire ze missiles
    now = love.timer.getTime()
    if love.keyboard.isDown("space") and now - player.lastMissile > player.reloadTime then
        m = fire(player.x, player.y + player.width, -1000)
        m.ours = true
        if player.hardpoint == 0 then
            player.hardpoint = 1
        else
            m.x = player.x + player.width
            player.hardpoint = 0
        end

        table.insert(missiles, m)
        player.lastMissile = now
    end

    -- collision between us and the enemy kills both
    for i = 1, #enemies do
        local e = enemies[i]
        if e.active and collision(player, e) then
            destroy(player)
            destroy(e)
        end
    end
end

function moveEnemy(i, dt)
    -- if the player has merged with us, GTFO
    local e = enemies[i]
    e.y = e.y + e.speed * dt
    if e.y > player.y then
        e.speed = e.speed * 1.1
        e.x = e.x - (player.x - e.x) * dt
    end

    --
    -- edge towards the player, unless we get in someone else's way (or the
    -- other way around
    --
    oldX = e.x
    if e.stalker then
        e.x = oldX + (player.x - e.x) * dt
    end

    for j = 1, #enemies do
        if i ~= j and enemies[j].active and xcollision(enemies[i], enemies[j]) then
            e.x = oldX
            break
        end
    end

    if e.x < 0 or e.x > love.graphics.getWidth() or e.y > love.graphics.getHeight() then
        e.y = math.random(-256, -128)
        e.x = math.random(love.graphics.getWidth())
        e.speed = math.random(100, 250)
    end

    if e.y > 0 and e.lastMissile < now - e.reloadTime then
        if player.active and love.math.random() < e.triggerHappiness then
            m = fire(e.x + e.width / 2, e.y + e.height, 1000)
            m.ours = false
            e.lastMissile = now
            table.insert(missiles, m)
        end
    end
end

function destroy(thing)
    local offset = thing.width / 2
    for k = 1, math.random(1, 5) do
        local expl = boom(thing)
        -- set the center of the explosion to the enemy
        expl.x = thing.x + offset * (0.5 + math.random())
        expl.y = thing.y + offset * (0.5 + math.random())
        expl.speed = 5 + math.random() * 5
        if thing == player then
            expl.color = {1, 1, 0.85}
        else
            expl.color = {1, 0.85, 0.85}
        end
        table.insert(explosions, expl)

        -- add some secondary explosions on the ground
        if thing ~= player then
            local crashSite = {
                x = thing.x + offset * math.random(-1, 1),
                y = thing.y + offset * math.random(-1, 1),
            }
            local gexpl = boom(crashSite)
            gexpl.frame = math.random(-3, -2)
            gexpl.speed = 3.5
            table.insert(ground_explosions, gexpl)
        end
    end
end

function registerPlayerHit(m, e)
    m.active = false
    e.health = e.health - 1
    table.insert(explosions, boom(m))
    if e.health <= 0 then
        destroy(e)
    end
end

function registerEnemyHit(m)
    m.active = false
    local expl = boom(m)
    expl.color = {1, 1, 0.8}
    table.insert(explosions, expl)

    player.health = player.health - 1
    if player.health <= 0 then
        destroy(player)
    end
end
