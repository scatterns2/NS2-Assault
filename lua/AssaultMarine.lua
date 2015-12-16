
Script.Load("lua/Marine.lua")
Script.Load("lua/Weapons/Marine/MarineStructureAbility.lua")

origMarineOnInit = Marine.OnInitialized
function Marine:OnInitialized()

	origMarineOnInit(self)
	//self:InitTechTree()
    
end


function Marine:InitWeapons()

    Player.InitWeapons(self)
    
    self:GiveItem(Rifle.kMapName)
    self:GiveItem(Pistol.kMapName)
    self:GiveItem(Axe.kMapName)
    self:GiveItem(Builder.kMapName)
	self:GiveItem(MarineStructureAbility.kMapName)
	
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)

end

function Marine:OverrideInput(input)

	// Always let the MarineStructureAbility override input, since it handles client-side-only build menu
	local buildAbility = self:GetWeapon(MarineStructureAbility.kMapName)

	if buildAbility then
		input = buildAbility:OverrideInput(input)
	end
	
	return Player.OverrideInput(self, input)
        
end

function Marine:ProcessBuyAction(techIds)

    ASSERT(type(techIds) == "table")
    ASSERT(table.count(techIds) > 0)
    
    local techTree = self:GetTechTree()
    local buyAllowed = true
    local totalCost = 0
    local validBuyIds = { }
    
    for i, techId in ipairs(techIds) do
    
        local techNode = techTree:GetTechNode(techId)
        if(techNode ~= nil and techNode.available) and not self:GetHasUpgrade(techId) then
			Print("%s", techNode.available)
            local cost = GetCostForTech(techId)
            if cost ~= nil then
                totalCost = totalCost + cost
                table.insert(validBuyIds, techId)
				Print("%s", validBuyIds)
            end
        
        else
        
            buyAllowed = false
            break
        
        end
        
    end
    
    if totalCost <= self:GetResources() then
    
        if self:AttemptToBuy(validBuyIds) then
		    local techNode = techTree:GetTechNode(validBuyIds[1])
            techNode:SetResearched(true)
            techNode:SetHasTech(true)
            techTree:SetTechNodeChanged(techNode)
            techTree:SetTechChanged() 
            //self:UpdateTechTree()
			self:AddResources(-totalCost)
            return true
        end
        
    else
        Print("not enough resources sound server")
        Server.PlayPrivateSound(self, self:GetNotEnoughResourcesSound(), self, 1.0, Vector(0, 0, 0))        
    end

    return false
    
end

function Marine:AttemptToBuy(techIds)

    local techId = techIds[1]
	Print("%s", techId)
	if techId == kTechId.Armor1 or techId == kTechId.Armor2 or techId == kTechId.Armor3 or techId == kTechId.Weapons1 or techId == kTechId.Weapons2 or techId == kTechId.Weapons3 then
		return true
	end
    local hostStructure = GetHostStructureFor(self, techId)

    if hostStructure then
    
        local mapName = LookupTechData(techId, kTechDataMapName)
        
        if mapName then
		Print("%s", mapName)

            Shared.PlayPrivateSound(self, Marine.kSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
            
            if self:GetTeam() and self:GetTeam().OnBought then
                self:GetTeam():OnBought(techId)
            end
            
			
			
            if techId == kTechId.Jetpack then

                // Need to apply this here since we change the class.
                self:AddResources(-GetCostForTech(techId))
                self:GiveJetpack()
                
            elseif kIsExoTechId[techId] then
                BuyExo(self, techId)    
            else
            
                // Make sure we're ready to deploy new weapon so we switch to it properly.
                if self:GiveItem(mapName) then
                
                    StartSoundEffectAtOrigin(Marine.kGunPickupSound, self:GetOrigin())                    
                    return true
                    
                end
                
            end
            
            return false
            
        end
        
    end
    
    return false
    
end

local orig_Marine_UpdateGhostModel = MarineUpdateGhostModel
function Marine:UpdateGhostModel()

    self.currentTechId = nil
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()
	
	if weapon then
		if weapon:isa("MarineStructureAbility") then
		
			self.currentTechId = weapon:GetGhostModelTechId()
			self.ghostStructureCoords = weapon:GetGhostModelCoords()
			self.ghostStructureValid = weapon:GetIsPlacementValid()
			self.showGhostModel = weapon:GetShowGhostModel()

			return weapon:GetShowGhostModel()
			
		elseif weapon:isa("LayMines") then
    
			self.currentTechId = kTechId.Mine
			self.ghostStructureCoords = weapon:GetGhostModelCoords()
			self.ghostStructureValid = weapon:GetIsPlacementValid()
			self.showGhostModel = weapon:GetShowGhostModel()
    
		end	
	end

end

if Client then

    function Marine:GetShowGhostModel()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("MarineStructureAbility") then
            return weapon:GetShowGhostModel()       
		end
		
        return false
        
    end
	
    function Marine:GetGhostModelOverride()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("MarineStructureAbility") and weapon.GetGhostModelName then
            return weapon:GetGhostModelName(self)

						
        end
        
    end
    
    function Marine:GetGhostModelTechId()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("MarineStructureAbility") then
            return weapon:GetGhostModelTechId()		
        end
        
    end
   
    function Marine:GetGhostModelCoords()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("MarineStructureAbility") then
            return weapon:GetGhostModelCoords()		
        end
        
    end
    
    function Marine:GetLastClickedPosition()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("MarineStructureAbility") then
            return weapon.lastClickedPosition
        end
    end

    function Marine:GetIsPlacementValid()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("MarineStructureAbility") then
            return weapon:GetIsPlacementValid()		
        end
    
    end

end

function Marine:GetExoCompletion()

	for i, teaminfo in ipairs ( GetEntitiesForTeam("TeamInfo", kMarineTeamType) ) do
		marineRes = teaminfo:GetTeamResources() / 200
	end
			
	return marineRes
	
end
	
function Marine:GetOnosCompletion()

	for i, teaminfo in ipairs ( GetEntitiesForTeam("TeamInfo", kAlienTeamType) ) do
		alienRes = teaminfo:GetTeamResources() / 200
	end
			
	return alienRes
	
end


