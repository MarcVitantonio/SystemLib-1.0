local _, Private = ...

local CBH = Private.CBH

local function noop() end

local function registerValidation(obj, key, event, func)
    if type(key) ~= "string" then
        return false, "Listener Key must be a string."
    elseif type(event) ~= "string" then
        return false, "Listener Event must be a string."
    elseif obj.validEvents[event] == nil then
        return false, "Invalid Event: "..event
    elseif type(func) ~= "function" then
        return false, "Listener Function must be a function."
    end
    return true
end

local function unregisterValidation(obj, key, event)
    if type(key) ~= "string" then
        return false, "Listener Key must be a string."
    elseif type(event) ~= "string" then
        return false, "Listener Event must be a string."
    elseif obj.validEvents[event] == nil then
        return false, "Invalid Event: "..event
    end
    return true
end

local function register(obj, key, event, func)
    local cbHandle = obj.handles[key.."-"..event]
    if not cbHandle then
        obj.handles[key.."-"..event] = {key = key, event = event}
        obj.registry.RegisterCallback(key, event, func)
        obj.counter = obj.counter + 1
        if obj.parent then
            obj.parent:OnEventCallbackRegistered()
        end
        if obj.counter == 1 then
            obj.onActivateFunc()
        end
    end
end

local function unregister(obj, key, event)
    local cbHandle = obj.handles[key.."-"..event]
    if cbHandle then
        obj.registry.UnregisterCallback(key, event)
        obj.handles[key.."-"..event] = nil
        obj.counter = obj.counter - 1
        if obj.parent then
            obj.parent:OnEventCallbackUnregistered()
        end
        if obj.counter == 0 then
            obj.onDeactivateFunc()
        end
    end
end

Private.EventCallbackHandlers = {
    APIFunctions = { -- List of All Possible Methods
        "RegisterEventCallback",
        "UnregisterEventCallback",
    },
    New = function(events)
        if type(events) ~= "table" then
            print("Events must be a table of strings.")
            return nil, false
        end

        local validEvents = {}
        for _, event in ipairs(events) do
            if type(event) == "string" then
                validEvents[event] = true
            else
                print("Events must be a strings.")
                return nil, false
            end
        end

        local obj = {}

        -- Properties
        obj.validEvents = validEvents
        obj.registry = {}
        obj.counter = 0
        obj.handles = {}
        obj.handler = CBH:New(obj.registry)
        obj.onActivateFunc = noop
        obj.onDeactivateFunc = noop
        obj.parent = nil

        -- Methods
        obj.SetParent = function(self, parent)
            if type(parent) ~= "table" then
                print("Parent must be a Event System object.")
                return nil, false
            elseif parent.OnEventCallbackRegistered == nil or parent.OnEventCallbackUnregistered == nil then
                print("Parent OnEventCallback functions do not exist.")
                return nil, false
            end
            self.parent = parent
        end

        obj.SetOnActivateFunc = function(self, func)
            if type(func) == "function" or func == nil then
                self.onActivateFunc = func
                return true
            else
                print("On Activate Function must be a function or nil.")
                return false
            end
        end

        obj.SetOnDeactivateFunc = function(self, func)
            if type(func) == "function" or func == nil then
                self.onDeactivateFunc = func
                return true
            else
                print("On Deactivate Function must be a function or nil.")
                return false
            end
        end

        obj.RegisterEventCallback = function(self, key, event, func)
            local isValid, errMsg = registerValidation(self, key, event, func)
            if isValid then
                register(self, key, event, func)
                return true
            else
                print(errMsg)
                return false
            end
        end

        obj.UnregisterEventCallback = function(self, key, event)
            local isValid, errMsg = unregisterValidation(self, key, event)
            if isValid then
                unregister(self, key, event)
                return true
            else
                print(errMsg)
                return false
            end
        end

        obj.GetActiveCallbackCount = function(self)
            return self.counter
        end

        obj.Fire = function(self, event, ...)
            if self.validEvents[event] == nil then
                print("Invalid Event: "..event)
                return
            end
            self.handler:Fire(event, ...)
        end

        return obj
    end,
}