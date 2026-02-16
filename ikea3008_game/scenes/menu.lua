-- Menu Scene for IKEA 3008 Game
-- Handles the main menu interface

local menu = {}

function menu:init()
    print("Initializing Menu Scene")
    self.selected_option = 1
    self.options = {
        "Single Player",
        "Settings",
        "Exit"
    }
end

function menu:update(dt)
    -- Handle menu navigation
    if love.keyboard.wasPressed('down') then
        self.selected_option = math.min(self.selected_option + 1, #self.options)
    elseif love.keyboard.wasPressed('up') then
        self.selected_option = math.max(self.selected_option - 1, 1)
    elseif love.keyboard.wasPressed('return') then
        self:selectOption()
    end
end

function menu:draw()
    love.graphics.setColor(1, 1, 1)
    
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    -- Draw title
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("IKEA 3008", 0, screen_height * 0.2, screen_width, "center")
    
    -- Draw menu options
    love.graphics.setFont(love.graphics.newFont(24))
    for i, option in ipairs(self.options) do
        if i == self.selected_option then
            love.graphics.setColor(1, 1, 0) -- Yellow for selected
        else
            love.graphics.setColor(1, 1, 1) -- White for unselected
        end
        love.graphics.printf(option, 0, screen_height * 0.4 + i * 40, screen_width, "center")
    end
    
    love.graphics.setColor(1, 1, 1)
end

function menu:selectOption()
    if self.selected_option == 1 then
        -- Single Player option selected
        print("Starting Single Player Game")
        -- Load the single player scene
    elseif self.selected_option == 2 then
        -- Settings option selected
        print("Opening Settings")
        -- Load settings scene
    elseif self.selected_option == 3 then
        -- Exit option selected
        love.event.quit()
    end
end

function menu:keypressed(key)
    -- Handle key presses specific to menu
end

return menu