

local InitLayer = class("InitLayer", cc.load("mvc").ViewBase);
local CharSelectLayer=require("app.views.CharSelectLayer");

function InitLayer:ctor()
    -- add background image



    local initLayer=cc.CSLoader:createNode("res/res/InitLayer/Init_Layer_UI.csb");
    self:addChild(initLayer);

    
    self.loadingBar= initLayer:getChildByName("LoadingBar_1");
    self.percent=0;
    

    local function onNodeEvent(event)
        if(event=="enter") then
            self:onEnter();
        elseif(event=="exit") then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function InitLayer:onEnter()
    local scheduler=cc.Director:getInstance():getScheduler();
    self.schedulerID=scheduler:scheduleScriptFunc(function()
        self.loadingBar:setPercent(self.percent);
        self.percent=self.percent+1;
        if(self.percent>=100) then
           cc.Director:getInstance():getRunningScene():addChild(CharSelectLayer:create());
           self:removeFromParent();
        end
    end,0,false);

end

function InitLayer:onExit()
    local scheduler=cc.Director:getInstance():getScheduler();
    scheduler:unscheduleScriptEntry(self.schedulerID);
end

return InitLayer
