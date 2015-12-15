// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\TechPoint.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

class 'TechPoint' (ScriptActor)

TechPoint.kMapName = "tech_point"

// Note that these need to be changed in editor_setup.xml as well.
TechPoint.kModelName = PrecacheAsset("models/misc/tech_point/tech_point.model")
local kGraphName = PrecacheAsset("models/misc/tech_point/tech_point.animation_graph")

TechPoint.kTechPointEffect = PrecacheAsset("cinematics/common/techpoint.cinematic")
TechPoint.kTechPointLightEffect = PrecacheAsset("cinematics/common/techpoint_light.cinematic")

//if Server then
//    Script.Load("lua/TechPoint_Server.lua")
//end

local networkVars =
{
    smashed = "boolean",
    smashScouted = "boolean",
    showObjective = "boolean",
    occupiedTeam = string.format("integer (-1 to %d)", kSpectatorIndex),
    attachedId = "entityid",
    extendAmount = "float (0 to 1 by 0.01)",
	marineside = "boolean",
	alienside = "boolean",
	marinecaptureProgress = "float (0 to 1 by 0.005)",
	aliencaptureProgress = "float (0 to 1 by 0.005)",

}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)


function TechPoint:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    // Anything that can be built upon should have this group
    self:SetPhysicsGroup(PhysicsGroup.AttachClassGroup)
    
    // Make the nozzle kinematic so that the player will collide with it.
    self:SetPhysicsType(PhysicsType.Kinematic)
    
    // Defaults to 1 but the mapper can adjust this setting in the editor.
    // The higher the chooseWeight, the more likely this point will be randomly chosen for a team.
    self.chooseWeight = 1
    if Server then
		self.timeLastChecked = 0
	end
    self.extendAmount = 0
    
end


function TechPoint:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false
end

function TechPoint:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(TechPoint.kModelName, kGraphName)
    
    self:SetTechId(kTechId.TechPoint)
    
    self.extendAmount = math.min(1, math.max(0, self.extendAmount))
	self.aliencaptureProgress = 0
	self.marinecaptureProgress = 0

   if Server then
    
        // 0 indicates all teams allowed for random selection process.
        self.allowedTeamNumber = self.teamNumber or 0
        self.smashed = false
        self.smashScouted = false
        self.showObjective = false
        self.occupiedTeam = 0
        self.marineside = false
		self.alienside = false

	   // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
       self:SetRelevancyDistance(Math.infinity)
       self:SetExcludeRelevancyMask(bit.bor(kRelevantToTeam1, kRelevantToTeam2, kRelevantToReadyRoom))
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
        local coords = self:GetCoords()
        self:AttachEffect(TechPoint.kTechPointEffect, coords)
        self:AttachEffect(TechPoint.kTechPointLightEffect, coords, Cinematic.Repeat_Loop)
        
    end
end



function TechPoint:GetChooseWeight()
    return self.chooseWeight
end

function TechPoint:SetIsSmashed(setSmashed)

    self.smashed = setSmashed
    self.smashScouted = false
    
end

function TechPoint:SetSmashScouted()

    if Server then
        self.smashScouted = true
    end
    
end

function TechPoint:GetExtendAmount()
    return self.extendAmount
end

function TechPoint:GetCaptureProgress()
	//for i, techPoint in ipairs(captureProgress) do
		//local bla = techPoint:GetEntitiesWithinRange("Player", techPoint:GetOrigin(), 5)
		
		
	//	Print("%s", techPoint)  
	return 0.5
	//end
end

if Server then

    function TechPoint:GetTeamNumberAllowed()
        return self.allowedTeamNumber
    end
    
end

if Client then

    function TechPoint:OnUpdateAnimationInput(modelMixin)
    
        PROFILE("TechPoint:OnUpdateAnimationInput")
        
        local player = Client.GetLocalPlayer()
        if player then
        
            local scouted = false
            
            if player:isa("Commander") and player:GetTeamNumber() == GetEnemyTeamNumber(self.occupiedTeam) then
                scouted = self.smashScouted
            else
                scouted = true
            end
            
            modelMixin:SetAnimationInput("hive_deploy", self.smashed and scouted)
            
        end
        
    end
    
end

function TechPoint:GetCanTakeDamageOverride()
    return false
end

function TechPoint:GetCanDieOverride()
    return false
end

function TechPoint:OnAttached(entity)
    self.occupiedTeam = entity:GetTeamNumber()
end

function TechPoint:OnDetached()
    self.showObjective = false
    self.occupiedTeam = 0
end

function TechPoint:Reset()
    
    self:OnInitialized()
    
    self:ClearAttached()
    
end

function TechPoint:SetAttached(structure)

    if structure and structure:isa("CommandStation") then
        self.smashed = false
        self.smashScouted = false
    end
    ScriptActor.SetAttached(self, structure)
    
end 


// Spawn command station or hive on tech point
function TechPoint:SpawnCommandStructure(teamNumber)

    local alienTeam = (GetGamerules():GetTeam(teamNumber):GetTeamType() == kAlienTeamType)
    local techId = ConditionalValue(alienTeam, kTechId.CragHive, kTechId.MainCommandStation)
    
    return CreateEntityForTeam(techId, Vector(self:GetOrigin()), teamNumber)

	
end

function TechPoint:SpawnCaptureStructure(teamNumber)

    local alienTeam = (GetGamerules():GetTeam(teamNumber):GetTeamType() == kAlienTeamType)
    local techId = ConditionalValue(alienTeam, kTechId.Hive, kTechId.CommandStation)
    
    return CreateEntityForTeam(techId, Vector(self:GetOrigin()), teamNumber)

	
end



function TechPoint:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
	if Server then
		if self.smashed and not self.smashScouted then
			local attached = self:GetAttached()
			if attached and attached:GetIsSighted() then
				self.smashScouted = true
			end
		end    
    
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
				    alienCaptureMultiplier = Clamp(alienCaptureMultiplier, 0, 3)
				end
				--Capture Rate
				
				if marineCaptureMultiplier > 0 and self.marinecaptureProgress < 1 then
					self.marinecaptureProgress = self.marinecaptureProgress + marineCaptureMultiplier * deltaTime * 0.02
				elseif alienCaptureMultiplier > 0 and self.aliencaptureProgress < 1 then
					self.aliencaptureProgress = self.aliencaptureProgress + alienCaptureMultiplier * deltaTime *0.02
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
					local commandStructure = self:SpawnCaptureStructure(kMarineTeamType)
					commandStructure:SetConstructionComplete()
					self.marinecaptureProgress = 0
				elseif self.aliencaptureProgress == 1 and numMarines == 0 then
					local commandStructure = self:SpawnCaptureStructure(kAlienTeamType)
					commandStructure:SetConstructionComplete()
					self.aliencaptureProgress = 0
				end
			//	Print("%s", self.captureProgress )

				if commandStructure ~= nil then
		
					//commandStructure:SetConstructionComplete()
					local techPointCoords = self:GetCoords()
					techPointCoords.origin = commandStructure:GetOrigin()
					commandStructure:SetCoords(techPointCoords)
					
				end
				
			end
		end
	end	
end 


Shared.LinkClassToMap("TechPoint", TechPoint.kMapName, networkVars)