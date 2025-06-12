local menu = {}

-- Load font
local font = love.graphics.newFont("fonts/subu.otf", 48)
local buttonFont = love.graphics.newFont("fonts/subu.otf", 32)
local creditsFont = love.graphics.newFont("fonts/subu.otf", 28)
local subFont = love.graphics.newFont("fonts/subu.otf", 18)

-- Parallax background settings
local bgImage = love.graphics.newImage("Sprites/ground.png")
bgImage:setFilter("linear", "linear")
local bgScale = 1.2
local bgAlpha = 0.5 -- transparency

-- Button definitions
local buttons = {
    { text = "Play",    y = 0, scale = 1, targetScale = 1, visible = true, hovered = false },
    { text = "Credits", y = 0, scale = 1, targetScale = 1, visible = true, hovered = false }
}

-- Back button for credits
local backButton = { text = "Back", x = 0, y = 0, width = 120, height = 44, scale = 1, targetScale = 1, hovered = false, visible = false }

local buttonWidth = 300
local buttonHeight = 60
local buttonGap = 40

-- Parallax offset
local parallax = {x = 0, y = 0}

-- Colors
local white = {1, 1, 1, 1}
local yellowgreen = {0.95, 1, 0.6, 1}
local transparent = {1, 1, 1, 0}

menu.selected = nil
menu._startGame = false
menu._showCredits = false

-- Flash state
local flashAlpha = 0
local flashDecay = 3.5

function menu.load()
    local screenW, screenH = love.graphics.getDimensions()
    local totalHeight = #buttons * buttonHeight + (#buttons - 1) * buttonGap
    local startY = (screenH - totalHeight) / 2

    for i, btn in ipairs(buttons) do
        btn.x = (screenW - buttonWidth) / 2
        btn.y = startY + (i - 1) * (buttonHeight + buttonGap)
        btn.width = buttonWidth
        btn.height = buttonHeight
        btn.scale = 1
        btn.targetScale = 1
        btn.visible = true
        btn.hovered = false
    end

    -- Back button position (will be updated in draw)
    backButton.scale = 1
    backButton.targetScale = 1
    backButton.visible = false
    backButton.hovered = false
end

-- Rainbow shine effect for hover (diagonal shine)
local function shineRainbow(x, y, w, h, t)
    -- Shine moves diagonally across the button
    local shineWidth = w * 0.18
    local shinePos = ((t * 1.5) % (w + h + shineWidth)) - shineWidth
    love.graphics.setScissor(x, y, w, h)
    for i = 0, shineWidth, 2 do
        local px = x + shinePos + i
        local py = y + shinePos + i
        local color = {0.5 + 0.5 * math.cos((t + i) * 2.5), 0.5 + 0.5 * math.cos((t + i) * 2.5 + 2), 0.5 + 0.5 * math.cos((t + i) * 2.5 + 4), 0.7}
        love.graphics.setColor(color)
        love.graphics.line(px, y, x, py)
    end
    love.graphics.setScissor()
end

-- Rainbow glare (diagonal, across whole button)
local function rainbowGlare(x, y, w, h, t)
    -- Diagonal glare bar moves across the button
    local glareWidth = w * 0.28
    local glarePos = ((t * 1.2) % (w + h + glareWidth)) - glareWidth
    love.graphics.setScissor(x, y, w, h)
    for i = 0, glareWidth, 2 do
        local px = x + glarePos + i
        local py = y + glarePos + i
        local color = {0.5 + 0.5 * math.cos((t + i) * 2.5), 0.5 + 0.5 * math.cos((t + i) * 2.5 + 2), 0.5 + 0.5 * math.cos((t + i) * 2.5 + 4), 0.65}
        love.graphics.setColor(color)
        love.graphics.setLineWidth(7)
        love.graphics.line(px, y, x, py)
    end
    love.graphics.setLineWidth(1)
    love.graphics.setScissor()
end

-- Helper: get smooth rainbow color
local function rainbowColor(t, offset)
    offset = offset or 0
    return {
        0.5 + 0.5 * math.cos(t + offset),
        0.5 + 0.5 * math.cos(t + 2 + offset),
        0.5 + 0.5 * math.cos(t + 4 + offset),
        1
    }
end

