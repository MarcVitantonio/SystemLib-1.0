local _, Private = ...

local MAJOR_VERSION = "SystemLib-1.0"
local MINOR_VERSION = 1

if not LibStub then
    error("LibStub is required but not loaded.")
end

local Lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not Lib then
    -- Library is already loaded and up to date
    return
end
-- Library requires upgrade

local CBH = LibStub:GetLibrary("CallbackHandler-1.0", true)
if not CBH then
    error("CallbackHandler-1.0 is required but not loaded.")
end

local LGF = LibStub:GetLibrary("LibGetFrame-1.0", true)
if not LGF then
    error("LibGetFrame-1.0 is required but not loaded.")
end

Private.Lib = Lib
Private.CBH = CBH
Private.LGF = LGF

LGF.GetUnitFrame()
