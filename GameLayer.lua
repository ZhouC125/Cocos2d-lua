
local CoinItem=require("app.views.CoinItem");
local ControlLayer=require("app.views.ControlLayer");
local RecallLayer=require("app.views.RecallLayer");
local SuperBullet=require("app.views.SuperBullet");
local UILayer=require("app.views.UILayer");
local Hero=require("app.views.Hero");
local Enemy=require("app.views.Enemy");
local Bullet=require("app.views.Bullet");
local GameLayer=class("GameLayer",cc.load("mvc").ViewBase);

function GameLayer:ctor()
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

function GameLayer:init()
    self.enemyTable={};
    self.bulletTable={};
    self.coinTable={};
    self.downEnemy=0;
    self.enemyWave=1;
    self.score=0;
    self.superBulletFlag=true;
    self.superBullet=nil;
    cc.UserDefault:getInstance():setIntegerForKey("Bullet_Id",1);
    cc.UserDefault:getInstance():setIntegerForKey("Enemy_HP",3);
    cc.UserDefault:getInstance():setIntegerForKey("Recall_Times",3);

    self.bg1 = cc.Sprite:create("res/res/Space1.png");
    self.bg1:setPosition(cc.p(display.cx,display.cy));
    self:addChild(self.bg1);
    self.bg2=cc.Sprite:create("res/res/Space1.png");
    self.bg2:setPosition(cc.p(display.cx,display.cy*3));
    self:addChild(self.bg2);

    self.countDownNode=cc.Node:create();
    self.countDownNode:setPosition(display.cx,150);
    self:addChild(self.countDownNode);
    local dt_bg=cc.Sprite:create("res/Game/dt_bg.png");
    self.countDownNode:addChild(dt_bg);
    local dt_light=cc.Sprite:create("res/Game/dt_light.png");
    self.countDownNode:addChild(dt_light);
    dt_light:runAction(cc.RotateBy:create(5,-1080));
    self.countDownNum=3;

    

end

function GameLayer:onEnter()
    --添加定时器
    local scheduler=cc.Director:getInstance():getScheduler();
    self.schedulerUpdate=scheduler:scheduleScriptFunc(function(dt)
        self:updateBg(dt);
        self:collideCheck();
        self:cleanTable();
        self:generateSuperBullet();
    end,0,false);

    self.schedulerCntDown=scheduler:scheduleScriptFunc(function()
        self:countDown();
    end,1,false);


    local eventDispatcher=cc.Director:getInstance():getEventDispatcher();

    self.listenerEnemyDown=cc.EventListenerCustom:create("Enemy_Down",function(event)
        self.downEnemy=self.downEnemy+1;
    end);
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerEnemyDown,self);

    self.listenerUpdateBullet=cc.EventListenerCustom:create("Update_Bullet",function(event)
        local bulletID=cc.UserDefault:getInstance():getIntegerForKey("Bullet_Id",1);
        bulletID=bulletID+1;
        bulletID=math.min( bulletID,5 );
        cc.UserDefault:getInstance():setIntegerForKey("Bullet_Id",bulletID);
    end);
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerUpdateBullet,self);

    self.listenerHeroDie=cc.EventListenerCustom:create("Hero_Die",function(event)
        local recallLayer=RecallLayer:create(self);
        cc.Director:getInstance():getRunningScene():addChild(recallLayer);
    end);
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerHeroDie,self);

    self.listenerRecallHero=cc.EventListenerCustom:create("Recall_Hero",function(event)
        self:addControlLayer();
        self:addUILayer();
    end);
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerRecallHero,self);

    self.listenerCoinEaten=cc.EventListenerCustom:create("Coin_Eaten",function(event)
        self.score=self.score+event._usedata;
    end);
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerCoinEaten,self);
end

function GameLayer:onExit()
    local scheduler=cc.Director:getInstance():getScheduler();
    scheduler:unscheduleScriptEntry(self.schedulerUpdate);
    scheduler:unscheduleScriptEntry(self.schedulerGenEnemy);

    local eventdispatcher=cc.Director:getInstance():getEventDispatcher();
    eventdispatcher:removeEventListener(self.listenerEnemyDown);
    eventdispatcher:removeEventListener(self.listenerUpdateBullet);
    eventdispatcher:removeEventListener(self.listenerHeroDie);
    eventdispatcher:removeEventListener(self.listenerRecallHero);
    eventdispatcher:removeEventListener(self.listenerCoinEaten);
end

function GameLayer:updateBg( dt )
    local bg1Posx,bg1Posy=self.bg1:getPosition();
    local bg2Posx,bg2Posy=self.bg2:getPosition();
    self.bg1:setPosition(cc.p(display.cx,bg1Posy-1*dt*60));
    self.bg2:setPosition(cc.p(display.cx,bg2Posy-1*dt*60));
    if(bg1Posy<=-display.cy)then
        self.bg1:setPosition(cc.p(display.cx,display.cy*3));
        self.bg1,self.bg2 = self.bg2,self.bg1;
    end

end

