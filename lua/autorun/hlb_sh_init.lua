if(!SLVBase_Fixed) then
	include("slvbase/slvbase.lua")
	if(!SLVBase_Fixed) then return end
end
local addon = "Half[-]Life Beta"
if(SLVBase_Fixed.AddonInitialized(addon)) then return end
if(SERVER) then
	AddCSLuaFile("autorun/hlb_sh_init.lua")
	AddCSLuaFile("hlb_init/hlb_sh_concommands.lua")
	AddCSLuaFile("autorun/slvbase/slvbase.lua")
end
SLVBase_Fixed.AddDerivedAddon(addon,{tag = "HL2 Beta"})

SLVBase_Fixed.InitLua("hlb_init")

local Category = "Combine"
SLVBase_Fixed.AddNPC(Category,"Cremator","npc_cremator")
SLVBase_Fixed.AddNPC(Category,"Combine Assassin","npc_fassassin")
SLVBase_Fixed.AddNPC(Category,"Mortar Synth","npc_mortarsynth")