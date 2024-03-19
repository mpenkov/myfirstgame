function Enemy()
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

        update = function(self, dt)
            -- if the player has merged with us, GTFO
            self.y = self.y + self.speed * dt
            if self.y > player.y then
                self.speed = self.speed * 1.1
                self.x = self.x - (player.x - self.x) * dt
            end

            --
            -- edge towards the player, unless we get in someone else's way (or the
            -- other way around
            --
            oldX = self.x
            if self.stalker then
                self.x = oldX + (player.x - self.x) * dt
            end

            for j = 1, #air.enemies do
                local other = air.enemies[j]
                if i ~= j and other.active and xcollision(self, other) then
                    self.x = oldX
                    break
                end
            end

            if self.x < 0 or self.x > love.graphics.getWidth() or self.y > love.graphics.getHeight() then
                self.y = math.random(-256, -128)
                self.x = math.random(love.graphics.getWidth())
                self.speed = math.random(100, 250)
            end

            if self.y > 0 and self.lastMissile < now - self.reloadTime then
                if player.active and love.math.random() < self.triggerHappiness then
                    self.lastMissile = now
                    air:addMissile(self.x + self.width / 2, self.y + self.height, false)
                end
            end
        end,

        draw = function(self)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.sprite, self.x, self.y, math.pi, 2, 2, self.width/2, self.height/2)
        end,

        hit = function(self, missile)
            if m.active then
                m.active = false
                self.health = self.health - 1
                print("hit " .. tostring(missile) .. " health " .. self.health)
                air:markExplosion(m.x, m.y)
                if self.health <= 0 then
                    destroy(self)
                end
            end
        end,
    }
end

return Enemy
