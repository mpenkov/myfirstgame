function Button(x, y, tox, toy, text, fn, fnargs)
    return {
        x = x,
        y = y,
        tox = tox,
        toy = toy,
        text = text,
        width = 400,
        height = 75,
        selcolor = {1.0, 0.5, 0.5},
        bgcolor = {0.7, 0.7, 0.7},
        fgcolor = {0, 0, 0},
        font = love.graphics.newFont("fonts/FreeMono.ttf", 32),
        selected = false,
        fn = fn,
        fn_args = fn_args,

        draw = function(self)
            local bgcolor = self.bgcolor
            if self.selected then
                bgcolor = self.selcolor
            end
            love.graphics.setColor(bgcolor[1], bgcolor[2], bgcolor[3])
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

            love.graphics.setColor(self.fgcolor[1], self.fgcolor[2], self.fgcolor[3])
            text = love.graphics.newText(self.font, self.text)
            love.graphics.draw(text, self.x + self.tox, self.y + self.toy)
        end,

        update = function(self, dt)
        end,
    }
end

local menuHide = function()
    _G.menu.show = false
end

local menuOptions = function()
    _G.menu.screen = "options"
end

local menuOptionsBack = function()
    _G.menu.screen = "main"
end

local spaceVertically = function(buttons, spacing)
    local nextY = buttons[1].y
    for num, btn in pairs(buttons) do
        btn.x = buttons[1].x
        btn.y = nextY
        btn.width = buttons[1].width
        btn.height = buttons[1].height
        nextY = nextY + btn.height + spacing
    end
end

local label = function(x, y, text)
    --
    -- Hacky: labels are just buttons that we never select
    --
    local lbl = Button(x, y, 10, 15, text)
    lbl.width = 600
    lbl.fgcolor = {1, 1, 1}
    lbl.bgcolor = {0.2, 0.2, 0.2}
    return lbl
end

local wrap = function(value, max)
    if value > max then
        return 1
    elseif value < 1 then
        return max
    end
    return value
end

function Menu()
    local planes = {}
    for key, val in pairs(_G.planes) do
        table.insert(planes, key)
    end
    local currentPlane = 1
    for key, val in pairs(planes) do
        if val == "Су-27" then
            currentPlane = key
            break
        end
    end

    local maps = {}
    for key, val in pairs(_G.terrain) do
        table.insert(maps, key)
    end
    local currentMap = 1

    local lastEvent = love.timer.getTime()
    local buttons = {}
    local spacing = 20
    buttons["main"] = {}
    buttons["options"] = {}

    local btnGo = Button(100, 100, 10, 15, "Полетели!", menuHide)
    local btnOptions = Button(0, 0, 10, 15, "Настройки", menuOptions)
    local btnQuit = Button(0, 0, 10, 15, "Выйти", love.event.quit)

    table.insert(buttons["main"], btnGo)
    table.insert(buttons["main"], btnOptions)
    table.insert(buttons["main"], btnQuit)
    spaceVertically(buttons["main"], spacing)

    local changePlane = function() currentPlane = wrap(currentPlane + 1, #planes) end
    local changeMap = function() currentMap = wrap(currentMap + 1, #maps) end
    local toggleSound = function() sfx.enabled = not sfx.enabled end

    local btnChangePlane = Button(btnGo.x, btnGo.y, 10, 15, "Сменить самолёт", changePlane)
    local btnChangeMap = Button(0, 0, 10, 15, "Сменить карту", changeMap)
    local btnToggleSound = Button(0, 0, 10, 15, "Звук", toggleSound)

    local btnOptionsBack = Button(0, 0, 10, 15, "Назад", menuOptionsBack)

    table.insert(buttons["options"], btnChangePlane)
    table.insert(buttons["options"], btnChangeMap)
    table.insert(buttons["options"], btnToggleSound)
    table.insert(buttons["options"], btnOptionsBack)
    spaceVertically(buttons["options"], spacing)

    local sel = {}
    sel["main"] = 1
    sel["options"] = 1

    local labels = {}
    labels["main"] = {}
    labels["options"] = {}

    local lblCurrentPlane = label(btnGo.x + btnGo.width + spacing, btnGo.y, planes[currentPlane])
    local lblCurrentMap = label(0, 0, maps[currentMap])
    local lblSound = label(0, 0, "")

    table.insert(labels["options"], lblCurrentPlane)
    table.insert(labels["options"], lblCurrentMap)
    table.insert(labels["options"], lblSound)
    spaceVertically(labels["options"], spacing)

    return {
        show = true,
        screen = "main",
        buttons = buttons,

        draw = function(self)
            for key, btn in pairs(buttons[self.screen]) do
                btn.selected = key == sel[self.screen]
                btn:draw()
            end

            for key, lbl in pairs(labels[self.screen]) do
                lbl:draw()
            end
        end,

        update = function(self, dt)
            lblCurrentPlane.text = planes[currentPlane]
            lblCurrentMap.text = maps[currentMap]
            if sfx.enabled then
                lblSound.text = "Включить"
            else
                lblSound.text = "Выключить"
            end
        end,

        keypressed = function(self, key, scancode, isrepeat)
            --
            -- these keys get handled uniformly across all screens
            --
            if key == "down" then
                sel[self.screen] = wrap(sel[self.screen] + 1, #buttons[self.screen])
                sfx:playEffect("ping")
            elseif key == "up" then
                sel[self.screen] = wrap(sel[self.screen] - 1, #buttons[self.screen])
                sfx:playEffect("ping")
            elseif key == "space" or key == "return" then
                local idx = sel[self.screen]
                local btn = buttons[self.screen][idx]
                if btn.fn then
                    btn.fn(btn.fn_args)
                    sfx:playEffect("ping")
                end
            end

            --
            -- screen-specific shortcuts
            --
            if self.screen == "main" then
                if key == "escape" then
                    menuHide()
                    sfx:playEffect("ping")
                end
            elseif self.screen == "options" then
                if key == "escape" then
                    menuOptionsBack()
                    sfx:playEffect("ping")
                end
            end
        end,

        getCurrentPlane = function(self) return planes[currentPlane] end,
        getCurrentMap = function(self) return maps[currentMap] end,
    }
end


return Menu
