local post = {}

local function get_position(id) return stack.ensure(nw.component.position, id) end
local function distance_to_squared(pos, x, y)
    local dx = x - pos.x
    local dy = y - pos.y
    return dx * dx + dy * dy
end

function post.nearest(x, y, ids)
    local ids = ids or stack.get_table(nw.component.is_post):keys()
    local index = ids
        :map(get_position)
        :map(distance_to_squared, x, y)
        :argsort()
        :head()
    if not index then return end
    return ids[index]
end

local function filter_by_left(other, x)
    local pos_other = stack.ensure(nw.component.position, other)
    return 1 < x - pos_other.x 
end

local function filter_by_right(other, x)
    local pos_other = stack.ensure(nw.component.position, other)
    return 1 < pos_other.x - x
end

local function filter_by_up(other, y)
    local pos_other = stack.ensure(nw.component.position, other)
    return 1 < y - pos_other.y
end

local function filter_by_down(other, y)
    local pos_other = stack.ensure(nw.component.position, other)
    return 1 < pos_other.y - y
end

function post.nearest_left(x, y)
    local ids = stack.get_table(nw.component.is_post):keys()
    return post.nearest(x, y, ids:filter(filter_by_left, x))
end

function post.nearest_right(x, y)
    local ids = stack.get_table(nw.component.is_post):keys()
    return post.nearest(x, y, ids:filter(filter_by_right, x))
end

function post.nearest_up(x, y)
    local ids = stack.get_table(nw.component.is_post):keys()
    return post.nearest(x, y, ids:filter(filter_by_up, y))
end

function post.nearest_down(x, y)
    local ids = stack.get_table(nw.component.is_post):keys()
    return post.nearest(x, y, ids:filter(filter_by_down, y))
end

local player_control = {}

function player_control.move_using_func(func)
    if not func then return end
    local pos = stack.ensure(nw.component.position, constant.id.player)
    local post_id = func(pos.x, pos.y)
    if not post_id then return end
    local post_pos = stack.ensure(nw.component.position, post_id)
    stack.set(nw.component.position, constant.id.player, post_pos.x, post_pos.y)
end

function player_control.move_left()
    player_control.move_using_func(post.nearest_left)
end

function player_control.move_right()
    player_control.move_using_func(post.nearest_right)
end

function player_control.move_up()
    player_control.move_using_func(post.nearest_up)
end

function player_control.move_down()
    player_control.move_using_func(post.nearest_down)
end

function player_control.trigger_food_store(post_id)
    local food_stack = stack.ensure(nw.component.food_stack, constant.id.player)
    if constant.max_food_stack <= food_stack:size() then return end
    local food = stack.get(nw.component.food_store, post_id)
    if not food then return end
    table.insert(food_stack, food)
end

function player_control.trigger_constumer(post_id)
    local food_stack = stack.ensure(nw.component.food_stack, constant.id.player)
    if food_stack:empty() then return end
    local desire = stack.get(nw.component.customer_desire, post_id)
    if not desire then return end
    local food = food_stack:tail()
    table.remove(food_stack)
    if desire == food then
        game.system.customer.success(post_id)
    else
        game.system.customer.failure(post_id)
    end
end

function player_control.trigger()
    local pos = stack.ensure(nw.component.position, constant.id.player)
    local post_id = post.nearest(pos.x, pos.y)
    if not post_id then return end
    player_control.trigger_food_store(post_id)
    player_control.trigger_constumer(post_id)
end

function player_control.spin()
    for _, key in event.view("keypressed") do
        if key == "left" then
            player_control.move_left()
        elseif key == "right" then
            player_control.move_right()
        elseif key == "up" then
            player_control.move_up()
        elseif key == "down" then
            print("down")
            player_control.move_down()
        elseif key == "space" then
            player_control.trigger()
        end
    end
end

local score = {}

local function compute_layout()
    local margin = 5
    local score_text = spatial(5, 5, 50, 12)
    local score_num = score_text:right(margin, 0)
    local strike_text = score_text:down(0, margin)
    local strike_num = strike_text:right(margin, 0)
    local border = Spatial.join(score_text, score_num, strike_text, strike_num):expand(10, 10)

    return {
        score_text = score_text,
        score_num = score_num,
        strike_text = strike_text,
        strike_num = strike_num,
        border = border
    }
end

local function draw_score()
    local s = stack.ensure(nw.component.score, score)
    local score_area = spatial(0, 0, 50, 25)
    
    painter.draw_text(s, score_area, opt)
end

function score.get()
    return stack.ensure(nw.component.score, score)
end

function score.set(s)
    stack.set(nw.component.score, score, s)
end

function score.increment(a)
    local a = a or 1
    local s = score.get()
    score.set(s + a)
end

function score.life()
    return stack.ensure(nw.component.life, score)
end

function score.lose_life()
    if constant.invincible then return end
    stack.set(nw.component.life, score, score.life() - 1)
end

function score.player_lose()
    return score.life() <= 0
end

