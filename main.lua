local rain = require("rain")
local boat = require("boat")
local menu = require("menu") -- Add menu require

local player = {
    x = 0, y = 0,
    speed = 200,
    dir = "right",
    animTimer = 0,
    animSpeed = 0.1,
    frame = 1
}

local camX, camY = 0, 0
groundImage = nil
groundImageName = "" -- used to check which background image is active
local charR, charL
local frameW, frameH = 32, 32
local numFramesR, numFramesL = 1, 1

mapWidth, mapHeight = 1280, 1280

local gameState = "menu" -- Add game state

function love.load()
    love.window.setMode(800, 600)

    groundImage = love.graphics.newImage("Sprites/ground.png")
    groundImage:setWrap("clamp", "clamp")
    groundImage:setFilter("nearest", "nearest")
    groundImageName = "Sprites/ground.png"

    charR = love.graphics.newImage("Sprites/charR.png")
    charL = love.graphics.newImage("Sprites/charL.png")
    charR:setFilter("nearest", "nearest")
    charL:setFilter("nearest", "nearest")

    frameW, frameH = 32, 32
    numFramesR = math.floor(charR:getHeight() / frameH)
    numFramesL = math.floor(charL:getWidth() / frameW)

    player.x = mapWidth / 2
    player.y = mapHeight / 2

    rain.load()
    boat.load()
    menu.load() -- Load menu
end

function love.update(dt)
    if gameState == "menu" then
        menu.update(dt)
        if menu.shouldStartGame() then
            gameState = "play"
        end
        return
    end

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

        if nextX > 16 and nextX < mapWidth - 16 then player.x = nextX end
        if nextY > 16 and nextY < mapHeight - 16 then player.y = nextY end
    end

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
    boat.update(dt, player)
end

function love.draw()
    if gameState == "menu" then
        menu.draw()
        return
    end

    love.graphics.push()
    love.graphics.translate(-camX, -camY)

    if groundImage then
        local scale = 1
        if groundImageName == "Sprites/cafe_0.png" then
            scale = 0.5
        end

        love.graphics.draw(
            groundImage,
            mapWidth / 2, mapHeight / 2,
            0,
            (mapWidth / groundImage:getWidth()) * scale,
            (mapHeight / groundImage:getHeight()) * scale,
            groundImage:getWidth() / 2,
            groundImage:getHeight() / 2
        )
    end

    local sx, sy = 2, 2
    if player.dir == "right" then
        love.graphics.draw(
            charR,
            love.graphics.newQuad(0, (player.frame - 1) * frameH, frameW, frameH, charR:getWidth(), charR:getHeight()),
            player.x, player.y, 0, sx, sy, frameW / 2, frameH / 2
        )
    else
        love.graphics.draw(
            charL,
            love.graphics.newQuad((player.frame - 1) * frameW, 0, frameW, frameH, charL:getWidth(), charL:getHeight()),
            player.x, player.y, 0, sx, sy, frameW / 2, frameH / 2
        )
    end

    boat.draw()
    rain.draw(camX, camY)

    love.graphics.pop()
end

function love.mousepressed(x, y, button)
    if gameState == "menu" then
        menu.mousepressed(x, y, button)
    end
    -- else: handle mouse input for other states if needed
end