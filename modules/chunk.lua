local ffi = require('ffi')
local dbg = require('debugger')

---@class Chunk
local Chunk = {}
Chunk.__index = Chunk

---@param generator fun(x: number, y: number): number
---@param chunk_size number
---@return Chunk
function Chunk.new(generator, chunk_size)
    ---@class Chunk
    local self = setmetatable({}, Chunk)
    self.data = love.image.newImageData(chunk_size, chunk_size)
    self.chunk_size = chunk_size

    local pointer = ffi.cast('uint32_t*', self.data:getFFIPointer()) ---@type ffi.cdata*
    for y = 0, chunk_size - 1 do
        for x = 0, chunk_size - 1 do
            local index = chunk_size * y + x
            pointer[index] = generator(x, y)
        end
    end

    return self
end

---@param x number
---@param y number
---@overload fun(self, index: number): number
---@return number
function Chunk:at(x, y)
    x = x - 1
    y = y - 1
    local pointer = ffi.cast('uint32_t*', self.data:getFFIPointer())
    if y then
        return pointer[self.chunk_size * y + x]
    else
        return pointer[x]
    end
end

---@param x number
---@param y number
---@param value number
---@overload fun(self, index: number, value: number)
function Chunk:set(x, y, value)
    x = x - 1
    y = y - 1
    local pointer = ffi.cast('uint32_t*', self.data:getFFIPointer())
    if not value then
        value = y
        pointer[x] = value
    else
        pointer[y * self.chunk_size + x] = value
    end
end

---@param chunk_top_left Chunk
---@param chunk_top_right Chunk
---@param chunk_bottom_left Chunk
---@param chunk_bottom_right Chunk
---@param x number
---@param y number
---@param chunk_size number
local function index(chunk_top_left, chunk_top_right, chunk_bottom_left, chunk_bottom_right, x, y, chunk_size)
    x = x + 1
    y = y + 1
    if x < chunk_size and y < chunk_size then
        return chunk_top_left:at(x, y)
    elseif x < chunk_size and y == chunk_size then
        return chunk_bottom_left:at(x, 1)
    elseif x == chunk_size and y < chunk_size then
        return chunk_top_right:at(1, y)
    else
        return chunk_bottom_right:at(1, 1)
    end
end

---@param chunk_right Chunk
---@param chunk_bottom Chunk
---@param chunk_bottom_right Chunk
---@param base number
---@return love.ImageData
function Chunk:calculateRenderGrid(chunk_right, chunk_bottom, chunk_bottom_right, base)
    local render_grid = love.image.newImageData(self.chunk_size, self.chunk_size)
    local pointer = ffi.cast('uint32_t*', render_grid:getFFIPointer())
    for y = 0, self.chunk_size - 1 do
        for x = 0, self.chunk_size - 1 do
            local tile_index = self.chunk_size * y + x

            --TODO: Optimize by dividing the loops instead of checking every time
            local top_left =
                index(self, chunk_right, chunk_bottom, chunk_bottom_right, x, y, self.chunk_size)
            local top_right =
                index(self, chunk_right, chunk_bottom, chunk_bottom_right, x + 1, y, self.chunk_size)
            local bottom_left =
                index(self, chunk_right, chunk_bottom, chunk_bottom_right, x, y + 1, self.chunk_size)
            local bottom_right =
                index(self, chunk_right, chunk_bottom, chunk_bottom_right, x + 1, y + 1, self.chunk_size)

            local value = top_left * base ^ 0 + top_right * base ^ 1 + bottom_left * base ^ 2 + bottom_right * base ^ 3

            pointer[tile_index] = bit.bor(value, 0xFF000000)
        end
    end

    return render_grid
end

return Chunk
