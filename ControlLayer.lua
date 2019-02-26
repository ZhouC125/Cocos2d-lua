
local ControlLayer=class("ControlLayer",cc.Layer);
 function ControlLayer:ctor(hero)
     -- body
     self:init(hero);
     local function onNodeEvent(event)
        if(event=="enter") then
            self:onEnter();
        elseif(event=="exit") then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
 end

 function ControlLayer:init(hero)
    self.hero=hero;
 end

 function ControlLayer:onEnter()
    local eventDispatcher=cc.Director:getInstance():getEventDispatcher();

    self.touchListener=cc.EventListenerTouchOneByOne:create();
    self.touchListener:setSwallowTouches(true);

    self.touchListener:registerScriptHandler(function(touch,event)
        return self:onTouchBegan(touch,event);
    end,cc.Handler.EVENT_TOUCH_BEGAN);

    self.touchListener:registerScriptHandler(function(touch,event)
        self:onTouchMoved(touch,event);
    end,cc.Handler.EVENT_TOUCH_MOVED);

    self.touchListener:registerScriptHandler(function(touch,event)
        self:ontouchEnded(touch,event);
    end,cc.Handler.EVENT_TOUCH_ENDED);
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.touchListener,self);

    self.listenerHeroDie=cc.EventListenerCustom:create("Hero_Die",function(event)
        eventDispatcher:dispatchEvent(cc.EventCustom:new("SendBullet_Stop"));
        self:removeFromParent();
    end);
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerHeroDie,self);
 end

 function ControlLayer:onExit()
    local eventDispatcher=cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:removeEventListener(self.listenerHeroDie);
 end

 function ControlLayer:onTouchBegan(touch,event)
    
    local touchPoint=touch:getLocation();
    local x,y=self.hero:getPosition();
    local rect=self.hero:getCollideBox();
    if(cc.rectContainsPoint(rect,touchPoint)) then
        --print("-----------touch began");
        local event=cc.EventCustom:new("SendBullet_Start");
        event._usedata={["deep"]="dark",["snow"]="halation"};
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(event);
        self.hero:setScale(1.1);

        --cc.Director:getInstance():getScheduler():setTimeScale(10);
        return true;
    else
        return false;
    end
end

function ControlLayer:onTouchMoved(touch,event)
    --print("--------touch moved");
    self.hero:setPositionX(touch:getLocation().x);
end

function ControlLayer:ontouchEnded(touch,event)
    --print("-----------touch ended");
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(cc.EventCustom:new("SendBullet_Stop"));
    self.hero:setScale(1.0);
    cc.Director:getInstance():getScheduler():setTimeScale(1);
end

return ControlLayer;
 