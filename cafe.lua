local cafe = {}
local cafeImg, itemImg, doorImg
local mapWidth, mapHeight = 1280, 1280
cafe.mapCX = mapWidth / 2
cafe.mapCY = mapHeight / 2

local items = {}
local door = nil
local collected = 0

function cafe.load()
    cafeImg = love.graphics.newImage("Sprites/cafe_0.png")
    cafeImg:setFilter("nearest","nearest")
    itemImg = love.graphics.newImage("Sprites/item1.png")
    itemImg:setFilter("nearest","nearest")
    doorImg = love.graphics.newImage("Sprites/door.png")
    doorImg:setFilter("nearest","nearest")

    items = {}
    for i=1,4 do
        table.insert(items, {
            x = math.random(100, mapWidth-100),
            y = math.random(100, mapHeight-100),
            collected = false
        })
    end

    collected = 0
    door = nil
end

function cafe.update(dt, player)
    for _, it in ipairs(items) do
        if not it.collected
          and math.abs(player.x - it.x) < 16
          and math.abs(player.y - it.y) < 16
        then
            it.collected = true
            collected = collected + 1
        end
    end

    if collected == 4 and not door then
        door = {
            x = mapWidth - 64,
            y = mapHeight / 2
        }
    end
end

function cafe.draw()
    love.graphics.draw(
        cafeImg,
        mapWidth / 2, mapHeight / 2, 0,
        0.5, 0.5,
        cafeImg:getWidth()/2, cafeImg:getHeight()/2
    )

    for _, it in ipairs(items) do
        if not it.collected then
            love.graphics.draw(
                itemImg,
                it.x, it.y,
                0, 1, 1,
                itemImg:getWidth()/2, itemImg:getHeight()/2
            )
        end
    end

    if door then
        love.graphics.draw(
            doorImg,
            door.x, door.y,
            0, 1, 1,
            doorImg:getWidth()/2, doorImg:getHeight()/2
        )
    end
end

return cafe