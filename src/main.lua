nw = require "nodeworks"
constant = require "constant"
stack = nw.ecs.stack

event = nw.system.event
input = nw.system.input
painter = require "painter"
loader = require "loaders"
nw.component = decorate(nw.component, require "component", true)
nw.drawable = decorate(nw.drawable, require "drawable", true)
game = {system = require "system"}

local function event_loop()
    while event.spin() > 0 do
        if not game.system.score.player_lose() then
            nw.system.timer.spin()
            nw.system.particles.spin()
            game.system.menu.spin()
            game.system.sound.spin()
            game.system.explosion.spin()
            game.system.customer.spin()
            game.system.player_control.spin()
            game.system.score.spin()
        end
    end

    game.system.scene.load()
end

function love.load()
    game.system.scene.request("main_menu")

    bg_music = love.audio.newSource("art/sound/bar.mp3", "static")
    bg_music:setLooping(true)
    bg_music:setVolume(1)
    love.audio.play(bg_music)

    print(ease.linear(10, 0, 1, 1))
end

function love.update(dt)
    if not paused then event.emit("update", dt) end
    event_loop()
end

function love.draw()
    painter.draw()

    if game.system.score.player_lose() then
        gfx.push()
        gfx.scale(painter.scale, painter.scale)

        local area = spatial(painter.relative(0.5, 0.5)):expand(200, 100)
        local opt = {
            align = "center",
            valign = "center",
            font = painter.font(48),
        }
        gfx.setColor(1, 1, 1)
        gfx.rectangle("fill", area:unpack())
        gfx.setColor(0, 0, 0)
        painter.draw_text("YOU LOSE! : (", area, opt)
        gfx.setColor(1, 1, 1)
        gfx.pop()
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    if key == "p" then
        paused = not paused
        print("pause", paused)
    end
    if key == "r" then
        stack.reset()
        loader.test_level()
    end
    input.keypressed(key)
end