
local RecallLayer=class("RecallLayer",cc.load("mvc").ViewBase);

function RecallLayer:ctor(gameLayer)
    -- body
    self:init(gameLayer);
    local function onNodeEvent(event)
        if(event=="enter") then
            self:onEnter();
        elseif(event=="exit") then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function RecallLayer:init(gameLayer)
    self.gameLayer=gameLayer;
    self.recallTimes=cc.UserDefault:getInstance():getIntegerForKey("Recall_Times",3);
    self.barPercent=100;
    self.bg=cc.Sprite:create("res/res/RecallLayer/bg.png");
    self.bg:setPosition(display.cx,display.cy);
    self.bg:setOpacity(0);
    self:addChild(self.bg);

    local recallLayer=cc.CSLoader:createNode("res/res/RecallLayer/RecallLayer.csb");
    self:addChild(recallLayer);
    self.btnRecall=recallLayer:getChildByName("Button_Recall");
    self.btnCancel=recallLayer:getChildByName("Button_Cancel");
    self.barRecall=recallLayer:getChildByName("LoadingBar_Recall");
    self.textScore=recallLayer:getChildByName("AtlasLabel_Score");
    self.textRecallTimes=recallLayer:getChildByName("AtlasLabel_RecallTimes");
end

function RecallLayer:onEnter()
    self.textScore:setString(self.gameLayer.score);
    self.textRecallTimes:setString(self.recallTimes);
    if(self.recallTimes<=0)then
        self.btnRecall:setEnabled(false);
        self.barRecall:setPercent(0);
        self.bg:setOpacity(200);
    end

    self.schedulerPercent=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:setPercentage();
    end,0.1,false);
    

    self.btnCancel:addClickEventListener(function(sender)
        cc.Director:getInstance():popScene();
    end);

    self.btnRecall:addClickEventListener(function(sender)
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(cc.EventCustom:new("Recall_Hero"));
        self.recallTimes=self.recallTimes-1;
        cc.UserDefault:getInstance():setIntegerForKey("Recall_Times",self.recallTimes);
        self:removeFromParent();
    end);
end

function RecallLayer:onExit()
    local scheduler=cc.Director:getInstance():getScheduler();
    scheduler:unscheduleScriptEntry(self.schedulerPercent);
end

function RecallLayer:setPercentage()
    if(self.recallTimes<=0 or self.barPercent<=0)then
        self.barRecall:setPercent(0);
        self.btnRecall:setEnabled(false);
        self.bg:setOpacity(200);
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerPercent);
    else
        self.barPercent=self.barPercent-1;
        self.barRecall:setPercent(self.barPercent);
        self.bg:setOpacity(200-self.barPercent*2);
    end

end

return RecallLayer;