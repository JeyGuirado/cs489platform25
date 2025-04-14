local Class = require "libs.hump.class"
local Hbox = require "src.game.Hbox"
local Timer = require "libs.hump.timer"

local Enemy = Class{}
function Enemy:init()
    self.x = 0
    self.y = 0
    self.name = ""
    self.type = ""
    self.dir = "l" -- Direction r = right, l = left
    self.state = "idle" -- idle state
    self.invincible = false 
    self.animations = {} -- dict of animations (each mob will have its own)
    self.sprites = {} -- dict of sprites (for animations)
    -- Attributes
    self.hitboxes = nil -- for later
    self.hurtboxes = nil -- for later
    self.hp = 10 -- hit/health points 
    self.damage = 10 -- mob's damage
    self.died = false
    self.score = 100 -- score to kill this mob 
    self.damageNumbers = {} 
    self.particles = love.graphics.newParticleSystem(love.graphics.newImage("graphics/particles/20.png"), 100)
    self.particles:setParticleLifetime(0.5, 1) 
    self.particles:setEmissionRate(0)
    self.particles:setSpeed(20, 50)
    self.particles:setSizes(0.5, 1)
    self.particles:setLinearAcceleration(-10, -10, 10, 10)
end

function Enemy:getDimensions() -- returns current Width,Height
    return self.animations[self.state]:getDimensions()
end

function Enemy:setAnimation(st,sprite,anim)
    self.animations[st] = anim
    self.sprites[st] = sprite
end

function Enemy:setCoord(x,y)
    self.x = x
    self.y = y
end

function Enemy:update(dt)
    self.animations[self.state]:update(dt)
end

function Enemy:draw()
    self.animations[self.state]:draw(self.sprites[self.state],
        math.floor(self.x), math.floor(self.y))
    
    if debugFlag then
        local w,h = self:getDimensions()
        love.graphics.rectangle("line",self.x,self.y,w,h) -- sprite
    
        if self:getHurtbox() then
            love.graphics.setColor(0,0,1) -- blue
            self:getHurtbox():draw()
        end
    
        if self:getHitbox() then
            love.graphics.setColor(1,0,0) -- red
            self:getHitbox():draw()
        end
        love.graphics.setColor(1,1,1) 
    end
        
end

function Enemy:changeDirection()
    if self.dir == "l" then
        self.dir = "r"
    else
        self.dir = "l"
    end

    for st,anim in pairs(self.animations) do
        anim:flipH()
    end
end

function Enemy:hit(damage)
    self.hp = self.hp - damage

    --display text
    self:showDamage(damage)

    if self.hp <= 0 then
        self.died = true
        self.state = "die"
        self.particles:setPosition(self.x + self:getDimensions()/2,
            self.y + self:getDimensions()/2)
        self.particles:setEmissionRate(100)
        self.particles:setColors(1, 1, 0, 1, 1, 0, 0, 0)
        self.particles:emit(100)
        --self.particles:stop()
    end
    --trigger particles
end

function Enemy:showDamage(damage)
    local num = DamageNumber(damage)
    num:setCoord(self.x + self:getDimensions()/2,
        self.y + self:getDimensions()/2)
    table.insert(self.damageNumbers,num)

    Timer.tween(0.8, num, { y = num.y - 20, alpha = 0 }, 'linear', function()
        for i, v in ipairs(self.damageNumbers) do
            if v == num then
                table.remove(self.damageNumbers, i)
                break
            end
        end
    end)
end

function Enemy:getHbox(boxtype)
    if boxtype == "hit" then
        return self.hitboxes[self.state]
    else
        return self.hurtboxes[self.state]
    end
end

function Enemy:getHitbox()
    return self:getHbox("hit")
end

function Enemy:getHurtbox()
    return self:getHbox("hurt")
end

function Enemy:setHurtbox(state,ofx,ofy,width,height)
    self.hurtboxes[state] = Hbox(self,ofx,ofy,width,height)
end

function Enemy:setHitbox(state,ofx,ofy,width,height)
    self.hitboxes[state] = Hbox(self,ofx,ofy,width,height)
end


return Enemy
