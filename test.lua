require "core"

-- poor man's test framework

function test_collision(name)
    test_cases = {
        {
            a = {x = 10, y = 0, width = 10, height = 10},
            b = {x = 0, y = 0, width = 20, height = 10},
            want = true,
        },
        {
            a = {x = 100, y = 0, width = 10, height = 10},
            b = {x = 0, y = 0, width = 20, height = 10},
            want = false,
        },
    }
    for i = 1, #test_cases do
        local tc = test_cases[i]
        local got = collision(tc.a, tc.b)
        ass(got == tc.want, "%s[%d]: want: %s got: %s", name, i, tc.want, got)
    end
end

function ass(thing, template, ...)
    if not thing then
        print(string.format(template, ...))
    end
end

for key, item in pairs(_G) do
    if type(item) == "function" and string.find(key, "^test") then
        item(key)
    end
end
