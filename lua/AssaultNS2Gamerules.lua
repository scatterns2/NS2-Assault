Script.Load("lua/NS2Gamerules.lua")

if Server then

	function NS2Gamerules:UpdateTechPoints()
    
        if self.timeToSendTechPoints == nil or Shared.GetTime() > self.timeToSendTechPoints then
        
            local spectators = Shared.GetEntitiesWithClassname("Player")
            if spectators:GetSize() > 0 then
                
                local powerNodes = Shared.GetEntitiesWithClassname("PowerPoint")
                local eggs = Shared.GetEntitiesWithClassname("Egg")
                
                for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
                
                    local message = BuildTechPointsMessage(techpoint, powerNodes, eggs)
                    for _, spectator in ientitylist(spectators) do
                    
                        if not spectator:GetIsFirstPerson() then
                            Server.SendNetworkMessage(spectator, "TechPoints", message, false)
                        end
                        
                    end
                    
                end
            
            end
            
            self.timeToSendTechPoints = Shared.GetTime() + 0.5
            
        end
        
    end
	
    function NS2Gamerules:CheckGameStart()
    
        if self:GetGameState() == kGameState.NotStarted or self:GetGameState() == kGameState.PreGame then
        
            -- Start pre-game when both teams have commanders or when once side does if cheats are enabled
            local team1Commander = true
            local team2Commander = true
			local team1Players = self.team1:GetNumPlayers()
			local team2Players = self.team2:GetNumPlayers()
           

		   if ((team1Players >= 1 and team2Players >= 1)  or Shared.GetCheatsEnabled()) and (not self.tournamentMode or self.teamsReady) then
            
                if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)
                end
                
            else
            
                if self:GetGameState() == kGameState.PreGame then
                    self:SetGameState(kGameState.NotStarted)
                end
                
               /*  if (not team1Commander or not team2Commander) and not self.nextGameStartMessageTime or Shared.GetTime() > self.nextGameStartMessageTime then
                
                    SendTeamMessage(self.team1, kTeamMessageTypes.GameStartCommanders)
                    SendTeamMessage(self.team2, kTeamMessageTypes.GameStartCommanders)
                    self.nextGameStartMessageTime = Shared.GetTime() + kGameStartMessageInterval
                    
                end*/

                
            end
            
        end
        
    end
	
	local function CheckAutoConcede(self)

        PROFILE("NS2Gamerules:CheckAutoConcede")
                
        -- This is an optional end condition based on the teams being unbalanced.
        local endGameOnUnbalancedAmount = Server.GetConfigSetting("end_round_on_team_unbalance")
        if endGameOnUnbalancedAmount and endGameOnUnbalancedAmount > 0 then

            local gameLength = Shared.GetTime() - self:GetGameStartTime()
            -- Don't start checking for auto-concede until the game has started for some time.
            local checkAutoConcedeAfterTime = Server.GetConfigSetting("end_round_on_team_unbalance_check_after_time") or 300
            if gameLength > checkAutoConcedeAfterTime then

                local team1Players = self.team1:GetNumPlayers()
                local team2Players = self.team2:GetNumPlayers()
                local totalCount = team1Players + team2Players
                -- Don't consider unbalanced game end until enough people are playing.

                if totalCount > 6 then
                
                    local team1ShouldLose = false
                    local team2ShouldLose = false
                    
                    /*if (1 - (team1Players / team2Players)) >= endGameOnUnbalancedAmount then

                        team1ShouldLose = true
                    elseif (1 - (team2Players / team1Players)) >= endGameOnUnbalancedAmount then

                        team2ShouldLose = true
                    end*/

                    
                    if team1ShouldLose or team2ShouldLose then
                    
                        -- Send a warning before ending the game.
                        local warningTime = Server.GetConfigSetting("end_round_on_team_unbalance_after_warning_time") or 30
                        if self.sentAutoConcedeWarningAtTime and Shared.GetTime() - self.sentAutoConcedeWarningAtTime >= warningTime then
                            return team1ShouldLose, team2ShouldLose
                        elseif not self.sentAutoConcedeWarningAtTime then
                        
                            Shared.Message((team1ShouldLose and "Marine" or "Alien") .. " team auto-concede in " .. warningTime .. " seconds")
                            Server.SendNetworkMessage("AutoConcedeWarning", { time = warningTime, team1Conceding = team1ShouldLose }, true)
                            self.sentAutoConcedeWarningAtTime = Shared.GetTime()
                            
                        end
                        
                    else
                        self.sentAutoConcedeWarningAtTime = nil
                    end
                    
                end
                
            else
                self.sentAutoConcedeWarningAtTime = nil
            end
            
        end
        
        return false, false
        
    end
end	