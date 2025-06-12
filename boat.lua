local boat = {}

local boatImage
local boatX, boatY
local boatWidth, boatHeight
local boatVisible = true
local triggered = false
local imageData
local checked = false

function boat.load()
    boatImage = love.graphics.newImage("Sprites/boat.png")
    boatImage:setFilter("nearest", "nearest")
    boatWidth = boatImage:getWidth()
    boatHeight = boatImage:getHeight()
    imageData = love.image.newImageData("Sprites/boat.png")

    boatX = mapWidth + 200
    boatY = mapHeight * 0.1
end

function boat.update(dt, player)
    if not boatVisible or not boatImage then return end

    local camTopVisible = player.y - love.graphics.getHeight() / 2 <= 0
    if camTopVisible then triggered = true end

    if triggered and boatX > mapWidth / 2 then
        boatX = boatX - 240 * dt
        if boatX < mapWidth / 2 then
            boatX = mapWidth / 2
        end
    end

    if checked then return end

    if math.abs(player.x - boatX) < boatWidth and math.abs(player.y - boatY) < boatHeight then
        if imageData then
            local px = math.floor((player.x - (boatX - boatWidth / 2)) / 2)
            local py = math.floor((player.y - (boatY - boatHeight / 2)) / 2)

            if px >= 0 and px < boatWidth and py >= 0 and py < boatHeight then
                local _, _, _, alpha = imageData:getPixel(px, py)
                if alpha > 0.1 then
                    checked = true
                    boatVisible = false
                    groundImage = love.graphics.newImage("Sprites/cafe_0.png")
                    boatImage = nil
                    imageData = nil
                end
            end
        end
    end
end

function boat.draw()
    if boatVisible and boatImage then
        love.graphics.draw(boatImage, boatX, boatY, 0, 2, 2, boatWidth / 2, boatHeight / 2)
    end
end

return boat