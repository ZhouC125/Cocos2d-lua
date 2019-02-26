
require("app.views.DefineType");
local Obj=require("app.views.Obj");
local Bullet=class("Bullet",Obj);

function Bullet:ctor( ... )
    -- body
    Bullet.super.ctor(self);
    self:init();

    local function onNodeEvent(event)
        if(event=="enter") then
            self:onEnter();
        elseif(event=="exit") then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function Bullet:init()
    
    self.id=cc.UserDefault:getInstance():getIntegerForKey("Bullet_Id",1);
    self.hp=1;
    self.damage=self.id;
    self:setState(STATE.kBorning); 
    self:setState(STATE.kBattle);
end

function Bullet:onEnter()
    --添加定时器
    self.schedulerUpdate=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        self:update(dt);
    end,0,false);
    --添加事件监听器

end

function Bullet:onExit()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerUpdate);

end

function Bullet:onBorning()
    local cache=cc.SpriteFrameCache:getInstance();
    cache:addSpriteFrames("res/Game/Bullet.plist");

    local heroId=cc.UserDefault:getInstance():getIntegerForKey("User_Id",1);
    self.mode=cc.Sprite:createWithSpriteFrameName("bullet_"..heroId.."_"..self.id..".png");
    self:addChild(self.mode);
end

function Bullet:update(dt)
    self:setPositionY(self:getPositionY()+5*dt*60);
    if(self:getPositionY()>=display.height)then
        self:setState(STATE.kCanBeRemoved);
    end

    if(self.hp<=0) then
        self:setState(STATE.kCanBeRemoved);
    end

    if(self:canBeRemoved()) then
        self:removeFromParent();
    end
end

return Bullet;