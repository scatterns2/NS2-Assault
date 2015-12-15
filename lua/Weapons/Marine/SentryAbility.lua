// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// Based on:
// lua\Weapons\Alien\HydraAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Gorge builds Sentry.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'SentryAbility' (Entity)

function SentryAbility:GetIsPositionValid()
	return true
end

function SentryAbility:AllowBackfacing()
    return false
end

function SentryAbility:GetDropRange()
    return kGorgeCreateDistance
end

function SentryAbility:GetStoreBuildId()
    return false
end

function SentryAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function SentryAbility:GetGhostModelName(ability)
    return Sentry.kModelName
end

function SentryAbility:GetDropStructureId()
    return kTechId.Sentry
end

function SentryAbility:GetSuffixName()
    return "Sentry"
end

function SentryAbility:GetRequiredTechId()
    return kTechId.RoboticsFactory
end

function SentryAbility:GetDropClassName()
    return "Sentry"
end

function SentryAbility:GetDropMapName()
    return Sentry.kMapName
end

function SentryAbility:CreateStructure()
	return false
end

function SentryAbility:IsAllowed(player)
    return true
end
