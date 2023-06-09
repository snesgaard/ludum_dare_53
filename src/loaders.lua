local loaders = {}

function loaders.test_level(difficulty)
    local difficulty = difficulty or "hard"
    stack.reset()

    local r = 0.3
    for i = 0, 5 do
        local rx = 0.5 + ease.linear(i, -r, 2 * r, 5)
        local id = nw.ecs.id.strong("post")
        stack.assemble(
            {
                {nw.component.position, painter.relative(rx, 0.65)},
                {nw.component.drawable, nw.drawable.costumer},
                {nw.component.is_post},
                {nw.component.layer, painter.layer.post}
            },
            id
        )
        if i == 0 then
            stack.set(nw.component.drawable, id, nw.drawable.food_store)
            stack.set(nw.component.food_store, id, constant.food.pizza)
            stack.set(nw.component.layer, id, painter.layer.desk)
        elseif i == 5 then
            stack.set(nw.component.drawable, id, nw.drawable.food_store)
            stack.set(nw.component.food_store, id, constant.food.wine)
            stack.set(nw.component.layer, id, painter.layer.desk)
        elseif i == 6 then
            stack.set(nw.component.food_store, id, constant.food.tomato)
            stack.set(nw.component.color, id, 1.0, 0.1, 0.3)
        else
            stack.set(nw.component.customer_spawn_setting, id, 4, 6)
        end
    end

    stack.assemble(
        {
            {nw.component.position, painter.relative(0.5, 0.9)},
            {nw.component.drawable, nw.drawable.player},
            {nw.component.layer, painter.layer.player}
        },
        constant.id.player
    )
    stack.assemble(
        {
            {nw.component.drawable, nw.drawable.frame},
            {nw.component.frame, get_atlas("art/characters"):get_frame("background/background")},
            {nw.component.layer, painter.layer.background}
        },
        "background"
    )
    stack.assemble(
        {
            {nw.component.drawable, nw.drawable.frame},
            {nw.component.frame, get_atlas("art/characters"):get_frame("background/table")},
            {nw.component.layer, painter.layer.desk}
        },
        "desk"
    )

    if difficulty == "hard" then
        game.system.score.set_life(3)
    elseif difficulty == "sudden_death" then
        game.system.score.set_life(2)
    else
        game.system.score.set_life(5)
    end

    stack.set(nw.component.difficulty, "setting", difficulty)

    game.system.score.show()
end

function loaders.test_level_easy()
    return loaders.test_level("easy")
end

function loaders.test_level_hard()
    return loaders.test_level("hard")
end

function loaders.test_level_sudden()
    return loaders.test_level("sudden_death")
end

function loaders.main_menu()
    local menu_items = list(
        constant.difficulty.easy,
        constant.difficulty.hard,
        constant.difficulty.sudden_death,
        "Quit"
    )

    local frame = get_atlas("art/characters"):get_frame("gui/main_menu")

    stack.assemble(
        {
            {nw.component.drawable, nw.drawable.frame},
            {nw.component.frame, frame},
            {nw.component.layer, painter.layer.background}
        },
        "menu_bg"
    )

    stack.assemble(
        {
            {nw.component.menu, menu_items, 1},
            {nw.component.drawable, nw.drawable.menu},
            --{nw.component.position, painter.relative(0.5, 0.55)},
            {nw.component.main_menu_action}
        },
        constant.id.main_menu
    )

    stack.assemble(
        {
            {nw.component.drawable, nw.drawable.text_box},
            {nw.component.gui_box, frame.slices.title:unpack()},
            {nw.component.text, "Fantasy Retail Simulator"},
            {nw.component.align, "center"},
            {nw.component.valign, "center"},
            {nw.component.font, painter.font(8 * 18)}
        },
        "Title"
    )
    
end

return loaders