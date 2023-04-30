local painter = {}

painter.scale = 4

painter.layer = {
    background = -1,
    post = 0,
    desk = 1,
    post_front = 2,
    player = 3,
    post_ui = 4
}

function painter.screen_size()
    return gfx.getWidth() / painter.scale, gfx.getHeight() / painter.scale
end

function painter.relative(rx, ry)
    local w, h = painter.screen_size()
    return w * rx, h * ry
end

local function sort_drawers(a, b)
    local layer_a = stack.get(nw.component.layer, a) or 0
    local layer_b = stack.get(nw.component.layer, b) or 0

    if layer_a ~= layer_b then return layer_a < layer_b end

    local pos_a = stack.ensure(nw.component.position, a)
    local pos_b = stack.ensure(nw.component.position, b)

    return pos_a.x < pos_b.x
end

local function draw_entity(ids)
    for _, id in ipairs(ids) do
        local drawable = stack.get(nw.component.drawable, id)
        if drawable then drawable(id) end
    end
end

painter.food_shape = spatial(-3, -6, 6, 6) 

function painter.draw_food(food, x, y)
    local x, y = x or 0, y or 0
    gfx.push("all")
    gfx.translate(x, y)

    if food == constant.food.pizza then
        local frame = get_atlas("art/characters"):get_frame("props/beer")
        frame:draw("body")
    elseif food == constant.food.salad then
        local frame = get_atlas("art/characters"):get_frame("props/salad")
        frame:draw("body")
    elseif food == constant.food.tomato then
        gfx.setColor(1, 0, 0)
        gfx.translate(0, -painter.food_shape.h / 2)
        gfx.ellipse("fill", 0, 0, painter.food_shape.w / 2, painter.food_shape.h / 2)
    elseif food == constant.food.wine then
        local frame = get_atlas("art/characters"):get_frame("props/wine")
        frame:draw("body")
    else
        gfx.setColor(1, 1, 1)
        gfx.rectangle("fill", painter.food_shape:unpack())
    end

    gfx.pop()
end

local function remove_hidden(id)
    return not stack.get(nw.component.hidden, id)
end

function painter.draw()
    gfx.push()
    gfx.scale(painter.scale, painter.scale)
    stack.get_table(nw.component.drawable):keys()
        :filter(remove_hidden)
        :sort(sort_drawers)
        :visit(draw_entity)
    gfx.pop()
end

painter.cache_font = {}

function painter.font(size)
    local path = "art/font/m5x7.ttf"
    painter.cache_font[size] = painter.cache_font[size] or gfx.newFont(path, size, "mono")
    return painter.cache_font[size]
end

local function compute_valign(text, font, w, h, scale, valign)
    local _, segs = font:getWrap(text, w / scale)
    local th = #segs * font:getHeight() * scale
    if valign == "center" then
        return (h  - th) * 0.5
    elseif valign == "bottom" then
        return h - th
    end

    return 0
end


local DEFAULT_OPT = {
    align = "left",
    valign = "top",
    scale = painter.scale,
    font = painter.font(8)
}

function painter.draw_text(text, area, opt)
    local opt = opt or DEFAULT_OPT
    local align = opt.align or DEFAULT_OPT.align
    local valign = opt.valign or DEFAULT_OPT.valign
    local s = opt.scale or DEFAULT_OPT.scale
    local font = opt.font or DEFAULT_OPT.font
    local dy = compute_valign(text, font, area.w, area.h, 1.0 / s, valign)
    gfx.printf(
        text, font, area.x, area.y + dy,
        area.w * s, align,
        0, 1.0 / s, 1.0 / s
    )
end


return painter