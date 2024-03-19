function Player()
    return {
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

        update = playerUpdate,

        draw = function(self)
            love.graphics.setColor(1, 1, 1)
            local sx = player.width / player.spriteWidth
            local sy = player.height / player.spriteHeight
            love.graphics.draw(player.sprite, player.x, player.y, 0, sx, sy)
        end,

        hit = function(self, missile)
            missile.active = false
            air:markExplosion(missile.x, missile.y, {1, 1, 0.8})

            self.health = self.health - 1
            if self.health <= 0 then
                destroy(self)
            end
        end,
    }
end

-- Make this a separate function for readability (don't want excess indentation levels)
-- If we do things this way, we won't have access to any of the "private" vars.
function playerUpdate(self, dt)
    if love.keyboard.isDown("left") then
        self.x = self.x - dt * self.speed
    end

    if love.keyboard.isDown("right") then
        self.x = self.x + dt * self.speed
    end

    self.x = math.max(self.x, 0)
    self.x = math.min(self.x, love.graphics.getWidth() - self.width)

    if love.keyboard.isDown("up") then
        self.y = self.y - dt * self.speed
    end

    if love.keyboard.isDown("down") then
        self.y = self.y + dt * self.speed
    end

    self.y = math.max(self.y, 0)
    self.y = math.min(self.y, love.graphics.getHeight() - self.height)

    -- fire ze missiles
    now = love.timer.getTime()
    if love.keyboard.isDown("space") and now - self.lastMissile > self.reloadTime then
        local x = self.x
        if self.hardpoint == 0 then
            self.hardpoint = 1
        else
            x = self.x + self.width
            self.hardpoint = 0
        end
        air:addMissile(x, self.y + self.width, true)
        self.lastMissile = now
    end

    -- collision between us and the enemy kills both
    for i = 1, #air.enemies do
        local e = air.enemies[i]
        if e.active and collision(player, e) then
            destroy(player)
            destroy(e)
        end
    end
end

return Player
