
require("app.views.DefineType");
local Obj=require("app.views.Obj");
local SuperBullet=class("SuperBullet",Obj);

function SuperBullet:ctor()
    -- body
    
    SuperBullet.super.ctor(self);
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

function SuperBullet:init()
    self.damage=0;
    self.hp=1;
    self:setState(STATE.kBorning);
    self:setState(STATE.kBattle);
end

function SuperBullet:onBorning()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/Game/prop_2.plist");
    self.mode=cc.Sprite:createWithSpriteFrameName("prop_2_2_1.png");
    self:addChild(self.mode);
end

function SuperBullet:onDie()
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(cc.EventCustom:new("Update_Bullet"));
    self:setState(STATE.kCanBeRemoved);
end

function SuperBullet:onEnter()
    --定时器
    self.schedulerUpdate=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        self:setPositionY(self:getPositionY()-dt*60*5);
        if(self:getPositionY()<=0)then
            self:setState(STATE.kCanBeRemoved);
        end
        if(self.hp<=0)then
            self:setState(STATE.kDie);
        end
        if(self:canBeRemoved()) then self:removeFromParent(); end
    end,0,false);

end

function SuperBullet:onExit()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerUpdate);
end

return SuperBullet;