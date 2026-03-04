--This class generates objects on the map
local objectGeneration = {}
objectGeneration.__index = objectGeneration
--Function to randomly pick image from a folder
local function pickRandomImage(folder)
    local files = love.filesystem.getDirectoryItems(folder)
    if #files == 0 then return nil end
    local file = files[math.random(1, #files)]
    return love.graphics.newImage(folder .. "/" .. file)
end


function objectGeneration:new()
    local obj = setmetatable({}, self)

    --Main variables
    obj.pointScale = 0.1
    obj.generalObjectDensity = 17
    obj.ruinsDensity = 10
    obj.rocksDensity = 5
    obj.safeDistanceFromCenter = 200
    obj.distanceBetweenObjectsMultiplier = 2
    obj.pointHitboxMultipier = 0.3


    --Auxiliary variables
    obj.generationIterationNumber = obj.generalObjectDensity * 100
    obj.point = love.graphics.newImage("Sprites/Particles/apoint.png")
    obj.pointWidth = obj.point:getWidth() * obj.pointScale
    obj.pointHeight = obj.point:getHeight() * obj.pointScale
    obj.pointExists = false
    obj.pointX = 0
    obj.pointY = 0

    --This part gives us random objects using the function above and density variables above. The values I chose are meant for
    --1920x1080 resolution.
    obj.objectSet = {}
    local j = 1
    for i=1, obj.generalObjectDensity do
        j = j + 1
        table.insert(obj.objectSet,pickRandomImage("Sprites/Objects/Bushes"))
        table.insert(obj.objectSet,pickRandomImage("Sprites/Objects/Trees"))
        if j > obj.ruinsDensity then table.insert(obj.objectSet,pickRandomImage("Sprites/Objects/Ruins")) end
        if j > obj.rocksDensity then table.insert(obj.objectSet,pickRandomImage("Sprites/Objects/Rocks")) end
    end

    --This handles generating coordinates for objects. To prevent overlapping of objects on the map logic is following: for all objects in table check if newly generated
    --coordinates are close to the object with width*2 value. if they are, consider these values as invalid and start the process again. number of iterations is general density
    --times 100 so that it is statistically impossible for this loop not to give us enough valid values.
    obj.objects = {}
    for i = 1, #obj.objectSet do
        local sprite = obj.objectSet[i]
        local spriteWidth = sprite:getWidth()
        local spriteHeight = sprite:getHeight()
        local x,y
        local valid = false

        for k = 1, obj.generationIterationNumber do
            x = math.random(0,love.graphics.getWidth() - spriteWidth)
            y = math.random(0,love.graphics.getHeight() - spriteHeight)
            while math.abs(x - love.graphics.getWidth() / 2) < obj.safeDistanceFromCenter and math.abs(y - love.graphics.getHeight() / 2) < obj.safeDistanceFromCenter do
                x = math.random(0,love.graphics.getWidth() - spriteWidth)
                y = math.random(0,love.graphics.getHeight() - spriteHeight)
            end



            valid = true
            for _, other in ipairs(obj.objects) do
                local dx = other.x - x
                local dy = other.y - y 
                if math.sqrt(dx*dx+dy*dy) < spriteWidth * obj.distanceBetweenObjectsMultiplier then
                    valid = false
                    break
                end
            end
            if valid then break end
        end



        if valid then
            table.insert(obj.objects, 
            {image = sprite,
            x=x,
            y=y,
            width = spriteWidth,
            height = spriteHeight,})
        end
    end


    return obj
end

function objectGeneration:update(dt)
    if self.pointExists == false then
        self:spawnPoint()
    end
end

function objectGeneration:draw()
    for _, o in ipairs(self.objects) do
        love.graphics.draw(o.image, o.x, o.y)
    end

    if self.pointExists == true then
        love.graphics.setColor(1,0.84,0,1)
        love.graphics.draw(self.point,self.pointX - 10,self.pointY - 10,0,self.pointScale,self.pointScale)
        love.graphics.setColor(1,1,1,1)
    end
end


--Function to spawn a point. same logic as above for overlapping
function objectGeneration:spawnPoint()
    local i = 0
    while i ~= 1 do
        local x = math.random(0, love.graphics.getWidth() - self.pointWidth)
        local y = math.random(0, love.graphics.getHeight() - self.pointHeight)
        local valid = true


        for _, other in ipairs(self.objects) do
            if x + self.pointWidth > other.x and x < other.x + other.width and
               y + self.pointHeight > other.y and y < other.y + other.height then
                valid = false
                break
            end
        end


        if valid then
            self.pointX, self.pointY = x, y
            self.pointExists = true
            i = 1
            return
        end
    end
end


function objectGeneration:pointCircleCollision(other)
    local pointCenterX = self.pointX + self.pointWidth / 2
    local pointCenterY = self.pointY + self.pointHeight / 2
    local dx = pointCenterX - other.x
    local dy = pointCenterY - other.y
    local distance = math.sqrt(dx^2 + dy^2)

    local radius1 = math.max(self.pointWidth, self.pointHeight)/2 * self.pointHitboxMultipier
    local radius2 = math.max(other.width, other.height)/2

    return distance < (radius1 + radius2)
end

return objectGeneration
