local _, Private = ...

local FRAME_CREATED = Private.Constants.EVENTS.FRAME_CREATED
local UNIT_ADDED = Private.Constants.EVENTS.UNIT_ADDED
local UNIT_UPDATED = Private.Constants.EVENTS.UNIT_UPDATED
local UNIT_REMOVED = Private.Constants.EVENTS.UNIT_REMOVED
local VALID_UNIT_TYPES = Private.Constants.VALID_UNIT_TYPES

local EventCallbackHandlers = Private.EventCallbackHandlers
local tinsert = tinsert
local CreateAndInitFromMixin = CreateAndInitFromMixin

local UnitEventCallbackHandlersMixin = {
    Init = function(self, unitType, events)
        self.unitType = unitType
        self.eventCallbackHandler = EventCallbackHandlers.New(events)
        self.Init = nil
    end,

    SetSystemManagerParent = function(self, systemManagerParent)
        if type(systemManagerParent) ~= "table" then
            print("System Manager Parent must be a Unit System Manager object.")
            return nil, false
        end
        self.eventCallbackHandler:SetParent(systemManagerParent)
        systemManagerParent.eventCallbackHandlers[self.unitType] = self.eventCallbackHandler
    end
}

Private.UnitEventCallbackHandlers = {
    New = function(unitType, isFrameCreatedEvent, isAddedEvent, isUpdatedEvent, isRemovedEvent)
        if type(unitType) ~= "string" then
            print("Unit Type must be a string.")
            return nil, false
        end
        if VALID_UNIT_TYPES[unitType] == nil then
            print("Invalid Unit Type.")
            return nil, false
        end

        if type(isFrameCreatedEvent) ~= "boolean" then
            isFrameCreatedEvent = false
        end
        if type(isAddedEvent) ~= "boolean" then
            isAddedEvent = false
        end
        if type(isUpdatedEvent) ~= "boolean" then
            isUpdatedEvent = false
        end
        if type(isRemovedEvent) ~= "boolean" then
            isRemovedEvent = false
        end
        local events = {}
        if isFrameCreatedEvent then
            tinsert(events, FRAME_CREATED)
        end
        if isAddedEvent then
            tinsert(events, UNIT_ADDED)
        end
        if isUpdatedEvent then
            tinsert(events, UNIT_UPDATED)
        end
        if isRemovedEvent then
            tinsert(events, UNIT_REMOVED)
        end
        if #events == 0 then
            print("At least one event type must exist.")
            return nil, false
        end

        return CreateAndInitFromMixin(UnitEventCallbackHandlersMixin, unitType, events)
    end
}