function GameLayer:countDown()
    if(self.countDownNum<0)then
        local scheduler=cc.Director:getInstance():getScheduler();
        scheduler:unscheduleScriptEntry(self.schedulerCntDown);
        self.countDownNode:removeFromParent();
        self:createHero();
        self:addControlLayer();
        self:addUILayer();
        self.schedulerGenEnemy=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            self:createEnemy();
        end,2,false);
    else
        local format=string.format( "res/Game/dt_%d.png",self.countDownNum );
        local sprite=cc.Sprite:create(format);
        self.countDownNode:addChild(sprite);
        sprite:setScale(3);
        sprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1),
        cc.MoveBy:create(0.5,cc.p(0,-600)),
        cc.RemoveSelf:create(),
        nil));
        self.countDownNum=self.countDownNum-1;
    end
end

function GameLayer:createHero( ... )
    self.hero=Hero:create(self);
    self.hero:setPosition(display.cx,100);
    self.hero:setLocalZOrder(1);
    self:addChild(self.hero);

    
    

    
end

function GameLayer:addControlLayer()
    local controlLayer=ControlLayer:create(self.hero);
    cc.Director:getInstance():getRunningScene():addChild(controlLayer);
end

function GameLayer:addUILayer()
    local uiLayer=UILayer:create(self,self.hero);
    cc.Director:getInstance():getRunningScene():addChild(uiLayer);
end

function GameLayer:createEnemy( ... )
    -- body 54
    --math.randomseed(tostring(os.time()):reverse():sub(1, 7));
    local arr={54,54*3,54*5,54*7};
    local num=math.random( 1,4 );
    --local index=math.random( 1,5-num );
    for i=1,num do
        local index=math.random( 1,#arr );
        local enemy=Enemy:create(self.coinTable);
        --enemy:setPosition(54+108*(index-1),display.height+100);
        enemy:setPosition(arr[index],display.height+100);
        table.remove( arr,index );
        self:addChild(enemy);
        table.insert( self.enemyTable,enemy );
        enemy:retain();
        index=index+1;
        
    end
    self.enemyWave=self.enemyWave+1;
    if(self.enemyWave>=5)then
        local enemyHP=cc.UserDefault:getInstance():getIntegerForKey("Enemy_HP",3);
        enemyHP=enemyHP+1;
        cc.UserDefault:getInstance():setIntegerForKey("Enemy_HP",enemyHP);
        self.enemyWave=0;
    end
end

function GameLayer:collideCheck( ... )
    -- body
    if(#self.enemyTable>0) then
        for i=1,#self.enemyTable do
            --dump(self.enemyTable[1]:getCollideBox());
            local enemy=self.enemyTable[i];
            local rectEnemy=enemy:getCollideBox();
            if(#self.bulletTable>0) then
                for j=1,#self.bulletTable do
                    local bullet=self.bulletTable[j];
                    local rectBullet=bullet:getCollideBox();
                    if(cc.rectIntersectsRect(rectBullet,rectEnemy) and enemy:lifeFlag() and bullet:lifeFlag()) then
                        enemy:cutHP(bullet.damage);
                        bullet:cutHP(enemy.damage);
                    end
    
                end
            end

            local rectHero=self.hero:getCollideBox();
            if(cc.rectIntersectsRect(rectHero,rectEnemy) and enemy:lifeFlag() and self.hero:lifeFlag()) then
                enemy:cutHP(self.hero.damage);
                self.hero:cutHP(enemy.damage);
            end

        end
    end

    --superbullet
    if(self.superBullet~=nil)then
        local rectHero=self.hero:getCollideBox();
        local rectSuperBullet=self.superBullet:getCollideBox();
        if(cc.rectIntersectsRect(rectHero,rectSuperBullet)) then 
            self.superBullet:cutHP(self.hero.damage);
            self.superBulletFlag=true;
            self.superBullet=nil;
        end
    end

    --coinItem
    if(#self.coinTable>0)then
        for i=1,#self.coinTable do
            local coinItem=self.coinTable[i];
            local rectCoin=coinItem:getCollideBox();
            local rectHero=self.hero:getCollideBox();
            if(cc.rectIntersectsRect(rectCoin,rectHero) and self.hero:lifeFlag() and coinItem:lifeFlag())then
                coinItem:cutHP(self.hero.damage);
            end

        end
    end
end

function GameLayer:cleanTable()
    local i=1;
    while(i<=#self.enemyTable) do 
        if(self.enemyTable[i]:canBeRemoved()) then
            self.enemyTable[i]:release();
            table.remove( self.enemyTable,i );
        else
            i=i+1;
        end
    end

    i=1;
    while(i<=#self.bulletTable) do
        if(self.bulletTable[i]:canBeRemoved()) then
            self.bulletTable[i]:release();
            table.remove( self.bulletTable,i );
        else
            i=i+1;
        end
    end

    i=1;
    while(i<=#self.coinTable) do
        if(self.coinTable[i]:canBeRemoved())then
            self.coinTable[i]:release();
            table.remove( self.coinTable,i );
        else
            i=i+1;
        end
    end
end

function GameLayer:generateSuperBullet()
    if(self.downEnemy~=0 and self.downEnemy%20==0 and self.superBulletFlag) then
        self.superBullet=SuperBullet:create();
        self.superBullet:setPosition(math.random( 50,380 ),math.random( display.height*0.8,display.height ));
        self:addChild(self.superBullet);
        self.superBulletFlag=false;
    end
end



return GameLayer;