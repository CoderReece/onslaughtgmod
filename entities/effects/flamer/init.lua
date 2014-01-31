
function EFFECT:Init( data ) 
 	self.Position = data:GetStart()
	self.Shooter = data:GetEntity()
 	//self.WeaponEnt = self.Player:GetActiveWeapon()
 	self.Attachment = data:GetAttachment() 
 	self.AimVector = data:GetNormal()
	-- Keep the start and end pos - we're going to interpolate between them 
	if self.Shooter:IsPlayer() then
		self.WeaponEnt = self.Shooter:GetActiveWeapon()
		self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment ) 
	elseif self.Shooter:GetClass()=="flameturret" then
		self.StartPos = self.Position
	end
 	self.EndPos = data:GetOrigin() 
 	 
	self.emitter = ParticleEmitter( self.StartPos )
   
 end
 
local aimvec = Vector(0,0,0)
local velocity = Vector(0,0,0)
 
function EFFECT:Think()

   	/*if not IsValid( self.WeaponEnt ) then
		self.emitter:Finish( )
		return false
	end*/
	
	if (self.Shooter:GetClass()=="flameturret") then
		aimvec = self.AimVector
		velocity = Vector(0,0,0)
	elseif (IsValid( self.WeaponEnt ) and self.WeaponEnt:GetClass( ) == "swep_flamethrower" and self.WeaponEnt:GetNWBool("On")) then
		aimvec = self.Shooter:GetAimVector()
		velocity = self.Shooter:GetVelocity()
	end
	
	if (self.Shooter:IsNPC() or self.Shooter:GetClass()=="flameturret") or (IsValid( self.WeaponEnt ) and self.WeaponEnt:GetClass( ) == "swep_flamethrower" and self.WeaponEnt:GetNWBool("On")) then
		for i = 0,20 do
			local p = self.emitter:Add( "particles/flamelet"..math.random( 1, 5 ), (self.StartPos + aimvec * 5))
			local vel = (aimvec * (math.random(500,600) + i) + velocity) + Vector(math.Rand(-25,25), math.Rand(-25,25),math.Rand(-25,25)) --spread it out a bit
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( .5, .8 ) )
			p:SetGravity( Vector( 0, 0, -1 ) )
			p:SetStartSize( math.Rand( 0.5, 1 ) )
			p:SetEndSize( 9 )
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 10 )
			p:SetEndAlpha( 0 )
		end
		for i = 0, 2 do
			local p = self.emitter:Add( "particles/flamelet"..math.random( 1, 5 ), self.StartPos )
			local vel = (aimvec * 450 + velocity)
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( .1, .2 ) )
			p:SetGravity( Vector( 0, 0, -5 ) )
			p:SetStartSize( math.Rand( 0.5, 1 ) )
			p:SetEndSize( 1)
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 10 )
			p:SetEndAlpha( 0 )
			p:SetColor(Color(100,100,255,math.random(150,200)))
		end

	end
	if math.random(1,5) >= 4 then
		local p = self.emitter:Add( "sprites/heatwave", (self.StartPos + aimvec * 5))
		local vel = (aimvec * math.random(440,460) + velocity) + Vector(math.Rand(-25,25), math.Rand(-25,25),math.Rand(-25,25)) --spread it out a bit
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( .5, .8 ) )
		p:SetGravity( Vector( 0, 0, -1 ) )
		p:SetStartSize( math.Rand( 5, 6 ) )
		p:SetEndSize( 10 )
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
	end
	if math.random(1,5) == 1 then
		local p = self.emitter:Add( "particle/smokesprites_000"..math.random(1,6), self.StartPos + aimvec)
		local vel = (((aimvec * 5) + velocity) + Vector(math.Rand(-5,5), math.Rand(-5,5),math.Rand(-5,5))) --spread it out a bit
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( .5, .8 ) )
		p:SetGravity( Vector( 0, 0, 2 ) )
		p:SetStartSize( math.Rand( 0.8, 1.2 ) )
		p:SetEndSize( 3 )
		p:SetStartAlpha( math.Rand( 150, 200 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
		p:SetColor(Color(50,50,50))
	end
	
	return false
 end
 
 function EFFECT:Render()
 
 end
