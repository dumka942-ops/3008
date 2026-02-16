-- Game World Scene for IKEA 3008 Game
-- Handles the main gameplay in the IKEA world

local game_world = {}

function game_world:init()
    print("Initializing Game World Scene")
    
    -- Initialize game state
    self.player_x = 0
    self.player_y = 0
    self.player_z = 0
    self.inventory = {}
    self.held_object = nil
    self.rotation_angle = 0
    self.game_mode = "survival"  -- Default mode
    self.difficulty = "normal"   -- Default difficulty
    self.time_of_day = "day"     -- day or night
    self.day_timer = 0           -- Timer for day/night cycle
    
    -- Initialize IKEA world objects
    self.objects = {}
    self.generateWorld()
end

function game_world:generateWorld()
    -- Generate an infinite IKEA-like world with furniture and objects
    print("Generating IKEA world...")
    
    -- Create initial objects around the player spawn point
    for x = -10, 10, 2 do
        for z = -10, 10, 2 do
            -- Randomly place some IKEA furniture
            local obj_type = math.random(1, 4)
            if obj_type == 1 then
                table.insert(self.objects, {x = x, y = 0, z = z, type = "chair", rotation = 0})
            elseif obj_type == 2 then
                table.insert(self.objects, {x = x, y = 0, z = z, type = "table", rotation = 0})
            elseif obj_type == 3 then
                table.insert(self.objects, {x = x, y = 0, z = z, type = "shelf", rotation = 0})
            else
                table.insert(self.objects, {x = x, y = 0, z = z, type = "box", rotation = 0})
            end
        end
    end
end

function game_world:update(dt)
    -- Handle player movement
    local move_speed = 5
    if love.keyboard.isDown('w') then
        self.player_x = self.player_x + math.sin(self.rotation_angle) * move_speed * dt
        self.player_z = self.player_z + math.cos(self.rotation_angle) * move_speed * dt
    end
    if love.keyboard.isDown('s') then
        self.player_x = self.player_x - math.sin(self.rotation_angle) * move_speed * dt
        self.player_z = self.player_z - math.cos(self.rotation_angle) * move_speed * dt
    end
    if love.keyboard.isDown('a') then
        self.player_x = self.player_x + math.sin(self.rotation_angle - math.pi/2) * move_speed * dt
        self.player_z = self.player_z + math.cos(self.rotation_angle - math.pi/2) * move_speed * dt
    end
    if love.keyboard.isDown('d') then
        self.player_x = self.player_x + math.sin(self.rotation_angle + math.pi/2) * move_speed * dt
        self.player_z = self.player_z + math.cos(self.rotation_angle + math.pi/2) * move_speed * dt
    end
    
    -- Handle mouse look
    if love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        local center_x, center_y = love.graphics.getWidth()/2, love.graphics.getHeight()/2
        local dx, dy = mx - center_x, my - center_y
        
        -- Rotate player based on mouse movement
        self.rotation_angle = self.rotation_angle + dx * 0.005
        
        -- Reset mouse to center
        love.mouse.setPosition(center_x, center_y)
    end
    
    -- Handle object interaction
    if love.keyboard.wasPressed('e') then
        self:interactWithObject()
    end
    
    -- Handle object rotation when holding an object
    if self.held_object and love.keyboard.wasPressed('q') then
        self.held_object.rotation = self.held_object.rotation + 15
    end
    if self.held_object and love.keyboard.wasPressed('r') then
        self.held_object.rotation = self.held_object.rotation - 15
    end
    
    -- Update day/night cycle
    self:updateDayNightCycle(dt)
    
    -- Spawn NPCs based on difficulty
    self:spawnNPCs()
end

function game_world:draw()
    -- Draw the 3D world
    love.graphics.clear(0.5, 0.7, 1) -- Sky color
    
    -- Draw world objects
    for _, obj in ipairs(self.objects) do
        self:drawObject(obj)
    end
    
    -- Draw UI elements
    self:drawUI()
end

