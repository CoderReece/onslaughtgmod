
if SERVER then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight = 1
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false
end

if CLIENT then
	SWEP.PrintName = "FlameThrower"
	SWEP.DrawCrosshair = true
	SWEP.DrawAmmo = true
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false
	SWEP.Slot = 3
end

SWEP.ViewModel	= "models/weapons/v_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.LastBall = CurTime()

SWEP.Sound = Sound("fire_large")
SWEP.StopSoond = Sound("k_lab.eyescanner_click")
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "smg" )
	end
end

function SWEP:Holster( )
	self:SetNWBool( "On", false )
	return true
end

function SWEP:Think( )
	if self.Owner:KeyPressed( IN_ATTACK ) then
		if ( !self:CanPrimaryAttack() ) then return end
		self:SetNWBool( "On", true )
		self.Weapon:EmitSound(self.Sound)
		local speed = CLASSES[self.Owner:GetNetworkedInt("class")].SPEED / 1.5
		GAMEMODE:SetPlayerSpeed(self.Owner, speed, speed)
	end
	if self.Owner:KeyReleased( IN_ATTACK ) then
		self:SetNWBool( "On", false )
		self.Weapon:StopSound(self.Sound)
		self.Weapon:EmitSound(self.StopSoond)
		local speed = CLASSES[self.Owner:GetNetworkedInt("class")].SPEED
		GAMEMODE:SetPlayerSpeed(self.Owner, speed, speed)
	end
end

function SWEP:PrimaryAttack( )
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .02 )
	local tr = util.GetPlayerTrace( self.Owner )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	local hitpos = trace.HitPos
	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetStart( self.Owner:GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self.Owner )
	util.Effect( "flamer", effectdata )
	if SERVER then
		if self.LastBall + 0.25 <= CurTime() then
			self:TakePrimaryAmmo(1)	
			local dmg = 6
			for k,v in pairs(ents.FindInCone( self.Owner:GetShootPos(), self.Owner:GetAimVector(), 400, 10 )) do
				if v:IsNPC() && v:GetClass() != "npc_turret_floor" then
					if !v:IsOnFire() then
						v:TakeDamage(dmg,self.Owner,self.Owner)
						dmg = dmg / 1.5
					end
					if v:Health() / v:GetMaxHealth() < .20 then
						v.Igniter = self:GetOwner()
						v:Ignite(10,40)
					end
				end
			end
			self.LastBall = CurTime()
		end
	end
end

function SWEP:SecondaryAttack( )

end
