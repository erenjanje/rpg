local Grid = require('modules.grid')

local grid ---@type Grid
local tile_shader ---@type love.Shader
local tilemap_atlas ---@type love.Image

function love.load()
    tilemap_atlas = love.graphics.newImage("assets/tilemap.png")
    tilemap_atlas:setFilter('nearest', 'nearest')

    tile_shader = love.graphics.newShader("shaders/tilemap.glsl")
    grid = Grid.new(0, 1)
    for i = 1, 16 do
        print(('%08x'):format(grid:at(i, i)))
    end
end

function love.draw()
    love.graphics.setShader(tile_shader)
    tile_shader:send('tilemap_atlas', tilemap_atlas)
    grid:draw()
end

function love.keypressed(key)
    if key == 's' and love.keyboard.isDown('lctrl') then
        print('Saving...')
        grid.tiles:encode('png', 'chunk_0_1.png')
    end
end
