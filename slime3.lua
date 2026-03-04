--This type has much bigger aura of magma, but while using it the slime is stationary. the most range, the least speed.
local Slime1 = {}
Slime1.__index = Slime1

function Slime1:new(x, y)
    local obj = setmetatable({}, self)

    --Main variables
    obj.x = x
    obj.y = y
    obj.aura = 0
    obj.defaultSpeed = 20
    obj.speed = 0
    obj.chaseCloseness = 1
    obj.attacking = false
    obj.attackSpeed = 5

    obj.attackSpeedTimer = 0
    obj.direction = 1
    obj.spriteSheet1 = love.graphics.newImage("Sprites/Slimes/Slime3_Walk_without_shadow.png")
    obj.spriteSheet2 = love.graphics.newImage("Sprites/Slimes/Slime3_Attack_without_shadow.png")
    obj.auraSheet = love.graphics.newImage("Sprites/Particles/lavaaura.png")
    obj.spriteSheet = obj.spriteSheet1
    
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

    local sheetWidth2, sheetHeight2 = obj.spriteSheet2:getDimensions()
    obj.animations2 = {}
    for row = 0, 3 do
        obj.animations2[row + 1] = {}
        for col = 0, 7 do
            obj.animations2[row + 1][col + 1] = love.graphics.newQuad(
                col * obj.width,
                row * obj.height,
                obj.width,
                obj.height,
                sheetWidth2,
                sheetHeight2
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

    --Timer for attacks
    self.attackSpeedTimer = self.attackSpeedTimer + dt
    if self.attackSpeedTimer >= self.attackSpeed then
        self.attacking = not self.attacking
        self.attackSpeedTimer = 0
    end
    if self.attacking then
        self.speed = 0
        self.aura = 0.5
    else
        self.speed = self.defaultSpeed
        self.aura = 0
    end

end

function Slime1:draw()
    --If it is attacking then it must be drawn accordingly.
    local frame
    if self.attacking then
    frame = self.animations2[self.direction][self.currentFrame]
    self.spriteSheet = self.spriteSheet2
    else 
    frame = self.animations[self.direction][self.currentFrame]
    self.spriteSheet = self.spriteSheet1
    end

    --slime
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

    --aura of magma
    love.graphics.setColor(1, 0.5, 0, 0.7)
    love.graphics.draw(
        self.auraSheet,
        self.x,
        self.y,
        0,
        self.aura,
        self.aura,
        self.auraSheet:getWidth()/2,
        self.auraSheet:getHeight()/2 + 100
    )
    love.graphics.setColor(1, 1, 1, 1)
end

return Slime1
