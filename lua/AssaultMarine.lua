
Script.Load("lua/Marine.lua")
Script.Load("lua/Weapons/Marine/MarineStructureAbility.lua")



	

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




