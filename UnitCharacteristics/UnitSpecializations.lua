local _, Private = ...

local UNIT_SPECIALIZATIONS = Private.Constants.UNIT_SPECIALIZATIONS

local C_TooltipInfo_GetUnit = C_TooltipInfo.GetUnit
local UnitIsPlayer = UnitIsPlayer
local GetGuildInfo = GetGuildInfo

local function getUnitSpec(unit)
    local tooltipData = C_TooltipInfo_GetUnit(unit, true)
    if tooltipData and UnitIsPlayer(unit) then
        local specRef = (GetGuildInfo(unit) and tooltipData.lines[4] and tooltipData.lines[4].leftText)
        or (tooltipData.lines[3] and tooltipData.lines[3].leftText)
        if specRef then
            return specRef
        end
    end
end

-- ['Vengeance Demon Hunter'] = {specName = 'Vengeance', specIndex = 581, roleToken = "DAMAGER", specIcon = 1247265},

Private.UnitSpecializations = {
    APIFunctions = {
        "GetUnitSpec",
        "GetSpecRole",
        "GetSpecIcon",
    },

    GetUnitSpec = getUnitSpec,

    GetSpecRole = function(specRef)
        local specData = specRef and UNIT_SPECIALIZATIONS[specRef]
        return specData and specData.roleToken
    end,

    GetSpecIcon = function(specRef)
        local specData = specRef and UNIT_SPECIALIZATIONS[specRef]
        return specData and specData.specIcon
    end
}