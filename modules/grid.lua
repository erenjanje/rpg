local new = require('table.new')
local ffi = require('ffi')

---@class Grid
local Grid = {
    Types = {
        Water = 0,
        Ground = 1,
    },
    BASE = 0,
    CHUNK_SIZE_X = 16,
    CHUNK_SIZE_Y = 16,
}
Grid.__index = Grid

for _, _ in pairs(Grid.Types) do
    Grid.BASE = Grid.BASE + 1
end

---@param chunk_x number
---@param chunk_y number
---@return Grid
function Grid.new(chunk_x, chunk_y)
    ---@class Grid
    local self = setmetatable(new(Grid.CHUNK_SIZE_X * Grid.CHUNK_SIZE_Y, 2), Grid)
    self.data = love.image.newImageData(Grid.CHUNK_SIZE_X, Grid.CHUNK_SIZE_Y)
    self.pointer = ffi.cast('uint32_t*', self.data:getFFIPointer()) ---@type ffi.cdata*
    for y = 0, Grid.CHUNK_SIZE_Y - 1 do
        for x = 0, Grid.CHUNK_SIZE_X - 1 do
            local index = Grid.CHUNK_SIZE_X * y + x
            local noise = love.math.noise(x * (1 / Grid.CHUNK_SIZE_X) + chunk_x,
                y * (1 / Grid.CHUNK_SIZE_Y) + chunk_y)
            self.pointer[index] = bit.bor(noise < 0.5 and 0 or 1, 0xFF000000)
        end
    end

    self.tiles = love.image.newImageData(Grid.CHUNK_SIZE_X, Grid.CHUNK_SIZE_Y)
    self.tile_pointer = ffi.cast('uint32_t*', self.tiles:getFFIPointer())
    for y = 0, Grid.CHUNK_SIZE_Y - 2 do
        for x = 0, Grid.CHUNK_SIZE_X - 2 do
            local tile_index = (Grid.CHUNK_SIZE_X) * y + x

            local top_left = self.pointer[Grid.CHUNK_SIZE_X * y + x]
            local top_right = self.pointer[Grid.CHUNK_SIZE_X * y + (x + 1)]
            local bottom_left = self.pointer[Grid.CHUNK_SIZE_X * (y + 1) + x]
            local bottom_right = self.pointer[Grid.CHUNK_SIZE_X * (y + 1) + (x + 1)]

            local value = top_left * Grid.BASE^0 + top_right * Grid.BASE^1 + bottom_left * Grid.BASE^2 + bottom_right * Grid.BASE^3

            self.tile_pointer[tile_index] = bit.bor(value, 0xFF000000)
        end
    end

    self.image = love.graphics.newImage(self.data)
    self.image:setFilter('nearest', 'nearest')

    self.tile_image = love.graphics.newImage(self.tiles)
    self.tile_image:setFilter('nearest', 'nearest')

    return self
end

---@param x number
---@param y number
---@overload fun(self, index: number): number
---@return number
function Grid:at(x, y)
    if y then
        return self.pointer[Grid.CHUNK_SIZE_X * (y - 1) + (x - 1)]
    else
        return self.pointer[x - 1]
    end
end

---@param x number
---@param y number
---@param value number
---@overload fun(self, index: number, value: number)
function Grid:set(x, y, value)
    if not value then
        value = y
        self.pointer[x - 1] = value
    else
        self.pointer[(y - 1) * Grid.CHUNK_SIZE_X + (x - 1)] = value
    end
    self.image:replacePixels(self.data)
end

---@param pos_x number?
---@param pos_y number?
function Grid:draw(pos_x, pos_y)
    pos_x = pos_x or 0
    pos_y = pos_y or 0
    love.graphics.draw(self.tile_image, pos_x, pos_y, 0, 32, 32)
end

return Grid
