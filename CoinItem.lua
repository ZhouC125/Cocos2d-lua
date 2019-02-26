
require("app.views.DefineType");
local Obj=require("app.views.Obj");
local CoinItem=class("CoinItem",Obj);

function CoinItem:ctor(id)
    -- body
    self:init(id);
    CoinItem.super.ctor(self);
    local function onNodeEvent(event)
        if(event=="enter") then
            self:onEnter();
        elseif(event=="exit") then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function CoinItem:init(id)
    self.id=id;
    self.hp=1;
    self.damage=0;
    self:setState(STATE.kBorning);
    self:setState(STATE.kBattle);

end

function CoinItem:onBorning()
    local cache=cc.SpriteFrameCache:getInstance();
    cache:addSpriteFrames("res/Game/prop_1.plist");

    self.mode=cc.Sprite:createWithSpriteFrameName("prop_1_"..self.id.."_1.png");
    self.mode:setScale(0.6);
    self:addChild(self.mode);

    if(self.id==1)then
        local animation=cc.Animation:create();
        for i=1,6 do
            local frameName=cache:getSpriteFrame("prop_1_1_"..i..".png");
            animation:addSpriteFrame(frameName);
        end
        animation:setDelayPerUnit(0.1);
        --animation:setRestoreOriginalFrame( true );
        local action=cc.Animate:create(animation);
        self.mode:runAction(cc.RepeatForever:create(action));
    end
end

function CoinItem:onDie()
    local event=cc.EventCustom:new("Coin_Eaten");
    event._usedata=self.id*5;
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event);
    self:setState(STATE.kCanBeRemoved);
end

function CoinItem:onEnter()
    self:bezierIt();
    local scheduler=cc.Director:getInstance():getScheduler();
    self.schedulerUpdate=scheduler:scheduleScriptFunc(function(dt)
        self:update(dt);
    end,0,false);
end

function CoinItem:onExit()
    local scheduler=cc.Director:getInstance():getScheduler();
    scheduler:unscheduleScriptEntry(self.schedulerUpdate);
end

function CoinItem:bezierIt()
    local seed=math.pow(-1,math.random( 1,10 ));
    local offsetX=seed*math.random( 30,200 );
    local offsetY=math.random( 100,300 );
    local endX=math.max( self:getPositionX()+offsetX,0 );
    endX=math.min( endX,display.width );
    local p1=cc.p(self:getPositionX(),self:getPositionY()+offsetY);
    local p2=cc.p(endX,offsetY-250);
    local p3=cc.p(endX,-250);
   
    self:runAction(cc.EaseSineIn:create(cc.BezierTo:create(1.2,{p1,p2,p3})));
end

function CoinItem:update(dt)
    if(self.hp<=0 and self:lifeFlag())then
        self:setState(STATE.kDie);
    end
    if(self:getPositionY()<=0)then
        self:setState(STATE.kCanBeRemoved);
    end
    if(self:canBeRemoved())then
        self:removeFromParent();
    end
end

return CoinItem;