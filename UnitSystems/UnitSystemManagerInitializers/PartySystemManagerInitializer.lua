local _, Private = ...

local PARTY = Private.Constants.UNITS.PARTY

local FRAME_CREATED = Private.Constants.EVENTS.FRAME_CREATED
local UNIT_ADDED = Private.Constants.EVENTS.UNIT_ADDED
local UNIT_UPDATED = Private.Constants.EVENTS.UNIT_UPDATED
local UNIT_REMOVED = Private.Constants.EVENTS.UNIT_REMOVED

local Timers = Private.Timers
local CoroutineQueues = Private.CoroutineQueues
local LGF = Private.LGF

local PartyFrameData = Private.UnitFunctions.PartyFrameData

local wipe = wipe
local select = select

Private.PartySystemManagerInitializer = function(obj)

    local unitDataHandler = obj.unitDataHandler
    local eventCallbackHandler = obj.eventCallbackHandlers.party



    local function add(unit, unitGUID, unitFrame)
        unitDataHandler:AddOrUpdateData(unit, unitFrame, unitGUID)
        if not unitDataHandler:IsFrameCreated(unitFrame) then
            unitDataHandler:AddFrame(unitFrame)
            eventCallbackHandler:Fire(FRAME_CREATED, unitFrame)
        end
        eventCallbackHandler:Fire(UNIT_ADDED, unit, unitGUID, unitFrame)
    end

    local function update(unit, unitGUID, unitFrame, refreshEvent)
        unitDataHandler:AddOrUpdateData(unit, unitFrame, unitGUID)
        eventCallbackHandler:Fire(UNIT_UPDATED, unit, unitGUID, unitFrame, refreshEvent)
    end

    local function remove(unit)
        local unitFrame, unitGUID = unitDataHandler:GetData(unit)
        eventCallbackHandler:Fire(UNIT_REMOVED, unit, unitGUID, unitFrame)
        unitDataHandler:RemoveData(unit)
    end

    local function frameExists(unitFrame)
        return unitFrame and unitFrame.IsVisible and unitFrame:IsVisible()
    end

    local partyState = false
    local prevFrames, prevGUIDs = {}, {}

    local function processUnit(unit)

        local unitFrame, unitGUID = PartyFrameData(unit)
        local unitFrameExists = frameExists(unitFrame)

        if (not unitFrameExists and unitGUID)
        or (not unitGUID and unitFrameExists)
        then return true end

        local prevFrame, prevGUID = prevFrames[unit], prevGUIDs[unit]

        if unitFrameExists then
            if (unitFrame and not prevFrame) and (unitGUID and not prevGUID) then
                add(unit, unitGUID, unitFrame)
            elseif (unitFrame and prevFrame) and (unitGUID and prevGUID) then
                local frameChanged, guidChanged = prevFrame ~= unitFrame, prevGUID ~= unitGUID
                if frameChanged and guidChanged then
                    update(unit, unitGUID, unitFrame, "FULL")
                elseif not frameChanged and guidChanged then
                    update(unit, unitGUID, unitFrame, "UNIT_DATA")
                elseif frameChanged and not guidChanged then
                    update(unit, unitGUID, unitFrame, "UNIT_FRAME")
                end
            end
        elseif (not unitGUID and prevGUID) then
            remove(unit)
        end

        prevFrames[unit], prevGUIDs[unit] = unitFrame, unitGUID
    end

    local UnitProcessor = CoroutineQueues.New("PartyUnitProcessor", processUnit)

    local function units_PollUpdate(_, _, ...)
        for i = 1, select("#", ...) do
            local unitArg = select(i, ...)
            if unitArg and PARTY[unitArg] then
                UnitProcessor:Push(unitArg)
            end
        end
    end

    local function units_UpdateAll()
        for unit in pairs(PARTY) do
            UnitProcessor:Push(unit)
        end
    end

    local function units_RemoveAll()
        wipe(prevFrames)
        wipe(prevGUIDs)
        UnitProcessor:Stop()
        for unit in unitDataHandler:UnitsExistsIterator() do
            remove(unit)
        end
    end

    local status_EventFrame = CreateFrame("Frame")

    local function zone_Update()
        if select(2, IsInInstance()) == "arena" then
            Timers:AddTimer("PartyNewZoneUpdated", 3, LGF.ScanForUnitFrames)
        end
    end

    local function partyState_Update()
        local curState = not UnitExists("raid6") and IsInGroup()

        if partyState ~= curState then
            if partyState == true and curState == false then -- Was a Party, but either in a raid or no group
                units_RemoveAll()
            elseif partyState == false and curState == true then
                units_UpdateAll()
            end
        end

        partyState = curState
    end

    local function status_EventHandler(_, event)
        if event == "PLAYER_ENTERING_WORLD" then
            zone_Update()
            partyState_Update()
        elseif event == "GROUP_ROSTER_UPDATE" then
            partyState_Update()
        end
    end

    local function activateFunc()
        status_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        status_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        status_EventFrame:SetScript("OnEvent", status_EventHandler)

        LGF.RegisterCallback("PartySystemManager", "FRAME_UNIT_ADDED", units_PollUpdate)
        LGF.RegisterCallback("PartySystemManager", "FRAME_UNIT_UPDATE", units_PollUpdate)
        LGF.RegisterCallback("PartySystemManager", "FRAME_UNIT_REMOVED", units_PollUpdate)

        zone_Update()
        partyState_Update()
    end

    local function deactivateFunc()
        Timers:RemoveTimer("PartyNewZoneUpdated")

        units_RemoveAll()

        LGF.UnregisterCallback("PartySystemManager", "FRAME_UNIT_ADDED")
        LGF.UnregisterCallback("PartySystemManager", "FRAME_UNIT_UPDATE")
        LGF.UnregisterCallback("PartySystemManager", "FRAME_UNIT_REMOVED")

        status_EventFrame:UnregisterAllEvents()
        status_EventFrame:SetScript("OnEvent", nil)
    end

    return activateFunc, deactivateFunc
end
