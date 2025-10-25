local _, Private = ...

local Lib = Private.Lib
local CheckNotation = Private.UtilityFunctions.CheckNotation
local EncapsulateTable = Private.UtilityFunctions.EncapsulateTable
local UnitEventCallbackHandlers = Private.UnitEventCallbackHandlers
local UnitDataHandlers = Private.UnitDataHandlers

local unitSystemManagerDatas = {
    Nameplate = {
        callbackHandlers = {
            hostileNPCNameplate = UnitEventCallbackHandlers.New(
                "hostileNPCNameplate",
                true,
                true,
                false,
                true
            ),
            hostilePlayerNameplate = UnitEventCallbackHandlers.New(
                "hostilePlayerNameplate",
                true,
                true,
                false,
                true
            ),
            friendlyNPCNameplate = UnitEventCallbackHandlers.New(
                "friendlyNPCNameplate",
                true,
                true,
                false,
                true
            ),
            friendlyPlayerNameplate = UnitEventCallbackHandlers.New(
                "friendlyPlayerNameplate",
                true,
                true,
                false,
                true
            ),
            nameplate = UnitEventCallbackHandlers.New(
                "nameplate",
                true,
                true,
                false,
                true
            ),
            playerNameplate = UnitEventCallbackHandlers.New(
                "playerNameplate",
                true,
                true,
                false,
                true
            ),
        },
        dataHandler = UnitDataHandlers.New({}, {}, {}, {}, {}, {}, {}, "MULTI_UNIT"),
    },
    TargetNameplate = {
        callbackHandlers = {
            hostileNPCTargetNameplate = UnitEventCallbackHandlers.New(
                "hostileNPCTargetNameplate",
                true,
                true,
                false,
                true
            ),
            hostilePlayerTargetNameplate = UnitEventCallbackHandlers.New(
                "hostilePlayerTargetNameplate",
                true,
                true,
                false,
                true
            ),
            friendlyNPCTargetNameplate = UnitEventCallbackHandlers.New(
                "friendlyNPCTargetNameplate",
                true,
                true,
                false,
                true
            ),
            friendlyPlayerTargetNameplate = UnitEventCallbackHandlers.New(
                "friendlyPlayerTargetNameplate",
                true,
                true,
                false,
                true
            ),
            targetNameplate = UnitEventCallbackHandlers.New(
                "targetNameplate",
                true,
                true,
                false,
                true
            ),
            playerTargetNameplate = UnitEventCallbackHandlers.New(
                "playerTargetNameplate",
                true,
                true,
                false,
                true
            ),
        },
        dataHandler = UnitDataHandlers.New({}, {}, {}, {}, {}, {}, {}, "SINGLE_UNIT"),
    },
    Party = {
        callbackHandlers = {
            party = UnitEventCallbackHandlers.New(
                "party",
                true,
                true,
                true,
                true
            ),
        },
        dataHandler = UnitDataHandlers.New({}, {}, {}, {}, {}, {}, {}, "MULTI_UNIT"),
    },
    Raid = {
        callbackHandlers = {
            raid = UnitEventCallbackHandlers.New(
                "raid",
                true,
                true,
                true,
                true
            ),
        },
        dataHandler = UnitDataHandlers.New({}, {}, {}, {}, {}, {}, {}, "MULTI_UNIT"),
    },
    Arena = {
        callbackHandlers = {
            arena = UnitEventCallbackHandlers.New(
                "arena",
                true,
                true,
                false,
                true
            ),
            battleground = UnitEventCallbackHandlers.New(
                "battleground",
                true,
                true,
                false,
                true
            ),
        },
        dataHandler = UnitDataHandlers.New({}, {}, {}, {}, {}, {}, {}, "MULTI_UNIT"),
    },
}

Private.UnitSystemManagers.New( -- NameplateSystemManager
    Private.NameplateSystemManagerInitializer,
    unitSystemManagerDatas.Nameplate.dataHandler,
    unitSystemManagerDatas.Nameplate.callbackHandlers.friendlyNPCNameplate,
    unitSystemManagerDatas.Nameplate.callbackHandlers.friendlyPlayerNameplate,
    unitSystemManagerDatas.Nameplate.callbackHandlers.hostileNPCNameplate,
    unitSystemManagerDatas.Nameplate.callbackHandlers.hostilePlayerNameplate,
    unitSystemManagerDatas.Nameplate.callbackHandlers.nameplate,
    unitSystemManagerDatas.Nameplate.callbackHandlers.playerNameplate
)

Private.UnitSystemManagers.New( -- TargetNameplateSystemManager
    Private.TargetNameplateSystemManagerInitializer,
    unitSystemManagerDatas.TargetNameplate.dataHandler,
    unitSystemManagerDatas.TargetNameplate.callbackHandlers.friendlyNPCTargetNameplate,
    unitSystemManagerDatas.TargetNameplate.callbackHandlers.friendlyPlayerTargetNameplate,
    unitSystemManagerDatas.TargetNameplate.callbackHandlers.hostileNPCTargetNameplate,
    unitSystemManagerDatas.TargetNameplate.callbackHandlers.hostilePlayerTargetNameplate,
    unitSystemManagerDatas.TargetNameplate.callbackHandlers.targetNameplate,
    unitSystemManagerDatas.TargetNameplate.callbackHandlers.playerTargetNameplate
)

Private.UnitSystemManagers.New( -- PartySystemManagerInitializer
    Private.PartySystemManagerInitializer,
    unitSystemManagerDatas.Party.dataHandler,
    unitSystemManagerDatas.Party.callbackHandlers.party
)

Private.UnitSystemManagers.New( -- RaidSystemManagerInitializer
    Private.RaidSystemManagerInitializer,
    unitSystemManagerDatas.Raid.dataHandler,
    unitSystemManagerDatas.Raid.callbackHandlers.raid
)

Private.UnitSystemManagers.New( -- ArenaSystemManagerInitializer
    Private.ArenaSystemManagerInitializer,
    unitSystemManagerDatas.Arena.dataHandler,
    unitSystemManagerDatas.Arena.callbackHandlers.arena,
    unitSystemManagerDatas.Arena.callbackHandlers.battleground
)

for unitSystemManagerName, unitSystemManagerData in pairs(unitSystemManagerDatas) do

    Lib[unitSystemManagerName] = {}
    local UnitSystemManager = Lib[unitSystemManagerName]

    -- Encapsulate Callback Handlers
    for _, methodName in ipairs(Private.EventCallbackHandlers.APIFunctions) do
        UnitSystemManager[methodName] = function(arg1, unitType, event, func)
            if CheckNotation(arg1, UnitSystemManager) then
                local unitEventCallbackHandler = unitSystemManagerData.callbackHandlers[unitType]
                if unitEventCallbackHandler then
                    local eventCallbackHandler = unitEventCallbackHandler.eventCallbackHandler
                    if eventCallbackHandler then
                        return eventCallbackHandler[methodName](eventCallbackHandler, arg1, event, func)
                    end
                end
            end
        end
    end

    -- Encapsulate Data Handler
    for _, methodName in ipairs(Private.UnitDataHandlers.APIFunctions) do
        local dataHandler = unitSystemManagerData.dataHandler
        UnitSystemManager[methodName] = function(arg1, ...)
            if CheckNotation(arg1, UnitSystemManager) then
                return dataHandler[methodName](dataHandler, arg1, ...)
            end
        end
    end

    EncapsulateTable(UnitSystemManager)
end
