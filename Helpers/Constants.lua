local _, Private = ...

Private.Constants = {
    EVENTS = {
        FRAME_CREATED = "FRAME_CREATED",
        UNIT_ADDED = "UNIT_ADDED",
        UNIT_UPDATED = "UNIT_UPDATED",
        UNIT_REMOVED = "UNIT_REMOVED",
    },
    LGF_EVENTS = {
        FRAME_ADDED = "FRAME_UNIT_ADDED",
        FRAME_UPDATED = "FRAME_UNIT_UPDATE",
        FRAME_REMOVED = "FRAME_UNIT_REMOVED",
    },
    UNITS = {
        NAMEPLATE = (function() local t = {} for i = 1, 20 do t["nameplate"..i] = true end return t end)(),
        PARTY = (function() local t = {} for i = 1, 4 do t["party"..i] = true end return t end)(),
        RAID = (function() local t = {} for i = 1, 40 do t["raid"..i] = true end return t end)(),
        ARENA = (function() local t = {} for i = 1, 5 do t["arena"..i] = true end return t end)(),
        BOSS = (function() local t = {} for i = 1, 5 do t["boss"..i] = true end return t end)(),
        PLAYER = { player = true },
        TARGET = { target = true },
        FOCUS = { focus = true },
    },
    UNIT_TYPES = {
        PLAYER_NAMEPLATE = "playerNameplate",
        FRIENDLY_NPC_NAMEPLATE = "friendlyNPCNameplate",
        FRIENDLY_PLAYER_NAMEPLATE = "friendlyPlayerNameplate",
        HOSTILE_NPC_NAMEPLATE = "hostileNPCNameplate",
        HOSTILE_PLAYER_NAMEPLATE = "hostilePlayerNameplate",
        NAMEPLATE = "nameplate",

        PLAYER_TARGET_NAMEPLATE = "playerTargetNameplate",
        FRIENDLY_NPC_TARGET_NAMEPLATE = "friendlyNPCTargetNameplate",
        FRIENDLY_PLAYER_TARGET_NAMEPLATE = "friendlyPlayerTargetNameplate",
        HOSTILE_NPC_TARGET_NAMEPLATE = "hostileNPCTargetNameplate",
        HOSTILE_PLAYER_TARGET_NAMEPLATE = "hostilePlayerTargetNameplate",
        TARGET_NAMEPLATE = "targetNameplate",

        PARTY = "party",
        RAID = "raid",
        ARENA = "arena",
        BATTLEGROUND = "battleground",
    },
    UNIT_SPECIALIZATIONS = {
        ['Havoc Demon Hunter'] = {specName = 'Havoc', specIndex = 577, roleToken = "DAMAGER", specIcon = 1247264},
        ['Vengeance Demon Hunter'] = {specName = 'Vengeance', specIndex = 581, roleToken = "DAMAGER", specIcon = 1247265},

        ['Blood Death Knight'] = {specName = 'Blood', specIndex = 250, roleToken = "TANK", specIcon = 135770},
        ['Frost Death Knight'] = {specName = 'Frost', specIndex = 251, roleToken = "DAMAGER", specIcon = 135773},
        ['Unholy Death Knight'] = {specName = 'Unholy', specIndex = 252, roleToken = "DAMAGER", specIcon = 135775},

        ['Balance Druid'] = {specName = 'Balance', specIndex = 102, roleToken = "DAMAGER", specIcon = 136096},
        ['Feral Druid'] = {specName = 'Feral', specIndex = 103, roleToken = "DAMAGER", specIcon = 132115},
        ['Guardian Druid'] = {specName = 'Guardian', specIndex = 104, roleToken = "TANK", specIcon = 132276},
        ['Restoration Druid'] = {specName = 'Restoration', specIndex = 105, roleToken = "HEALER", specIcon = 136041},

        ['Beast Mastery Hunter'] = {specName = 'Beast Mastery', specIndex = 253, roleToken = "DAMAGER", specIcon = 461112},
        ['Marksmanship Hunter'] = {specName = 'Marksmanship', specIndex = 254, roleToken = "DAMAGER", specIcon = 236179},
        ['Survival Hunter'] = {specName = 'Survival', specIndex = 255, roleToken = "DAMAGER", specIcon = 461113},

        ['Arcane Mage'] = {specName = 'Arcane', specIndex = 62, roleToken = "DAMAGER", specIcon = 135932},
        ['Fire Mage'] = {specName = 'Fire', specIndex = 63, roleToken = "DAMAGER", specIcon = 135810},
        ['Frost Mage'] = {specName = 'Frost', specIndex = 64, roleToken = "DAMAGER", specIcon = 135846},

        ['Brewmaster Monk'] = {specName = 'Brewmaster', specIndex = 268, roleToken = "TANK", specIcon = 608951},
        ['Windwalker Monk'] = {specName = 'Windwalker', specIndex = 269, roleToken = "DAMAGER", specIcon = 608953},
        ['Mistweaver Monk'] = {specName = 'Mistweaver', specIndex = 270, roleToken = "HEALER", specIcon = 608952},

        ['Holy Paladin'] = {specName = 'Holy', specIndex = 65, roleToken = "HEALER", specIcon = 135920},
        ['Protection Paladin'] = {specName = 'Protection', specIndex = 66, roleToken = "TANK", specIcon = 236264},
        ['Retribution Paladin'] = {specName = 'Retribution', specIndex = 70, roleToken = "DAMAGER", specIcon = 135873},

        ['Discipline Priest'] = {specName = 'Discipline', specIndex = 256, roleToken = "HEALER", specIcon = 237542},
        ['Holy Priest'] = {specName = 'Holy', specIndex = 257, roleToken = "HEALER", specIcon = 237542},
        ['Shadow Priest'] = {specName = 'Shadow', specIndex = 258, roleToken = "DAMAGER", specIcon = 136207},

        ['Assassination Rogue'] = {specName = 'Assassination', specIndex = 259, roleToken = "DAMAGER", specIcon = 236270},
        ['Outlaw Rogue'] = {specName = 'Outlaw', specIndex = 260, roleToken = "DAMAGER", specIcon = 135340},
        ['Subtlety Rogue'] = {specName = 'Subtlety', specIndex = 261, roleToken = "DAMAGER", specIcon = 132320},

        ['Elemental Shaman'] = {specName = 'Elemental', specIndex = 262, roleToken = "DAMAGER", specIcon = 136048},
        ['Enhancement Shaman'] = {specName = 'Enhancement', specIndex = 263, roleToken = "DAMAGER", specIcon = 237581},
        ['Restoration Shaman'] = {specName = 'Restoration', specIndex = 264, roleToken = "HEALER", specIcon = 136052},

        ['Affliction Warlock'] = {specName = 'Affliction', specIndex = 265, roleToken = "DAMAGER", specIcon = 136145},
        ['Demonology Warlock'] = {specName = 'Demonology', specIndex = 266, roleToken = "DAMAGER", specIcon = 136172},
        ['Destruction Warlock'] = {specName = 'Destruction', specIndex = 267, roleToken = "DAMAGER", specIcon = 136186},

        ['Arms Warrior'] = {specName = 'Arms', specIndex = 71, roleToken = "DAMAGER", specIcon = 132355},
        ['Fury Warrior'] = {specName = 'Fury', specIndex = 72, roleToken = "DAMAGER", specIcon = 132347},
        ['Protection Warrior'] = {specName = 'Protection', specIndex = 73, roleToken = "TANK", specIcon = 132341},

        ['Devastation Evoker'] = {specName = 'Devastation', specIndex = 1467, roleToken = "DAMAGER", specIcon = 4622451}, -- Incorrect Icon
        ['Preservation Evoker'] = {specName = 'Preservation', specIndex = 1468, roleToken = "HEALER", specIcon = 4622476},
        ['Augmentation Evoker'] = {specName = 'Augmentation', specIndex = 1473, roleToken = "DAMAGER", specIcon = 4567909},
    },
}

Private.Constants.VALID_UNIT_TYPES = {}
for _, unitType in pairs(Private.Constants.UNIT_TYPES) do
    if type(unitType) == "string" then
        Private.Constants.VALID_UNIT_TYPES[unitType] = true
    end
end