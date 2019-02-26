local GameLayer=require("app.views.GameLayer");
local CharSelectLayer = class("CharSelectLayer",cc.load("mvc").ViewBase);

function CharSelectLayer:ctor()
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

function CharSelectLayer:init()
    -- body
    self.charselLayer=cc.CSLoader:createNode("res/res/CharSelectLayer/CHAR_Select_layer.csb");
    self:addChild(self.charselLayer);

    local timeLine=cc.CSLoader:createTimeline("res/res/CharSelectLayer/CHAR_Select_layer.csb");
    timeLine:gotoFrameAndPlay(0,120,true);
    self.charselLayer:runAction(timeLine);


    self.pageView=self.charselLayer:getChildByName("Char_Select_Page");
    self.button=self.charselLayer:getChildByName("Confirm_Button");


end

function CharSelectLayer:onEnter()
    local x,y=self.pageView:getPosition();
    self.pageView:runAction(cc.MoveTo:create(1,cc.p(display.cx,y)));
    self.pageView:scrollToPage(0);
    self.pageView:addEventListener(function(sender,eventType)
       -- print(self.pageView:getCurrentPageIndex());
        local temp=self.pageView:getCurrentPageIndex()+1;
        cc.UserDefault:getInstance():setIntegerForKey("User_Id",temp);
    end);

    self.button:addTouchEventListener(function(sender,eventType)
        --print(sender:getTag())
        if(eventType==ccui.TouchEventType.ended) then
            local scene=cc.Scene:create();
            scene:addChild(GameLayer:create());
            cc.Director:getInstance():pushScene(cc.TransitionFadeBL:create(1,scene));
            --self:removeFromParent();



        end
    end);
end

function CharSelectLayer:onExit()
    
end

return CharSelectLayer