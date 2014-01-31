if (SERVER) then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Prop Spawner"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= true
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 0
end

--Swep info and other stuff
SWEP.Author	= "Matt Damon"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Makes props that defend you"
SWEP.Instructions = "Click to spawn a prop."
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_physcannon.mdl"
SWEP.WorldModel	= "models/weapons/w_physics.mdl"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize	= 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"
SWEP.IsRotating = false

function SWEP:SetupDataTables()
	self:DTVar("Entity",0,"ghost")
end
local d = false
function SWEP:PrimaryAttack()
	if SERVER then return end
	if d then return end
	d = true
	RunConsoleCommand("gm_spawn",self.Owner:GetNWString("prop"),(self.PHeight or 0),(self.PPitch or 0),(self.PYaw or 0),(self.PRoll or 0))
	timer.Simple(0.5, function() d = false end)
end

function SWEP:SecondaryAttack()
	return
end


/*---------------------------------------------------------
   Name: SWEP:Think()
   Desc: Called every frame while the weapon is equipped.
---------------------------------------------------------*/
function SWEP:Think()
	if SERVER then return end
	local prop = self.Owner:GetNWString("prop")
	if self.Owner ~= LocalPlayer() or not MODELS[prop] then return end

	if not IsValid(self.Ghost) then
		self.Ghost = ents.CreateClientProp("models/props_lab/blastdoor001c.mdl")
		self.Ghost:SetOwner(self.Owner)
		self.Ghost:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetDTEntity(0,self.Ghost)
	elseif self.Ghost:GetModel() != prop then
		self.Ghost:SetModel(prop)
	end
	
	if not IsValid(self.Ghost) then return end
	//self.Ghost:SetModel(prop)

	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + 500 * self.Owner:GetAimVector()
	tr.filter = {self.Ghost, self.Owner}
	local trace = util.TraceLine(tr)
	
	if trace.Hit then
		local ang = self.Owner:EyeAngles()
		ang.yaw = ang.yaw + 180
		if MODELS[prop].ANG then 
			ang.yaw = ang.yaw + MODELS[prop].ANG.yaw 
		end
		ang.roll = 0
		ang.pitch = 0
		local vec = trace.HitPos
		if MODELS[prop].HEIGHT then
			local maxs = self.Ghost:OBBMaxs()
			local mins = self.Ghost:OBBMins()
			local height = maxs.Z - mins.Z
			vec.Z = vec.Z + (height/2)
		end

		ang.yaw = ang.yaw + (self.PYaw or 0)
		ang.pitch = ang.pitch + (self.PPitch or 0)
		ang.roll = ang.roll + (self.PRoll or 0)
		vec.Z = vec.Z + (self.PHeight or 0)

		self.Ghost:SetPos(vec + trace.HitNormal)
	
		self.Ghost:SetAngles(ang)
		self.Ghost:SetColor(Color(255, 255, 255, 100))
	else
		self.Ghost:SetColor(Color(255, 255, 255, 0))
	end

	local cmd = self.Owner:GetCurrentCommand()
	if cmd:KeyDown(IN_USE) then
		if self.Menu then 
			if self.Menu:IsValid() then
				if self.Menu:IsVisible() then return end
				gui.EnableScreenClicker( true )
				self.Menu:SetVisible(true)
				return
			//else
			//	self.Menu = nil
			end
		end
		gui.EnableScreenClicker( true )

		self.Menu = vgui.Create("onslaught_propedit")
		self.Menu.Target = self
	elseif self.Menu and self.Menu:IsVisible() then
		gui.EnableScreenClicker(false)
		self.Menu:Close()
	end
end