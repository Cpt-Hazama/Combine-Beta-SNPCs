include('shared.lua')

function ENT:GetStartPos()
	local posStart
	local entStart = self:GetNetworkedEntity("entStart")
	if entStart != NULL then
		local entTgt = entStart.GetWeaponModel && entStart:GetWeaponModel() || entStart
		if(!entTgt:IsValid()) then return vector_origin end
		local att = entTgt:LookupAttachment("muzzle")
		att = entTgt:GetAttachment(att)
		return att && att.Pos || vector_origin
	else posStart = self:GetNetworkedVector("vecStart") end
	return posStart
end

local matSpr = Material("sprites/animglow02.vmt")
function ENT:Draw()
	local posDest = self:GetEndPos()
	if(!posDest) then return end
	self.BaseClass.Draw(self)
	cam.Start3D(EyePos(), EyeAngles())
		render.SetMaterial(matSpr)
		local sc = (math.sin(CurTime() *10) +2) *1 +16
		render.DrawSprite(posDest,sc,sc,Color(255,0,0,255))
	cam.End3D()
end