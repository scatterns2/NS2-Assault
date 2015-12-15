local function CTFTechAdditions(techData)

								
	table.insert(techData, {    [kTechDataId] = kTechId.MarineStructureAbility, 
								[kTechDataTooltipInfo] = "MARINE_BUILD_TOOLTIP", 
								[kTechDataPointValue] = kWeaponPointValue,   
								[kTechDataMapName] = MarineStructureAbility.kMapName, 
								[kTechDataDisplayName] = "MARINE_BUILD",        
								[kTechDataModel] = Welder.kModelName, 
								[kTechDataDamageType] = kWelderDamageType,
								[kTechDataCostKey] = kWelderCost, })
								
	table.insert(techData, {	[kTechDataId] = kTechId.Sentry, 
							    [kTechDataSupply] = kSentrySupply,
							    [kTechDataBuildMethodFailedMessage] = "COMMANDERERROR_TOO_MANY_SENTRIES", 
							    [kTechDataAllowConsumeDrop] = true,
								[kTechDataHint] = "SENTRY_HINT", 
							    [kTechDataGhostModelClass] = "MarineGhostModel",
							    [kTechDataMapName] = Sentry.kMapName,  
							    [kTechDataDisplayName] = "SENTRY_TURRET", 
							    [kTechDataCostKey] = kSentryCost,        
							    [kTechDataPointValue] = kSentryPointValue, 
							    [kTechDataModel] = Sentry.kModelName,    
							    [kTechDataBuildTime] = kSentryBuildTime,
							    [kTechDataMaxHealth] = kSentryHealth, 
							    [kTechDataMaxArmor] = kSentryArmor, 
							    [kTechDataDamageType] = kSentryAttackDamageType,
							    [kTechDataSpecifyOrientation] = true, 
							    [kTechDataHotkey] = Move.S, 
							    [kTechDataInitialEnergy] = kSentryInitialEnergy, 
							    [kTechDataMaxEnergy] = kSentryMaxEnergy,
							    [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, 
							    [kTechDataEngagementDistance] = kSentryEngagementDistance, 
							    [kStructureBuildNearClass] = "SentryBattery", 
							    [kStructureAttachRange] = SentryBattery.kRange, 
							    [kTechDataBuildRequiresMethod] = GetCheckSentryLimit,
							    [kTechDataGhostGuidesMethod] = GetBatteryInRange, 
							    [kTechDataMaxAmount] = kNumSentriesPerPlayer, 
							    [kTechDataObstacleRadius] = 0.25 })
								
  
	table.insert(techData,	  { [kTechDataId] = kTechId.Armory,
								[kTechDataSupply] = kArmorySupply,
								[kTechDataHint] = "ARMORY_HINT",
								[kTechDataGhostModelClass] = "MarineGhostModel", 
								[kTechDataRequiresPower] = false,     
								[kTechDataMapName] = Armory.kMapName,  
								[kTechDataDisplayName] = "ARMORY",     
								[kTechDataCostKey] = kArmoryCost,     
								[kTechDataBuildTime] = kArmoryBuildTime,
								[kTechDataMaxHealth] = kArmoryHealth, 
								[kTechDataMaxArmor] = kArmoryArmor,
								[kTechDataEngagementDistance] = kArmoryEngagementDistance, 
								[kTechDataModel] = Armory.kModelName, 
								[kTechDataPointValue] = kArmoryPointValue,
								[kTechDataInitialEnergy] = kArmoryInitialEnergy,
								[kTechDataAllowConsumeDrop] = true, 
								[kTechDataMaxEnergy] = kArmoryMaxEnergy, 
								[kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation,
								[kTechDataMaxAmount] = kNumArmoriesPerPlayer, 
								[kTechDataTooltipInfo] = "ARMORY_TOOLTIP"})
   
   table.insert(techData, 	   { [kTechDataId] = kTechId.Observatory,
							   [kTechDataHint] = "OBSERVATORY_HINT", 
							   [kTechDataGhostModelClass] = "MarineGhostModel",  
							   [kTechDataAllowConsumeDrop] = true, 
							   [kTechDataRequiresPower] = false, 
							   [kTechDataSpecifyOrientation] = true, 
							   [kTechDataMapName] = Observatory.kMapName, 
							   [kTechDataDisplayName] = "OBSERVATORY", 
							   [kVisualRange] = Observatory.kDetectionRange, 
							   [kTechDataCostKey] = kObservatoryCost,     
							   [kTechDataModel] = Observatory.kModelName,   
							   [kTechDataBuildTime] = kObservatoryBuildTime,
							   [kTechDataMaxHealth] = kObservatoryHealth,   
							   [kTechDataEngagementDistance] = kObservatoryEngagementDistance,
							   [kTechDataMaxArmor] = kObservatoryArmor,   
							   [kTechDataInitialEnergy] = kObservatoryInitialEnergy, 
							   [kTechDataMaxEnergy] = kObservatoryMaxEnergy, 
							   [kTechDataPointValue] = kObservatoryPointValue, 
							   [kTechDataHotkey] = Move.O, 
							   [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation,
							   [kTechDataTooltipInfo] = "OBSERVATORY_TOOLTIP", 
							   [kTechDataMaxAmount] = kNumObservatoriesPerPlayer,
							   [kTechDataObstacleRadius] = 0.25})
		
	table.insert(techData,	   { [kTechDataId] = kTechId.PhaseGate,
								[kTechDataHint] = "PHASE_GATE_HINT",
								[kTechDataGhostModelClass] = "MarineGhostModel", 
								[kTechDataAllowConsumeDrop] = true,
								[kTechDataSupply] = kPhaseGateSupply,
								[kTechDataRequiresPower] = false,    
								[kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation, 
								[kTechDataMapName] = PhaseGate.kMapName,                
								[kTechDataDisplayName] = "PHASE_GATE", 
								[kTechDataCostKey] = kPhaseGateCost,
								[kTechDataMaxAmount] = kNumPhaseGatesPerPlayer,  
								[kTechDataModel] = PhaseGate.kModelName, 
								[kTechDataBuildTime] = kPhaseGateBuildTime, 
								[kTechDataMaxHealth] = kPhaseGateHealth,  
								[kTechDataEngagementDistance] = kPhaseGateEngagementDistance, 
								[kTechDataMaxArmor] = kPhaseGateArmor,   
								[kTechDataPointValue] = kPhaseGatePointValue,
								[kTechDataHotkey] = Move.P, 
								[kTechDataSpecifyOrientation] = true, 
								[kTechDataBuildRequiresMethod] = CheckSpaceForPhaseGate, 
								[kTechDataTooltipInfo] = "PHASE_GATE_TOOLTIP",
								[kTechDataIgnorePathingMesh] = false, 
								[kTechDataObstacleRadius] = 0.5})
								
   
	table.insert(techData,	 { [kTechDataId] = kTechId.FourCommandStations, 
								[kTechDataDisplayName] = "FOUR_COMMAND_STATIONS",
								[kTechIDShowEnables] = false,
								[kTechDataTooltipInfo] = "FOUR_COMMAND_STATIONS"})              

end								

local oldBuildTechData = BuildTechData
function BuildTechData()
	local techData = oldBuildTechData()
	CTFTechAdditions(techData)
	return techData
end