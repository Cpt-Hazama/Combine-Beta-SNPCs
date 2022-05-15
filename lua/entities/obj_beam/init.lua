
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	if self:GetWidth() == 0 then self:SetWidth(20) end
	if string.len(self:GetNetworkedString("color")) == 0 then self:SetBeamColor(255,255,255,255) end
end

function ENT:SetWidth(flWidth)
	self:SetNetworkedFloat("width", flWidth)
end

function ENT:GetWidth()
	return self:GetNetworkedFloat("width")
end

function ENT:SetStart(tStart, iAtt)
	if type(tStart) == "Vector" then
		self:SetNetworkedEntity("entStart", NULL)
		self:SetNetworkedVector("vecStart", tStart)
	else
		self:SetNetworkedEntity("entStart", tStart)
		if iAtt then self:SetNetworkedInt("attachmentStart", iAtt) end
		self:SetNetworkedVector("vecStart", Vector(0,0,0))
	end
end

function ENT:GetStart()
	local ent = self:GetNetworkedEntity("start")
	if ent != NULL then return ent, self:GetNetworkedInt("attachmentStart") end
	return self:GetNetworkedVector("start")
end

function ENT:SetEnd(tEnd, iAtt)
	if type(tEnd) == "Vector" then
		self:SetNetworkedEntity("entEnd", NULL)
		self:SetNetworkedVector("vecEnd", tEnd)
	else
		self:SetNetworkedEntity("entEnd", tEnd)
		if iAtt then self:SetNetworkedInt("attachmentEnd", iAtt) end
		self:SetNetworkedVector("vecEnd", Vector(0,0,0))
	end
end

function ENT:GetEnd()
	local ent = self:GetNetworkedEntity("end")
	if ent != NULL then return ent, self:GetNetworkedInt("attachmentEnd") end
	return self:GetNetworkedVector("end")
end

function ENT:SetTexture(sText)
	self:SetNetworkedString("texture", sText)
end

function ENT:GetTexture()
	return self:GetNetworkedString("texture")
end

function ENT:SetAmplitude(flAmp)
	self:SetNetworkedFloat("amplitude", math.Clamp(flAmp,0,25))
end

function ENT:GetAmplitude()
	return self:GetNetworkedFloat("amplitude")
end

function ENT:SetUpdateRate(flRate)
	self:SetNetworkedFloat("update", flRate)
end

function ENT:GetUpdateRate()
	return self:GetNetworkedFloat("update")
end

function ENT:SetRandom(bRandom)
	self:SetNetworkedBool("random", bRandom)
end

function ENT:GetRandom()
	return self:GetNetworkedBool("random")
end

function ENT:SetDistance(iDist)
	self:SetNetworkedInt("distance", iDist)
end

function ENT:GetDistance()
	return self:GetNetworkedInt("distance")
end

function ENT:SetDelay(flDelay)
	self:SetNetworkedFloat("delay", flDelay)
end

function ENT:GetDelay()
	return self:GetNetworkedFloat("delay")
end

function ENT:SetBeamColor(r,g,b,a)
	local color = r .. "," .. g .. "," .. b
	if a then color = color .. "," .. a end
	self:SetNetworkedString("color", color)
end

function ENT:GetBeamColor()
	local _color = self:GetNetworkedString("color")
	_color = string.Explode(",", _color)
	local color = Color(_color[1],_color[2],_color[3],_color[4])
	return color
end

function ENT:SetLifeTime(flTime)
	self.flLifeTime = CurTime() +flTime
end

function ENT:GetLifeTime()
	return self.flLifeTime || -1
end

function ENT:OnRemove()
end

function ENT:Think()
	local flLife = self:GetLifeTime()
	if flLife == -1 || CurTime() < flLife then return end
	self:Remove()
end

function ENT:TurnOn()
	self:SetNetworkedBool("active", true)
end

function ENT:TurnOff()
	self:SetNetworkedBool("active", false)
end
