local player = {
    x = 0, y = 0,
    width = 0, height = 0,
    speed = 120,
    dir = "right",
    animTimer = 0,
    animFrame = 1,
    isMoving = false
}

local frameCount = 3
local groundImage, charL, charR
local camX, camY
local camScale = 2

local groundWidth, groundHeight

function love.load()
    groundImage = love.graphics.newImage("Sprites/ground.png")
    charR = love.graphics.newImage("Sprites/charR.png")
    charL = love.graphics.newImage("Sprites/charL.png")

    groundImage:setFilter("nearest", "nearest")
    charR:setFilter("nearest", "nearest")
    charL:setFilter("nearest", "nearest")

    groundWidth = groundImage:getWidth()
    groundHeight = groundImage:getHeight()

    player.width = charR:getWidth()
    player.height = charR:getHeight() / frameCount

    player.x = groundWidth / 2 - player.width / 2
    player.y = groundHeight / 2 - player.height / 2
end

function clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

function love.update(dt)
    local moveX, moveY = 0, 0
    player.isMoving = false

    if love.keyboard.isDown("w") then moveY = moveY - 1 end
    if love.keyboard.isDown("s") then moveY = moveY + 1 end
    if love.keyboard.isDown("a") then moveX = moveX - 1; player.dir = "left" end
    if love.keyboard.isDown("d") then moveX = moveX + 1; player.dir = "right" end

    local len = math.sqrt(moveX^2 + moveY^2)
    if len > 0 then
        moveX, moveY = moveX / len, moveY / len
        player.isMoving = true

        local nextX = player.x + moveX * player.speed * dt
        local nextY = player.y + moveY * player.speed * dt

        -- Invisible boundary collision (can't leave ground image)
        nextX = clamp(nextX, 0, groundWidth - player.width)
        nextY = clamp(nextY, 0, groundHeight - player.height)

        player.x = nextX
        player.y = nextY

        player.animTimer = player.animTimer + dt
        if player.animTimer > 0.15 then
            player.animFrame = (player.animFrame % frameCount) + 1
            player.animTimer = 0
        end
    else
        player.animFrame = 1
    end

    camX = player.x + player.width / 2 - love.graphics.getWidth() / (2 * camScale)
    camY = player.y + player.height / 2 - love.graphics.getHeight() / (2 * camScale)
end

function love.draw()
    love.graphics.scale(camScale)
    love.graphics.translate(-camX, -camY)

    -- Draw ground (single background image)
    love.graphics.draw(groundImage, 0, 0)

    -- Draw player
    local quad
    if player.dir == "right" then
        quad = love.graphics.newQuad(0, (player.animFrame - 1) * player.height, player.width, player.height, charR:getDimensions())
        love.graphics.draw(charR, quad, player.x, player.y)
    else
        quad = love.graphics.newQuad((player.animFrame - 1) * player.width, 0, player.width, player.height, charL:getDimensions())
        love.graphics.draw(charL, quad, player.x, player.y)
    end
end