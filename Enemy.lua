local enemyUpdate = function(self, dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    --
    -- if the player has merged with us, GTFO
    -- if we're stalking, then edge towards the player
    -- if we're evasive and being fired upon, move away
    --
    self.y = self.y + self.speed * dt
    if self.y + self.width > player.y then
        local x = self.x - (player.x - self.x) * dt
        if self.stupid or self:checkSafe(x, self.y) then
            self.x = x
        end

        self.speed = self.speed * 1.1
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
        end
    end

    --
    -- we've moved off-screen, teleport to a new position
    --
    if self.x < 0 or self.x > screenWidth or self.y > screenHeight then
        self.y = math.random(-256, -128)
        self.x = math.random(screenWidth)
        self.speed = math.random(100, 250)
    end

    --
    -- fire ze missiles
    --
    if self.y > 0 and self.lastMissile < now - self.reloadTime then
        if player.active and love.math.random() < self.triggerHappiness then
            self.lastMissile = now
            air:addMissile(self.x + self.width / 2, self.y + self.height, false)
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
        end,

        hit = function(self, msl)
            msl.active = false
            self.health = self.health - 1
            air:addExplosion(msl.x, msl.y)
            if self.health <= 0 then
                destroy(self)
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
    }
end

return Enemy
