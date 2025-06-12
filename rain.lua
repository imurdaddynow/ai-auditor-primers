local rain = {}

local raindrops = {}
local numDrops = 300
local rainSound
local rainSoundPlaying = false

function rain.load()
    for i = 1, numDrops do
        table.insert(raindrops, {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            speed = math.random(300, 600)
        })
    end

    rainSound = love.audio.newSource("Sounds/rain.mp3", "stream")
    rainSound:setLooping(true)
end

function rain.update(dt, camX, camY)
    if groundImageName == "Sprites/cafe_0.png" then
        if rainSoundPlaying then
            rainSound:stop()
            rainSoundPlaying = false
        end
        return
    end

    for _, drop in ipairs(raindrops) do
        drop.y = drop.y + drop.speed * dt
        if drop.y > love.graphics.getHeight() then
            drop.y = 0
            drop.x = math.random(0, love.graphics.getWidth())
        end
    end

    if not rainSoundPlaying then
        rainSound:play()
        rainSoundPlaying = true
    end
end

function rain.draw(camX, camY)
    if groundImageName == "Sprites/cafe_0.png" then return end

    love.graphics.setColor(0.6, 0.6, 1, 0.6)
    for _, drop in ipairs(raindrops) do
        love.graphics.line(
            camX + drop.x, camY + drop.y,
            camX + drop.x + 2, camY + drop.y + 10
        )
    end
    love.graphics.setColor(1, 1, 1)
end

return rain