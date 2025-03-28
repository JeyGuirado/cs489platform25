local Class = require "libs.hump.class"
local Matrix = require "libs.matrix"

local Stage = Class{}
function Stage:init(rows, cols, ts)
    self.tileset = ts -- tileset used in this map
    self.rowCount = rows
    self.colCount = cols

    self.initialPlayerY = 0
    self.initialPlayerX = 0

    self.music = nil -- this stage music
    self.mobs = {} -- mobs
    self.objects = {} -- game objects
    self.bgs = {} -- backgrounds
    self.map = Matrix:new(self.rowCount, self.colCount) -- map will be a matrix of tiles
end


function Stage:update(dt)
end

function Stage:getWidth()
    return self.colCount * self:getTileSize()
end

function Stage:getHeight()
    return self.rowCount * self:getTileSize()
end

function Stage:getTileSize()
    return self.tileset.tileSize
end

function Stage:draw()
    for row = 1, self.rowCount do
        for col = 1, self.colCount do
            self:drawTile(row,col) 
        end -- end for col
    end -- end for row
end

function Stage:drawTile(row,col)
    local curTile = self.map[row][col]
    if curTile then -- if not nil
        love.graphics.draw(self.tileset:getImage(), --img
            curTile.quad,  -- quad
            (col-1)*self:getTileSize(), -- x 
            (row-1)*self:getTileSize(),  -- y
            curTile.rotation, -- rotation (zero = no rotation)
            curTile.flipHor, --  no flip = 1, flipped = -1 
            curTile.flipVer)
    end
end

function Stage:addBackground(background)
    table.insert(self.bgs, background)
end

function Stage:drawBg()
    for k=1, #self.bgs do
        self.bgs[k]:draw()
    end 
end

function Stage:readMapData(mapdata)
    local index = 1
    for row = 1, self.rowCount do
        for col = 1, self.colCount do
            if mapdata[index] == 0 then
                self.map[row][col] = nil
            else -- there is a tile
                self.map[row][col] = self.tileset:get(mapdata[index])
            end
            index = index +1
        end -- end for col
    end -- end for row
end

function Stage:toMapCoords(gameobject)
    local width, height = gameobject:getDimensions()
    local ts = self:getTileSize()

    local col1 = 1+math.floor( (gameobject.x+ts-1)/ts ) --left 
    local row1 = 1+math.floor( (gameobject.y+ts-1)/ts ) --top
    -- row1, col1 = top left corner
    local col2 = math.floor( (gameobject.x+width)/ts ) --right
    local row2 = math.floor( (gameobject.y+height)/ts )--bottom
    -- row2,col2 = bottom right corner
    
    return row1,col1,row2,col2
end

function Stage:rightCollision(entity, offset)
    local row1,col1,row2,col2 = self:toMapCoords(entity)
    if col2 < self.colCount then -- bellow the right corner of the stage
        for i = math.max(1, row1+offset), 
                math.min(row2-offset,self.rowCount) do
            if self.map[i][col2] ~= nil 
                    and self.map[i][col2].solid then
                return true
            end -- end if 
        end -- end for
    end -- end if    
    return false
end

function Stage:leftCollision(entity, offset)
    local row1,col1,row2,col2 = self:toMapCoords(entity)
    if col1 >= 1 then -- bellow the left corner of the stage
        for i = math.max(1, row1+offset), 
                math.min(row2-offset,self.rowCount) do
            if self.map[i][col1] ~= nil 
                    and self.map[i][col1].solid then
                return true
            end -- end if 
        end -- end for
    end -- end if    
    return false
end

function Stage:bottomCollision(entity, ofsRow, ofsCol)
    local row1,col1,row2,col2 = self:toMapCoords(entity)

    if row2+ofsRow < self.rowCount then -- not falling below screen
        for j = math.max(1, col1+ofsCol),
                math.min(col2-ofsCol, self.colCount) do
            if self.map[row2+ofsRow][j] ~= nil 
                    and self.map[row2+ofsRow][j].solid then
                return true
            end -- end if solid tile
        end -- end for j
    end -- end if row2 < rowCount
    return false
end

return Stage
