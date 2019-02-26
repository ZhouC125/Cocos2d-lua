
require("app.views.DefineType");
local Obj=require("app.views.Obj");
local Bullet=require("app.views.Bullet");
local Hero=class("Hero",Obj);

function Hero:ctor( gameLayer )
    -- body
    self.gameLayer=gameLayer;
    Hero.super.ctor(self);
    self:init()
    local function onNodeEvent(event)
        if(event=="enter") then
            self:onEnter();
        elseif(event=="exit") then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function Hero:init()

    self.sendBulletFlag=false;
    self.id=cc.UserDefault:getInstance():getIntegerForKey("User_Id",1);

    self.hp=3*self.id;
    cc.UserDefault:getInstance():setIntegerForKey("Hero_Max_HP",self.hp);
    self.damage=99999;
    

    self:setState(STATE.kBorning);
    self:setState(STATE.kBattle);
end

function Hero:onEnter()
    --添加定时器
    self.schedulerUpdate=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        self:update(dt);
    end,0,false);

    self.schedulerSendBullet=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:sendBullet();
    end,0.2,false);



    --添加事件监听器
    local eventDispatcher=cc.Director:getInstance():getEventDispatcher();
    self.listenerBulletStart = cc.EventListenerCustom:create("SendBullet_Start",function(event)
        self.sendBulletFlag=true;
    end);
    eventDispatcher:addEventListenerWithFixedPriority(self.listenerBulletStart,1);

    self.listenerBulletStop = cc.EventListenerCustom:create("SendBullet_Stop",function(evnet)
        --print("--------send bullet stop")
        self.sendBulletFlag=false;
    end);
    eventDispatcher:addEventListenerWithFixedPriority(self.listenerBulletStop,1);

    self.listenerRecallHero=cc.EventListenerCustom:create("Recall_Hero",function(event)
        self.hp=3*self.id;
        self:setState(STATE.kBattle);
    end);
    eventDispatcher:addEventListenerWithFixedPriority(self.listenerRecallHero,1);
end

function Hero:onExit()
    local scheduler=cc.Director:getInstance():getScheduler();
    scheduler:unscheduleScriptEntry(self.schedulerUpdate);
    scheduler:unscheduleScriptEntry(self.schedulerSendBullet);

    local eventDispatcher=cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:removeEventListener(self.listenerBulletStart);
    eventDispatcher:removeEventListener(self.listenerBulletStop);
    eventDispatcher:removeEventListener(self.listenerRecallHero);
end

function Hero:onBorning()
    local action=cc.CSLoader:createNode("res/res/GamingLayerUI/Hero"..self.id..".csb");
    self:addChild(action);

    local heroTml=cc.CSLoader:createTimeline("res/res/GamingLayerUI/Hero"..self.id..".csb");
    if(self.id==3) then
        heroTml:gotoFrameAndPlay(0,35,true);
    else 
        heroTml:gotoFrameAndPlay(0,55,true);
    end
    action:runAction(heroTml);
    self.mode=action:getChildByName("mode");
end

function Hero:onDie()
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(cc.EventCustom:new("Hero_Die"));
    self:setState(STATE.kCanBeRemoved);
end

function Hero:update(dt)
    self:borderCheck();
    if(self.hp<=0 and self:lifeFlag()) then
        self:setState(STATE.kDie);
    end
end

function Hero:borderCheck()
    local x=math.max(44,self:getPositionX());
    x=math.min(display.width-44,x);
    self:setPositionX(x);
end

function Hero:sendBullet()
    if(not self.sendBulletFlag) then
        return;
    end
    local bullet=Bullet:create();
    bullet:setPosition(self:getPositionX(),self:getPositionY()+80);
    bullet:setLocalZOrder(1);
    self:getParent():addChild(bullet);
    table.insert( self.gameLayer.bulletTable,bullet );
    bullet:retain();

end

return Hero;