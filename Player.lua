function singleCannon()
    lastMissile = 0
    reloadTime = 0.15

    return {
        offset = 8,
        fire = function(self)
            local now = love.timer.getTime()
            if player.ammo > 0 and now - lastMissile > reloadTime then
                air:addMissile(player.x + player.width / 2 + self.offset, player.y, true)
                lastMissile = now
                player.ammo = player.ammo - 1

                sfx:playEffect("player_fire")
            end
        end
    }
end

function altCannon()
    hardpoint = 0
    lastMissile = 0
    reloadTime = 0.20

    return {
        offset = 8,
        fire = function(self)
            local now = love.timer.getTime()
            if player.ammo > 0 and now - lastMissile > reloadTime then
                local x = player.x + self.offset
                if hardpoint == 0 then
                    hardpoint = 1
                else
                    x = player.x + player.width - self.offset
                    hardpoint = 0
                end
                air:addMissile(x, player.y, true)
                lastMissile = now
                player.ammo = player.ammo - 1

                sfx:playEffect("player_fire")
            end
        end,
    }
end

function dualCannon()
    lastMissile = 0
    reloadTime = 0.4

    return {
        offset = 24,
        fire = function(self)
            local now = love.timer.getTime()
            if player.ammo > 0 and now - lastMissile > reloadTime then
                local x1 = player.x + self.offset
                local x2 = player.x + player.width - self.offset
                air:addMissile(x1, player.y, true)
                air:addMissile(x2, player.y, true)
                lastMissile = now
                player.ammo = player.ammo - 2

                sfx:playEffect("player_fire")
            end
        end,
    }
end

function tripleCannon()
    lastMissile = 0
    reloadTime = 0.6

    return {
        offset = 28,
        fire = function(self)
            local now = love.timer.getTime()
            if player.ammo > 0 and now - lastMissile > reloadTime then
                local x1 = player.x + self.offset
                local x2 = player.x + player.width / 2
                local x3 = player.x + player.width - self.offset
                air:addMissile(x1, player.y, true)
                air:addMissile(x2, player.y, true)
                air:addMissile(x3, player.y, true)
                lastMissile = now
                player.ammo = player.ammo - 3

                sfx:playEffect("player_fire")
            end
        end,
    }
end

function RandomWeapon()
    -- TODO: make sure the new weapon is different from the current one
    dice = math.random(4)
    if dice < 1 then
        return singleCannon()
    elseif dice < 2 then
        return altCannon()
    elseif dice < 3 then
        return dualCannon()
    else
        return tripleCannon()
    end
end

function Player()
    local sprite = love.graphics.newImage("sprites/su27-64-camo.png")
    local spriteWidth = 64
    local spriteHeight = 64
    local defaultHealth = 5

    if false then
        defaultHealth = 10000
    end

    width, height = 128, 128

    return {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() - height * 2,
        width = width,
        height = height,
        --
        -- There are two hitboxes, one for the fuselage (lengthwise) and one
        -- for the wings (breadthwise).
        --
        hitboxes = {
            {x = 48, y = 0, width = 32, height = 128},
            {x = 4, y = 64, width = 120, height = 64},
        },
        speed = 500,
        ammo = 50,
        weapon = singleCannon(),
        health = defaultHealth,
        active = true,

        update = playerUpdate,

        draw = function(self)
            love.graphics.setColor(1, 1, 1)
            local sx = player.width / spriteWidth
            local sy = player.height / spriteHeight
            love.graphics.draw(sprite, self.x, self.y, 0, sx, sy)
        end,

        hit = function(self, missile)
            missile.active = false
            air:addExplosion(missile.x, missile.y, {1, 1, 0.8})

            self.health = math.max(0, self.health - 1)
            if self.health == 0 then
                _G.losses = _G.losses + 1
                destroy(self)
                sfx:playEffect("player_destroyed")
            else
                sfx:playEffect("player_hit")
            end

            if self.health == 1 then
                sfx:playEffect("alarm")
            end
        end,

        morph = function(self, key)
            local p = _G.planes[key]
            sprite = p.sprite
            spriteWidth = p.spriteWidth
            spriteHeight = p.spriteHeight
        end,

        respawn = function(self)
            self.x = love.graphics.getWidth() / 2
            self.y = love.graphics.getHeight() - 2*self.width
            self.active = true
            self.health = 5
            self.ammo = 50
            player.weapon = singleCannon()
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
    if love.keyboard.isDown("space") then
        player.weapon:fire()

    end

    -- collision between us and the enemy kills both
    for key, enemy in pairs(air.enemies) do
        if enemy and enemy.active and player.active and collision(player, enemy) then
            _G.kills = _G.kills + 1
            _G.losses = _G.losses + 1
            destroy(player)
            destroy(enemy)
            sfx:playEffect("player_destroyed")
        end
    end
end

return Player