function score.draw()
    gfx.push("all")
    nw.drawable.push_transform(score)

    local layout = stack.ensure(compute_layout, score)
    gfx.setColor(0.1, 0.2, 0.8, 0.6)
    gfx.rectangle("fill", layout.border:unpack(5))
    gfx.setColor(1, 1, 1)

    local text_opt = {
        align = "left",
        valign = "center",
        font = painter.font(48)
    }
    painter.draw_text("Score:", layout.score_text, text_opt)
    painter.draw_text("Lives:", layout.strike_text, text_opt)

    local s = score.get()
    painter.draw_text(s, layout.score_num, text_opt)
    local l = score.life()
    gfx.push()
    gfx.translate(layout.strike_num:leftcenter():unpack())
    for i = 1, l do
        gfx.circle("fill", 0, 0, 4)
        gfx.translate(10, 0)
    end
    gfx.pop()

    gfx.pop()

    score.draw_controls()
end

function score.draw_controls()
    local x, y = painter.screen_size()
    local box = spatial(x, 0, 75, 12):left():move(-5, 5)
    local space_box = box:down(0, 5)
    local border = Spatial.join(box, space_box):expand(10, 10)
    
    gfx.push("all")

    nw.drawable.push_transform(score)

    gfx.setColor(0.1, 0.2, 0.8, 0.6)
    gfx.rectangle("fill", border:unpack(5))
    gfx.setColor(1, 1, 1)

    local text_opt = {
        align = "right",
        valign = "center",
        font = painter.font(48)
    }

    painter.draw_text("Move :: <- ->", box, text_opt)
    painter.draw_text("Interact :: space", space_box, text_opt)

    gfx.pop()
end

function score.spin()
    stack
        .init(nw.component.drawable, score, score.draw)
end

local customer = {}

function customer.pick_food_desire()
    return stack.get_table(nw.component.food_store):values():shuffle():head()
end

function customer.pick_patron()
    return constant.patron:values():shuffle():head()
end

function customer.spin_once(id, settings)
    local scale = 1 + math.log(1 + customer.get_runtime() / 100.0)
    local timer = stack.ensure(
        nw.component.customer_timer, id,
        settings.duration_min, settings.duration_max,
        1.0 / scale
    )
    if not nw.system.timer.is_done(timer) then return end

    if stack.has(nw.component.customer_desire, id) then
        stack.remove(nw.component.customer_desire, id)
        customer.failure(id)
    else
        stack.set(nw.component.customer_desire, id, customer.pick_food_desire())
        stack.set(nw.component.patron, id, customer.pick_patron())
    end

    stack.remove(nw.component.customer_timer, id)
end

function customer.get_timer(id)
    local timer_id = stack.get(nw.component.customer_timer, id)
    if not timer_id then return end
    return stack.get(nw.component.timer, timer_id)
end

function customer.get_runtime()
    return stack.ensure(nw.component.time, customer)
end

function customer.spin()
    for id, settings in stack.view_table(nw.component.customer_spawn_setting) do
        customer.spin_once(id, settings)
    end

    for _, dt in event.view("update") do
        stack.set(nw.component.time, customer, customer.get_runtime() + dt)
    end
end

function customer.success(id)
    stack.remove(nw.component.customer_desire, id)
    game.system.score.increment()
end

function customer.failure(id)
    stack.remove(nw.component.customer_desire, id)
    game.system.score.lose_life()

    local pos = stack.get(nw.component.position, id)
    if pos then game.system.explosion.spawn(pos.x, pos.y- 34) end
end

local explosion = {}

function explosion.flag() return true end

explosion.particle_op = {
    image = gfx.prerender(8, 8, function(w, h) gfx.rectangle("fill", 0, 0, w, h) end),
    buffer = 60,
    lifetime = {0.5, 0.75},
    emit = 60,
    damp = 25,
    speed = {100, 900},
    area = {"normal", 10, 10},
    color = {
        gfx.hex2color("ced09eff"),  
        gfx.hex2color("cdad59ff"),
        gfx.hex2color("564159ff"),
        gfx.hex2color("00000000")
    },
    acceleration = {0, -30},
    spread = math.pi * 2,
    size = {1, 2, 2}
}

function explosion.spawn(x, y)
    local id = nw.ecs.id.strong("explosion")

    stack.assemble(
        {
            {nw.component.position, x, y},
            {nw.component.drawable, nw.drawable.explosion},
            {nw.component.timer, 0.1},
            {nw.component.particles, explosion.particle_op},
            {explosion.flag}
        },
        id
    )
end

function explosion.spin_once(id)
    if nw.system.timer.is_done(id) and nw.system.particles.empty(id) then
        stack.destroy(id)
    end
end

function explosion.update()
    for id, _ in stack.view_table(explosion.flag) do
        explosion.spin_once(id)
    end
end

function explosion.spin()
    for _, dt in event.view("update") do explosion.update(dt) end
end

return {
    post = post,
    player_control = player_control,
    customer = customer,
    score = score,
    explosion = explosion
}