local Chunk = require('modules.chunk')

---@class ChunkManager
local ChunkManager = {
    Types = {
        Water = 0,
        Ground = 1,
    },
    BASE = 0,
    CHUNK_SIZE = 16, -- Assumption: chunks are always square
}
ChunkManager.__index = ChunkManager

for _, _ in pairs(ChunkManager.Types) do
    ChunkManager.BASE = ChunkManager.BASE + 1
end

function ChunkManager.new()
    ---@class ChunkManager
    local self = setmetatable({}, ChunkManager)
    self.data = {} ---@type {[number]: {[number]: Chunk}}
    return self
end

---@param chunk_x number
---@param chunk_y number
---@return Chunk
function ChunkManager:createChunk(chunk_x, chunk_y)
    self.data[chunk_x] = self.data[chunk_x] or {}
    self.data[chunk_x][chunk_y] = self.data[chunk_x][chunk_y] or
    Chunk.new(ChunkManager:chunkGenerator(chunk_x, chunk_y), ChunkManager.CHUNK_SIZE)
    return self.data[chunk_x][chunk_y]
end

---@param chunk_x number
---@param chunk_y number
---@return fun(x: number, y: number): number
function ChunkManager:chunkGenerator(chunk_x, chunk_y)
    ---@param x number
    ---@param y number
    return function(x, y)
        local noise =
            love.math.noise(x * (1 / self.CHUNK_SIZE) + chunk_x, - (y * (1 / self.CHUNK_SIZE) + chunk_y))
        return bit.bor(noise < 0.5 and 0 or 1, 0xFF000000)
    end
end

function ChunkManager:createRenderer(chunk_x, chunk_y)
    local chunk = self:createChunk(chunk_x, chunk_y)
    local right = self:createChunk(chunk_x + 1, chunk_y)
    local bottom = self:createChunk(chunk_x, chunk_y + 1)
    local bottom_right = self:createChunk(chunk_x + 1, chunk_y + 1)
    return chunk:calculateRenderGrid(right, bottom, bottom_right, self.BASE)
end

function ChunkManager:dump()
    for x,row in pairs(self.data) do
        for y,chunk in pairs(row) do
            chunk.data:encode("png", ("chunk_%d_%d.png"):format(x, y))
        end
    end
end

return ChunkManager