function menu.update(dt)
    -- Parallax follows mouse
    local mx, my = love.mouse.getPosition()
    local sw, sh = love.graphics.getDimensions()
    parallax.x = ((mx - sw / 2) / sw) * 40
    parallax.y = ((my - sh / 2) / sh) * 40

    if not menu._showCredits then
        for _, btn in ipairs(buttons) do
            btn.hovered = btn.visible and mx >= btn.x and mx <= btn.x + btn.width and my >= btn.y and my <= btn.y + btn.height
            btn.targetScale = btn.hovered and 1.12 or 1
            btn.scale = btn.scale + (btn.targetScale - btn.scale) * math.min(16 * dt, 1)
        end
        backButton.visible = false
    else
        -- Only show back button in credits
        local boxW, boxH = 520, 220
        local boxX, boxY = (sw - boxW) / 2, (sh - boxH) / 2
        backButton.x = boxX + boxW - backButton.width - 24
        backButton.y = boxY + boxH + 16
        backButton.visible = true
        backButton.hovered = mx >= backButton.x and mx <= backButton.x + backButton.width and my >= backButton.y and my <= backButton.y + backButton.height
        backButton.targetScale = backButton.hovered and 1.12 or 1
        backButton.scale = backButton.scale + (backButton.targetScale - backButton.scale) * math.min(16 * dt, 1)
        -- Hide main menu buttons
        for _, btn in ipairs(buttons) do
            btn.visible = false
        end
    end

    if flashAlpha > 0 then
        flashAlpha = math.max(0, flashAlpha - flashDecay * dt)
    end
end

