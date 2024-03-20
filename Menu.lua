function Button(x, y, tox, toy, text, fn, fnargs)
    return {
        x = x,
        y = y,
        tox = tox,
        toy = toy,
        text = text,
        width = 200,
        height = 50,
        selcolor = {1.0, 0.5, 0.5},
        bgcolor = {0.7, 0.7, 0.7},
        fgcolor = {0, 0, 0},
        font = love.graphics.newFont("fonts/FreeMono.ttf", 20),
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

local menuChangeMap = function()
    print("change map")
end

local menuOptionsBack = function()
    _G.menu.screen = "main"
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

    local lastEvent = love.timer.getTime()
    local buttons = {}
    buttons["main"] = {}
    buttons["options"] = {}

    table.insert(
        buttons["main"],
        Button(100, 100, 10, 15, "Полетели!", menuHide)
    )
    table.insert(
        buttons["main"],
        Button(100, 200, 10, 15, "Настройки", menuOptions)
    )
    table.insert(
        buttons["main"],
        Button(100, 300, 10, 15, "Выйти", love.event.quit)
    )

    local changePlane = function()
        currentPlane = currentPlane + 1
        if currentPlane > #planes then
            currentPlane = 1
        end
    end

    table.insert(
        buttons["options"],
        Button(100, 100, 10, 15, "Сменить самолёт", changePlane)
    )
    table.insert(
        buttons["options"],
        Button(100, 200, 10, 15, "Сменить карту", menuOptionsChangeMap)
    )
    table.insert(
        buttons["options"],
        Button(100, 300, 10, 15, "Назад", menuOptionsBack)
    )

    local sel = {}
    sel["main"] = 1
    sel["options"] = 1

    local labels = {}
    labels["main"] = {}
    labels["options"] = {}

    --
    -- Hacky: labels are just buttons that we never select
    --
    local lblCurrentPlane = Button(400, 100, 10, 15, planes[currentPlane])
    lblCurrentPlane.width = 400
    table.insert(labels["options"], lblCurrentPlane)
    table.insert(
        labels["options"],
        Button(400, 200, 10, 15, "TODO")
    )

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

            local now = love.timer.getTime()
            if now - lastEvent < 0.1 then
                return
            end
            lastEvent = now

            if love.keyboard.isDown("down") then
                sel[self.screen] = sel[self.screen] + 1
            elseif love.keyboard.isDown("up") then
                sel[self.screen] = sel[self.screen] - 1
            end

            if sel[self.screen] > #buttons[self.screen] then
                sel[self.screen] = 1
            elseif sel[self.screen] < 1 then
                sel[self.screen] = #buttons[self.screen]
            end

            if love.keyboard.isDown("space") or love.keyboard.isDown("return") then
                local idx = sel[self.screen]
                local btn = buttons[self.screen][idx]
                if btn.fn then
                    btn.fn(btn.fn_args)
                end
            end
        end,

        getCurrentPlane = function(self) return planes[currentPlane] end,
    }
end


return Menu
