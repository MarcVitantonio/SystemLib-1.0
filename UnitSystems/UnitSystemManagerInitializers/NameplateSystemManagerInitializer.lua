local _, Private = ...

local NAMEPLATE = Private.Constants.UNITS.NAMEPLATE
local FRAME_CREATED = Private.Constants.EVENTS.FRAME_CREATED
local UNIT_ADDED = Private.Constants.EVENTS.UNIT_ADDED
local UNIT_REMOVED = Private.Constants.EVENTS.UNIT_REMOVED

local NameplateData = Private.UnitFunctions.NameplateData
local NameplateUnitType = Private.UnitFunctions.NameplateUnitType
local UnitHostility = Private.UnitFunctions.UnitHostility
local IsNameplateSecure = Private.UnitFunctions.IsNameplateSecure

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit

Private.NameplateSystemManagerInitializer = function(obj)

    local unitDataHandler = obj.unitDataHandler
    local eventCallbackHandlers = obj.eventCallbackHandlers

    local nameplateEventCallbackHandler = eventCallbackHandlers.nameplate

    local units_EventFrame = CreateFrame("Frame")

    local flags_EventFrames = {}
    for unit in pairs(NAMEPLATE) do
        flags_EventFrames[unit] = CreateFrame("Frame")
    end

    local function add(unit)
        local unitFrame, unitGUID, unitHostility, unitNPCID = NameplateData(unit)
        local unitType = NameplateUnitType(unit, unitHostility, unitNPCID)
        unitDataHandler:AddOrUpdateData(unit, unitFrame, unitGUID, unitHostility, unitNPCID, unitType)
        if not unitDataHandler:IsFrameCreated(unitFrame) then
            unitDataHandler:AddFrame(unitFrame)
            for _, eventCallbackHandler in pairs(eventCallbackHandlers) do
                eventCallbackHandler:Fire(FRAME_CREATED, unitFrame) -- Note: Dispatch To All Unit Systems
            end
        end
        nameplateEventCallbackHandler:Fire(UNIT_ADDED, unit, unitGUID, unitFrame, unitHostility, unitNPCID)
        local eventCallbackHandler = eventCallbackHandlers[unitType]
        if eventCallbackHandler then
            eventCallbackHandler:Fire(UNIT_ADDED, unit, unitGUID, unitFrame, unitHostility, unitNPCID)
        end
    end

    local function remove(unit)
        local unitFrame, unitGUID, unitHostility, unitNPCID, unitType = unitDataHandler:GetData(unit)
        nameplateEventCallbackHandler:Fire(UNIT_REMOVED, unit, unitGUID, unitFrame, unitHostility, unitNPCID)
        local eventCallbackHandler = eventCallbackHandlers[unitType]
        if eventCallbackHandler then
            eventCallbackHandler:Fire(UNIT_REMOVED, unit, unitGUID, unitFrame, unitHostility, unitNPCID)
        end
        unitDataHandler:RemoveData(unit)
    end

    local function units_EventFrameFunc(_, event, unit)
        if event == "NAME_PLATE_UNIT_ADDED" then
            add(unit)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            remove(unit)
        end
    end

    local function flags_EventFrameFunc(_, _, unit)
        if UnitIsUnit(unit, "player") then return end -- Don't Care About Player Nameplate Changes Here

        if not unitDataHandler:UnitHostility(unit) == UnitHostility(unit) and IsNameplateSecure(unit) then
            units_EventFrameFunc(nil, "NAME_PLATE_UNIT_REMOVED", unit)
            units_EventFrameFunc(nil, "NAME_PLATE_UNIT_ADDED", unit)
        end
    end

    local function activateFunc()
        unitDataHandler:RemoveAllData() -- Sanity

        units_EventFrame:SetScript("OnEvent", units_EventFrameFunc)
        units_EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        units_EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

        for unit, flags_EventFrame in pairs(flags_EventFrames) do
            flags_EventFrame:SetScript("OnEvent", flags_EventFrameFunc)
            flags_EventFrame:RegisterUnitEvent("UNIT_FLAGS", unit)
        end

        for unit in pairs(NAMEPLATE) do
            if UnitExists(unit) and IsNameplateSecure(unit) then
                units_EventFrameFunc(nil, "NAME_PLATE_UNIT_ADDED", unit)
            end
        end
    end

    local function deactivateFunc()
        for unit in unitDataHandler:UnitsExistsIterator() do
            units_EventFrameFunc(nil, "NAME_PLATE_UNIT_REMOVED", unit)
        end

        units_EventFrame:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        units_EventFrame:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
        units_EventFrame:SetScript("OnEvent", nil)

        for _, flags_EventFrame in pairs(flags_EventFrames) do
            flags_EventFrame:UnregisterEvent("UNIT_FLAGS")
            flags_EventFrame:SetScript("OnEvent", nil)
        end

        unitDataHandler:RemoveAllData() -- Sanity
    end

    return activateFunc, deactivateFunc
end