AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.LastUse = CurTime()
ENT.Healing = 0
ENT.Model = "models/props_combine/health_charger001.mdl"
ENT.Juice = 100

function ENT:Use(act, cal)
	if !act:IsPlayer() then return end
	if self.LastUse + 0.08 < CurTime() then
	if act:Health() >= act:GetMaxHealth() then return end
		self.Entity:EmitSound("items/medshot4.wav",50,100)
		act:AddHealth(math.Round(act:GetMaxHealth()/GAMEMODE.Config.DISP_RATE))
		if (act:Health() / act:GetMaxHealth()) >= 0.5 then act.Poisoned = false end
		if act:Health() > act:GetMaxHealth() then act:SetHealth(act:GetMaxHealth()) end
		if PHASE == "BATTLE" then
			self.Healing = self.Healing + 1
			if (self.Healing / 50) == math.Round(self.Healing / 50) && self.Healing > 49 then
				if self.Class == 3 then
					self.Owner:Message("+100 [Dispenser healing]", Color(100,255,100,255))
					self.Owner:SetNWInt("money",self.Owner:GetNWInt("money") + 100)
				end
			end
		end
		timer.Simple(2, function() act:Extinguish() end)
		self.LastUse = CurTime()
	end
end

function ENT:Off()

end
