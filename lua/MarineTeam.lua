// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for teams that are actually playing the game, e.g. Marines or Aliens.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Marine.lua")
Script.Load("lua/PlayingTeam.lua")

class 'MarineTeam' (PlayingTeam)

MarineTeam.gSandboxMode = false

// How often to send the "No IPs" message to the Marine team in seconds.
local kSendNoIPsMessageRate = 20

local kCannotSpawnSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/need_ip")

--Cache for spawned ip positions
local takenInfantryPortalPoints = {}

function MarineTeam:ResetTeam()
	takenInfantryPortalPoints = {}
	
    local commandStructure = PlayingTeam.ResetTeam(self)
    
    self.updateMarineArmor = false
    
    if self.brain ~= nil then
        self.brain:Reset()
    end
    
    return commandStructure
    
end

function MarineTeam:OnResetComplete()

    //adjust first power node    
    local initialTechPoint = self:GetInitialTechPoint()
    for index, powerPoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
    
        if powerPoint:GetLocationName() == initialTechPoint:GetLocationName() then
            powerPoint:SetConstructionComplete()
        end
        
    end
    
end

function MarineTeam:GetTeamType()
    return kMarineTeamType
end

function MarineTeam:GetIsMarineTeam()
    return true 
end

function MarineTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = Marine.kMapName
    
    self.updateMarineArmor = false
    
    self.lastTimeNoIPsMessageSent = Shared.GetTime()
    
end

function MarineTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
	self.marineOwnedStructures = { }

    self.respawnEntity = Marine.kMapName
    
    self.updateMarineArmor = false
    
    self.lastTimeNoIPsMessageSent = Shared.GetTime()
    
end

function MarineTeam:OnInitialized()

    PlayingTeam.OnInitialized(self)
    
    
    self.marineOwnedStructures = { }
    
end

local function RemoveMarineStructureFromClient(self, techId, clientId)

    local structureTypeTable = self.marineOwnedStructures[clientId]
    
    if structureTypeTable then
    
        if not structureTypeTable[techId] then
        
            structureTypeTable[techId] = { }
            return
            
        end    
        
        local removeIndex = 0
        local structure = nil
        for index, id in ipairs(structureTypeTable[techId])  do
        
            if id then
            
                removeIndex = index
                structure = Shared.GetEntity(id)
                break
                
            end
            
        end
        
        if structure then
        
            table.remove(structureTypeTable[techId], removeIndex)
            structure.consumed = true
            if structure:GetCanDie() then
                structure:Kill()
            else
                DestroyEntity(structure)
            end
            
        end
        
    end
    
end

function MarineTeam:AddMarineStructure(player, structure)

    if player ~= nil and structure ~= nil then
    
        local clientId = Server.GetOwner(player):GetUserId()
        local structureId = structure:GetId()
        local techId = structure:GetTechId()

        if not self.marineOwnedStructures[clientId] then
            self.marineOwnedStructures[clientId] = { }
        end
        
        local structureTypeTable = self.marineOwnedStructures[clientId]
        
        if not structureTypeTable[techId] then
            structureTypeTable[techId] = { }
        end
        
        table.insertunique(structureTypeTable[techId], structureId)
        
        local numAllowedStructure = LookupTechData(techId, kTechDataMaxAmount, -1) 
        
        if numAllowedStructure >= 0 and table.count(structureTypeTable[techId]) > numAllowedStructure then
            RemoveMarineStructureFromClient(self, techId, clientId)
        end
        
    end
    
end

function MarineTeam:GetDroppedMarineStructures(player, techId)

    local owner = Server.GetOwner(player)

    if owner then
    
        local clientId = owner:GetUserId()
        local structureTypeTable = self.marineOwnedStructures[clientId]
        
        if structureTypeTable then
            return structureTypeTable[techId]
        end
    
    end
    
end


function MarineTeam:GetNumDroppedMarineStructures(player, techId)

    local structureTypeTable = self:GetDroppedMarineStructures(player, techId)
    return (not structureTypeTable and 0) or #structureTypeTable
    
end

function MarineTeam:UpdateMarineOwnedStructures(oldEntityId)

    if oldEntityId then
    
        for clientId, structureTypeTable in pairs(self.marineOwnedStructures) do
        
            for techId, structureList in pairs(structureTypeTable) do
            
                for i, structureId in ipairs(structureList) do
                
                    if structureId == oldEntityId then
                    
                        table.remove(structureList, i)
                        break
                        
                    end
                    
                end
                
            end
            
        end
        
    end

