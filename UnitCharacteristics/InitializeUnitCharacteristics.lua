local _, Private = ...

local Lib = Private.Lib
local CheckNotation = Private.UtilityFunctions.CheckNotation
local EncapsulateTable = Private.UtilityFunctions.EncapsulateTable

local unitCharacteristicSystems = {
    UnitSpecializations = Private.UnitSpecializations,
}


for systemName, system in pairs(unitCharacteristicSystems) do

    Lib[systemName] = {}
    local API = Lib[systemName]

    for _, methodName in ipairs(system.APIFunctions) do
        API[methodName] = function(arg1, ...)
            if CheckNotation(arg1, API) then
                return system[methodName](arg1, ...)
            end
        end
    end

    EncapsulateTable(API)
end