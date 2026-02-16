-- Main entry point for IKEA 3008 Game
-- Uses LÖVE framework for game engine

-- Load required libraries
local current_scene = nil

function love.load()
    print("Loading IKEA 3008 Game...")
    
    -- Initialize the game
    initGame()
end

function initGame()
    -- Set initial scene to menu
    loadScene("menu")
end

function loadScene(scene_name)
    if current_scene and current_scene.leave then
        current_scene:leave()
    end
    
    local scene_path = "scenes." .. scene_name
    current_scene = require(scene_path)
    
    if current_scene.init then
        current_scene:init()
    end
end

function love.update(dt)
    if current_scene and current_scene.update then
        current_scene:update(dt)
    end
end

function love.draw()
    if current_scene and current_scene.draw then
        current_scene:draw()
    end
end

function love.keypressed(key)
    if current_scene and current_scene.keypressed then
        current_scene:keypressed(key)
    end
    
    -- Global key handling
    if key == "escape" then
        love.event.quit()
    end
end

-- Helper function to detect key presses (not built into LOVE by default)
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed then
        return love.keyboard.keysPressed[key]
    end
    return false
end

-- Reset pressed keys at the beginning of each frame
function love.update(dt)
    love.keyboard.keysPressed = {}
    
    if current_scene and current_scene.update then
        current_scene:update(dt)
    end
end

-- Callback function to handle key press events
function love.keypressed(key)
    if not love.keyboard.keysPressed then
        love.keyboard.keysPressed = {}
    end
    love.keyboard.keysPressed[key] = true
    
    if current_scene and current_scene.keypressed then
        current_scene:keypressed(key)
    end
    
    -- Global key handling
    if key == "escape" then
        love.event.quit()
    end
end