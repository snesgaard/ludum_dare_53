local drawable = {}

function drawable.post(id)
    gfx.push("all")

    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)

    local w, h = painter.relative(0.075, 0.3)
    gfx.circle("fill", 0, 0, 2)
    gfx.rectangle("line", spatial(-w / 2, -h, w, h):unpack())
    
    gfx.pop()
    return w, h
end

function drawable.costumer(id)
    local w, h = drawable.post(id)

    gfx.push("all")
    nw.drawable.push_transform(id)
    
    local desire = stack.get(nw.component.customer_desire, id)
    local timer = game.system.customer.get_timer(id)
    if not desire or not timer then return gfx.pop() end
    
    gfx.translate(0, -h - 2)
    local timer_shape = spatial():expand(20 * timer:normalized(), 1)
    gfx.rectangle("fill", timer_shape:unpack())
    gfx.translate(0, -4)
    painter.draw_food(desire)


    gfx.pop()
end

function drawable.player(id)
    gfx.push("all")

    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)

    local frame = get_atlas("art/characters"):get_frame("bartender")
    frame:draw("body", 0, 0)
    
    local stack_slice = frame:get_slice("stack", "body")
    
    gfx.translate(stack_slice:centerbottom():unpack())
    drawable.food_stack(id)

    gfx.pop()
end

function drawable.food_stack(id)
    local food_stack = stack.get(nw.component.food_stack, id) or list()
    gfx.push("all")

    for index, food in ipairs(food_stack) do
        painter.draw_food(food)
        gfx.translate(0, -14)
    end

    gfx.pop()
end

function drawable.food_store(id)
    gfx.push("all")

    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)

    gfx.pop()
end

function drawable.frame(id)
    local frame = stack.get(nw.component.frame, id)
    if not frame then return end

    gfx.push("all")

    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)
    frame:draw()

    gfx.pop()
end

return drawable