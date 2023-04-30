local component = {}

function component.is_post() return true end

function component.customer_desire(desire) return desire end

function component.customer_result(success) return success end

function component.customer_spawn_setting(min_duration, max_duration)
    return {
        duration_min = min_duration,
        duration_max = max_duration or min_duration
    }
end

function component.customer_timer(duration_min, duration_max, scale)
    local scale = scale or 1
    local duration = love.math.random(duration_min, duration_max) * scale
    local id = nw.ecs.id.weak("spawn_timer")
    stack.set(nw.component.timer, id, duration)
    return id
end

function component.layer(layer) return layer or 0 end

function component.food_stack(stack) return stack or list() end

function component.food_store(food) return food end

function component.score(s) return s or 0 end

function component.life(s) return s or constant.max_lives end

function component.time(t) return t or 0 end

function component.patron(patron) return patron end

function component.menu(items, init)
    return {
        items = items,
        index = init
    }
end

function component.main_menu_action() return true end

function component.gui_box(x, y, w, h) return spatial(x, y, w, h) end

function component.text(t) return t end

function component.focus() return true end

return component