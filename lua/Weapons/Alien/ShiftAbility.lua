//
// lua\Weapons\Alien\ShiftAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ShiftAbility' (StructureAbility)

function ShiftAbility:GetEnergyCost(player)
    return 0
end

function ShiftAbility:GetPrimaryAttackDelay()
    return 0
end

function ShiftAbility:GetIconOffsetY(secondary)
    return kAbilityOffset.Hydra
end

function ShiftAbility:GetGhostModelName(ability)
    return Shift.kModelName
end

function ShiftAbility:GetDropStructureId()
    return kTechId.Shift
end

function ShiftAbility:GetRequiredTechId()
    return kTechId.None
end

function ShiftAbility:GetSuffixName()
    return "shift"
end

function ShiftAbility:GetDropClassName()
    return "Shift"
end

function ShiftAbility:GetDropMapName()
    return Shift.kMapName
end