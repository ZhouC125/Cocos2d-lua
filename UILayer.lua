
local UILayer=class("UILayer",cc.load("mvc").ViewBase);

function UILayer:ctor(gameLayer,hero)
    -- body
    self:init(gameLayer,hero);
    local function onNodeEvent(event)
        if(event=="enter") then
            self:onEnter();
        elseif(event=="exit") then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function UILayer:init(gameLayer,hero)
    self.gameLayer=gameLayer;
    self.hero=hero;
    self.maxHP=cc.UserDefault:getInstance():getIntegerForKey("Hero_Max_HP",1);
    local uiLayer=cc.CSLoader:createNode("res/res/GamingLayerUI/Gaming_Layer_UI.csb");
    self:addChild(uiLayer);

    self.HPBar=uiLayer:getChildByName("HP_Bar");
    self.scoreText=uiLayer:getChildByName("Score_Text");
    self.pauseButton=uiLayer:getChildByName("Pause_Btn");
    self.backToHome=uiLayer:getChildByName("Back_To_Home");
    self.continue=uiLayer:getChildByName("Continue");
    self.restart=uiLayer:getChildByName("Restart");

end

function UILayer:onEnter()
    --定时器
    self.schedulerUpdate=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        self:update(dt);
    end,0,false);


    --事件监听
    self.pauseButton:addTouchEventListener(function(sender,eventType)
        if(eventType==ccui.TouchEventType.ended) then
            self.pauseButton:setVisible(false);
            self.backToHome:setVisible(true);
            self.continue:setVisible(true);
            self.restart:setVisible(true);
            cc.Director:getInstance():pause();
        end
    end);

    self.continue:addTouchEventListener(function(sender,eventType)
        if(eventType==ccui.TouchEventType.ended) then
            self.pauseButton:setVisible(true);
            self.backToHome:setVisible(false);
            self.continue:setVisible(false);
            self.restart:setVisible(false);
            cc.Director:getInstance():resume();
        end
    end);

    self.restart:addTouchEventListener(function(sender,eventType)
        if(eventType==ccui.TouchEventType.ended) then
            cc.Director:getInstance():resume();
            cc.Director:getInstance():popScene();
        end
    end);

    self.backToHome:addClickEventListener(function(sender)
        cc.Director:getInstance():endToLua();
    end);

    local eventDispatcher=cc.Director:getInstance():getEventDispatcher();
    self.listenerHeroDie=cc.EventListenerCustom:create("Hero_Die",function(event)
        self:removeFromParent();
    end);
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerHeroDie,self);
end

function UILayer:onExit()
    local scheduler=cc.Director:getInstance():getScheduler();
    scheduler:unscheduleScriptEntry(self.schedulerUpdate);

    local eventDispatcher=cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:removeEventListener(self.listenerHeroDie);
end

function UILayer:update(dt)
    self.scoreText:setString(self.gameLayer.score);
    self.HPBar:setPercent(self.hero.hp/self.maxHP*100);
end

return UILayer;
