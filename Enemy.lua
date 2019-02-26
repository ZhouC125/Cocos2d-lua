
local CoinItem=require("app.views.CoinItem");
require("app.views.DefineType");
local Obj=require("app.views.Obj");
local Enemy=class("Enemy",Obj);

function Enemy:ctor( coinTable )
    -- body
    Enemy.super.ctor(self);
    self:init(coinTable);
    local function onNodeEvent(event)
        if(event=="enter") then
            self:onEnter();
        elseif(event=="exit") then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function Enemy:init(coinTable)
    self.coinTable=coinTable;
    self.id=math.random( 1,25 );
    self.hp=cc.UserDefault:getInstance():getIntegerForKey("Enemy_HP",3);
    self.maxHP=self.hp;
    self.damage=1;
    self:setState(STATE.kBorning);


end

function Enemy:onEnter()
    self.schedulerUpdate=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        self:update(dt);
    end,0,false);
end

function Enemy:onExit()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerUpdate);
end

function Enemy:onBorning()
    local cache=cc.SpriteFrameCache:getInstance();
    cache:addSpriteFrames("res/Game/Enemy.plist");

    self.mode=cc.Sprite:createWithSpriteFrameName("Enemy_"..self.id.."_1.png");
    self:addChild(self.mode);

    local hpBarBg=cc.Sprite:create("res/Game/enemy_hp_bg.png");
    hpBarBg:setPositionY(60);
    self:addChild(hpBarBg);
    local hpBarSprite=cc.Sprite:create("res/Game/enemy_hp.png");
    self.hpBar=cc.ProgressTimer:create(hpBarSprite);
    self.hpBar:setPositionY(60);
    self.hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.hpBar:setMidpoint(cc.p(0,0));
    self.hpBar:setBarChangeRate(cc.p(1,0));
    self.hpBar:setPercentage(100);
    self:addChild(self.hpBar);
end

function Enemy:onDie()
    local cache=cc.SpriteFrameCache:getInstance();
    cache:addSpriteFrames("res/Game/boster_1.plist");

    local sprite=cc.Sprite:createWithSpriteFrameName("boster_1_0000.png");
    sprite:setPosition(self:getPositionX(),self:getPositionY());
    self:getParent():addChild(sprite);

    local animation=cc.Animation:create();
    for i=0,6 do
        local frameName=cache:getSpriteFrame("boster_1_000"..i..".png");
        animation:addSpriteFrame(frameName);
    end
    animation:setDelayPerUnit(0.1);
    local action=cc.Animate:create(animation);
    sprite:runAction(cc.Sequence:create(action,cc.RemoveSelf:create(),nil));

    self:generateCoinItem();

    self:setState(STATE.kCanBeRemoved);
end

function Enemy:update(dt)
    self:setPositionY(self:getPositionY()-3*60*dt);
    self.hpBar:setPercentage(self.hp/self.maxHP*100);

    if(self:getPositionY()<=display.height*0.85 and self:lifeFlag()) then
        self:setState(STATE.kBattle);
    end

    if(self:getPositionY()<=0) then
        self:setState(STATE.kCanBeRemoved);
    end

    if(self.hp<=0 and self:lifeFlag()) then
        self:setState(STATE.kDie);
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(cc.EventCustom:new("Enemy_Down"));
    end

    if(self:canBeRemoved()) then
        self:removeFromParent();
    end
end

function Enemy:generateCoinItem()
    local times=0;
    if(self.id>=5 and self.id<=10)then
        times=1;
    elseif(self.id>10 and self.id<=20)then
        times=2;
    elseif(self.id>20)then
        times=3;
    else
        
    end

    for i=1,times do
        for j=1,7 do
            local coinItem=CoinItem:create(j);
            coinItem:setPosition(self:getPosition());
            self:getParent():addChild(coinItem);
            table.insert( self.coinTable,coinItem );
            coinItem:retain();

        end
    end
end

return Enemy;