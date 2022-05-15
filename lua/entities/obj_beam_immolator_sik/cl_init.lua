include('shared.lua')

local matBeamMain = Material("sprites/physbeam.vmt")//sprites/crystal_beam2")
local matBeamSub = Material("sprites/physbeam.vmt")//sprites/rollermine_shock_yellow")
local colBeam = Color(200,255,0,255)

ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:Initialize()
	local posStart = self:GetAttachmentPos()
	local owner = self:GetOwner()
	local tr
	if owner:IsPlayer() then tr = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))
	else
		local endpos = self:GetBeamPositions()[2] || posStart
		tr = util.TraceLine({start = posStart, endpos = endpos, filter = owner})
	end
	self.nextUpdate = 0
	
	local iIndex = self:EntIndex()
	hook.Add("RenderScreenspaceEffects", "Effect_EgonBeam" .. iIndex, function()
		if !IsValid(self) then
			hook.Remove("RenderScreenspaceEffects", "Effect_EgonBeam" .. iIndex)
			return
		end
		
		local owner = self:GetOwner()
		if(IsValid(owner)) then
			local entTesla = self:GetNetworkedEntity("tesla")
			local pos = self:GetAttachmentPos()
			local posTgt
			if(entTesla:IsValid()) then posTgt = entTesla:GetPos()
			else
				local dir = owner:GetAimVector()
				local tr = util.TraceLine({
					start = pos,
					endpos = pos +dir *400,
					mask = MASK_SOLID,
					filter = {self,owner}
				})
				posTgt = tr.HitPos
			end
			local xpos = pos
			pos = posTgt
			posTgt = xpos
			///local StartPos = self:GetAttachmentPos()
			///if CurTime() >= self.nextUpdate then self:RefreshBeam(StartPos); self.nextUpdate = CurTime() +0.02 end
			cam.Start3D(EyePos(), EyeAngles())
				render.SetMaterial(matBeamSub)
				/*render.StartBeam(table.Count(self.positions))
				for k, v in pairs(self.positions) do
					render.AddBeam(v, 4 *self:GetNetworkedFloat("scale"), CurTime(), Color(255,255,255,255))
				end
				render.EndBeam()*/
				local TexOffset = CurTime() *-2.0
				render.SetMaterial(matBeamSub)
				render.DrawBeam(pos,posTgt,4 *self:GetNetworkedFloat("scale"),TexOffset *-0.4, TexOffset *-0.4  +pos:Distance(posTgt) /256,colBeam)
				render.SetMaterial(matBeamMain)
				render.DrawBeam(pos,posTgt,12 *self:GetNetworkedFloat("scale"),TexOffset *-0.4, TexOffset *-0.4  +pos:Distance(posTgt) /256,colBeam)
				/*local posStart = self:GetAttachmentPos()
				local TexOffset = CurTime() *-2.0
				render.SetMaterial(matBeamMain)
				for i = 1, self:GetNetworkedInt("positions") do
					local posDest = self:GetNetworkedVector(i)
					render.DrawBeam(posStart, posDest, 12 *self:GetNetworkedFloat("scale"), TexOffset *-0.4, TexOffset *-0.4 +posStart:Distance(posDest) /256, Color(255,255,255,255))
					posStart = posDest
				end*/
			cam.End3D()
		end
	end)
end

function ENT:Think()
end

function ENT:Draw()
end

function ENT:IsTranslucent()
	return true
end

function ENT:RefreshBeam(posStart)
	local amplitude = 0.8
	local tblVec = self:GetBeamPositions()
	self.positions = {posStart}
	for k, v in pairs(tblVec) do
		if k > 1 then
			local pos = tblVec[k -1]
			local posDest = v
			local normal = (posDest -pos):GetNormal()
			local ang = normal:Angle()
			local fDist = pos:Distance(posDest)
			local iSegments = math.Clamp(math.Round(fDist *0.05), 0, 100)
			local fDistEach = math.Round(fDist /iSegments)
			local _pos = pos
			for i = 1, iSegments -1 do
				if i < iSegments -1 then
					pos = _pos +ang:Forward() *fDistEach *i +ang:Up() *math.Rand(-amplitude, amplitude) +ang:Right() *math.Rand(-amplitude, amplitude)
				else pos = posDest end
				table.insert(self.positions, pos)
			end
		end
	end
end