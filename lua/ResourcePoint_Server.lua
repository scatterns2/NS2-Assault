// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ResourcePoint_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function ResourcePoint:Reset()
    
    self:OnInitialized()
    
    self:ClearAttached()
    
end

function ResourcePoint:OnAttached(entity)
    self.occupiedTeam = entity:GetTeamNumber()
    entity:SetCoords(self:GetCoords())
end

function ResourcePoint:OnDetached()
    self.showObjective = false
    self.occupiedTeam = 0
end

function ResourcePoint:SpawnResStructure(teamNumber)

    local alienTeam = (GetGamerules():GetTeam(teamNumber):GetTeamType() == kAlienTeamType)
    local techId = ConditionalValue(alienTeam, kTechId.Harvester, kTechId.Extractor)
    
    return CreateEntityForTeam(techId, Vector(self:GetOrigin()), teamNumber)
    
	
end



// Create a new resource tower on this nozzle, returning false if already occupied or not enough room
function ResourcePoint:SpawnResourceTowerForTeam(team, techId)

    if self:GetAttached() == nil then
    
        // Force create because entity may not be cleaned up from round reset
        local tower = CreateEntityForTeam(techId, self:GetOrigin(), team:GetTeamNumber(), nil)
        
        if tower then
        
            tower:SetConstructionComplete()           
            
            self:SetAttached(tower)
            
            return tower
            
        end
       
    else
        Print("ResourcePoint:SpawnResourceTowerForTeam(%s): Entity %s already attached.", EnumToString(kTechId, techId), self:GetAttached():GetClassName()) 
    end
    
    return nil
    
end

function ResourcePoint:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
		if GetGamerules():GetGameStarted() then

			if self:GetAttached() == nil then

				local kCaptureRange = 5
				
				--Check for number of marines and aliens nearby
				
				numMarines = #GetEntitiesWithinRange("Marine", Vector(self:GetOrigin()), kCaptureRange)
				numAliens  = #GetEntitiesWithinRange("Alien", Vector(self:GetOrigin()), kCaptureRange)

				local alienCaptureMultiplier = 0
				local marineCaptureMultiplier = 0
				
				--Capture Multiplier
				
				if numMarines > numAliens and numMarines > 0 then
					marineCaptureMultiplier = numMarines - numAliens
					marineCaptureMultiplier = Clamp(marineCaptureMultiplier, 0, 3)
				elseif numAliens > numMarines and numAliens > 0 then
					alienCaptureMultiplier = numAliens - numMarines
					  alienCaptureMultiplier = math.max(alienCaptureMultiplier, 3)
				end
				
				--Capture Rate
				
				if marineCaptureMultiplier > 0 and self.marinecaptureProgress < 1 then
					self.marinecaptureProgress = self.marinecaptureProgress + marineCaptureMultiplier * deltaTime * 0.03
				elseif alienCaptureMultiplier > 0 and self.aliencaptureProgress < 1 then
					self.aliencaptureProgress = self.aliencaptureProgress + alienCaptureMultiplier * deltaTime *0.03
				end
				self.marinecaptureProgress = Clamp(self.marinecaptureProgress, 0, 1)
				self.aliencaptureProgress = Clamp(self.aliencaptureProgress, 0, 1)
				
				-- Capture Decay
				
				if numMarines == 0 and self.marinecaptureProgress > 0 and self.marinecaptureProgress < 1 then
					self.marinecaptureProgress = self.marinecaptureProgress - 1 * deltaTime * 0.02
					//self.captureProgress = Clamp(self.captureProgress, 0.5, 1)
				elseif numAliens == 0 and self.aliencaptureProgress > 0 and self.aliencaptureProgress < 1 then
					self.aliencaptureProgress = self.aliencaptureProgress - 1 * deltaTime * 0.02
					//self.captureProgress = Clamp(self.captureProgress, 0, 0.5)
				end
				
				--Spawning command structure conditions
				
				if self.marinecaptureProgress == 1 and numAliens == 0 then
					local resStructure = self:SpawnResStructure(kMarineTeamType)
					resStructure:SetConstructionComplete()
					self.marinecaptureProgress = 0
				elseif self.aliencaptureProgress == 1 and numMarines == 0 then
					local resStructure = self:SpawnResStructure(kAlienTeamType)
					resStructure:SetConstructionComplete()
					self.aliencaptureProgress = 0

				end
			//	Print("%s", self.captureProgress )

				if resStructure ~= nil then
		
					//commandStructure:SetConstructionComplete()
					local techPointCoords = self:GetCoords()
					techPointCoords.origin = resStructure:GetOrigin()
					resStructure:SetCoords(techPointCoords)
					
				end
				
			end
		end
		
		

	
end   