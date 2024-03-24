function SFX()
    local sfx = {}
    sfx["player_fire"] = love.audio.newSource("sounds/gunfire 1.ogg", "static")
    sfx["enemy_destroyed"] = love.audio.newSource("sounds/explosion 2.ogg", "static")
    sfx["player_destroyed"] = love.audio.newSource("sounds/explosion 3.ogg", "static")
    sfx["player_hit"] = love.audio.newSource("sounds/dull thud.ogg", "static")
    sfx["enemy_hit"] = love.audio.newSource("sounds/ding.ogg", "static")
    sfx["alarm"] = love.audio.newSource("sounds/alarm.ogg", "static")
    sfx["ping"] = love.audio.newSource("sounds/ping.ogg", "static")
    sfx["kachink"] = love.audio.newSource("sounds/kachink.ogg", "static")
    return {
        enabled = true,
        playEffect = function(self, name)
            if not self.enabled then
                return
            end
            local effect = sfx[name]
            if effect then
                if effect:isPlaying() then
                    effect:stop()
                end
                effect:play()
            end
        end,

        stopEffect = function(self, name)
            if not self.enabled then
                return
            end
            if sfx[name]:isPlaying() then
                sfx[name]:stop()
            end
        end,
    }
end

return SFX
