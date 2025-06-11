local rain = require("rain")

local player = {
    x = 0, y = 0,
    speed = 200,
    dir = "right",
    animTimer = 0,
    animSpeed = 0.1,
    frame = 1
}

local camX, camY = 0, 0
local map = {}
local mapWidth, mapHeight = 1280, 1280
local groundImage
local charR, charL
local frameW, frameH = 32, 32
local numFramesR = 1
local numFramesL = 1

function love.load()
    love.window.setMode(800, 600)
    groundImage = love.graphics.newImage("Sprites/ground.png")
    groundImage:setWrap("clamp", "clamp")

    -- Load character sprites
    charR = love.graphics.newImage("Sprites/charR.png")
    charL = love.graphics.newImage("Sprites/charL.png")
    charR:setFilter("nearest", "nearest")
    charL:setFilter("nearest", "nearest")

    frameW = 32
    frameH = 32

    numFramesR = math.floor(charR:getHeight() / frameH)
    numFramesL = math.floor(charL:getWidth() / frameW)

    -- Start in center
    player.x = mapWidth / 2
    player.y = mapHeight / 2

    rain.load()
end

function love.update(dt)
    local moveX, moveY = 0, 0
    local isMoving = false

    if love.keyboard.isDown("w") then moveY = moveY - 1 end
    if love.keyboard.isDown("s") then moveY = moveY + 1 end
    if love.keyboard.isDown("a") then moveX = moveX - 1; player.dir = "left" end
    if love.keyboard.isDown("d") then moveX = moveX + 1; player.dir = "right" end

    if moveX ~= 0 or moveY ~= 0 then
        isMoving = true
        local length = math.sqrt(moveX * moveX + moveY * moveY)
        moveX, moveY = moveX / length, moveY / length
        local nextX = player.x + moveX * player.speed * dt
        local nextY = player.y + moveY * player.speed * dt

        -- Boundaries
        if nextX > 16 and nextX < mapWidth - 16 then player.x = nextX end
        if nextY > 16 and nextY < mapHeight - 16 then player.y = nextY end
    end

    -- Animate
    if isMoving then
        player.animTimer = player.animTimer + dt
        if player.animTimer >= player.animSpeed then
            player.animTimer = 0
            player.frame = player.frame + 1
            if player.dir == "right" and player.frame > numFramesR then player.frame = 1 end
            if player.dir == "left" and player.frame > numFramesL then player.frame = 1 end
        end
    else
        player.frame = 1
        player.animTimer = 0
    end

    camX = player.x - love.graphics.getWidth() / 2
    camY = player.y - love.graphics.getHeight() / 2

    rain.update(dt, camX, camY)
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-camX, -camY)

    -- Draw ground centered
    love.graphics.draw(groundImage, mapWidth / 2, mapHeight / 2, 0, mapWidth / groundImage:getWidth(), mapHeight / groundImage:getHeight(), groundImage:getWidth() / 2, groundImage:getHeight() / 2)

    -- Draw character
    local sx, sy = 2, 2 -- scale character up
    if player.dir == "right" then
        love.graphics.draw(charR, love.graphics.newQuad(0, (player.frame - 1) * frameH, frameW, frameH, charR:getWidth(), charR:getHeight()), player.x, player.y, 0, sx, sy, frameW / 2, frameH / 2)
    else
        love.graphics.draw(charL, love.graphics.newQuad((player.frame - 1) * frameW, 0, frameW, frameH, charL:getWidth(), charL:getHeight()), player.x, player.y, 0, sx, sy, frameW / 2, frameH / 2)
    end

    rain.draw(camX, camY)

    love.graphics.pop()
end