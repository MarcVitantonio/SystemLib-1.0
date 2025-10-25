local _, Private = ...

local encapsulationMetatable = {
    __newindex = function(_, key, _)
        error("Attempt to modify key '" .. tostring(key) .. "' in encapsulated table.", 2)
    end,
    __metatable = "This table is encapsulated and cannot be accessed."
}

Private.UtilityFunctions = {
    HashTableLength = function(t)
        local count = 0
        for _ in pairs(t) do
            count = count + 1
        end
        return count
    end,
    IsHashTableEmpty = function(t)
        return next(t) == nil
    end,
    IteratorLength = function(iterator)
        local count = 0
        for _ in iterator do
            count = count + 1
        end
        return count
    end,
    IsIteratorEmpty = function(iterator)
        return iterator() == nil
    end,
    CheckNotation = function(arg1, t)
        if arg1 == t then
            print("':' notation was used.")
            return false
        else
            return true
        end
    end,
    EncapsulateTable = function(table)
        return setmetatable(table, encapsulationMetatable)
    end,
}