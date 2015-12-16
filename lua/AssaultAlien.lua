Script.Load("lua/Alien.lua")

function Alien:GetExoCompletion()

	for i, teaminfo in ipairs ( GetEntitiesForTeam("TeamInfo", kMarineTeamType) ) do
		marineRes = teaminfo:GetTeamResources() / 200
	end
			
	return marineRes
	
end
	
function Alien:GetOnosCompletion()

	for i, teaminfo in ipairs ( GetEntitiesForTeam("TeamInfo", kAlienTeamType) ) do
		alienRes = teaminfo:GetTeamResources() / 200
	end
			
	return alienRes
	
end

