--This slime has deathly aura but lower speed. More range, lower speed.
local Slime1 = {}
Slime1.__index = Slime1

function Slime1:new(x, y)
    local obj = setmetatable({}, self)

    --Main variables
    obj.x = x
    obj.y = y
    obj.aura = 0.25
    obj.speed = 80
    obj.chaseCloseness = 1

    obj.direction = 1
    obj.spriteSheet = love.graphics.newImage("Sprites/Slimes/Slime2_Run_without_shadow.png")
    obj.auraSheet = love.graphics.newImage("Sprites/Particles/aura.png")

    
    obj.width  = 64
    obj.height = 64
    local sheetWidth, sheetHeight = obj.spriteSheet:getDimensions()

    obj.animations = {}
    for row = 0, 3 do
        obj.animations[row + 1] = {}
        for col = 0, 7 do
            obj.animations[row + 1][col + 1] = love.graphics.newQuad(
                col * obj.width,
                row * obj.height,
                obj.width,
                obj.height,
                sheetWidth,
                sheetHeight
            )
        end
    end

    obj.currentFrame = 1
    obj.animationTimer = 0
    obj.frameRate = 0.12

    obj.movePhase = nil

    return obj
end

function Slime1:update(dt, target)
    local moveX, moveY = 0, 0

    if target then
        local playerCenterX = target.x + target.width/2 - 12
        local playerCenterY = target.y + target.height/2
        local dx = playerCenterX - self.x
        local dy = playerCenterY - self.y
        local absDx = math.abs(dx)
        local absDy = math.abs(dy)

        if not self.movePhase then
            if absDx > absDy then self.movePhase = "x"
            else self.movePhase = "y" end
        end

        if self.movePhase == "x" then
            if absDx > self.chaseCloseness then
                if dx > 0 then moveX = 1 self.direction = 4 else moveX = -1 self.direction = 3 end
            else
                self.movePhase = "y"
            end

        elseif self.movePhase == "y" then
            if absDy > self.chaseCloseness then
                if dy > 0 then moveY = 1 self.direction = 1 else moveY = -1 self.direction = 2 end
            else
                self.movePhase = "x"
            end
        end

        if absDx < self.chaseCloseness and absDy < self.chaseCloseness then
            self.movePhase = nil
        end
    end

    if moveX ~= 0 or moveY ~= 0 then
        self.x = self.x + moveX * self.speed * dt
        self.y = self.y + moveY * self.speed * dt

        self.animationTimer = self.animationTimer + dt
        if self.animationTimer >= self.frameRate then
            self.currentFrame = (self.currentFrame % 8) + 1
            self.animationTimer = 0
        end
    else
        self.currentFrame = 1
    end
end

function Slime1:draw()
    --Slime itself
    local frame = self.animations[self.direction][self.currentFrame]
    love.graphics.draw(
        self.spriteSheet,
        frame,
        self.x,
        self.y,
        0,
        1,
        1,
        self.width / 2,
        self.height
    )

    --aura
    love.graphics.setColor(0, 0.76, 1, 0.5)
    love.graphics.draw(
        self.auraSheet,
        self.x,
        self.y,
        0,
        self.aura,
        self.aura,
        self.auraSheet:getWidth()/2,
        self.auraSheet:getHeight()/2 + 130
    )
    love.graphics.setColor(1, 1, 1, 1)
end

return Slime1
