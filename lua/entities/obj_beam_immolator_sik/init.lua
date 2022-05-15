
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	if self:GetScale() == 0 then self:SetScale(1) end
	
	local ent = ents.Create("point_tesla")
	ent:SetKeyValue("texture","sprites/physbeam.vmt")
	ent:SetKeyValue("m_Color","200 255 0 255")
	ent:SetKeyValue("m_flRadius","150")
	ent:SetKeyValue("beamcount_min","20")
	ent:SetKeyValue("beamcount_max","50")
	ent:SetKeyValue("lifetime_min","0.05")
	ent:SetKeyValue("lifetime_max","0.05")
	ent:SetKeyValue("interval_min","0.05")
	ent:SetKeyValue("interval_max","0.05")
	ent:SetPos(self:GetPos())
	ent:Spawn()
	ent:Activate()
	ent:Fire("TurnOn","",0)
	self:SetNetworkedEntity("tesla",ent)
	self.m_entTesla = ent
	self:DeleteOnRemove(ent)
end

function ENT:SetScale(flScale)
	self:SetNetworkedFloat("scale", flScale)
end

function ENT:GetScale()
	return self:GetNetworkedFloat("scale")
end

function ENT:SetSourceEntity(ent)
	self.m_entSrc = ent
end

function ENT:Think()
	local owner = self:GetOwner()
	if(self.m_entTesla:IsValid() && IsValid(owner) && IsValid(self.m_entSrc)) then
		local ent = self.m_entSrc
		//local att = ent:GetAttachment(ent:LookupAttachment("muzzle"))
		local pos = owner:GetShootPos()//att.Pos
		local dir = owner:GetAimVector()//att.Ang:Forward()
		local tr = util.TraceLine({
			start = pos,
			endpos = pos +dir *400,
			mask = MASK_SOLID,
			filter = {self,owner,ent}
		})
		self.m_entTesla:SetPos(tr.HitPos)
	end
	self:NextThink(CurTime())
	return true
end

function ENT:AddPosition(vecPos)
	local iPos = self:GetNetworkedInt("positions") +1
	self:SetNetworkedInt("positions", iPos)
	self:SetNetworkedVector(iPos, vecPos)
end