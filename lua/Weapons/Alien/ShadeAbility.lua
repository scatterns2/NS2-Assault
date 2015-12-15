//
// lua\Weapons\Alien\ShadeAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ShadeAbility' (StructureAbility)

function ShadeAbility:GetEnergyCost(player)
    return 0
end

function ShadeAbility:GetPrimaryAttackDelay()
    return 0
end

function ShadeAbility:GetGhostModelName(ability)
    return Shade.kModelName
end

function ShadeAbility:GetDropStructureId()
    return kTechId.Shade
end

function ShadeAbility:GetRequiredTechId()
    return kTechId.None
end

function ShadeAbility:GetSuffixName()
    return "shade"
end

function ShadeAbility:GetDropClassName()
    return "Shade"
end

function ShadeAbility:GetDropMapName()
    return Shade.kMapName
end