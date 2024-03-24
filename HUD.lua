function Bar(width, height, color, max)
    return {
        draw = function(self, x, y, val)
            val = math.min(max, val or 0)
            fillwidth = val / max * width
            love.graphics.setColor(color[1], color[2], color[3])
            love.graphics.rectangle("fill", x, y, fillwidth, height)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", x, y, width, height)
        end,

        update = function(self, dt)
        end,
    }
end

function HUD()
    ammoBar = Bar(200, 32, {1, 0, 0}, 100)
    healthBar = Bar(200, 32, {0, 1, 0}, 10)

    return {
        x = 0,
        y = 0,
        width = love.graphics.getWidth(),
        height = 40,
        font = fonts.large,

        update = function(self, dt)

        end,

        draw = function(self)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

            if player.ammo <= 10 then
                love.graphics.setColor(1, 0, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf("б/к:", self.font, self.x, self.y, 100, "right")
            ammoBar:draw(self.x + 100, self.y + 4, player.ammo)

            if player.health < 2 then
                love.graphics.setColor(1, 0, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf("броня:", self.font, self.x + 300, self.y, 200, "right")
            healthBar:draw(self.x + 500, self.y + 4, player.health)

            love.graphics.printf(
                "сбито: " .. _G.kills,
                self.font,
                love.graphics.getWidth() - 400,
                self.y,
                200,
                "left"
            )
            love.graphics.printf(
                "потери: " .. _G.losses,
                self.font,
                love.graphics.getWidth() - 200,
                self.y,
                200,
                "left"
            )
        end,
    }
end

return HUD
