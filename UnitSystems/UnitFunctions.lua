local AddonName, Private = ...
local LGF = Private.LGF

local PLAYER_NAMEPLATE = Private.Constants.UNIT_TYPES.PLAYER_NAMEPLATE
local HOSTILE_NPC_NAMEPLATE = Private.Constants.UNIT_TYPES.HOSTILE_NPC_NAMEPLATE
local HOSTILE_PLAYER_NAMEPLATE = Private.Constants.UNIT_TYPES.HOSTILE_PLAYER_NAMEPLATE
local FRIENDLY_NPC_NAMEPLATE = Private.Constants.UNIT_TYPES.FRIENDLY_NPC_NAMEPLATE
local FRIENDLY_PLAYER_NAMEPLATE = Private.Constants.UNIT_TYPES.FRIENDLY_PLAYER_NAMEPLATE

local PLAYER_TARGET_NAMEPLATE = Private.Constants.UNIT_TYPES.PLAYER_TARGET_NAMEPLATE
local HOSTILE_NPC_TARGET_NAMEPLATE = Private.Constants.UNIT_TYPES.HOSTILE_NPC_TARGET_NAMEPLATE
local HOSTILE_PLAYER_TARGET_NAMEPLATE = Private.Constants.UNIT_TYPES.HOSTILE_PLAYER_TARGET_NAMEPLATE
local FRIENDLY_NPC_TARGET_NAMEPLATE = Private.Constants.UNIT_TYPES.FRIENDLY_NPC_TARGET_NAMEPLATE
local FRIENDLY_PLAYER_TARGET_NAMEPLATE = Private.Constants.UNIT_TYPES.FRIENDLY_PLAYER_TARGET_NAMEPLATE

local ARENA = Private.Constants.UNIT_TYPES.ARENA
local BATTLEGROUND = Private.Constants.UNIT_TYPES.BATTLEGROUND

local UnitGUID = UnitGUID
local UnitReaction = UnitReaction
local UnitIsUnit = UnitIsUnit
local GetNameplateForUnit = C_NamePlate.GetNamePlateForUnit
local strsplit = strsplit

local function getUnitHostility(unit) -- Needs reworked
    return (UnitReaction("player", unit) or 0) < 5 and true or false
end

local function getUnitNPCID(unitGUID)
    local unitController, _, _, _, _, npcID = strsplit("-", unitGUID)
    if not (unitController == "Player") then
        return npcID
    else
        return false
    end
end


local function getArenaFrame(unitGUID)

    for i = 1, 5 do

        local elvUIFrame = _G["ElvUF_Arena" .. i]
        if elvUIFrame and elvUIFrame:IsVisible() and elvUIFrame.unit then
            if unitGUID == UnitGUID(elvUIFrame.unit) then
                return elvUIFrame --_G["ElvUF_Arena" .. i .. "_HealthBar"]
            end
        end

        local oUFFrame = _G["oUF_Arena" .. i]
        if oUFFrame and oUFFrame:IsVisible() and oUFFrame.unit then
            if unitGUID == UnitGUID(oUFFrame.unit) then
                return oUFFrame
            end
        end

        local blizzFrame = _G["ArenaEnemyMatchFrame" .. i .. "ClassPortrait"]
        if blizzFrame and blizzFrame:IsVisible() and blizzFrame.unit then
            if unitGUID == UnitGUID(blizzFrame.unit) then
                return blizzFrame
            end
        end

    end
end

local raidFrames_LGFOptions = {
    ignorePartyFrame = false,
    ignoreRaidFrame = false,
    ignoreBossFrame = true,
}

local partyFrames_LGFOptions = {
    ignorePartyFrame = false,
    ignoreRaidFrame = false,
    ignoreBossFrame = true,
}

--[[-----------------------------------------------------------------------------
Unit Functions
-------------------------------------------------------------------------------]]

Private.UnitFunctions = { -- Static Class

    RaidFrameData = function(unit)
        return LGF.GetUnitFrame(unit, raidFrames_LGFOptions), UnitGUID(unit)
    end,

    PartyFrameData = function(unit)
        return LGF.GetUnitFrame(unit, partyFrames_LGFOptions), UnitGUID(unit)
    end,

    ArenaFrameData = function(unit)
        local unitGUID = UnitGUID(unit)
        return getArenaFrame(unitGUID), unitGUID, getUnitHostility(unit)
    end,

    NameplateData = function(unit)
        local unitGUID = UnitGUID(unit)
        return LGF.GetUnitNameplate(unit), unitGUID, getUnitHostility(unit), getUnitNPCID(unitGUID)
    end,

    UnitHostility = getUnitHostility,

    UnitNPCID = getUnitNPCID,

    NameplateUnitType = function(unit, unitReaction, unitNPCID)
        if UnitIsUnit(unit, "player") then
            return PLAYER_NAMEPLATE
        else
            if unitReaction then
                if unitNPCID then
                    return HOSTILE_NPC_NAMEPLATE
                else
                    return HOSTILE_PLAYER_NAMEPLATE
                end
            else
                if unitNPCID then
                    return FRIENDLY_NPC_NAMEPLATE
                else
                    return FRIENDLY_PLAYER_NAMEPLATE
                end
            end
        end
    end,

    TargetNameplateUnitType = function(unit, unitReaction, unitNPCID)
        if UnitIsUnit(unit, "player") then
            return PLAYER_TARGET_NAMEPLATE
        else
            if unitReaction then
                if unitNPCID then
                    return HOSTILE_NPC_TARGET_NAMEPLATE
                else
                    return HOSTILE_PLAYER_TARGET_NAMEPLATE
                end
            else
                if unitNPCID then
                    return FRIENDLY_NPC_TARGET_NAMEPLATE
                else
                    return FRIENDLY_PLAYER_TARGET_NAMEPLATE
                end
            end
        end
    end,

    ArenaUnitType = function()
        local inInstance, instanceType = IsInInstance()
        if inInstance then
            if instanceType == "arena" then
                return ARENA
            elseif instanceType == "pvp" then
                return BATTLEGROUND
            end
        end
    end,

    TargetNameplate = function()
        local nameplate = GetNameplateForUnit("target")
        if nameplate then
            return nameplate.namePlateUnitToken
        end
    end,

    FocusNameplate = function()
        local nameplate = GetNameplateForUnit("focus")
        if nameplate then
            return nameplate.namePlateUnitToken
        end
    end,

    IsNameplateSecure = function(unit)
        local frame = GetNameplateForUnit(unit)
        return frame and not frame:IsForbidden() or false
    end,
}