end

function MarineTeam:OnEntityChange(oldEntityId, newEntityId)

    PlayingTeam.OnEntityChange(self, oldEntityId, newEntityId)

    // Check if the oldEntityId matches any client's built structure and
    // handle the change.
    
    self:UpdateMarineOwnedStructures(oldEntityId)

end

function MarineTeam:GetHasAbilityToRespawn()

    // Any active IPs on team? There could be a case where everyone has died and no active
    // IPs but builder bots are mid-construction so a marine team could theoretically keep
    // playing but ignoring that case for now
    local spawningStructures = GetEntitiesForTeam("InfantryPortal", self:GetTeamNumber())
    
    for index, current in ipairs(spawningStructures) do
    
        if current:GetIsBuilt() and current:GetIsPowered() then
            return true
        end
        
    end        
    
    return false
    
end

function MarineTeam:SpawnSuperUnit()

    local commandStructures = GetEntitiesForTeam("RoboticsFactory", kMarineTeamType)
    //local startBase = commandStructure:GetEntitiesWithinRange("PrototypeLab", commandStructures:GetOrigin(), 10)
	local teamRes = self:GetTeamResources()
	if teamRes == 200 then
	
		CreateEntityForTeam(kTechId.Exosuit, commandStructures:GetOrigin() + Vector(0, 2, 2), kMarineTeamType)
		self:AddResources(-200)
	end
end

function MarineTeam:OnRespawnQueueChanged()

    local spawningStructures = GetEntitiesForTeam("InfantryPortal", self:GetTeamNumber())
    
    for index, current in ipairs(spawningStructures) do
    
        if current:GetIsBuilt() and current:GetIsPowered() then
            current:FillQueueIfFree()
        end
        
    end        
    
end


function MarineTeam:GetTotalInRespawnQueue()
    
    local queueSize = #self.respawnQueue
    local numPlayers = 0
    
    for i = 1, #self.respawnQueue do
        local player = Shared.GetEntity(self.respawnQueue[i])
        if player then
            numPlayers = numPlayers + 1
        end
    
    end
    
    local allIPs = GetEntitiesForTeam( "InfantryPortal", self:GetTeamNumber() )
    if #allIPs > 0 then
        
        for _, ip in ipairs( allIPs ) do
        
            if GetIsUnitActive( ip ) then
                
                if ip.queuedPlayerId ~= nil and ip.queuedPlayerId ~= Entity.invalidId then
                    numPlayers = numPlayers + 1
                end
                
            end
        
        end
        
    end
    
    return numPlayers
    
end


// Clear distress flag for all players on team, unless affected by distress beaconing Observatory. 
// This function is here to make sure case with multiple observatories and distress beacons is
// handled properly.
function MarineTeam:UpdateGameMasks(timePassed)

    PROFILE("MarineTeam:UpdateGameMasks")

    local beaconState = false
    
    for obsIndex, obs in ipairs(GetEntitiesForTeam("Observatory", self:GetTeamNumber())) do
    
        if obs:GetIsBeaconing() then
        
            beaconState = true
            break
            
        end
        
    end
    
    for playerIndex, player in ipairs(self:GetPlayers()) do
    
        if player:GetGameEffectMask(kGameEffect.Beacon) ~= beaconState then
            player:SetGameEffectMask(kGameEffect.Beacon, beaconState)
        end
        
    end
    
    
end

local function CheckForNoIPs(self)

    PROFILE("MarineTeam:CheckForNoIPs")

    if Shared.GetTime() - self.lastTimeNoIPsMessageSent >= kSendNoIPsMessageRate then
    
        self.lastTimeNoIPsMessageSent = Shared.GetTime()
        if Shared.GetEntitiesWithClassname("InfantryPortal"):GetSize() == 0 then
        
            self:ForEachPlayer(function(player) StartSoundEffectForPlayer(kCannotSpawnSound, player) end)
            SendTeamMessage(self, kTeamMessageTypes.CannotSpawn)
            
        end
        
    end
    
end

function MarineTeam:SpawnExo()
	
	 
	for _, techPoint in ipairs(GetEntitiesForTeam("MainCommandStation", self:GetTeamNumber())) do
	
		local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
		
		local spawnPoint = nil
		
			spawnPoint = GetRandomBuildPosition( kTechId.Exosuit, techPointOrigin, kInfantryPortalAttachRange + 5 )
			spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
			
		if spawnPoint then
		
			local pt = CreateEntity(Exosuit.kMapName, spawnPoint, self:GetTeamNumber())
			

			
		end
		techPoint:GetTeam():AddTeamResources(-200)
    end