function menu.draw()
    -- Draw blurred, transparent background with parallax
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, bgAlpha)
    local sw, sh = love.graphics.getDimensions()
    local bgW, bgH = bgImage:getWidth() * bgScale, bgImage:getHeight() * bgScale
    local bx = (sw - bgW) / 2 + parallax.x
    local by = (sh - bgH) / 2 + parallax.y
    love.graphics.draw(bgImage, bx, by, 0, bgScale, bgScale)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()

    -- Blur effect: draw a translucent white rectangle over everything
    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.rectangle("fill", 0, 0, sw, sh)
    love.graphics.setColor(1, 1, 1, 1)

    -- Menu title
    if not menu._showCredits then
        love.graphics.setFont(font)
        love.graphics.setColor(white)
        love.graphics.printf("Bunny Nightshift", 0, 80, sw, "center")
    end

    -- Draw buttons (main menu)
    love.graphics.setFont(buttonFont)
    local t = love.timer.getTime()
    for i, btn in ipairs(buttons) do
        if btn.visible then
            -- Smooth scale and center
            local scale = btn.scale
            local bx = btn.x + btn.width/2
            local by = btn.y + btn.height/2
            love.graphics.push()
            love.graphics.translate(bx, by)
            love.graphics.scale(scale, scale)
            love.graphics.translate(-bx, -by)

            -- Border: only corners, thick, white, with bigger vertical gaps
            love.graphics.setColor(white)
            local bw, bh = btn.width, btn.height
            local cornerLenH = 28
            local cornerLenV = 56 -- increased vertical gap
            love.graphics.setLineWidth(3)
            -- Top left
            love.graphics.line(btn.x, btn.y, btn.x + cornerLenH, btn.y)
            love.graphics.line(btn.x, btn.y, btn.x, btn.y + cornerLenV)
            -- Top right
            love.graphics.line(btn.x + bw, btn.y, btn.x + bw - cornerLenH, btn.y)
            love.graphics.line(btn.x + bw, btn.y, btn.x + bw, btn.y + cornerLenV)
            -- Bottom left
            love.graphics.line(btn.x, btn.y + bh, btn.x + cornerLenH, btn.y + bh)
            love.graphics.line(btn.x, btn.y + bh, btn.x, btn.y + bh - cornerLenV)
            -- Bottom right
            love.graphics.line(btn.x + bw, btn.y + bh, btn.x + bw - cornerLenH, btn.y + bh)
            love.graphics.line(btn.x + bw, btn.y + bh, btn.x + bw, btn.y + bh - cornerLenV)
            love.graphics.setLineWidth(1)

            -- Button text (rainbow on hover, else white)
            love.graphics.setFont(buttonFont)
            if btn.hovered then
                love.graphics.setColor(rainbowColor(t * 2))
            else
                love.graphics.setColor(white)
            end
            love.graphics.printf(btn.text, btn.x, btn.y + 6, btn.width, "center")

            -- Subtext (yellow-green, screenshot style)
            love.graphics.setFont(subFont)
            love.graphics.setColor(yellowgreen)
            if btn.text == "Play" then
                love.graphics.printf("Start Game", btn.x, btn.y + btn.height - 28, btn.width, "center")
            elseif btn.text == "Credits" then
                love.graphics.printf("See Credits", btn.x, btn.y + btn.height - 28, btn.width, "center")
            end

            love.graphics.pop()
        end
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw credits GUI in same style
    if menu._showCredits then
        local boxW, boxH = 520, 220
        local boxX, boxY = (sw - boxW) / 2, (sh - boxH) / 2
        -- Transparent background
        love.graphics.setColor(transparent)
        love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 18, 18)
        -- White border
        love.graphics.setColor(white)
        local cornerLen = 40
        love.graphics.setLineWidth(3)
        -- Corners
        -- Top left
        love.graphics.line(boxX, boxY, boxX + cornerLen, boxY)
        love.graphics.line(boxX, boxY, boxX, boxY + cornerLen)
        -- Top right
        love.graphics.line(boxX + boxW, boxY, boxX + boxW - cornerLen, boxY)
        love.graphics.line(boxX + boxW, boxY, boxX + boxW, boxY + cornerLen)
        -- Bottom left
        love.graphics.line(boxX, boxY + boxH, boxX + cornerLen, boxY + boxH)
        love.graphics.line(boxX, boxY + boxH, boxX, boxY + boxH - cornerLen)
        -- Bottom right
        love.graphics.line(boxX + boxW, boxY + boxH, boxX + boxW - cornerLen, boxY + boxH)
        love.graphics.line(boxX + boxW, boxY + boxH, boxX + boxW, boxY + boxH - cornerLen)
        love.graphics.setLineWidth(1)

        love.graphics.setFont(font)
        love.graphics.setColor(white)
        love.graphics.printf("Credits", boxX, boxY + 16, boxW, "center")
        love.graphics.setFont(creditsFont)
        love.graphics.setColor(white)
        local creditText = [[
@bunnyrumi - Original Game Idea - castle.xyz
@SubuNoob - Story - castle.xyz
@currymaster_69 - Game Dev - discord
        ]]
        love.graphics.printf(creditText, boxX + 24, boxY + 70, boxW - 48, "left")

        -- Draw back button (rainbow on hover)
        if backButton.visible then
            local scale = backButton.scale
            local bx = backButton.x + backButton.width/2
            local by = backButton.y + backButton.height/2
            love.graphics.push()
            love.graphics.translate(bx, by)
            love.graphics.scale(scale, scale)
            love.graphics.translate(-bx, -by)

            -- Border (with bigger vertical gaps)
            local bw, bh = backButton.width, backButton.height
            local cornerLenH = 18
            local cornerLenV = 36 -- bigger vertical gap for back button
            love.graphics.setLineWidth(3)
            love.graphics.setColor(white)
            -- Top left
            love.graphics.line(backButton.x, backButton.y, backButton.x + cornerLenH, backButton.y)
            love.graphics.line(backButton.x, backButton.y, backButton.x, backButton.y + cornerLenV)
            -- Top right
            love.graphics.line(backButton.x + bw, backButton.y, backButton.x + bw - cornerLenH, backButton.y)
            love.graphics.line(backButton.x + bw, backButton.y, backButton.x + bw, backButton.y + cornerLenV)
            -- Bottom left
            love.graphics.line(backButton.x, backButton.y + bh, backButton.x + cornerLenH, backButton.y + bh)
            love.graphics.line(backButton.x, backButton.y + bh, backButton.x, backButton.y + bh - cornerLenV)
            -- Bottom right
            love.graphics.line(backButton.x + bw, backButton.y + bh, backButton.x + bw - cornerLenH, backButton.y + bh)
            love.graphics.line(backButton.x + bw, backButton.y + bh, backButton.x + bw, backButton.y + bh - cornerLenV)
            love.graphics.setLineWidth(1)

            -- Rainbow text on hover, else white
            love.graphics.setFont(buttonFont)
            if backButton.hovered then
                love.graphics.setColor(rainbowColor(t * 2))
            else
                love.graphics.setColor(white)
            end
            love.graphics.printf(backButton.text, backButton.x, backButton.y + 6, backButton.width, "center")

            love.graphics.pop()
        end
    end

    -- Screen flash overlay
    if flashAlpha > 0 then
        love.graphics.setColor(1, 1, 1, flashAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        if menu._showCredits then
            if backButton.visible and x >= backButton.x and x <= backButton.x + backButton.width and y >= backButton.y and y <= backButton.y + backButton.height then
                menu._showCredits = false
                for _, btn in ipairs(buttons) do
                    btn.visible = true
                    btn.scale = 1
                    btn.targetScale = 1
                    btn.hovered = false
                end
                backButton.visible = false
                backButton.scale = 1
                backButton.targetScale = 1
                backButton.hovered = false
                flashAlpha = 0.7 -- flash on back
            end
            return
        end
        for _, btn in ipairs(buttons) do
            if btn.visible and x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                menu.selected = btn.text:lower()
                if btn.text == "Play" then
                    menu._startGame = true
                elseif btn.text == "Credits" then
                    menu._showCredits = true
                end
                flashAlpha = 0.7 -- flash on click
            end
        end
    end
end

function menu.shouldStartGame()
    if menu._startGame then
        menu._startGame = false
        return true
    end
    return false
end

function menu.shouldShowCredits()
    return false
end

return menu