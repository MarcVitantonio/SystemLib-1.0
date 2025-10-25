local _, Private = ...

-- Created Frames, Active Units tables
local function generateTraverseKeysInPairsFunc(tbl)
    return function()
        local key
        return function()
            key = next(tbl, key)
            if key then
                return key, tbl[key]
            end
        end
    end
end

local handlerTypeTemplates = {
    MULTI_UNIT = function(obj)
        obj.UnitGUID = function(self, unit) return self.unitGUIDs[unit] end
        obj.UnitFrame = function(self, unit) return self.unitFrames[unit] end
        obj.UnitExists = function(self, unit) return self.activeUnits[unit] ~= nil end
        obj.UnitNPCId = function(self, unit) return self.unitNPCIds[unit] end
        obj.UnitHostility = function(self, unit) return self.unitHostilities[unit] end
        obj.UnitFramesIterator = generateTraverseKeysInPairsFunc(obj.createdFrames)
        obj.UnitsExistsIterator = generateTraverseKeysInPairsFunc(obj.activeUnits)
    end,

    SINGLE_UNIT = function(obj)
        obj.UnitGUID = function(self) return select(2, next(self.unitGUIDs)) end
        obj.UnitFrame = function(self) return select(2, next(self.unitFrames)) end
        obj.UnitExists = function(self) return next(self.activeUnits) ~= nil end
        obj.UnitNPCId = function(self) return select(2, next(self.unitNPCIds)) end
        obj.UnitHostility = function(self) return select(2, next(self.unitHostilities)) end
        obj.UnitFramesIterator = generateTraverseKeysInPairsFunc(obj.createdFrames)
        obj.UnitsExistsIterator = generateTraverseKeysInPairsFunc(obj.activeUnits)
    end,
}

local UnitDataHandlersMixin = {
    Init = function(self, createdFrames, activeUnits, unitGUIDs, unitFrames, unitNPCIds, unitHostilities, unitTypes, handlerType)
        self.createdFrames = createdFrames or {}
        self.activeUnits = activeUnits or {}
        self.unitGUIDs = unitGUIDs or {}
        self.unitFrames = unitFrames or {}
        self.unitNPCIds = unitNPCIds or {}
        self.unitHostilities = unitHostilities or {}
        self.unitTypes = unitTypes or {}

        handlerTypeTemplates[handlerType](self)

        self.Init = nil
    end,

    IsFrameCreated = function(self, frame) return self.createdFrames[frame] ~= nil end,

    AddFrame = function(self, frame) self.createdFrames[frame] = true end,

    AddOrUpdateData = function(self, unit, unitFrame, unitGUID, unitHostility, unitNPCID, unitType)
        self.unitFrames[unit] = unitFrame
        self.unitGUIDs[unit] = unitGUID
        self.activeUnits[unit] = true
        self.unitHostilities[unit] = unitHostility
        self.unitNPCIds[unit] = unitNPCID
        self.unitTypes[unit] = unitType
    end,

    GetData = function(self, unit)
        return
        self.unitFrames[unit],
        self.unitGUIDs[unit],
        self.unitHostilities[unit],
        self.unitNPCIds[unit],
        self.unitTypes[unit]
    end,

    RemoveData = function(self, unit)
        self.unitFrames[unit] = nil
        self.unitGUIDs[unit] = nil
        self.activeUnits[unit] = nil
        self.unitHostilities[unit] = nil
        self.unitNPCIds[unit] = nil
        self.unitTypes[unit] = nil
    end,

    RemoveAllData = function(self)
        for unit in pairs(self.activeUnits) do
            self:RemoveData(unit)
        end
    end,
}


Private.UnitDataHandlers = {
    APIFunctions = {
        "UnitGUID",
        "UnitFrame",
        "UnitExists",
        "UnitNPCId",
        "UnitHostility",
        "UnitFramesIterator",
        "UnitsExistsIterator",
    },

    New = function(
        createdFrames, activeUnits, unitGUIDs, unitFrames,
        unitNPCIds, unitHostilities, unitTypes, handlerType
    )

        if type(handlerType) ~= "string" then
            print("Handler Type must be a string.")
            return nil, false
        elseif handlerTypeTemplates[handlerType] == nil then
            print("Invalid Handler Type.")
            return nil, false
        elseif type(createdFrames) ~= "table" then
            print("Created Frames must be a table.")
            return nil, false
        elseif type(activeUnits) ~= "table" then
            print("Active Units must be a table.")
            return nil, false
        elseif type(unitGUIDs) ~= "table" then
            print("Unit GUIDs must be a table.")
            return nil, false
        elseif type(unitFrames) ~= "table" then
            print("Unit Frames must be a table.")
            return nil, false
        elseif type(unitNPCIds) ~= "table" then
            print("Unit NPC IDs must be a table.")
            return nil, false
        elseif type(unitHostilities) ~= "table" then
            print("Unit Hostilities must be a table.")
            return nil, false
        elseif type(unitTypes) ~= "table" then
            print("Unit Types must be a table.")
            return nil, false
        end

        return CreateAndInitFromMixin(UnitDataHandlersMixin,
            createdFrames, activeUnits, unitGUIDs, unitFrames,
            unitNPCIds, unitHostilities, unitTypes, handlerType
        )
    end
}