end

local function SpawnMac(self, techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.MAC, techPointOrigin, kInfantryPortalAttachRange + 5 )
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local pt = CreateEntity(MAC.kMapName, spawnPoint, self:GetTeamNumber())
        
        
    end
    
end

function MarineTeam:SpawnStructure(techPoint,techId, mapName)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
    // First check the predefined spawn points. Look for a close one.
    for p = 1, #Server.infantryPortalSpawnPoints do
		
		if not takenInfantryPortalPoints[p] then 
			local predefinedSpawnPoint = Server.infantryPortalSpawnPoints[p]
			if (predefinedSpawnPoint - techPointOrigin):GetLength() <= kInfantryPortalAttachRange then
				spawnPoint = predefinedSpawnPoint
				takenInfantryPortalPoints[p] = true
				break
			end
		end
        
    end
    
    if not spawnPoint then
		
        spawnPoint = GetRandomBuildPosition( mapName, techPointOrigin, kInfantryPortalAttachRange )
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    end
    
    if spawnPoint then
    
        local ip = CreateEntity(mapName, spawnPoint, self:GetTeamNumber())
        
        SetRandomOrientation(ip)
        ip:SetConstructionComplete()
        
    end
    
end



local function GetArmorLevel(self)

    local armorLevels = 0
    
    local techTree = self:GetTechTree()
    if techTree then
    
        if techTree:GetHasTech(kTechId.Armor3) then
            armorLevels = 3
        elseif techTree:GetHasTech(kTechId.Armor2) then
            armorLevels = 2
        elseif techTree:GetHasTech(kTechId.Armor1) then
            armorLevels = 1
        end
    
    end
    
    return armorLevels

end

function MarineTeam:Update(timePassed)

    PROFILE("MarineTeam:Update")

    PlayingTeam.Update(self, timePassed)

    // Update distress beacon mask
    self:UpdateGameMasks(timePassed)    

    if GetGamerules():GetGameStarted() then
        CheckForNoIPs(self)
    end
        
    for index, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
        if self:GetTeamNumber() == 1 and player:GetIsAlive() then
            local armorLevel = player:GetArmorLevel()
            player:UpdateArmorAmount(armorLevel)
        end
    end
	
	if self:GetTeamResources() == 200 then
	
		self:SpawnExo()
	end
	
end

function MarineTeam:GetHasPoweredPhaseGate()
    return self.hasPoweredPG == true    
end

