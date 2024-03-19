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
            for key, crater in pairs(craters) do
                if crater.active then
                    crater.frame = crater.frame + crater.speed * dt
                    if crater.frame > #boomSprite.quads then
                        -- show's over, hide and disable whatever exploded
                        crater.active = false
                    end

                    crater.y = crater.y + bg.speed * dt
                    if crater.y > screenHeight then
                        crater.active = false
                    end
                else
                    craters[key] = nil
                end
            end
        end,

        draw = function(self)
            love.graphics.setColor(1, 1, 1)

            -- the -128 is so that part of the background is always off-screen,
            -- otherwise we get a flickering black band
            love.graphics.draw(bg.batch, 0, bg.y - 128)

            for key, crater in pairs(craters) do
                if crater and crater.active and crater.frame >= 1 then
                    love.graphics.draw(
                        boomSprite.image,
                        boomSprite.quads[math.floor(crater.frame)],
                        crater.x - 32,
                        crater.y - 32,
                        0,
                        2
                    )
                end
            end

        end,

        -- add some secondary explosions on the ground
        addCraters = function(self, x, y, offset)
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
