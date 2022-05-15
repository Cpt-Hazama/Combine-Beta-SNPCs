ENT.Type 			= "anim"
ENT.Base 			= "obj_beam"

function ENT:GetEndPos()
	local entStart = self:GetNetworkedEntity("entStart")
	if(!entStart:IsValid()) then return end
	local pos = entStart.GetShootPos && entStart:GetShootPos() || self:GetStartPos()
	local dir
	if(entStart.GetAimVector) then dir = entStart:GetAimVector()
	else
		local attID = entStart:LookupAttachment("muzzle")
		local att = entStart:GetAttachment(attID)
		local entTgt = entStart:GetNetworkedEntity("enemy")
		if(IsValid(entTgt)) then dir = util.GetConstrictedDirection(att.Pos,entTgt:GetCenter(),att.Ang,Angle(10,10,10))
		else dir = att.Ang:Forward() end
	end
	local tr = util.TraceLine({
		start = pos,
		endpos = pos +dir *300,
		filter = entStart,
		mask = MASK_PLAYERSOLID
	})
	return tr.HitPos
end