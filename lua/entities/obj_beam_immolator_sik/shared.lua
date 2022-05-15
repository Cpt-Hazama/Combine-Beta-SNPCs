ENT.Type = "anim"

function ENT:SetEndPos(endpos)
	self:SetNetworkedVector(0, endpos)	
	self:SetCollisionBoundsWS(self.Entity:GetPos(), endpos, Vector() *0.25)
end

function ENT:GetEndPos()
	return self:GetNetworkedVector(0)
end

function ENT:GetBeamPositions()
	local tblVec = {self:GetAttachmentPos()}
	for i = 1, self:GetNetworkedInt("positions") do
		table.insert(tblVec, self:GetNetworkedVector(i))
	end
	return tblVec
end

function ENT:GetAttachmentPos()
	local entOwner = self:GetOwner()
	local ViewModel = entOwner == LocalPlayer() && GetViewEntity() == LocalPlayer()
	if ViewModel then return entOwner:GetViewModel():GetAttachment(1).Pos end
	local wep
	if entOwner:IsPlayer() then wep = entOwner:GetActiveWeapon()
	else wep = entOwner:slvGetWeapon("weapon_gauss") end
	return wep:GetAttachment(1).Pos
end