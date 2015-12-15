//
// lua\Weapons\Alien\WhipAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'WhipAbility' (StructureAbility)

function WhipAbility:GetEnergyCost(player)
    return 0
end

function WhipAbility:GetPrimaryAttackDelay()
    return 0
end

function WhipAbility:GetGhostModelName(ability)
    return Whip.kModelName
end

function WhipAbility:GetDropStructureId()
    return kTechId.Whip
end

function WhipAbility:GetRequiredTechId()
    return kTechId.None
end

function WhipAbility:GetSuffixName()
    return "whip"
end

function WhipAbility:GetDropClassName()
    return "Whip"
end

function WhipAbility:GetDropMapName()
    return Whip.kMapName
end