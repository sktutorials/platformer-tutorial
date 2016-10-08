local timer = {timers = {}}

function timer.create(timer_length, thunk, ...)
    local t = {
        initial_time = timer_length,
        time = timer_length,
        state = {...},
        thunk = thunk
    }
    table.insert(timer.timers, t)
    return t
end

function timer.update(dt)
    for i=1, #timer.timers do
        local t = timer.timers[i]
        if t.time <= 0 then
            t.state = {t.thunk(unpack(t.state))}
            if t.state[1] then
                t.time = t.initial_time
            else
                table.remove(timer.timers, i)
            end
            table.remove(t.state, 1)
        end
        t.time = t.time - dt
    end
end

setmetatable(timer, {__call = function(_, ...) timer.create(...) end})
return timer
