AddCSLuaFile("shared.lua")

include('shared.lua')

util.AddNPCClassAlly(CLASS_COMBINE,"npc_cremator")
ENT.NPCFaction = NPC_FACTION_COMBINE
ENT.sModel = "models/cremator.mdl"
ENT.iClass = CLASS_COMBINE
ENT.fRangeDistance = 280
ENT.UseActivityTranslator = true

ENT.iBloodType = BLOOD_COLOR_RED
ENT.sSoundDir = "npc/cremator/"

ENT.m_tbSounds = {
	["Attack"] = "alert_object.wav",
	["Alert"] = "alert_player.wav",
	["Death"] = "crem_die.wav",
	["Foot"] = "foot[1-3].wav"
}

ENT.tblFlinchActivities = {
	[HITBOX_GENERIC] = ACT_BIG_FLINCH
}

function ENT:OnInit()
	self:SetNPCFaction(NPC_FACTION_COMBINE,CLASS_COMBINE)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetCollisionBounds(Vector(20,20,90),Vector(-20,-20,0))

	self:slvCapabilitiesAdd(bit.bor(CAP_MOVE_GROUND,CAP_OPEN_DOORS))
	self.nextRangeAttack = 0
	self.nextPlayIdleChase = 0
	self:slvSetHealth(GetConVarNumber("sk_cremator_health"))
	
	local cspLoop = CreateSound(self,self.sSoundDir .. "amb_loop.wav")
	cspLoop:SetSoundLevel(65)
	cspLoop:Play()
	self:StopSoundOnDeath(cspLoop)
end

function ENT:OnPrimaryTargetChanged(ent)
	self:SetNetworkedEntity("enemy",ent)
end

function ENT:TranslateActivity(act)
	if(act == ACT_IDLE && self.bInAttack) then return ACT_RANGE_ATTACK2 end
end

function ENT:OnLimbCrippled(hitbox, attacker)
	if(hitbox == HITBOX_LEFTLEG || hitbox == HITBOX_RIGHTLEG) then
		self:SetWalkActivity(ACT_WALK_HURT)
		self:SetRunActivity(ACT_WALK_HURT)
	end
end

function ENT:EventHandle(...)
	local event = select(1,...)
	if(event == "rattack") then
		if(!self.bInAttack) then self:StartRangeAttack() end
		//self:SLVPlayActivity(ACT_RANGE_ATTACK2,true)
		return true
	end
end

function ENT:LegsCrippled()
	return self:LimbCrippled(HITBOX_LEFTLEG) || self:LimbCrippled(HITBOX_RIGHTLEG) || self:LimbCrippled(HITBOX_LEFTARM) || self:LimbCrippled(HITBOX_RIGHTARM)
end

function ENT:EntInAttackCone(ent)
	local i = 0
	local ang = self:GetAngleToPos(ent:GetCenter())
	return (ang.y <= 35 || ang.y >= 325) && (ang.p <= 45 || ang.p >= 315)
end

function ENT:OnDeath(dmginfo)
	self:EndRangeAttack()
end

function ENT:EndRangeAttack(bAnim)
	if(!self.bInAttack) then return end
	if(bAnim) then
		self:SLVPlayActivity(ACT_RANGE_ATTACK1_LOW)
	end
	self.m_cspPlasma:Stop()
	self.m_cspPlasma = nil
	if(self.m_cspHit) then
		self.m_cspHit:Stop()
		self.m_cspHit = nil
	end
	self.m_tNextDamage = nil
	self.bInAttack = false
	for _,ent in ipairs(self.tbEffects) do
		if(ent:IsValid()) then ent:Remove() end
	end
	self.tbEffects = nil
end

function ENT:OnInterrupt()
	self:EndRangeAttack()
end

function ENT:OnAreaCleared()
	self:slvPlaySound("AreaClear")
	self:EndRangeAttack(true)
end

function ENT:StartRangeAttack()
	self.bInAttack = true
	self.m_tNextDamage = CurTime()
	self.tbEffects = {}
	for i = 1, 3 do
		local ent = ents.Create("obj_beam_immolator")
		ent:SetPos(self:GetPos())
		ent:SetParent(self)
		ent:Spawn()
		ent:Activate()
		ent:SetAmplitude(2)
		ent:SetWidth(12)
		ent:SetUpdateRate(0.02)
		ent:SetTexture("sprites/physbeam.vmt")
		ent:SetBeamColor(100,255,0,255)
		ent:SetStart(self)
		ent:TurnOn()
		table.insert(self.tbEffects,ent)
		self:DeleteOnRemove(ent)
	end
	self.m_cspPlasma = CreateSound(self,"weapons/immolator/plasma_shoot.wav")
	self.m_cspPlasma:Play()
	self:StopSoundOnDeath(self.m_cspPlasma)
	
	local ent = ents.Create("point_tesla")
	ent:SetKeyValue("texture","sprites/physbeam.vmt")
	ent:SetKeyValue("m_Color","200 255 0 255")
	ent:SetKeyValue("m_flRadius","200")
	ent:SetKeyValue("beamcount_min","5")
	ent:SetKeyValue("beamcount_max","10")
	ent:SetKeyValue("lifetime_min","0.075")
	ent:SetKeyValue("lifetime_max","0.075")
	ent:SetKeyValue("interval_min","0.002")
	ent:SetKeyValue("interval_max","0.002")
	self.entTesla = ent
	self:UpdateTeslaPos()
	ent:Spawn()
	ent:Activate()
	ent:Fire("TurnOn","",0)
	table.insert(self.tbEffects,ent)
	self:DeleteOnRemove(ent)
