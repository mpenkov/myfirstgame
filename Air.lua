Enemy = require("Enemy")

function Air()
    local boomSprite = {
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

    local explosions = {}

    local clouds = {}
    local cloudSprite = {
        image = love.graphics.newImage("sprites/cloud.png"),
        width = 64,
        height = 64,
    }
    local cloudCount = 8
    for i = 1, cloudCount do
        local c = {
            x = math.random(love.graphics.getWidth()),
            y = math.random(love.graphics.getHeight()),
            speed = math.random(512, 1536), 
            scale = math.random(2, 4),
        }
        table.insert(clouds, c)
    end

    local missiles = {}
    local enemies = {}

    return {
        player=player,
        enemies=enemies,

        update=function(self, dt)
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()

            for i = 1, #clouds do
                clouds[i].y = clouds[i].y + clouds[i].speed * dt
                if clouds[i].y > screenHeight then
                    clouds[i].x = math.random(screenWidth - cloudSprite.width * clouds[i].scale)
                    clouds[i].y = math.random(-screenHeight, - cloudSprite.height * clouds[i].scale)
                end
            end

            activeCount = 0
            for i = 1, #enemies do
                if enemies[i].active then
                    activeCount = activeCount + 1
                    enemies[i]:update(dt)
                end
            end

            if activeCount == 0 then
                self:addEnemies(math.random(1, 10))
            else
                self.enemies = {}
            end

            -- move existing missiles
            for i = 1, #missiles do
                local m = missiles[i]
                if m.active then
                    m.y = m.y + m.speed * dt

                    -- collision detection
                    if m.ours then
                        for j = 1, #enemies do
                            if enemies[j].active and collision(m, enemies[j]) then
                                enemies[j]:hit(m)
                                break
                            end
                        end
                    else
                        if collision(m, player) then
                            player:hit(m)
                        end
                    end
                end
            end

            -- update explosions
            for i = 1, #explosions do
                local e = explosions[i]
                if e.active then
                    e.frame = e.frame + e.speed * dt
                    if e.frame > #boomSprite.quads then
                        -- show's over, hide and disable whatever exploded
                        e.active = false
                        e.thing.active = false
                    end
                end
            end

        end,

        draw=function(self)
            love.graphics.setColor(1, 1, 1)
            for i = 1, #clouds do
                love.graphics.draw(cloudSprite.image, clouds[i].x, clouds[i].y, 0, clouds[i].scale)
            end

            if player.active then
                player:draw()
            end

            for i = 1, #enemies do
                local e = enemies[i]
                if e.active then
                    e:draw()
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

            -- Nb. this must happen _after_ the player etc. have been drawn
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
        end,

        markExplosion = function(self, x, y, color)
            expl = boom({x=x, y=y})
            expl.speed = 5 + math.random() * 5
            expl.color = color or {1, 1, 0.85}
            table.insert(explosions, expl)
        end,

        addEnemy = function(self)
            local enemy = Enemy()
            table.insert(enemies, enemy)
            return enemy
        end,

        addEnemies = function(self, number)
            local spacing = love.graphics.getWidth() / (number + 1)
            for i = 1, number do
                local enemy = self.addEnemy()
                enemy.x = i * spacing + math.random(-32, 32)
                enemy.triggerHappiness = love.math.random()
            end
        end,

        addMissile = function(self, x, y, ours)
            local m = fire(x, y)
            m.ours = ours
            m.speed = 1000
            if ours then
                m.speed = -1000
            end
            table.insert(missiles, m)
        end,
    }
end

return Air