function MarineTeam:InitTechTree()
   
   PlayingTeam.InitTechTree(self)
    
    // Marine tier 1
    self.techTree:AddBuildNode(kTechId.CommandStation,            kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.MainCommandStation,            kTechId.None,                kTechId.None)
	self.techTree:AddTechInheritance(kTechId.CommandStation , kTechId.MainCommandStation)

  self.techTree:AddBuildNode(kTechId.Extractor,                 kTechId.None,                kTechId.None)
    
    self.techTree:AddUpgradeNode(kTechId.ExtractorArmor)
    
    // Count recycle like an upgrade so we can have multiples
    self.techTree:AddUpgradeNode(kTechId.Recycle, kTechId.None, kTechId.None)
    
    self.techTree:AddPassive(kTechId.Welding)
    self.techTree:AddPassive(kTechId.SpawnMarine)
    self.techTree:AddPassive(kTechId.CollectResources, kTechId.Extractor)
    self.techTree:AddPassive(kTechId.Detector)
    
    self.techTree:AddSpecial(kTechId.TwoCommandStations)
    self.techTree:AddSpecial(kTechId.ThreeCommandStations)
    self.techTree:AddSpecial(kTechId.FourCommandStations)
  
    // When adding marine upgrades that morph structures, make sure to add to GetRecycleCost() also
    self.techTree:AddBuildNode(kTechId.InfantryPortal,            kTechId.CommandStation,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Sentry,                    kTechId.RoboticsFactory,     kTechId.None, true)
    self.techTree:AddBuildNode(kTechId.Armory,                    kTechId.CommandStation,      kTechId.None)  
    self.techTree:AddBuildNode(kTechId.ArmsLab,                   kTechId.CommandStation,                kTechId.None)  
    self.techTree:AddManufactureNode(kTechId.MAC,                 kTechId.RoboticsFactory,                kTechId.None,  true) 

    self.techTree:AddBuyNode(kTechId.Axe,                         kTechId.None,              kTechId.None)
    self.techTree:AddBuyNode(kTechId.Pistol,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Rifle,                       kTechId.None,                kTechId.None)

    self.techTree:AddBuildNode(kTechId.SentryBattery,             kTechId.RoboticsFactory,      kTechId.None)      
    
    self.techTree:AddOrder(kTechId.Defend)
    self.techTree:AddOrder(kTechId.FollowAndWeld)
    
    // Commander abilities
    self.techTree:AddResearchNode(kTechId.NanoShieldTech)
    self.techTree:AddResearchNode(kTechId.CatPackTech)
    
    self.techTree:AddTargetedActivation(kTechId.NanoShield,       kTechId.NanoShieldTech)
    self.techTree:AddTargetedActivation(kTechId.Scan,             kTechId.Observatory)
    self.techTree:AddTargetedActivation(kTechId.PowerSurge,       kTechId.RoboticsFactory)
    self.techTree:AddTargetedActivation(kTechId.MedPack,          kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.AmmoPack,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.CatPack,          kTechId.CatPackTech) 
    
    self.techTree:AddAction(kTechId.SelectObservatory)

    // Armory upgrades
    self.techTree:AddUpgradeNode(kTechId.AdvancedArmoryUpgrade,  kTechId.Armory)
    
    // arms lab upgrades
    
    self.techTree:AddResearchNode(kTechId.Armor1,                 kTechId.None)
    self.techTree:AddResearchNode(kTechId.Armor2,                 kTechId.Armor1, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Armor3,                 kTechId.Armor2, kTechId.None)    
    self.techTree:AddResearchNode(kTechId.NanoArmor,              kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.Weapons1,               kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons2,               kTechId.Weapons1, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons3,               kTechId.Weapons2, kTechId.None)
    
    // Marine tier 2
    self.techTree:AddBuildNode(kTechId.AdvancedArmory,               kTechId.None,        kTechId.None)
    self.techTree:AddResearchNode(kTechId.PhaseTech,                    kTechId.None,        kTechId.None)
    self.techTree:AddBuildNode(kTechId.PhaseGate,                    kTechId.None,        kTechId.None, true)


    self.techTree:AddBuildNode(kTechId.Observatory,               kTechId.None,       kTechId.Armory)      
    self.techTree:AddActivation(kTechId.DistressBeacon,           kTechId.None)         
    
    // Door actions
    self.techTree:AddBuildNode(kTechId.Door, kTechId.None, kTechId.None)
    self.techTree:AddActivation(kTechId.DoorOpen)
    self.techTree:AddActivation(kTechId.DoorClose)
    self.techTree:AddActivation(kTechId.DoorLock)
    self.techTree:AddActivation(kTechId.DoorUnlock)
    
    // Weapon-specific
    self.techTree:AddResearchNode(kTechId.ShotgunTech,           kTechId.TwoCommandStations,              kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.Shotgun,            kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropShotgun,     kTechId.TwoCommandStations,         kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.AdvancedWeaponry,      kTechId.AdvancedArmory,      kTechId.None)    
    
    self.techTree:AddTargetedBuyNode(kTechId.GrenadeLauncher,  kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropGrenadeLauncher,  kTechId.AdvancedWeaponry)
    
    self.techTree:AddResearchNode(kTechId.GrenadeTech,           kTechId.Armory,                   kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.ClusterGrenade,     kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.GasGrenade,         kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.PulseGrenade,       kTechId.None)
    
    self.techTree:AddTargetedBuyNode(kTechId.Flamethrower,     kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropFlamethrower,    kTechId.TwoCommandStations)
    
    self.techTree:AddResearchNode(kTechId.MinesTech,            kTechId.CommandStation,           kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.LayMines,          kTechId.None,        kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropMines,      kTechId.MinesTech,        kTechId.None)
    
    self.techTree:AddTargetedBuyNode(kTechId.Welder,          kTechId.None,        kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropWelder,   kTechId.Armory,        kTechId.None)
    
    // ARCs
    self.techTree:AddBuildNode(kTechId.RoboticsFactory,                    kTechId.InfantryPortal,                 kTechId.None)  
    self.techTree:AddUpgradeNode(kTechId.UpgradeRoboticsFactory,           kTechId.Armory,              kTechId.RoboticsFactory) 
    self.techTree:AddBuildNode(kTechId.ARCRoboticsFactory,                 kTechId.Armory,              kTechId.RoboticsFactory)
    
    self.techTree:AddTechInheritance(kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory)
   
    self.techTree:AddManufactureNode(kTechId.ARC,    kTechId.ARCRoboticsFactory,     kTechId.None, true)        
    self.techTree:AddActivation(kTechId.ARCDeploy)
    self.techTree:AddActivation(kTechId.ARCUndeploy)
    
    // Robotics factory menus
    self.techTree:AddMenu(kTechId.RoboticsFactoryARCUpgradesMenu)
    self.techTree:AddMenu(kTechId.RoboticsFactoryMACUpgradesMenu)
    
    self.techTree:AddMenu(kTechId.WeaponsMenu)
    
    // Marine tier 3
    self.techTree:AddBuildNode(kTechId.PrototypeLab,          kTechId.AdvancedArmory,              kTechId.None)        

    // Jetpack
    self.techTree:AddResearchNode(kTechId.JetpackTech,           kTechId.PrototypeLab, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Jetpack,                    kTechId.None, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropJetpack,    kTechId.JetpackTech, kTechId.None)
    
    // Exosuit
   // self.techTree:AddResearchNode(kTechId.ExosuitTech,           kTechId.FourCommandStations, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exosuit,                    kTechId.FourCommandStations, kTechId.None)
   // self.techTree:AddTargetedActivation(kTechId.DropExosuit,     kTechId.ExosuitTech, kTechId.None)
    //self.techTree:AddResearchNode(kTechId.DualMinigunTech,       kTechId.ExosuitTech, kTechId.FourCommandStations)
   // self.techTree:AddResearchNode(kTechId.DualMinigunExosuit,    kTechId.DualMinigunTech, kTechId.FourCommandStations)
		self.techTree:AddBuyNode(kTechId.ClawRailgunExosuit,    kTechId.FourCommandStations, kTechId.None)
    //self.techTree:AddResearchNode(kTechId.DualRailgunTech,       kTechId.ExosuitTech, kTechId.FourCommandStations)
  //  self.techTree:AddResearchNode(kTechId.DualRailgunExosuit,    kTechId.DualMinigunTech, kTechId.FourCommandStations)
    
    self.techTree:AddBuyNode(kTechId.UpgradeToDualMinigun, kTechId.FourCommandStations, kTechId.None)
    self.techTree:AddBuyNode(kTechId.UpgradeToDualRailgun, kTechId.FourCommandStations, kTechId.None)

    self.techTree:AddActivation(kTechId.SocketPowerNode,    kTechId.None,   kTechId.None)
    
    self.techTree:SetComplete()

