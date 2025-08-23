local new = require('table.new')

---@class Grid
---@field width number
---@field height number
---@field [number] number
local Grid = {
    Types = {
        Water = 0,
        Ground = 1,
    }
}
Grid.__index = Grid
local base = 0

for _, _ in pairs(Grid.Types) do
    base = base + 1
end

---@param width number
---@param height number
---@return Grid
function Grid.new(width, height)
    local self = setmetatable(new(width * height, 2), Grid) ---@type Grid
    self.width = width
    self.height = height

    local size = width * height

    for i = 1, size do
        self[i] = Grid.Types.Water
    end

    return self
end

---@param x number
---@param y number
---@overload fun(self, index: number): number
---@return number
function Grid:at(x, y)
    if y then
        return self[(y - 1) * self.width + x]
    else
        return self[x]
    end
end

---@param x number
---@param y number
---@param value number
---@overload fun(self, index: number, value: number)
function Grid:set(x, y, value)
    if not value then
        value = y
        self[x] = value
    else
        self[(y - 1) * self.width + x] = value
    end
end

---@param batch love.SpriteBatch
---@param sprites love.Quad[]
---@param pos_x number?
---@param pos_y number?
function Grid:draw(batch, sprites, pos_x, pos_y)
    pos_x = pos_x or 0
    pos_y = pos_y or 0
    local width, height = self.width - 1, self.height - 1
    for y_index = 1, width do
        for x_index = 1, height do
            local x_next = x_index + 1
            local y_next = y_index + 1

            local top_left = self:at(x_index, y_index)
            local top_right = self:at(x_next, y_index)
            local bottom_left = self:at(x_index, y_next)
            local bottom_right = self:at(x_next, y_next)

            local sprite_index = (top_left + (base) * top_right + (base ^ 2) * bottom_left + (base ^ 3) * bottom_right) +
                1

            local x, y = (x_index - 1) * 32, (y_index - 1) * 32
            local sprite = sprites[sprite_index]
            batch:add(sprite, pos_x + x, pos_y + y, 0, 2, 2)
        end
    end
end

return Grid
