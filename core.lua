-- this is a separate file so that tests can require it without loading love

function boom(thing)
    return {
        x = thing.x,
        y = thing.y,
        thing = thing,
        active = true,
        frame = 1,
        speed = 30,
        color = {1, 0.8, 0.8},
    }
end

function fire(x, y, speed)
    return {
        x = x,
        y = y,
        width = 5,
        height = 20,
        speed = speed,
        active = true,
        exploded = false,
        explodedTime = nil,
        explosionRadius = 0,
    }
end

function xcollision(a, b)
    -- TODO: shrink the hitboxes a little bit
    local horizontal = false
    if a.x < b.x then
        horizontal = (a.x + a.width) >= b.x
    else
        horizontal = (b.x + b.width) >= a.x
    end
    return horizontal
end

function collision(a, b)
    -- TODO: shrink the hitboxes a little bit
    local horizontal = false
    if a.x < b.x then
        horizontal = (a.x + a.width) >= b.x
    else
        horizontal = (b.x + b.width) >= a.x
    end

    local vertical = false
    if a.y < b.y then
        vertical = (a.y + a.height) >= b.y
    else
        vertical = (b.y + b.height) >= a.y
    end

    return horizontal and vertical
end
