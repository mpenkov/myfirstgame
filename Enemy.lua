local enemyUpdate = function(self, dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    --
    -- if the player has merged with us, GTFO
    -- if we're stalking, then edge towards the player
    -- if we're evasive and being fired upon, move away
    --
    self.y = self.y + self.speed * dt
    if not player.active and self.y > 256 and self.speed > 0 then
        self:gtfo(dt)
    elseif self.y + self.width > player.y and self.speed > 0 then
        self:gtfo(dt)
    elseif self.stalker then
        local x = self.x + (player.x - self.x) * dt
        if self.stupid or self:checkSafe(x, self.y) then
            self.x = x
        end
    elseif self.evasive and self:incoming() < 2000 then
        local x = self.x - (player.x - self.x) * 2 * dt
        if self.stupid or self:checkSafe(x, self.y) then
            self.x = x
        end
    end

    --
    -- mid-air collision between enemies
    --
    for key, other in pairs(air.enemies) do
        if other and other.active and other ~= self and collision(self, other) then
            destroy(self)
            destroy(other)

            if math.random() > 0.5 then
                air:addItem(self.x, self.y)
            end
        end
    end

    --
    -- we've moved off-screen, teleport to a new position
    --
    local maxX, maxY = screenWidth - self.width, screenHeight - self.height
    if self.x < 0 or self.x > maxX or self.y > maxY then
        self.y = math.random(-256, -128)
        self.x = math.random(maxX)
        self.speed = math.random(100, 250)
    end

    --
    -- fire ze missiles
    --
    local now = love.timer.getTime()
    if self.y > 0 and self.lastMissile < now - self.reloadTime then
        if player.active and love.math.random() < self.triggerHappiness then
            self.lastMissile = now
            local msl = air:addMissile(self.x + self.width / 2, self.y + self.height, false)

            --
            -- Nb. prevent enemies from killing themselves by accelerating
            -- into missiles they have just fired
            --
            msl.owner = self
        end
    end
end

function Enemy()
    local sprite = love.graphics.newImage("sprites/f15-64.png")
    local spriteWidth = 64
    local spriteHeight = 64

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    return {
        x = screenWidth / 2,
        y = math.random(-512, -256),
        width = 128,
        height = 128,
        --
        -- enemy is upside down, so hitboxes are upside down, too
        --
        hitboxes = {
            {x = 48, y = 0, width = 32, height = 128},
            {x = 4, y = 0, width = 120, height = 64},
        },
        lastMissile = 0,
        reloadTime = 0.5,
        triggerHappiness = 0.25,
        active = true,
        health = 5,
        speed = math.random(100, 250),
        stalker = math.random() > 0.25,
        stupid = math.random() > 0.75,
        evasive = math.random() > 0.25,

        update = enemyUpdate,

        draw = function(self)
            local ox, oy = self.width/2, self.height/2
            local sx, sy = self.width/spriteWidth, self.height/spriteHeight

            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(sprite, self.x, self.y, math.pi, sx, sy, ox, oy)

            --[[
            local bubbles = (5 - self.health) * 3
            local radius = 3
            local intensity = 0.9
            local smoke_x = self.x + self.width / 2
            local smoke_y = self.y - self.height / 8

            for i = 1, bubbles do
                love.graphics.setColor(intensity, intensity, intensity)
                love.graphics.circle("line", smoke_x, smoke_y, radius)
                intensity = intensity - 0.1
                smoke_y = smoke_y - radius * 2
                radius = radius * 1.15
            end
            ]]
        end,

        hit = function(self, msl)
            msl.active = false
            self.health = self.health - 1
            air:addExplosion(msl.x, msl.y)
            if self.health <= 0 then
                _G.kills = _G.kills + 1
                destroy(self)
                sfx:playEffect("enemy_destroyed")

                if math.random() > 0.8 then
                    air:addItem(self.x, self.y, "health")
                elseif math.random() > 0.8 then
                    air:addItem(self.x, self.y, "ammo")
                end

                if _G.kills % 5 == 0 and _G.kills > 1 then
                    air:addItem(self.x, self.y, "weapon")
                end
            else
                sfx:playEffect("enemy_hit")
            end

        end,

        -- returns true if it's save for us to move to these co-ordinates
        -- avoids collisions with other enemies
        checkSafe = function(self, x, y)
            for key, other in pairs(air.enemies) do
                if other and self ~= other and other.active and xcollision(self, other) then
                    return false
                end
            end

            return true
        end,

        -- are we being fired upon?  Returns the y-distance to the missile
        incoming = function(self)
            local left = self.x - 16
            local right = self.x + self.width + 16
            for key, msl in pairs(air.missiles) do
                if msl and msl.active and msl.speed < 0 then
                    if msl.x > left and msl.x < right and msl.y > self.y then
                        dist = msl.y - self.y
                        return dist
                    end
                end
            end

            --
            -- something large enough to mean "no incoming missile"
            --
            return 1000000
        end,

        -- leave the game area with speed
        gtfo = function(self, dt)
            local x = self.x - (player.x - self.x) * dt
            if self:checkSafe(x, self.y) then
                self.x = x
            end
            self.speed = self.speed * 1.1
        end,
    }
end

return Enemy
