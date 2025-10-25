local _, Private = ...

local NAMEPLATE = Private.Constants.UNITS.NAMEPLATE
local FRAME_CREATED = Private.Constants.EVENTS.FRAME_CREATED
local UNIT_ADDED = Private.Constants.EVENTS.UNIT_ADDED
local UNIT_REMOVED = Private.Constants.EVENTS.UNIT_REMOVED

local TargetNameplate = Private.UnitFunctions.TargetNameplate
local TargetNameplateUnitType = Private.UnitFunctions.TargetNameplateUnitType
local NameplateData = Private.UnitFunctions.NameplateData
local UnitHostility = Private.UnitFunctions.UnitHostility
local IsNameplateSecure = Private.UnitFunctions.IsNameplateSecure

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit

-- Note: "PLAYER_TARGET_CHANGED" fires multiple times
    -- Soft targeting is enabled
-- Note: "PLAYER_TARGET_CHANGED" fires before "NAME_PLATE_UNIT_ADDED"
    -- Nameplate is out of range, then targeted
-- Note: "PLAYER_TARGET_CHANGED" fires before "NAME_PLATE_UNIT_REMOVED"
    -- Nameplate is out of range, then untargeted
-- Note: "NAME_PLATE_UNIT_REMOVED" fires before "PLAYER_TARGET_CHANGED"
    -- Nameplate is out of range and target is out of range, then forcefully untargeted, and nameplate is removed

Private.TargetNameplateSystemManagerInitializer = function(obj)

    local unitDataHandler = obj.unitDataHandler
    local eventCallbackHandlers = obj.eventCallbackHandlers

    local targetNameplateEventCallbackHandler = eventCallbackHandlers.targetNameplate

    local units_EventFrame = CreateFrame("Frame")

    local flags_EventFrames = {}
    for unit in pairs(NAMEPLATE) do
        flags_EventFrames[unit] = CreateFrame("Frame")
    end

    local targetGUIDPrev
    local targetNameplatePrev

    local function addDataAndDispatchEvents(unit)
        local unitFrame, unitGUID, unitHostility, unitNPCID = NameplateData(unit)
        local unitType = TargetNameplateUnitType(unit, unitHostility, unitNPCID)
        unitDataHandler:AddOrUpdateData(unit, unitFrame, unitGUID, unitHostility, unitNPCID, unitType)
        if not unitDataHandler:IsFrameCreated(unitFrame) then
            unitDataHandler:AddFrame(unitFrame)
            for _, eventCallbackHandler in pairs(eventCallbackHandlers) do
                eventCallbackHandler:Fire(FRAME_CREATED, unitFrame) -- Note: Dispatch To All Unit Systems
            end
        end
        targetNameplateEventCallbackHandler:Fire(UNIT_ADDED, unit, unitGUID, unitFrame, unitHostility, unitNPCID, unitType)
        local eventCallbackHandler = eventCallbackHandlers[unitType]
        if eventCallbackHandler then
            eventCallbackHandler:Fire(UNIT_ADDED, unit, unitGUID, unitFrame, unitHostility, unitNPCID, unitType)
        end
    end

    local function removeDataAndDispatchEvents(unit)
        local prevUnitFrame, prevUnitGUID, prevUnitHostility, prevUnitNPCID, prevUnitType = unitDataHandler:GetData(unit)
        targetNameplateEventCallbackHandler:Fire(UNIT_REMOVED, unit, prevUnitGUID, prevUnitFrame, prevUnitHostility, prevUnitNPCID, prevUnitType)
        local eventCallbackHandler = eventCallbackHandlers[prevUnitType]
        if eventCallbackHandler then
            eventCallbackHandler:Fire(UNIT_REMOVED, unit, prevUnitGUID, prevUnitFrame, prevUnitHostility, prevUnitNPCID, prevUnitType)
        end
        unitDataHandler:RemoveData(unit)
    end

    local function units_EventFrameFunc(_, event, unit)

        if event == "PLAYER_TARGET_CHANGED" then
            local targetGUID = UnitGUID("target")
            local targetNameplate = TargetNameplate()

            if targetGUID ~= targetGUIDPrev then
                if targetNameplatePrev and targetNameplate then
                    if targetGUIDPrev then
                        removeDataAndDispatchEvents(targetNameplatePrev)
                    end
                    if targetGUID then
                        addDataAndDispatchEvents(targetNameplate)
                    end
                elseif not targetNameplatePrev and targetNameplate then
                    addDataAndDispatchEvents(targetNameplate)
                elseif targetNameplatePrev and not targetNameplate then
                    removeDataAndDispatchEvents(targetNameplatePrev)
                end
            end

            targetGUIDPrev = targetGUID
            targetNameplatePrev = targetNameplate

        elseif event == "NAME_PLATE_UNIT_ADDED" then

            if targetGUIDPrev and UnitIsUnit("target", unit) then
                if targetNameplatePrev then
                    removeDataAndDispatchEvents(targetNameplatePrev)
                end
                addDataAndDispatchEvents(unit)
                targetNameplatePrev = unit
            end

        elseif event == "NAME_PLATE_UNIT_REMOVED" then

            if targetGUIDPrev and UnitIsUnit("target", unit) then
                if targetNameplatePrev then
                    removeDataAndDispatchEvents(targetNameplatePrev)
                    targetNameplatePrev = nil
                end
            end

        end
    end

    local function flags_EventFrameFunc(_, _, unit)
        if UnitIsUnit(unit, "player") then return end -- Don't Care About Player Nameplate Changes Here

        if targetNameplatePrev == unit and unitDataHandler:UnitHostility(unit) ~= UnitHostility(unit) and IsNameplateSecure(unit) then
            units_EventFrameFunc(nil, "NAME_PLATE_UNIT_REMOVED", unit)
            units_EventFrameFunc(nil, "NAME_PLATE_UNIT_ADDED", unit)
        end
    end

    local function activateFunc()
        unitDataHandler:RemoveAllData() -- Sanity

        units_EventFrame:SetScript("OnEvent", units_EventFrameFunc)
        units_EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        units_EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        units_EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

        for unit, flags_EventFrame in pairs(flags_EventFrames) do
            flags_EventFrame:SetScript("OnEvent", flags_EventFrameFunc)
            flags_EventFrame:RegisterUnitEvent("UNIT_FLAGS", unit)
        end

        targetGUIDPrev = nil
        targetNameplatePrev = nil

        if UnitExists("target") then
            units_EventFrameFunc(nil, "PLAYER_TARGET_CHANGED")
        end

    end

    local function deactivateFunc()
        for unit in unitDataHandler:UnitsExistsIterator() do
            removeDataAndDispatchEvents(unit)
        end

        targetGUIDPrev = nil
        targetNameplatePrev = nil

        units_EventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
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