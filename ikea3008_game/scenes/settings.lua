-- Settings Scene for IKEA 3008 Game
-- Handles game settings configuration

local settings = {}
local game_modes = {"Survival", "Creative", "Hardcore"}
local difficulties = {"Easy", "Peaceful", "Normal", "Hard"}

function settings:init()
    print("Initializing Settings Scene")
    self.selected_setting = 1
    self.game_mode = 1  -- Default: Survival
    self.difficulty = 3  -- Default: Normal
    self.day_duration = 10  -- Default: 10 minutes
    self.night_duration = 5  -- Default: 5 minutes
    self.show_secret_settings = false
    self.secret_clicks = 0
    self.setting_options = {
        {name = "Game Mode", values = game_modes, current = self.game_mode},
        {name = "Difficulty", values = difficulties, current = self.difficulty},
        {name = "Day Duration (min)", min = 1, max = 60, current = self.day_duration},
        {name = "Night Duration (min)", min = 1, max = 30, current = self.night_duration},
        {name = "Secret Settings", action = true, name = "Click 5 times to unlock"},
        {name = "Back to Menu"}
    }
end

function settings:update(dt)
    -- Handle settings navigation
    if love.keyboard.wasPressed('down') then
        self.selected_setting = math.min(self.selected_setting + 1, #self.setting_options)
    elseif love.keyboard.wasPressed('up') then
        self.selected_setting = math.max(self.selected_setting - 1, 1)
    elseif love.keyboard.wasPressed('left') then
        self:changeSetting(-1)
    elseif love.keyboard.wasPressed('right') then
        self:changeSetting(1)
    elseif love.keyboard.wasPressed('return') then
        self:selectSetting()
    end
end

function settings:draw()
    love.graphics.setColor(1, 1, 1)
    
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    -- Draw title
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("Settings", 0, screen_height * 0.1, screen_width, "center")
    
    -- Draw settings options
    love.graphics.setFont(love.graphics.newFont(20))
    for i, option in ipairs(self.setting_options) do
        if i == self.selected_setting then
            love.graphics.setColor(1, 1, 0) -- Yellow for selected
        else
            love.graphics.setColor(1, 1, 1) -- White for unselected
        end
        
        local y_pos = screen_height * 0.25 + i * 30
        
        -- Draw setting name
        love.graphics.print(option.name, screen_width * 0.25, y_pos)
        
        -- Draw current value if applicable
        if option.values then
            love.graphics.print(option.values[option.current], screen_width * 0.6, y_pos)
        elseif option.min and option.max then
            love.graphics.print(tostring(option.current), screen_width * 0.6, y_pos)
        elseif option.action then
            if self.show_secret_settings then
                love.graphics.print("Unlocked!", screen_width * 0.6, y_pos)
            else
                love.graphics.print("Locked", screen_width * 0.6, y_pos)
            end
        end
    end
    
    if self.show_secret_settings then
        love.graphics.setColor(0, 1, 0) -- Green for secret settings
        love.graphics.printf("SECRET SETTINGS UNLOCKED", 0, screen_height * 0.85, screen_width, "center")
    end
    
    love.graphics.setColor(1, 1, 1)
end

function settings:changeSetting(direction)
    local option = self.setting_options[self.selected_setting]
    
    if option.values then
        -- Cycle through values
        option.current = math.max(1, math.min(#option.values, option.current + direction))
        
        -- Update internal value
        if option.name == "Game Mode" then
            self.game_mode = option.current
        elseif option.name == "Difficulty" then
            self.difficulty = option.current
        end
    elseif option.min and option.max then
        -- Adjust numeric value
        option.current = math.max(option.min, math.min(option.max, option.current + direction))
        
        -- Update internal value
        if option.name == "Day Duration (min)" then
            self.day_duration = option.current
        elseif option.name == "Night Duration (min)" then
            self.night_duration = option.current
        end
    end
end

function settings:selectSetting()
    local option = self.setting_options[self.selected_setting]
    
    if option.name == "Secret Settings" then
        self.secret_clicks = self.secret_clicks + 1
        if self.secret_clicks >= 5 then
            self.show_secret_settings = true
            print("Secret settings unlocked!")
        end
    elseif option.name == "Back to Menu" then
        print("Returning to main menu")
        -- Code to return to main menu would go here
    end
end

function settings:keypressed(key)
    -- Handle key presses specific to settings
end

return settings