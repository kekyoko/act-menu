include("act_menu/sh_config.lua")																																																										-- Codded by Friks(https://steamcommunity.com/id/9871275127721)

if SERVER then
	AddCSLuaFile("act_menu/cl_core.lua")
	AddCSLuaFile("act_menu/sh_config.lua")
	include("act_menu/sv_core.lua")
else 
	include("act_menu/cl_core.lua")
end
	