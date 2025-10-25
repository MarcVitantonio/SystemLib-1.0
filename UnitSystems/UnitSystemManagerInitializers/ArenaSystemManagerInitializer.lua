local _, Private = ...

local ARENA = Private.Constants.UNITS.ARENA

local FRAME_CREATED = Private.Constants.EVENTS.FRAME_CREATED
local UNIT_ADDED = Private.Constants.EVENTS.UNIT_ADDED
local UNIT_UPDATED = Private.Constants.EVENTS.UNIT_UPDATED
local UNIT_REMOVED = Private.Constants.EVENTS.UNIT_REMOVED

local CoroutineQueues = Private.CoroutineQueues

local ArenaFrameData = Private.UnitFunctions.ArenaFrameData
local ArenaUnitType = Private.UnitFunctions.ArenaUnitType
local UnitHostility = Private.UnitFunctions.UnitHostility

local wipe = wipe
local CreateFrame = CreateFrame

Private.ArenaSystemManagerInitializer = function(obj)

    local unitDataHandler = obj.unitDataHandler
    local eventCallbackHandlers = obj.eventCallbackHandlers

    local units_EventFrame = CreateFrame("Frame")
    local zone_EventFrame = CreateFrame("Frame")

    local unitType

    local function add(unit, unitGUID, unitFrame)
        unitDataHandler:AddOrUpdateData(unit, unitFrame, unitGUID, UnitHostility(unit), nil, unitType)
        if not unitDataHandler:IsFrameCreated(unitFrame) then
            unitDataHandler:AddFrame(unitFrame)
            for _, eventCallbackHandler in pairs(eventCallbackHandlers) do
                eventCallbackHandler:Fire(FRAME_CREATED, unitFrame) -- Note: Dispatch To All Unit Systems
            end
        end
        local eventCallbackHandler = eventCallbackHandlers[unitType]
        if eventCallbackHandler then
            eventCallbackHandler:Fire(UNIT_ADDED, unit, unitGUID, unitFrame)
        end
    end

    --local function update(unit, unitGUID, unitFrame, refreshEvent)
        --unitDataHandler:AddOrUpdateData(unit, unitFrame, unitGUID)
        --eventCallbackHandler:Fire(UNIT_UPDATED, unit, unitGUID, unitFrame, refreshEvent)
    --end

    local function remove(unit)
        local prevFrame, prevGUID, _, _, prevType = unitDataHandler:GetData(unit)
        local eventCallbackHandler = eventCallbackHandlers[prevType]
        if eventCallbackHandler then
            eventCallbackHandler:Fire(UNIT_REMOVED, unit, prevGUID, prevFrame)
        end
        unitDataHandler:RemoveData(unit)
    end

    local prevFrames, prevGUIDs = {}, {}

    -- Allow units to only be added or updated inside an arena, 
    -- always let them be removed,
    -- events always fire for removal after an arena match.

    local function processUnit(unit)

        local unitFrame, unitGUID = ArenaFrameData(unit)
        if (not unitFrame and unitGUID)
        or (not unitGUID and unitFrame)
        then return true end

        local prevFrame, prevGUID = prevFrames[unit], prevGUIDs[unit]

        if (unitFrame and not prevFrame) and (unitGUID and not prevGUID) and unitType then
            add(unit, unitGUID, unitFrame)
        --elseif (unitFrame and prevFrame) and (unitGUID and prevGUID) and isArena then
            --local frameChanged, guidChanged = prevFrame ~= unitFrame, prevGUID ~= unitGUID
            --if frameChanged and guidChanged then
                --update(unit, unitGUID, unitFrame, "FULL")
            --elseif not frameChanged and guidChanged then
                --update(unit, unitGUID, unitFrame, "UNIT_DATA")
            --elseif frameChanged and not guidChanged then
                --update(unit, unitGUID, unitFrame, "UNIT_FRAME")
            --end
        elseif (not unitGUID and prevGUID) then
            remove(unit)
        end

        prevFrames[unit], prevGUIDs[unit] = unitFrame, unitGUID
    end

    local UnitProcessor = CoroutineQueues.New("ArenaUnitProcessor", processUnit)

    local function units_PollUpdate(_, _, unit)
        if unit and ARENA[unit] then
            UnitProcessor:Push(unit)
        end
    end

    local function zone_Update()
        unitType = ArenaUnitType()
        print(unitType)

        if unitType then
            for unit in pairs(ARENA) do
                UnitProcessor:Push(unit)
            end
        end
    end

    local function activateFunc()
        zone_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        zone_EventFrame:SetScript("OnEvent", zone_Update)
        zone_Update()

        units_EventFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
        units_EventFrame:SetScript("OnEvent", units_PollUpdate)
    end

    local function deactivateFunc()
        wipe(prevFrames)
        wipe(prevGUIDs)
        unitType = nil
        UnitProcessor:Stop()

        for unit in unitDataHandler:UnitsExistsIterator() do
            remove(unit)
        end

        unitDataHandler:RemoveAllData()

        units_EventFrame:UnregisterAllEvents()
        units_EventFrame:SetScript("OnEvent", nil)

        zone_EventFrame:UnregisterAllEvents()
        zone_EventFrame:SetScript("OnEvent", nil)
    end

    return activateFunc, deactivateFunc
end