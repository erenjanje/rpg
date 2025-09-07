local dbg = require('debugger')

local ChunkManager = require('modules.chunk_manager')

local chunk_manager ---@type ChunkManager
local tile_shader ---@type love.Shader
local tilemap_atlas ---@type love.Image

function love.load()
    tilemap_atlas = love.graphics.newImage("assets/tilemap.png")
    tilemap_atlas:setFilter('nearest', 'nearest')

    tile_shader = love.graphics.newShader("shaders/tilemap.glsl")
    chunk_manager = ChunkManager.new()
end

function love.update(dt)
    chunk_manager:createChunk(1, 1)
    chunk_manager:createChunk(2, 1)
    chunk_manager:createChunk(1, 2)
    chunk_manager:createChunk(2, 2)
end

function love.draw()
    love.graphics.setShader(tile_shader)
    tile_shader:send('tilemap_atlas', tilemap_atlas)
    local renderer = chunk_manager:createRenderer(1, 1)
    local image = love.graphics.newImage(renderer)
    image:setFilter("nearest", "nearest")
    love.graphics.draw(image, 0, 0, 0, 32, 32)
end

function love.keypressed(key)
    if key == 's' and love.keyboard.isDown('lctrl') then
        print('Saving...')
        -- chunk_manager:dump()
    end
end
