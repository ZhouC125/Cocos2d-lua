require("app.views.DefineType")
local State=class("State");
function State:onState(obj) end



local BorningState=class("BorningState",State);
function BorningState:onState(obj)
    obj:onBorning();
end

function BorningState:canAttack() return false; end
function BorningState:canBeAttacked() return true; end
function BorningState:lifeFlag() return true; end
function BorningState:canBeRemoved() return false; end
function BorningState:canGetHurt() return false; end



local BattleState=class("BattleState",State);
function BattleState:onState(obj) 
end

function BattleState:canAttack() return true; end
function BattleState:canBeAttacked() return true; end
function BattleState:lifeFlag() return true; end
function BattleState:canBeRemoved() return false; end
function BattleState:canGetHurt() return true; end



local DieState=class("DieState",State);
function DieState:onState(obj)
    obj:onDie();
end

function DieState:canAttack() return false; end
function DieState:canBeAttacked() return false; end
function DieState:lifeFlag() return false; end
function DieState:canBeRemoved() return false; end
function DieState:canGetHurt() return false; end



local CanBeRemovedState=class("CanBeRemovedState",State);
function CanBeRemovedState:onState(obj)
end

function CanBeRemovedState:canAttack() return false; end
function CanBeRemovedState:canBeAttacked() return false; end
function CanBeRemovedState:lifeFlag() return false; end
function CanBeRemovedState:canBeRemoved() return true; end
function CanBeRemovedState:canGetHurt() return false; end



local UnmatchedState=class("UnmatchedState",State);
function UnmatchedState:onState(obj)
end

function UnmatchedState:canAttack() return true; end
function UnmatchedState:canBeAttacked() return true; end
function UnmatchedState:lifeFlag() return true; end
function UnmatchedState:canBeRemoved() return false; end
function UnmatchedState:canGetHurt() return false; end




local StateMng=class("StateMng");
function StateMng:getInstance(  )
    -- body
    if(self.instance==nil) then
        self.instance=StateMng:create();
    end
    return self.instance;
end

function StateMng:ctor()
    self.stateArr={};
    self.stateArr[STATE.kBorning]=BorningState:create();
    self.stateArr[STATE.kBattle]=BattleState:create();
    self.stateArr[STATE.kDie]=DieState:create();
    self.stateArr[STATE.kCanBeRemoved]=CanBeRemovedState:create();
    self.stateArr[STATE.kUnmatched]=UnmatchedState:create();
    
end

function StateMng:getState(s)
    return self.stateArr[s];
end

return StateMng;