

Script.Load("lua/TDplus/Build_343/PlusBabblerGame.lua")
Script.Load("lua/TDplus/Build_343/PlusHiveskillBars.lua")

oldGMTDLobbyScreenInitialize = GMTDLobbyScreen.Initialize
function GMTDLobbyScreen:Initialize(params, errorDepth)

      oldGMTDLobbyScreenInitialize(self, params, errorDepth)

    self.target = CreateGUIObject("targetButton", PlusBabblerGame, self,
        {
        },
        errorDepth)
    self.target:AlignTopLeft()
    self.target:SetPosition(1930, 30 )
    self.target:SetLayer(2001)


    self.bars = CreateGUIObject("bars", PlusHiveskillBars, self,
        {
        },
        errorDepth)
    self.bars:AlignTopRight()
    self.bars:SetVisible(false)
    self.bars:SetLayer(2001)

    function hideBars()
      self.bars:SetVisible(false)
    end

    function showBars()
      self.bars:calcTeamskillgraph()
    end

    self.printmapvotes = function()

        Shared.Message("maps:")
        local memberModel = Thunderdome():GetMemberListLocalData(Thunderdome():GetActiveLobbyId())
        if not memberModel then return end

        local mapVotes = {} --iterdict?

        local rank1 = 3
        local rank2 = 2
        local rank3 = 1

        local totalvotes = 0

        --Build sorting table
        for i = 1, #kThunderdomeMaps do
            local map = tostring(kThunderdomeMaps[i])
            table.insert( mapVotes, { map = map, count = 0 } )
        end

        local function AddVote(voteRank, map)
            local mapWeight = 0
            if voteRank == rank1 then
                mapWeight = rank1
            elseif voteRank == rank2 then
                mapWeight = rank2
            else
                mapWeight = rank3
            end

            for i = 1, #mapVotes do
                if mapVotes[i].map == map then
                    mapVotes[i].count = mapVotes[i].count + mapWeight
                    break
                end
            end
        end

        --Loop over members, and tally votes
        for m = 1, #memberModel do
            --each member vote is weighted first to last
            local votes = memberModel[m].map_votes
            if votes ~= "" then
                local v = StringSplit(votes, ",")

                AddVote( rank1, v[1] )
                totalvotes = totalvotes + 3

                if v[2] then
                    AddVote( rank2, v[2] )
                    totalvotes = totalvotes + 2
                end
                if v[3] then
                    AddVote( rank3, v[3] )
                    totalvotes = totalvotes + 1
                end
            end
        end

        local function SortVotes(a, b)
            return a.count > b.count --desc order
        end
        table.sort(mapVotes, SortVotes)


        for i = 1, #mapVotes do
            if mapVotes[i].count > 0 then
                  Shared.Message(tostring(mapVotes[i].map) .. ": " .. tostring(mapVotes[i].count) .. " vote points")
            end

        end

        mapVotes[1].map = mapVotes[1].map or "none"
        mapVotes[1].count = mapVotes[1].count or 1
        mapVotes[2].map = mapVotes[2].map or "none"
        mapVotes[2].count = mapVotes[2].count or 0
        mapVotes[3].map = mapVotes[3].map or "none"
        mapVotes[3].count = mapVotes[3].count or 0
        if totalvotes == 0 then totalvotes = 1 end

        setMapvoteText(mapVotes[1].map,mapVotes[1].count,mapVotes[2].map,mapVotes[2].count,mapVotes[3].map,mapVotes[3].count,totalvotes)
    end
end


oldGMTDLobbyScreenOnShowRightClickMenu = GMTDLobbyScreen.OnShowRightClickMenu
function GMTDLobbyScreen:OnShowRightClickMenu(plaque)
    self.target:FireEvent("SetPassive")
    oldGMTDLobbyScreenOnShowRightClickMenu(self, plaque)
end


oldGMTDLobbyScreenInitializeLobbyGUI = GMTDLobbyScreen.InitializeLobbyGUI
function GMTDLobbyScreen:InitializeLobbyGUI( lobbyId )
    oldGMTDLobbyScreenInitializeLobbyGUI(self, lobbyId)

    self.target:FireEvent("SetPassive")

    if self.titleText:GetText() == Locale.ResolveString("THUNDERDOME_LOBBY_TITLE") then
      local shortID = string.sub(lobbyId, string.len(lobbyId) -2, string.len(lobbyId))
      local titleText = "LOBBY  " .. tostring(shortID)
      self.titleText:SetText(titleText)
    end
end



oldGMTDLobbyScreenRegisterEvents = GMTDLobbyScreen.RegisterEvents
function GMTDLobbyScreen:RegisterEvents()
      oldGMTDLobbyScreenRegisterEvents(self)
      Thunderdome_AddListener(kThunderdomeEvents.OnGUIMapVoteComplete, self.printmapvotes)
end


oldGMTDLobbyScreenUnregisterEvents = GMTDLobbyScreen.UnregisterEvents
function GMTDLobbyScreen:UnregisterEvents()
      oldGMTDLobbyScreenUnregisterEvents(self)
      Thunderdome_RemoveListener(kThunderdomeEvents.OnGUIMapVoteComplete, self.printmapvotes)
end
