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

local function food_store_frame(food_store_type)
    local atlas = get_atlas("art/characters")
    if food_store_type == constant.food.pizza then
        return atlas:get_frame("stores/beer")
    elseif food_store_type == constant.food.wine then
        return atlas:get_frame("stores/wine")
    end
end

function drawable.food_store(id)
    gfx.push("all")

    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)
    local frame = food_store_frame(stack.get(nw.component.food_store, id))
    if frame then
        frame:draw("body")
    else
        local w, h = 64, 64
        gfx.rectangle("line", -w / 2, -h, w, h)
    end

    gfx.pop()
end

local function draw_patron(patron_type)
    if patron_type == constant.patron.wizard then
        local frame = get_atlas("art/characters"):get_frame("patrons/wizard")
        frame:draw("body")
        local _, _, w, h = frame.quad:getViewport()
        return w, h
    elseif patron_type == constant.patron.orc then
        local frame = get_atlas("art/characters"):get_frame("patrons/orc")
        frame:draw("body")
        local _, _, w, h = frame.quad:getViewport()
        return w, h
    else
        local w, h = 64, 64
        gfx.rectangle("line", -w / 2, -h, w, h)
        return w, h
    end
end

local function anger_color(id, desire, timer)
    local e = ease.linear
    if not timer or not desire then
        gfx.setColor(1, 1, 1)
        return
    end

    local t = timer:inverse_normalized()
    local r = e(t, 1, 1 - 1, 1)
    local g = e(t, 1, 0.1 - 1, 1)
    local b = e(t, 1, 0.0 - 1, 1)
    gfx.setColor(r, g, b)
end

local function anger_shake(id, desire, timer)
    if not timer or not desire then return 0 end
    local e = ease.inQuad
    local t = timer:inverse_normalized()
    local amp = e(t, 0, 10, 1)
    local freq = e(t, 0, 200, 1)

    return amp * math.sin(timer.time * freq)
end 

function drawable.costumer(id)
    --local w, h = drawable.post(id)
    local desire = stack.get(nw.component.customer_desire, id)
    local timer = game.system.customer.get_timer(id)
    if not desire then return end

    gfx.push("all")
    nw.drawable.push_transform(id)

    anger_color(id, desire, timer)
    gfx.translate(anger_shake(id, desire, timer), 0)
    local _, h = draw_patron(stack.get(nw.component.patron, id) or constant.patron.orc)
    
    if not desire or not timer then return gfx.pop() end
    
    gfx.setColor(1, 1, 1)
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

function drawable.frame(id)
    local frame = stack.get(nw.component.frame, id)
    if not frame then return end

    gfx.push("all")

    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)
    frame:draw()

    gfx.pop()
end

local function draw_flash(id)
    if nw.system.timer.is_done(id) then return end
    gfx.circle("fill", 0, 0, 30)
end

local function draw_particles(id)
    local p = stack.get(nw.component.particles, id)
    if not p then return end
    gfx.draw(p, 0, 0)
end

function drawable.explosion(id)
    gfx.push("all")

    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)

    draw_particles(id)
    draw_flash(id)

    gfx.pop()
end

function drawable.menu(id)
    local menu_state = stack.get(nw.component.menu, id)
    if not menu_state then return end

    gfx.push("all")

    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)

    local box = spatial():expand(64, 16)

    local text_opt = {
        align = "center",
        valign = "center",
        font = painter.font(32)
    }

    for index, key in ipairs(menu_state.items) do
        gfx.setColor(0.1, 0.2, 0.8, 0.6)
        gfx.rectangle("fill", box:unpack(5))
        
        if index == menu_state.index then
            gfx.setColor(0.8, 0.8, 0.2)
            local mode = menu_state.done and "fill" or "line"
            gfx.rectangle(mode, box:unpack(5))
        end

        if index == menu_state.index and menu_state.done then
            gfx.setColor(0.1, 0.2, 0.4)
        else
            gfx.setColor(1, 1, 1)
        end
        painter.draw_text(key, box, text_opt)

        box = box:down(0, 5)
    end

    gfx.pop()
end

function drawable.text_box(id)
    gfx.push("all")
    
    nw.drawable.push_transform(id)
    nw.drawable.push_state(id)

    local text_opt = {
        align = stack.get(nw.component.align, id),
        valign = stack.get(nw.component.valign, id),
        font = stack.get(nw.component.font, id),
    }

    local area = stack.ensure(nw.component.gui_box, id)
    local text = stack.ensure(nw.component.text, id)
    gfx.setColor(0.1, 0.2, 0.8, 0.6)
    gfx.rectangle("fill", area:unpack(5))
    gfx.setColor(1, 1, 1)
    painter.draw_text(text, area, text_opt)

    gfx.pop()
end

return drawable