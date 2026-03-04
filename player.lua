local Slime1 = require("slime1")
local Slime2 = require("slime2")
local Slime3 = require("slime3")

local Player = {}
Player.__index = Player

function Player:new(x, y)
    local obj = setmetatable({}, self)
    --Sprites and font
    obj.spriteSheet = love.graphics.newImage("Sprites/mushroomanim.png")
    obj.dashSheet = love.graphics.newImage("Sprites/Particles/dash.png")
    obj.healthBar3 = love.graphics.newImage("Sprites/3HPmushroom.png")
    obj.healthBar2 = love.graphics.newImage("Sprites/2HPmushroom.png")
    obj.healthBar1 = love.graphics.newImage("Sprites/1HPmushroom.png")
    obj.healthBar0 = love.graphics.newImage("Sprites/0HPmushroom.png")
    obj.point = love.graphics.newImage("Sprites/Particles/apoint.png")
    obj.gameFont = love.graphics.newFont("gameFont.ttf",32)

    --Main variables
    obj.x = x
    obj.y = y
    obj.speed = 150
    obj.health = 3
    obj.dashDuration = 0.3
    obj.dashCooldown = 3
    obj.dashDistance = 100
    obj.damageCooldown = 3



    --Auxiliary variables
    obj.width = 31
    obj.height = 40

    obj.damageTimer = 0
    obj.direction = 1
    obj.isIdle = true
    --Dash variables
    obj.dashCoords = {nil,nil}
    obj.dashOrientation = 0
    obj.dashTimer = 0
    obj.dashCooldownTimer = 0





    --Animation
    obj.frames = {}
    for i = 0, 3 do
        obj.frames[i+1] = love.graphics.newQuad(
            i * 31, 0, 31, 40,
            obj.spriteSheet:getDimensions()
        )
    end
    obj.currentFrame = 1
    obj.animationTimer = 0
    obj.frameRate = 0.2
    return obj
end

function Player:update(dt)
    --Standard simple movement
    self.isIdle = true
    local move_v = 0
	local move_h = 0

	if love.keyboard.isDown("s") then
        move_v = 1
        self.isIdle = false
    end
	if love.keyboard.isDown("w") then
        move_v = -1
        self.isIdle = false
    end 
	if love.keyboard.isDown("a") then
        move_h = -1
        self.isIdle = false 
        self.direction = 1
    end 
	if love.keyboard.isDown("d") then 
        move_h = 1 
        self.isIdle = false 
        self.direction = -1 
    end
	local dir = math.atan2(move_v, move_h)
	if move_v ~= 0 or move_h ~= 0 then
		self.x = self.x + math.cos(dir) * self.speed * dt
		self.y = self.y + math.sin(dir) * self.speed * dt
	end


    self.animationTimer = self.animationTimer + dt
    if not self.isIdle and self.animationTimer >= self.frameRate then
        self.currentFrame = self.currentFrame % 4 + 1
        self.animationTimer = 0
    end
    --First frame of mushroom's animation is used as idling state frame.
    if self.isIdle then
        self.currentFrame = 1
    end

    --Dash despawn timer.
    if self.dashCoords[1] then
        self.dashTimer = self.dashTimer + dt
        if self.dashTimer >= self.dashDuration then
            self.dashCoords = {nil,nil}
            self.dashTimer = 0
        end
    end

    --cooldown timer should update here, because dash cooldown is checked in main.lua on keypressed event.
    self.dashCooldownTimer = self.dashCooldownTimer + dt

    --Boundry check for map
    self:BoundryCheck()
end

