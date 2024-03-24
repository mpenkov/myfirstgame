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
    local horizontal = false
    if a.x < b.x then
        horizontal = (a.x + a.width) >= b.x
    else
        horizontal = (b.x + b.width) >= a.x
    end
    return horizontal
end

function collision(a, b)
    --
    -- swap A and B if only B has detailed hitboxes.  This simplifies the
    -- logic below.
    --
    if not a.hitboxes and b.hitboxes then
        a, b = b, a
    end

    --
    -- Larger objects (like airplanes) have several hitboxes as opposed to a
    -- single large one.  This is because large areas correspond to empty
    -- space (e.g. front left and front right) and shouldn't contribute to a
    -- collision.
    --
    -- Smaller objects (e.g. missiles) don't have explicit hitboxes.  It's
    -- implicit that the entire area occupied by the object is the hitbox.
    --
    -- The below logic handles collisions between two large objects, or a
    -- a large object with a small object.
    --
    if a.hitboxes then
        for _, ahb in pairs(a.hitboxes) do
            hitboxA = {
                x = a.x + ahb.x,
                y = a.y + ahb.y,
                width = ahb.width,
                height = ahb.height,
            }

            if not b.hitboxes then
                if collision(hitboxA, b) then
                    return true
                end
            else
                for _, bhb in pairs(b.hitboxes) do
                    hitboxB = {
                        x = b.x + bhb.x,
                        y = b.y + bhb.y,
                        width = bhb.width,
                        height = bhb.height,
                    }
                    if collision(hitboxA, hitboxB) then
                        return true
                    end
                end
            end
        end
        return false
    end

    --
    -- The logic below handles collisions between two small objects
    --
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