end

function MarineTeam:SpawnInitialStructures(techPoint)

    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
	self:SpawnStructure(techPoint, kTechId.Sentry, Sentry.kMapName)
	self:SpawnStructure(techPoint, kTechId.InfantryPortal, InfantryPortal.kMapName)
	self:SpawnStructure(techPoint, kTechId.InfantryPortal, InfantryPortal.kMapName)
	self:SpawnStructure( techPoint, kTechId.PrototypeLab, PrototypeLab.kMapName)
	self:SpawnStructure(techPoint, kTechId.AdvancedArmory, AdvancedArmory.kMapName)
	self:SpawnStructure(techPoint, kTechId.Observatory, Observatory.kMapName)
	self:SpawnStructure(techPoint, kTechId.PhaseGate, PhaseGate.kMapName)
	self:SpawnStructure( techPoint, kTechId.Sentry, Sentry.kMapName)
	self:SpawnStructure(techPoint, kTechId.Sentry, Sentry.kMapName)
    SpawnMac(self,techPoint)
	//SpawnExo(self,techPoint)
	

	local origin = techPoint:GetOrigin()
	local right = techPoint:GetCoords().xAxis
	local forward = techPoint:GetCoords().zAxis
	


    if Shared.GetCheatsEnabled() and MarineTeam.gSandboxMode then

        // Pretty dumb way of spawning two things..heh
        local origin = techPoint:GetOrigin()
        local right = techPoint:GetCoords().xAxis
        local forward = techPoint:GetCoords().zAxis
        CreateEntity( AdvancedArmory.kMapName, origin+right*3.5+forward*1.5, kMarineTeamType)
        CreateEntity( PrototypeLab.kMapName, origin+right*3.5-forward*1.5, kMarineTeamType)

    end
    
    return tower, commandStation
    
end

function MarineTeam:GetSpectatorMapName()
    return MarineSpectator.kMapName
end

function MarineTeam:OnBought(techId)

    local listeners = self.eventListeners['OnBought']

    if listeners then

        for _, listener in ipairs(listeners) do
            listener(techId)
        end

    end

end