function Player:draw()
    --Player
    local playerScale = 0.5
    love.graphics.draw(
        self.spriteSheet,
        self.frames[self.currentFrame],
        self.x, 
        self.y,
        0, 
        self.direction * playerScale,
        playerScale, 
        self.width / 2,
        self.height)
        
    --Dash effect
    if self.dashCoords[1] then 
        love.graphics.setColor(1, 0.62, 0.47, 1)
        love.graphics.draw(self.dashSheet,self.dashCoords[1],self.dashCoords[2],self.dashOrientation,0.5,0.3,self.dashSheet:getHeight()/2 - 120,self.dashSheet:getWidth()/2)
        love.graphics.setColor(1, 1, 1, 1)
    end

    --HP HUD
    local hpXcoord, hpYcoord = 30,30
    if self.health == 3 then
        love.graphics.draw(self.healthBar3,hpXcoord,hpYcoord,0,2)
    end
    if self.health == 2 then
        love.graphics.draw(self.healthBar2,hpXcoord,hpYcoord,0,2)
    end
    if self.health == 1 then
        love.graphics.draw(self.healthBar1,hpXcoord,hpYcoord,0,2)
    end
    if self.health == 0 then
        love.graphics.draw(self.healthBar0,hpXcoord,hpYcoord,0,2)
    end

    --Points sprite + text
    love.graphics.setColor(1,0.84,0,1)
    love.graphics.draw(self.point,70,55,0,0.1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Points: ",self.gameFont,110,65,0,1)
end

--Circle collision checking for slimes
function Player:checkCircleCollision(slimeTable)
    local standardSlimeRadius = 0.3
    local necroSlimeRadius = 0.75
    local lavalSlimeRadius = 0.9

    for _, slime in ipairs(slimeTable) do
        local dx = self.x - slime.x
        local dy = self.y - slime.y
        local distance = math.sqrt(dx*dx + dy*dy)

        local radius1 = math.max(self.width, self.height) * 0.5
        local radius2
    if getmetatable(slime) == Slime2 then
        radius2 = math.max(slime.width, slime.height) * necroSlimeRadius
    end
    if getmetatable(slime) == Slime1 then
        radius2 = math.max(slime.width, slime.height) * standardSlimeRadius
    end
    if getmetatable(slime) == Slime3 then
        radius2 = math.max(slime.width, slime.height) * standardSlimeRadius
        if slime.attacking then
        radius2 = math.max(slime.width, slime.height) * lavalSlimeRadius
        end
    end

        if distance < (radius1 + radius2) then
            return true
        end
    end
    return false
end

--Rectangle collisions checking for world objects. I use scale because sprites were messed up in resolutions
function Player:checkRectangleCollision(other)
local scale = 0.005
    local left1   = self.x - self.width/2 * scale
    local right1  = self.x + self.width/2 * scale
    local top1    = self.y - self.height * scale
    local bottom1 = self.y

    local left2   = other.x
    local right2  = other.x + other.width
    local top2    = other.y
    local bottom2 = other.y + other.height

    return right1 > left2 and left1 < right2 and bottom1 > top2 and top1 < bottom2
end


--Dash movement method. Because dash is only diagonal, it checks if player is moving diagonally, meaning if player is pressing any pair of (w,s) or (a,d) keys.
--If he has, he dashes which is basically teleportation which effectively avoids any contant with enemy NPC. The player should be cautious not to dash into world objects
--and get stuck there before becoming able to perform another new dash.
function Player:moveDiagonally()
    if love.keyboard.isDown("s") and love.keyboard.isDown("d") then
        self.dashCoords[1] = self.x 
        self.dashCoords[2] = self.y
        self.x = self.x + self.dashDistance
        self.y = self.y + self.dashDistance
        self.dashOrientation = math.rad(45)
    end
    if love.keyboard.isDown("s") and love.keyboard.isDown("a") then
        self.dashCoords[1] = self.x 
        self.dashCoords[2] = self.y
        self.x = self.x - self.dashDistance
        self.y = self.y + self.dashDistance
        self.dashOrientation = math.rad(135)
    end
    if love.keyboard.isDown("w") and love.keyboard.isDown("d") then
        self.dashCoords[1] = self.x 
        self.dashCoords[2] = self.y
        self.x = self.x + self.dashDistance
        self.y = self.y - self.dashDistance
        self.dashOrientation = math.rad(-45)
    end
    if love.keyboard.isDown("w") and love.keyboard.isDown("a") then
        self.dashCoords[1] = self.x 
        self.dashCoords[2] = self.y
        self.x = self.x - self.dashDistance
        self.y = self.y - self.dashDistance
        self.dashOrientation = math.rad(-135)
    end
end

--Method to prevent player from going out of bounds
function Player:BoundryCheck()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local yTopOffset = 15
    local yBottomOffset = 30

    if self.x < 0 then self.x = 0
    elseif self.x + self.width > screenWidth then self.x = screenWidth - self.width end
    if self.y < yTopOffset then self.y = yTopOffset
    elseif self.y + self.height - yBottomOffset > screenHeight then self.y = screenHeight - self.height + yBottomOffset end
end

return Player
