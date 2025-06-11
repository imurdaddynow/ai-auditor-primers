-- main.lua

local character = {
    x = 100,
    y = 100,
    speed = 100,
    dir = "right", -- "left" or "right"
    frame = 1,
    timer = 0,
    frameDelay = 0.15,
    frameWidth = 32,
    frameHeight = 32,
    animations = {
        left = {},
        right = {}
    },
    spritesheets = {
        left = nil,
        right = nil
    }
}

function loadAnimation(image, frameWidth, frameHeight)
    local frames = {}
    local imageHeight = image:getHeight()
    local frameCount = imageHeight / frameHeight

    for i = 0, frameCount - 1 do
        local quad = love.graphics.newQuad(
            0, i * frameHeight,
            frameWidth, frameHeight,
            image:getDimensions()
        )
        table.insert(frames, quad)
    end

    return frames
end

function love.load()
    character.spritesheets.left = love.graphics.newImage("Sprites/charL.png")
    character.spritesheets.right = love.graphics.newImage("Sprites/charR.png")

    character.animations.left = loadAnimation(character.spritesheets.left, character.frameWidth, character.frameHeight)
    character.animations.right = loadAnimation(character.spritesheets.right, character.frameWidth, character.frameHeight)
end

function love.update(dt)
    local moving = false
    local vx, vy = 0, 0

    -- Collect input
    if love.keyboard.isDown("a") then
        vx = vx - 1
    end
    if love.keyboard.isDown("d") then
        vx = vx + 1
    end
    if love.keyboard.isDown("w") then
        vy = vy - 1
    end
    if love.keyboard.isDown("s") then
        vy = vy + 1
    end

    -- Normalize diagonal movement
    if vx ~= 0 or vy ~= 0 then
        moving = true
        local len = math.sqrt(vx * vx + vy * vy)
        vx = vx / len
        vy = vy / len
    end

    -- Apply movement
    character.x = character.x + vx * character.speed * dt
    character.y = character.y + vy * character.speed * dt

    -- Update direction only if moving left or right
    if vx < 0 then
        character.dir = "left"
    elseif vx > 0 then
        character.dir = "right"
    end

    -- Animate
    if moving then
        character.timer = character.timer + dt
        if character.timer >= character.frameDelay then
            character.timer = 0
            character.frame = character.frame + 1
            if character.frame > #character.animations[character.dir] then
                character.frame = 1
            end
        end
    else
        character.frame = 1
    end
end

function love.draw()
    local sprite = character.spritesheets[character.dir]
    local quad = character.animations[character.dir][character.frame]

    love.graphics.draw(sprite, quad, character.x, character.y)
end