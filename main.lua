local Grid = require('modules.grid')

local tilemap ---@type love.Image
local batch ---@type love.SpriteBatch

local grid ---@type Grid
local sprites = {} ---@type love.Quad[]

function love.load()
    tilemap = love.graphics.newImage('assets/tilemap.png')
    tilemap:setFilter("nearest", "nearest")
    batch = love.graphics.newSpriteBatch(tilemap)
    local tilemap_x, tilemap_y = tilemap:getDimensions()
    for j = 1, 16 do
        for i = 1, 16 do
            table.insert(sprites, love.graphics.newQuad((i - 1) * 16, (j - 1) * 16, 16, 16, tilemap_x, tilemap_y))
        end
    end

    grid = Grid.new(32, 32)

    local noise_base_x, noise_base_y = love.math.random(0, 255), love.math.random(0, 255)
    for y = 1, 32 do
        for x = 1, 32 do
            grid:set(x, y, math.floor(love.math.noise(noise_base_x + x / 16, noise_base_y + y / 16) * 2))
        end
    end
end

function love.draw()
    batch:clear()
    grid:draw(batch, sprites)
    love.graphics.draw(batch)
end
