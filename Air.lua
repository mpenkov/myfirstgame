Enemy = require("Enemy")

function itemAmmo(x, y, volume)
    volume = volume or 50
    return {
        x = x,
        y = y,
        volume = volume,
        width = 50,
        height = 50,

        update = function(self, dt)
            self.y = self.y + ground.speed * dt
        end,

        draw = function(self, dt)
            cx = self.x + self.width / 2
            cy = self.y + self.height / 2
            love.graphics.setColor(0, 0, 1)
            love.graphics.circle("fill", cx, cy, self.width / 2)
            love.graphics.setColor(0, 0, 0.8)
            love.graphics.circle("fill", cx, cy, self.width / 2 - 8)
            love.graphics.setColor(0, 0, 0)
            love.graphics.circle("line", cx, cy, self.width / 2)
        end,

        apply = function(self)
            player.ammo = player.ammo + self.volume
        end
    }
end

function itemHealth(x, y, volume)
    volume = volume or 5
    return {
        x = x,
        y = y,
        volume = 5,
        width = 50,
        height = 50,

        update = function(self, dt)
            self.y = self.y + ground.speed * dt
        end,

        draw = function(self, dt)
            cx = self.x + self.width / 2
            cy = self.y + self.height / 2
            love.graphics.setColor(0, 1, 1)
            love.graphics.circle("fill", cx, cy, self.width / 2)
            love.graphics.setColor(0, 0.8, 0.8)
            love.graphics.circle("fill", cx, cy, self.width / 2 - 8)
            love.graphics.setColor(0, 0, 0)
            love.graphics.circle("line", cx, cy, self.width / 2)
        end,

        apply = function(self)
            player.health = math.min(player.health + self.volume, 10)
        end
    }
end

function itemWeapon(x, y)
    return {
        x = x,
        y = y,
        volume = 5,
        width = 50,
        height = 50,

        update = function(self, dt)
            self.y = self.y + ground.speed * dt
        end,

        draw = function(self, dt)
            cx = self.x + self.width / 2
            cy = self.y + self.height / 2
            love.graphics.setColor(1, 0, 1)
            love.graphics.circle("fill", cx, cy, self.width / 2)
            love.graphics.setColor(0.8, 0, 0.8)
            love.graphics.circle("fill", cx, cy, self.width / 2 - 8)
            love.graphics.setColor(0, 0, 0)
            love.graphics.circle("line", cx, cy, self.width / 2)
        end,

        apply = function(self)
            player.weapon = RandomWeapon()
        end
    }
