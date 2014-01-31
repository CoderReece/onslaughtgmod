
function EFFECT:Init( data ) 
	self.Pos = data:GetOrigin() + Vector(0,0,40)
	self.emitter = ParticleEmitter( self.Pos )
	self.DieTime = CurTime() + 1
	self.Ent = data:GetEntity()
end

local parts = {"particle/Particle_Glow_02.vtf"}--, "sprites/flamelet1.vtf", "sprites/flamelet2.vtf", "sprites/flamelet3.vtf"}
 
function EFFECT:Think()
	local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos + Vector(0,0,-20))
	for i = 0, 100 do
		local vel = Vector(math.Rand(-100,100),math.Rand(-100,100),i)
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( .2, .5 ) )
		p:SetGravity( Vector( 0, 0, -1 ) )
		p:SetStartSize( math.Rand( 7, 13 ) )
		p:SetEndSize( 25 )
		p:SetColor(Color(50,math.random(80,150),math.random(50,80)))
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
	end
	if self.DieTime < CurTime() then return false end
	return true
end

function EFFECT:Render()
	self.light = self.light or false
	if self.light != true then
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.Pos = self:GetPos()
			dlight.r = 50
			dlight.g = 255
			dlight.b = 50
			dlight.Brightness = 12
			dlight.Size = 300
			dlight.Decay = 500
			dlight.DieTime = CurTime() + 3
			self.light = true
		end
	end
end
