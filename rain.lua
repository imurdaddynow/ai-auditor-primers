local rain = {}

local rainSound
local raindrops = {}
local splashes = {}
local numDrops = 300 -- increased from 100

function rain.load()
    -- Load and play looping rain sound
    rainSound = love.audio.newSource("Sounds/rain.mp3", "stream")
    rainSound:setLooping(true)
    rainSound:setVolume(0.4)
    rainSound:play()

    -- Create raindrops
    for i = 1, numDrops do
        table.insert(raindrops, {
            x = math.random(0, 2000),
            y = math.random(0, 2000),
            speed = math.random(250, 400),
            length = math.random(12, 20),
            wiggle = math.random() * 0.8
        })
    end
end

function rain.update(dt, camX, camY)
    local screenBottom = camY + love.graphics.getHeight()

    for _, drop in ipairs(raindrops) do
        drop.y = drop.y + drop.speed * dt
        drop.x = drop.x + math.sin(drop.y * 0.05) * drop.wiggle

        if drop.y > screenBottom then
            table.insert(splashes, {
                x = drop.x,
                y = screenBottom - 2,
                time = 0,
                maxTime = 0.2
            })
            drop.y = camY - drop.length
            drop.x = math.random(camX, camX + love.graphics.getWidth())
        end
    end

    for i = #splashes, 1, -1 do
        local splash = splashes[i]
        splash.time = splash.time + dt
        if splash.time > splash.maxTime then
            table.remove(splashes, i)
        end
    end
end

function rain.draw(camX, camY)
    -- Draw thicker and more visible rain
    love.graphics.setColor(0.3, 0.6, 1, 0.5)
    love.graphics.setLineWidth(1.5)

    for _, drop in ipairs(raindrops) do
        love.graphics.line(drop.x, drop.y, drop.x, drop.y + drop.length)
    end

    love.graphics.setLineWidth(1)

    -- Draw splashes
    for _, splash in ipairs(splashes) do
        local alpha = 1 - (splash.time / splash.maxTime)
        love.graphics.setColor(0.3, 0.6, 1, 0.5 * alpha)
        love.graphics.points(splash.x - 1, splash.y, splash.x + 1, splash.y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return rain