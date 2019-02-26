
local StateMng=require("app.views.State");
local Obj=class("Obj",cc.Node);

function  Obj:getCollideBox( ... )
    -- body
    local rect=self.mode:getBoundingBox();
    rect.x=rect.x+self:getPositionX();
    rect.y=rect.y+self:getPositionY();
    return rect;

end

function Obj:setState(s)
    self.state=StateMng:getInstance():getState(s);
    self.state:onState(self);
end

function Obj:cutHP(damage)
    if(self:canGetHurt()) then
        self.hp=self.hp-damage;
    end
end

function Obj:canAttack() return self.state:canAttack(); end
function Obj:canBeAttacked() return self.state:canBeAttacked(); end
function Obj:lifeFlag() return self.state:lifeFlag(); end
function Obj:canBeRemoved() return self.state:canBeRemoved(); end
function Obj:canGetHurt() return self.state:canGetHurt(); end

return Obj;