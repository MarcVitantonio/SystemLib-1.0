local _, Private = ...

local RAID = Private.Constants.UNITS.RAID

local FRAME_CREATED = Private.Constants.EVENTS.FRAME_CREATED
local UNIT_ADDED = Private.Constants.EVENTS.UNIT_ADDED
local UNIT_UPDATED = Private.Constants.EVENTS.UNIT_UPDATED
local UNIT_REMOVED = Private.Constants.EVENTS.UNIT_REMOVED

local Timers = Private.Timers
local CoroutineQueues = Private.CoroutineQueues
local LGF = Private.LGF

local RaidFrameData = Private.UnitFunctions.RaidFrameData

local wipe = wipe
local select = select

Private.RaidSystemManagerInitializer = function(obj)

    local unitDataHandler = obj.unitDataHandler
    local eventCallbackHandler = obj.eventCallbackHandlers.raid

    local zone_EventFrame = CreateFrame("Frame")

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

    local raidState = false
    local prevFrames, prevGUIDs = {}, {}

    local function frameExists(unitFrame)
        return unitFrame and unitFrame.IsVisible and unitFrame:IsVisible()
    end

    local function processUnit(unit)

        local unitFrame, unitGUID = RaidFrameData(unit)
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

    local UnitProcessor = CoroutineQueues.New("RaidUnitProcessor", processUnit)

    local function units_PollUpdate(_, _, ...)
        for i = 1, select("#", ...) do
            local unitArg = select(i, ...)
            if unitArg and RAID[unitArg] then
                UnitProcessor:Push(unitArg)
            end
        end
    end

    local function units_UpdateAll()
        for unit in pairs(RAID) do
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
            Timers:AddTimer("RaidNewZoneUpdated", 3, LGF.ScanForUnitFrames)
        end
    end

    local function raidState_Update()
        local curState = UnitExists("raid6") and IsInGroup()

        if raidState ~= curState then
            if raidState == true and curState == false then
                units_RemoveAll()
            elseif raidState == false and curState == true then
                units_UpdateAll()
            end
        end

        raidState = curState
    end

    local function status_EventHandler(_, event)
        if event == "PLAYER_ENTERING_WORLD" then
            zone_Update()
            raidState_Update()
        elseif event == "GROUP_ROSTER_UPDATE" then
            raidState_Update()
        end
    end

    local function activateFunc()
        status_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        status_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        status_EventFrame:SetScript("OnEvent", status_EventHandler)

        LGF.RegisterCallback("RaidSystemManager", "FRAME_UNIT_ADDED", units_PollUpdate)
        LGF.RegisterCallback("RaidSystemManager", "FRAME_UNIT_UPDATE", units_PollUpdate)
        LGF.RegisterCallback("RaidSystemManager", "FRAME_UNIT_REMOVED", units_PollUpdate)

        zone_Update()
        raidState_Update()
    end

    local function deactivateFunc()
        Timers:RemoveTimer("RaidNewZoneUpdated")

        units_RemoveAll()

        LGF.UnregisterCallback("RaidSystemManager", "FRAME_UNIT_ADDED")
        LGF.UnregisterCallback("RaidSystemManager", "FRAME_UNIT_UPDATE")
        LGF.UnregisterCallback("RaidSystemManager", "FRAME_UNIT_REMOVED")

        status_EventFrame:UnregisterAllEvents()
        status_EventFrame:SetScript("OnEvent", nil)
    end

    return activateFunc, deactivateFunc
end