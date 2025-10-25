local _, Private = ...

local UnitSystemManagersMixin = {
    Init = function(self, unitSystemManagerInitFunc, unitDataHandler, unitEventCallbackHandlers)
        self.eventCallbackHandlers = {}
        self.unitDataHandler = unitDataHandler
        self.counter = 0

        for _, unitEventCallbackHandler in ipairs(unitEventCallbackHandlers) do
            unitEventCallbackHandler:SetSystemManagerParent(self)
        end

        -- DEBUG
        for k,v in pairs(self.eventCallbackHandlers) do
            print(k,v)
        end

        local activateFunc, deactivateFunc = unitSystemManagerInitFunc(self)
        self.Activate = activateFunc
        self.Deactivate = deactivateFunc
        self.Init = nil
    end,

    OnEventCallbackRegistered = function(self)
        self.counter = self.counter + 1
        if self.counter == 1 then
            self.Activate()
        end
    end,

    OnEventCallbackUnregistered = function(self)
        self.counter = self.counter - 1
        if self.counter == 0 then
            self.Deactivate()
        end
    end,
}

Private.UnitSystemManagers = {
    New = function(unitSystemManagerInitFunc, unitDataHandler, ...)
        local unitEventCallbackHandlers = {...}

        if type(unitSystemManagerInitFunc) ~= "function" then
            print("Unit System Manager Init Function must be a function.")
            return nil, false
        end
        if type (unitDataHandler) ~= "table" or unitDataHandler.AddOrUpdateData == nil or type(unitDataHandler.AddOrUpdateData) ~= "function" then
            print("Unit Data Handler must be a valid Unit Data Handler.")
            return nil, false
        end

        for i, v in ipairs(unitEventCallbackHandlers) do
            if type(v) ~= "table" or v.unitType == nil or type(v.unitType) ~= "string" or v.eventCallbackHandler == nil or type(v.eventCallbackHandler) ~= "table" then
                print("Unit Event Callback Handlers must be a valid table of Event Callback Handlers. Error at index: "..i)
                return nil, false
            end
        end

        return CreateAndInitFromMixin(
            UnitSystemManagersMixin, unitSystemManagerInitFunc,
            unitDataHandler, unitEventCallbackHandlers
        )
    end
}