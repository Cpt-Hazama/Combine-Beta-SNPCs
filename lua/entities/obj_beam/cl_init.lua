include('shared.lua')

ENT.nextUpdate = 0
ENT.nextRandom = 0
ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:Initialize()
end

function ENT:GetStartPos()
	local posStart
	local entStart = self:GetNetworkedEntity("entStart")
	if entStart != NULL then
		local iAtt = self:GetNetworkedInt("attachmentStart")
		if iAtt > 0 then posStart = entStart:GetAttachment(iAtt).Pos
		else posStart = entStart:GetPos() end
	else posStart = self:GetNetworkedVector("vecStart") end
	return posStart
end

function ENT:GetEndPos()
	local posDest
	if self:GetNetworkedBool("random") then
		if CurTime() >= self.nextRandom then
			self.posRandom = self:GetRandomPos()
			self.nextRandom = CurTime() +self:GetNetworkedFloat("delay")
		end
		if !self.posRandom then return end
		posDest = self.posRandom
	else
		local entEnd = self:GetNetworkedEntity("entEnd")
		if entEnd:IsValid() then
			local iAtt = self:GetNetworkedInt("attachmentEnd")
			if iAtt > 0 then posDest = entEnd:GetAttachment(iAtt).Pos
			else posDest = entEnd:GetPos() end
		else posDest = self:GetNetworkedVector("vecEnd") end
	end
	return posDest
end

function ENT:Think()
	local posDest = self:GetEndPos()
	if !posDest then return end
	self:SetRenderBoundsWS(posDest, self:GetStartPos(), Vector() *8)
end

function ENT:Draw()
	if !self:GetNetworkedBool("active") then return end
	local mat = self:GetNetworkedString("texture")
	if mat != self.sMaterial then
		self.sMaterial = mat
		self.texture = Material(mat)
	end
	local color = self:GetNetworkedString("color")
	color = string.Explode(",", color)
	color = Color(color[1],color[2],color[3],color[4])
	local width = self:GetNetworkedFloat("width")
	local updateRate = self:GetNetworkedFloat("update")
	local posStart = self:GetStartPos()
	local posDest = self:GetEndPos()
	if !posDest then return end
	
	local normal = (posDest -posStart):GetNormal()
	local ang = normal:Angle()
	local pos = posStart
	local amplitude = self:GetNetworkedFloat("amplitude")
	if amplitude != 0 && CurTime() >= self.nextUpdate then self:RefreshBeam(ang, pos, posDest); self.nextUpdate = CurTime() +updateRate end
	cam.Start3D(EyePos(), EyeAngles())
		render.SetMaterial(self.texture)
		if amplitude == 0 then
			render.DrawBeam(posStart, posDest, width, 1, 1, color)
		else
			local num = #self.positions
			render.StartBeam(num)
			for i = 1,num do
				local pos = self.positions[i]
				render.AddBeam(pos,width,CurTime(),color)
			end
			render.EndBeam()
		end
	cam.End3D()
end

function ENT:GetRandomPos()
	local iDist = self:GetNetworkedInt("distance")
	local pos = self:GetPos()
	local posDest
	for i = 0, 10 do
		posDest = pos +VectorRand() *iDist
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = posDest
		tracedata.mask = MASK_SOLID_BRUSHONLY
		local tr = util.TraceLine(tracedata)
		if tr.Hit then return tr.HitPos end
	end
	return
end

function ENT:RefreshBeam(ang,pos,posDest)
	local amplitude = self:GetNetworkedFloat("amplitude")
	local fDist = pos:Distance(posDest)
	local iSegments = math.Clamp(math.Round(fDist *0.05), 0, 100)
	local fDistEach = math.Round(fDist /iSegments)
	self.positions = {}
	table.insert(self.positions, pos)
	local _pos = pos
	for i = 1, iSegments -1 do
		if i < iSegments -1 then
			pos = _pos +ang:Forward() *fDistEach *i +ang:Up() *math.Rand(-amplitude, amplitude) +ang:Right() *math.Rand(-amplitude, amplitude)
		else pos = posDest end
		table.insert(self.positions, pos)
	end
end