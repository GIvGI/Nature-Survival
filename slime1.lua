--Main slime NPC class. (Slime2 and Slime3 are addition of this class)
local Slime1 = {}
Slime1.__index = Slime1

function Slime1:new(x, y)
    local obj = setmetatable({}, self)

    --Main variables
    obj.x = x
    obj.y = y
    obj.speed = math.random(90,120)
    obj.chaseCloseness = 1 --Limit of how close slime can get to the player

    obj.direction = 1
    obj.spriteSheet = love.graphics.newImage("Sprites/Slimes/Slime1_Run_without_shadow.png")

    --Animation
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
    --If player exists then chase them
    if target then
        --Since game is really simple and the player has no power ups and stuff, giving slimes free movement would put player in great disadvantage since slimes would use
        --shortest path to reach player. For that reason slimes are limited to only moving vertically or horizontally.

        local playerCenterX = target.x + target.width/2 - 12 -- -I don't remember what this -12 offset is. probably visual fix.
        local playerCenterY = target.y + target.height/2
        local dx = playerCenterX - self.x
        local dy = playerCenterY - self.y
        local absDx = math.abs(dx)
        local absDy = math.abs(dy)

        --NPC starts moving on the axis it is closest to the player.
        if not self.movePhase then
            if absDx > absDy then self.movePhase = "x"
            else self.movePhase = "y" end
        end

        --Directions for the axis movement.
        --If x axis is closest then start moving left or right until you get close enough to the player on x axis, then change movement to y axis.
        if self.movePhase == "x" then
            if absDx > self.chaseCloseness then
                if dx > 0 then moveX = 1 self.direction = 4 else moveX = -1 self.direction = 3 end
            else
                self.movePhase = "y"
            end
            
        --Same logic as above but inverted
        elseif self.movePhase == "y" then
            if absDy > self.chaseCloseness then
                if dy > 0 then moveY = 1 self.direction = 1 else moveY = -1 self.direction = 2 end
            else
                self.movePhase = "x"
            end
        end

        --If close enough on both axes then stop moving.
        if absDx < self.chaseCloseness and absDy < self.chaseCloseness then
            self.movePhase = nil
        end
    end

    --update for movement and animation
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
end

return Slime1
