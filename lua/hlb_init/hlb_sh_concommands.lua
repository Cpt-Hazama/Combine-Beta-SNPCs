local ConVars = {}

// CREMATOR
ConVars["sk_cremator_health"] = 650
ConVars["sk_cremator_dmg_fire"] = 12

// COMBINE ASSASSIN
ConVars["sk_fassassin_health"] = 150
ConVars["sk_fassassin_dmg_kick"] = 12
ConVars["sk_fassassin_dmg_bullet"] = 1

// MORTARSYNTH
ConVars["sk_mortarsynth_health"] = 200
ConVars["sk_mortarsynth_dmg_beam"] = 18

for cvar,val in pairs(ConVars) do
	CreateConVar(cvar,val,FCVAR_ARCHIVE)
end