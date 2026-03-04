local Player = require("player")
local Slime1 = require("slime1")
local Slime2 = require("slime2")
local Slime3 = require("slime3")
local Introductions = require("introductions")
local objectGeneration = require("objectGeneration")
local tileMapGeneration = require("tileMapGeneration")
function love.load()
    --Main variables
    slimeSpawnInterval= 5
    maxNumberSlimes = 20
    slimeEdgeSpawnDistance = 200
    gameOverText = "GAME OVER!"

    --Auxiliary variables
    math.randomseed(os.time())
    introductions = Introductions:new()
    gameFont = love.graphics.newFont("gameFont.ttf",64)
    playerCharacter = Player:new(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
    objects = objectGeneration:new()
    tileMap = tileMapGeneration:new()

    gameOver = false
    gameOverTimer = 0
    slimeCount = 0
    timer = 0
    totalPoints = 0
    slimes = {}
end

function love.update(dt)
    introductions:update(dt)
    tileMap:update(dt)

    --slime spawn interval timer
    timer = timer + dt
    if timer >= slimeSpawnInterval then
        if slimeCount <= maxNumberSlimes then
            slimeCount = slimeCount + 1
        end
        timer = timer - slimeSpawnInterval

        --This direction determines where the slimes spawn. North/South/West/East
        local spawnDirection = math.random(1,4)
        local x,y
        if spawnDirection == 1 then -- north
            x = math.random(0, love.graphics.getWidth())
            y = slimeEdgeSpawnDistance * -1
        elseif spawnDirection == 2 then --south
            x = math.random(0, love.graphics.getWidth())
            y = love.graphics.getHeight() + slimeEdgeSpawnDistance
        elseif spawnDirection == 3 then --west
            x = slimeEdgeSpawnDistance * -1
            y = math.random(0, love.graphics.getHeight())
        elseif spawnDirection == 4 then --east
            x = love.graphics.getWidth() + slimeEdgeSpawnDistance
            y = math.random(0,love.graphics.getHeight())
        end


        --Which type of slime spawns. All 3 of them have same chances
        local slimeChooser = math.random(1,3)
        if slimeChooser == 1  then
            table.insert(slimes, Slime1:new(x, y))
        elseif slimeChooser == 2 then
            table.insert(slimes, Slime2:new(x, y)) 
        else 
            table.insert(slimes, Slime3:new(x, y)) 
        end
    end

local oldCollisionX, oldCollisionY = playerCharacter.x, playerCharacter.y
playerCharacter:update(dt)
for _, slime in ipairs(slimes) do
    slime:update(dt, playerCharacter)
end
objects:update(dt)

--Damage cooldown was needed so the player didn't take bunch of damage on a single collision.
playerCharacter.damageTimer = playerCharacter.damageTimer + dt
if playerCharacter:checkCircleCollision(slimes) and playerCharacter.damageTimer >= playerCharacter.damageCooldown then
    playerCharacter.damageTimer = 0
    playerCharacter.health = playerCharacter.health - 1
end

--Collision handling for objects in the world. If player collides with any of them, simply put player back to old coordinates before collision happened
for _, obj in ipairs(objects.objects) do
    if playerCharacter:checkRectangleCollision(obj) then
        playerCharacter.x = oldCollisionX
        playerCharacter.y = oldCollisionY
        break
    end
end

objects:update(dt)

--If player collides with point, despawn it and give player +1 points
if objects.pointExists and objects:pointCircleCollision(playerCharacter) then
    objects.pointExists = false
    totalPoints = totalPoints + 1
end

--Restart timer. GAME OVER! text is visible for 3 seconds and then game restarts.
if gameOver then
    gameOverTimer = gameOverTimer - dt
    if gameOverTimer <= 0 then
        love.event.quit('restart')
    end
    return
end
if playerCharacter.health <= 0 then
    gameOver = true
    gameOverTimer = 3
    return
end
end

function love.draw()
    if playerCharacter.health > 0 then
    tileMap:draw()
    love.graphics.setBackgroundColor(0, 0.6, 0)
    objects:draw()
    for _, slime in ipairs(slimes) do slime:draw() end
    love.graphics.print(tostring(totalPoints),gameFont, 200, 65,0,0.5)
    introductions:draw()
    playerCharacter:draw()
end

if gameOver then
    love.graphics.setBackgroundColor(0,0,0)
    love.graphics.setColor(1,1,1)
    local textWidth = gameFont:getWidth(gameOverText)
    local textHeight = gameFont:getHeight(gameOverText)
    love.graphics.print(gameOverText, gameFont,
    (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() - textHeight) / 2 ,0,1)
end

end

--Pressing space directly calls dash function, which separately checks diagonal movement condition.
function love.keypressed(key)
    if key == "space" then
        if playerCharacter.dashCooldownTimer >= playerCharacter.dashCooldown then
        playerCharacter:moveDiagonally()
        playerCharacter.dashCooldownTimer = 0
        end
    end
end