function HUD()
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

            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(
                "б/к: " .. player.ammo,
                self.font,
                self.x,
                self.y,
                200,
                "left"
            )

            love.graphics.printf(
                "броня: " .. player.health,
                self.font,
                self.x + 200,
                self.y,
                200,
                "left"
            )

            love.graphics.printf(
                "сбито: " .. _G.kills,
                self.font,
                self.x + 400,
                self.y,
                200,
                "left"
            )
        end,
    }
end

return HUD