end

function ENT:_PossPrimaryAttack(entPossessor, fcDone)
	if(self.bInAttack) then fcDone(true); return end
	self:SLVPlayActivity(ACT_RANGE_ATTACK1,false,fcDone)
end

function ENT:UpdateTeslaPos()
	if(!IsValid(self.entTesla) || !self.tbEffects) then return end
	local ent = self.tbEffects[1]
	if(!IsValid(ent)) then return end
	self.entTesla:SetPos(ent:GetEndPos())
end

function ENT:OnThink()
	self:UpdateLastEnemyPositions()
	self:UpdateTeslaPos()
	if(self.bInAttack) then
		local bDmg = true
		if(self:SLV_IsPossesed()) then if(!self:GetPossessor():KeyDown(IN_ATTACK)) then bDmg = false; self:EndRangeAttack(true) end
		elseif(!IsValid(self.entEnemy) || self:OBBDistance(self.entEnemy) > self.fRangeDistance || !self:CanSee(self.entEnemy)) then bDmg = false; self:EndRangeAttack() end
		if(bDmg && CurTime() >= self.m_tNextDamage) then
			self.m_tNextDamage = CurTime() +0.1
			local ent = self.tbEffects[1]
			if(IsValid(ent)) then
				local att = self:GetAttachment(self:LookupAttachment("muzzle"))
				local pos = ent:GetEndPos()
				local bHit
				for _,ent in ipairs(ents.FindInSphere(pos,25)) do
					if(ent:IsValid() && ((ent:IsNPC() && ent != self) || ent:IsPlayer() || ent:IsPhysicsEntity())) then
						bHit = true
						local dmg = DamageInfo()
						dmg:SetAttacker(self)
						dmg:SetDamage(ent:IsNPC() && 5 || 3)
						dmg:SetDamageForce(self:GetForward() *20)
						dmg:SetDamagePosition(pos)
						dmg:SetDamageType(DMG_DISSOLVE)
						dmg:SetInflictor(self)
						ent:TakeDamageInfo(dmg,att.Pos,pos)
					end
				end
				if(bHit) then
					if(!self.m_cspHit) then
						local csp = CreateSound(self,"npc/stalker/laser_flesh.wav")
						csp:Play()
						self.m_cspHit = csp
						self:StopSoundOnDeath(csp)
					end
				elseif(self.m_cspHit) then self.m_cspHit:Stop(); self.m_cspHit = nil end
			end
		end
	end
	local pp = self:GetPoseParameter("aim_pitch")
	local ppTgt
	local py = self:GetPoseParameter("aim_yaw")
	local pyTgt
	local bPossessed = self:SLV_IsPossesed()
	if(!IsValid(self.entEnemy) && !bPossessed) then
		self:SetCondition(COND_SEE_HATE)
		if(pp == 0 && py == 0) then return end
		ppTgt = 0
		pyTgt = 0
	else
		local posTgt = !bPossessed && self.entEnemy:GetCenter() || self:GetPossessor():GetPossessionEyeTrace().HitPos
		local pos,ang = self:GetBonePosition(self:LookupBone("Bip01 Spine"))
		ang = (posTgt -pos):Angle() -self:GetAngles()
		ppTgt = math.NormalizeAngle(ang.p)
		pyTgt = math.NormalizeAngle(ang.y)
	end
	self:SetPoseParameter("aim_pitch",math.ApproachAngle(pp,ppTgt,1))
	self:SetPoseParameter("aim_yaw",math.ApproachAngle(py,pyTgt,1))
	self:NextThink(CurTime())
	return true
end

function ENT:SelectScheduleHandle(enemy,dist,distPred,disp)
	if(disp == D_HT) then
		if(!self.bInAttack) then
			if(self:CanSee(enemy) && dist <= self.fRangeDistance -50) then
				self:SLVPlayActivity(ACT_RANGE_ATTACK1,true)
				return
			end
		end
		if(dist <= 80) then self:StopMoving(); return end // TODO: Can See?
		self:ChaseEnemy()
	elseif(disp == D_FR) then
		self:Hide()
	end
end
