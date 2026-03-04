--Very simple and self explanatory class. I use it to output sequence of tutorial text on screen.
--By changing text in textTable, the outputed text on the screen will automatically change dinamically.

local Introductions = {}
Introductions.__index = Introductions

function Introductions:new(x, y)
    local obj = setmetatable({}, self)

    --8 seconds is enough to read text on the screen
    obj.interval = 8

    obj.timer = 0
    obj.printable = true
    obj.donePrintable = false
    obj.textTableElement = 1
    obj.gameFont = love.graphics.newFont("gameFont.ttf",64)

    obj.textTable = {
        "Use   W   A   S   D   to move",
        "Diagonal movement + space = dash",
        "Mind not to dash into objects and get stuck",
        "They have no solid form, they can pass right through anything",
        "Avoid touching them in any form",
        "And try to collect yellow points"
    }
    return obj
end

function Introductions:update(dt)
    if self.donePrintable then return end

    self.timer = self.timer + dt
    if self.timer >= self.interval then
        self.timer = 0
        self.textTableElement = self.textTableElement + 2 --Text is outputed as pairs so we have to increment by 2

        if self.textTableElement > #self.textTable then
            self.printable = false
            self.donePrintable = true
    end
end
end

function Introductions:draw()
    if self.printable and self.textTableElement <= #self.textTable then
    --Is needed to offset text horizontally
    local textWidth = self.gameFont:getWidth(self.textTable[self.textTableElement])
    local textWidth2 = self.gameFont:getWidth(self.textTable[self.textTableElement + 1])

    love.graphics.print(self.textTable[self.textTableElement], self.gameFont,
    (love.graphics.getWidth() - textWidth) / 2, love.graphics.getHeight() / 2 - 150 ,0,1)
    love.graphics.print(self.textTable[self.textTableElement + 1], self.gameFont,
    (love.graphics.getWidth() - textWidth2) / 2, love.graphics.getHeight() / 2 + 100 ,0,1)
    end
end

return Introductions
