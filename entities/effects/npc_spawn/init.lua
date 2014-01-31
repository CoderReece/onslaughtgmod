local MatBeam = Material( "cable/xbeam" )
local MatGlow = Material( "onslaught/light_glow_onslaught" )

function EFFECT:Init( data )
	local ent = data:GetEntity( )
	if not IsValid( ent ) then
		return
	end
	
	self:SetPos( ent:GetPos( ) )
	local tr = util.TraceLine( {
		start = self:GetPos( ),
		endpos = self:GetPos( ) + Vector( 0, 0, -10000 ),
		filter = data:GetEntity( )
	} )
	self:SetPos( tr.HitPos )
	
	tr = util.TraceLine( {
		start = self:GetPos( ),
		endpos = self:GetPos( ) + Vector( 0, 0, 10000 ),
		filter = data:GetEntity( )
	} )
	
	self.EndPos = tr.HitPos
	self.EndTime = CurTime( ) + 1
	self.BeamWidth = 30
	self.RefractSize = 2
	self.RefractAmount = 0
	
	self:SetRenderBoundsWS( self:GetPos( ), self.EndPos )
	
	local emitter = ParticleEmitter( self:GetPos( ) )

	for i = 1, 15 do
		local particle = emitter:Add( "onslaught/light_glow_onslaught", self:GetPos( ) )
		particle:SetStartSize( 20 )
		particle:SetEndSize( 5 )
		particle:SetDieTime( 1 )
		particle:SetVelocity( VectorRand( ) * 50 )
		particle:SetAirResistance( 2 )
		particle:SetCollide( true )
		particle:SetBounce( .1 )
	end
	
	emitter:Finish( )
end

function EFFECT:Think( )
	if !self.EndTime || !self.BeamWidth || CurTime( ) > self.EndTime then
		return false
	end
	self.BeamWidth = self.BeamWidth - FrameTime( ) * 30
	self.RefractAmount = self.RefractAmount + FrameTime( )
	self.RefractSize = self.RefractSize + ( ( self.EndTime - CurTime( ) ) * FrameTime( ) * 200 )
	
	return true
end

function EFFECT:Render( )
	if !self.EndPos || !self.BeamWidth then return end
	render.SetMaterial( MatBeam )
	render.DrawBeam( self:GetPos( ), self.EndPos, self.BeamWidth, 0, 0, Color( 255, 255, 255, 255 ) )
	
	render.SetMaterial( MatGlow )
	render.DrawSprite( self.EndPos, self.BeamWidth * 20, self.BeamWidth * 20, Color( 255, 255, 255, 255 ) )
	
	render.SetMaterial( MatGlow )
	render.DrawSprite( self:GetPos( ), self.BeamWidth * 10, self.BeamWidth * 10, Color( 255, 255, 255, 255 ) )
end
