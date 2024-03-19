function Ground(backgroundFilename)
    backgroundFilename = backgroundFilename or "sprites/green.png" 
    bg = {
        image = love.graphics.newImage(backgroundFilename),
        y = 0,
        speed = 500,
    }
    bg.batch = love.graphics.newSpriteBatch(bg.image)
    for i = 1, 16 do
        for j = 1, 16 do
            bg.batch:add((i - 1) * 128, (j - 1) * 128)
        end
    end

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

    craters = {}
    return {
        update = function(self, dt)
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()

            bg.y = (bg.y + bg.speed * dt) % 128

            -- update craters, which move at the same speed as the background
            numActive = 0
            for i = 1, #craters do
                local c = craters[i]
                if c.active then
                    numActive = numActive + 1
                    c.frame = c.frame + c.speed * dt
                    if c.frame > #boomSprite.quads then
                        -- show's over, hide and disable whatever exploded
                        c.active = false
                    end

                    c.y = c.y + bg.speed * dt
                    if c.y > screenHeight then
                        c.active = false
                    end
                end
            end
            if numActive == 0 then
                craters = {}
            end
        end,

        draw = function(self)
            love.graphics.setColor(1, 1, 1)

            -- the -128 is so that part of the background is always off-screen,
            -- otherwise we get a flickering black band
            love.graphics.draw(bg.batch, 0, bg.y - 128)

            for i = 1, #craters do
                local c = craters[i]
                if c.active and c.frame >= 1 then
                    love.graphics.draw(
                        boomSprite.image,
                        boomSprite.quads[math.floor(c.frame)],
                        c.x - 32,
                        c.y - 32,
                        0,
                        2
                    )
                end
            end

        end,

        -- add some secondary explosions on the ground
        markCrashSite = function(self, x, y, offset)
            offset = offset or 32
            for k = 1, math.random(1, 5) do
                local point = {
                    x = x + offset * math.random(-1, 1),
                    y = y + offset * math.random(-1, 1),
                }
                local gexpl = boom(point)
                gexpl.frame = math.random(-3, -2)
                gexpl.speed = 3.5
                table.insert(craters, gexpl)
            end
        end,
    }
end

return Ground
