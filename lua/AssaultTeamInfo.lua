Script.Load("lua/TeamInfo.lua")

function TeamInfo:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
    
    local mask = 0
    
    if self:GetTeamNumber() == kTeam1Index then
        mask = kRelevantToTeam1
    elseif self:GetTeamNumber() == kTeam2Index then
        mask = kRelevantToTeam2
    end
        
    //self:SetExcludeRelevancyMask(mask)

end