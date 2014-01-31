if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Select SWEP"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 1
end

SWEP.ViewModel	= "models/weapons/v_toolgun.mdl"
SWEP.WorldModel	= "models/weapons/w_toolgun.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

function SWEP:Initialize( )

end

function SWEP:Reload( )
	if SERVER then
		GAMEMODE:DeselectAll( )
		self.FirstPoint = nil
	end
end

function SWEP:PrimaryAttack( )
	if CLIENT then return end

	local tr = self.Owner:GetEyeTrace( )
	if not tr.Hit or tr.HitWorld then return end
	if not IsValid( tr.Entity ) then return end

	local e = tr.Entity

	if e:GetClass( ) == "sent_prop" || e:GetClass() == "sent_ladder" then
		if table.HasValue( GAMEMODE.SaveProps, e ) then
			GAMEMODE:DeselectProp( e )
		else
			GAMEMODE:SelectProp( e )
		end
	end

	self:SetNextPrimaryFire( CurTime( ) + .5 )
end

function SWEP:SecondaryAttack( )
	if CLIENT then return end

	if not self.FirstPoint then
		self.FirstPoint = self.Owner:GetEyeTrace( ).HitPos
	else
		local es = ents.FindInBox( self.FirstPoint, self.Owner:GetEyeTrace( ).HitPos )
		for k,v in pairs( es ) do
			if v:GetClass( ) == "sent_prop" || v:GetClass() == "sent_ladder" then
				GAMEMODE:SelectProp( v )
			end
		end
		self.FirstPoint = nil
	end
end
