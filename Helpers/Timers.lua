local AddonName, Private = ...

local pairs = pairs
local C_Timer_NewTicker = C_Timer.NewTicker


local systemNameMsg = "[TimerObj]: "

local function isAddTimerValid(obj, key, pollRate, func)
    if type(key) ~= "string" then
        return false, systemNameMsg.."Timer Key must be a string."
    elseif obj.timerHandles[key] then
        return false, systemNameMsg.."Timer Key already exists: "..key
    elseif type(pollRate) ~= "number" then
        return false, systemNameMsg.."Poll Rate must be a number."
    elseif type(func) ~= "function" then
        return false, systemNameMsg.."Timer Callback must be a function."
    end

    return true
end

local function isRemoveOrFinishTimerValid(obj, key)
    if type(key) ~= "string" then
        return false, systemNameMsg.."Listener Key must be a string."
    elseif obj.timerHandles[key] == nil then
        return false, systemNameMsg.."Timer Key doesn't exist: "..key
    end

    return true
end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

local function addTimer(obj, timerKey, pollRate, func)
    local timer = obj.timerHandles[timerKey]
    if timer then
        timer:Cancel()
    end
    timer = C_Timer_NewTicker(pollRate, func, 1)
end

local function finishTimer(obj, timerKey)
    local timer = obj.timerHandles[timerKey]
    if timer then
        timer:Invoke()
        timer:Cancel()
        obj.timerHandles[timerKey] = nil
    end
end

local function removeTimer(obj, timerKey)
    local timer = obj.timerHandles[timerKey]
    if timer then
        timer:Cancel()
        obj.timerHandles[timerKey] = nil
    end
end

local function removeAllTimers(obj)
    for key, timer in pairs(obj.timerHandles) do
        if timer then
            timer:Cancel()
            obj.timerHandles[key] = nil
        end
    end
end

--[[-----------------------------------------------------------------------------
Internal Object
-------------------------------------------------------------------------------]]

Private.Timers = {

    timerHandles = {},

    AddTimer = function(self, key, pollRate, func)
        local isValid, errMsg = isAddTimerValid(self, key, pollRate, func)
        if isValid then
            addTimer(self, key, pollRate, func)
            return true
        else
            return false, errMsg
        end
    end,

    FinishTimer = function(self, key)
        local isValid, errMsg = isRemoveOrFinishTimerValid(self, key)
        if isValid then
            finishTimer(self, key)
            return true
        else
            return false, errMsg
        end
    end,

    RemoveTimer = function(self, key)
        local isValid, errMsg = isRemoveOrFinishTimerValid(self, key)
        if isValid then
            removeTimer(self, key)
            return true
        else
            return false, errMsg
        end
    end,

    Exists = function(self, key)
        return self.timerHandles[key] ~= nil
    end,

    RemoveAllTimers = removeAllTimers
}

