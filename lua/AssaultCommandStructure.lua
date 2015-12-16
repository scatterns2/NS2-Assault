Script.Load("lua/CommandStructure.lua")

function CommandStructure:OnUpdateAnimationInput(modelMixin)

    PROFILE("CommandStructure:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("occupied", true)
    
end

function CommandStructure:OnUse(player, elapsedTime, useSuccessTable)   
end


function CommandStructure:GetIsCollecting()
    return GetIsUnitActive(self) and GetGamerules():GetGameStarted()
end

function CommandStructure:CollectResources()

	local team = self:GetTeam()
	if team then
		team:AddTeamResources(kTeamResourcePerTick, true)
	end
   
	local attached = self:GetAttached()
	
	if attached and attached.CollectResources then
	
		// reduces the resource count of the node
		attached:CollectResources()
	
	end
	
end

function CommandStructure:OnUpdate(deltaTime)
    
	ScriptActor.OnUpdate(self, deltaTime)

	if self:GetIsCollecting() then

        if not self.timeLastCollected then
            self.timeLastCollected = Shared.GetTime()
        end

        if self.timeLastCollected + kResourceTowerResourceInterval < Shared.GetTime() then
        
            self:CollectResources()
            self.timeLastCollected = Shared.GetTime()
            
        end
        
    else
        self.timeLastCollected = nil
    end
	
end