function game_world:drawObject(obj)
    -- Draw a simple representation of an object
    local screen_x = (obj.x - self.player_x) * 20 + love.graphics.getWidth()/2
    local screen_y = (obj.z - self.player_z) * 20 + love.graphics.getHeight()/2
    
    -- Simple cube drawing
    love.graphics.setColor(0.8, 0.6, 0.4) -- Wood color for furniture
    if obj.type == "chair" then
        love.graphics.rectangle("fill", screen_x - 10, screen_y - 10, 20, 20)
    elseif obj.type == "table" then
        love.graphics.rectangle("fill", screen_x - 15, screen_y - 15, 30, 30)
    elseif obj.type == "shelf" then
        love.graphics.rectangle("fill", screen_x - 12, screen_y - 20, 24, 40)
    elseif obj.type == "box" then
        love.graphics.rectangle("fill", screen_x - 8, screen_y - 8, 16, 16)
    end
    
    -- Draw rotation indicator
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(screen_x, screen_y, 
                      screen_x + 15 * math.cos(math.rad(obj.rotation)), 
                      screen_y + 15 * math.sin(math.rad(obj.rotation)))
    
    love.graphics.setColor(1, 1, 1)
end

function game_world:drawUI()
    -- Draw UI elements like inventory, held object, etc.
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 10, 10, 200, 30)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Mode: " .. self.game_mode .. " | Difficulty: " .. self.difficulty, 20, 20)
    
    love.graphics.print("Time: " .. self.time_of_day .. " | Day timer: " .. math.floor(self.day_timer), 20, 40)
    
    if self.held_object then
        love.graphics.print("Holding: " .. self.held_object.type .. " (Rotation: " .. self.held_object.rotation .. "°)", 20, 60)
    end
    
    love.graphics.print("Controls: WASD to move, Mouse to look, E to interact, Q/R to rotate held object", 20, love.graphics.getHeight() - 40)
end

function game_world:interactWithObject()
    -- Find closest object to interact with
    local closest_obj = nil
    local closest_dist = math.huge
    
    for _, obj in ipairs(self.objects) do
        local dist = math.sqrt((obj.x - self.player_x)^2 + (obj.z - self.player_z)^2)
        if dist < closest_dist and dist < 3 then
            closest_dist = dist
            closest_obj = obj
        end
    end
    
    if closest_obj then
        if self.held_object == nil then
            -- Pick up object
            self.held_object = closest_obj
            -- Remove from world objects temporarily
            for i, obj in ipairs(self.objects) do
                if obj == closest_obj then
                    table.remove(self.objects, i)
                    break
                end
            end
        else
            -- Place object down
            self.held_object.x = self.player_x + math.sin(self.rotation_angle) * 2
            self.held_object.z = self.player_z + math.cos(self.rotation_angle) * 2
            table.insert(self.objects, self.held_object)
            self.held_object = nil
        end
    end
end

function game_world:updateDayNightCycle(dt)
    -- Update the day/night cycle based on settings
    self.day_timer = self.day_timer + dt
    
    -- For now, we'll just toggle between day and night based on a simple timer
    -- In a real implementation, this would use the settings from the settings scene
    if self.time_of_day == "day" and self.day_timer > 30 then  -- 30 seconds for demo
        self.time_of_day = "night"
        self.day_timer = 0
    elseif self.time_of_day == "night" and self.day_timer > 15 then  -- 15 seconds for demo
        self.time_of_day = "day"
        self.day_timer = 0
    end
end

function game_world:spawnNPCs()
    -- Spawn NPCs (IKEA employees) based on difficulty
    if self.difficulty == "hard" and math.random() < 0.01 then  -- Higher chance on hard mode
        -- Spawn an employee NPC
        local x = self.player_x + math.random(-20, 20)
        local z = self.player_z + math.random(-20, 20)
        print("Spawning employee at: " .. x .. ", " .. z)
    end
end

function game_world:keypressed(key)
    -- Handle key presses specific to game world
    if key == "escape" then
        -- Return to menu
        print("Returning to main menu")
        -- Code to return to main menu would go here
    end
end

return game_world