end


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

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local clouds = {}
    local cloudSprite = {
        image = love.graphics.newImage("sprites/cloud.png"),
        width = 64,
        height = 64,
    }
    local cloudCount = 8
    for i = 1, cloudCount do
        local c = {
            x = math.random(screenWidth),
            y = math.random(screenHeight),
            speed = math.random(512, 1536),
            scale = math.random(2, 4),
        }
        table.insert(clouds, c)
    end

    local explosions = {}
    local missiles = {}
    local enemies = {}
    local items = {}

    return {
        player = player,
        enemies = enemies,
        missiles = missiles,
        items = items,

        update = function(self, dt)
            for key, cloud in pairs(clouds) do
                cloud.y = cloud.y + cloud.speed * dt
                if cloud.y > screenHeight then
                    cloud.x = math.random(screenWidth - cloudSprite.width * cloud.scale)
                    cloud.y = math.random(-screenHeight, - cloudSprite.height * cloud.scale)
                end
            end

            activeCount = 0
            for key, enemy in pairs(enemies) do
                if enemy and enemy.active then
                    activeCount = activeCount + 1
                    enemy:update(dt)
                else
                    enemies[key] = nil
                end
            end

            -- no more enemies left, respawn
            if activeCount == 0 then
                self:addEnemies(math.random(1, 10))
            end

            -- move existing missiles
            for key, msl in pairs(missiles) do
                if msl and msl.active then
                    msl.y = msl.y + msl.speed * dt

                    -- enemy missiles can hurt other enemies, too
                    for key, enemy in pairs(enemies) do
                        if enemy and enemy.active and msl.owner ~= enemy then
                            if collision(msl, enemy) then
                                enemy:hit(msl)
                                break
                            end
                        end
                    end

                    -- only enemy missiles can hurt the player
                    if not msl.ours and collision(msl, player) then
                        player:hit(msl)
                    end

                    if msl.y < 0 or msl.y > screenHeight then
                        msl.active = false
                    end
                else
                    missiles[key] = nil
                end
            end

            -- update items, which move at the same speed as the ground
            local itemCount = 0
            for key, item in pairs(items) do
                if item then
                    itemCount = itemCount + 1
                    item:update(dt)

                    if player.active and collision(item, player) then
                        item:apply()
                        items[key] = nil
                    end

                    if item.y > love.graphics.getHeight() then
                        items[key] = nil
                    end
                end
            end

            --
            -- Give the player more ammo if they've run out
            --
            if itemCount == 0 and player.ammo <= 0 and math.random() > 0.99 then
                self:addItem(math.random(love.graphics.getWidth()), 0, "ammo")
            end

            -- update explosions
            for key, expl in pairs(explosions) do
                if expl and expl.active then
                    expl.frame = expl.frame + expl.speed * dt
                    if expl.frame > #boomSprite.quads then
                        -- show's over, hide and disable whatever exploded
                        expl.active = false
                        expl.thing.active = false
                    end
                else
                    explosions[key] = nil
                end
            end


        end,

        draw = function(self)
            love.graphics.setColor(1, 1, 1)
            for key, cloud in pairs(clouds) do
                love.graphics.draw(cloudSprite.image, cloud.x, cloud.y, 0, cloud.scale)
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
                player:draw()
            end

            for key, enemy in pairs(enemies) do
                if enemy and enemy.active then
                    enemy:draw()
                end
            end

            for key, msl in pairs(missiles) do
                if msl and msl.active and msl.ours then
                    love.graphics.setColor(1, 0, 0)
                    love.graphics.rectangle("fill", msl.x, msl.y, msl.width, msl.height)
                elseif msl and msl.active then
                    love.graphics.setColor(0, 0, 1)
                    love.graphics.rectangle("fill", msl.x, msl.y, msl.width, msl.height)
                end
            end

            -- Nb. this must happen _after_ the player etc. have been drawn
            for key, expl in pairs(explosions) do
                if expl and expl.active then
                    love.graphics.setColor(expl.color[1], expl.color[2], expl.color[3])
                    love.graphics.draw(
                        boomSprite.image,
                        boomSprite.quads[math.floor(expl.frame)],
                        expl.x - 5 * 32,
                        expl.y - 5 * 32,
                        0,
                        10
                    )
                end
            end

            for key, item in pairs(items) do
                if item then
                    item:draw()
                end
            end
        end,

        addExplosion = function(self, x, y, color)
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
            --
            -- TODO: pick a safe place to add the new enemy
            --
            local spacing = love.graphics.getWidth() / (number + 1)
            for i = 1, number do
                local enemy = self.addEnemy()
                enemy.x = i * spacing + math.random(-32, 32)
                enemy.triggerHappiness = love.math.random()
            end
        end,

        addMissile = function(self, x, y, ours)
            local msl = fire(x, y)
            msl.ours = ours
            msl.speed = 1000
            if ours then
                msl.speed = -1000
            end
            table.insert(missiles, msl)
            return msl
        end,

        addItem = function(self, x, y, kind)
            if kind == "ammo" then
                table.insert(items, itemAmmo(x, y))
            elseif kind == "health" then
                table.insert(items, itemHealth(x, y))
            elseif kind == "weapon" then
                table.insert(items, itemWeapon(x, y))
            end
        end,
    }
end

return Air
