Script.Load("lua/Hive.lua")


function CragHive:OnInitialized()

    InitMixin(self, InfestationMixin)
    
    CommandStructure.OnInitialized(self)

	self.health = kCragHiveHealth
	self.armor = kCragHiveArmor

	Print("%s", self.health)
	Print("%s", self.armor)

    -- Pre-compute list of egg spawn points.
    if Server then
        
        self:SetModel(Hive.kModelName, kAnimationGraph)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)

        local evochamber = CreateEntity( "evolutionchamber", self:GetOrigin(), self:GetTeamNumber())
        evochamber:SetOwner( self )
        self.evochamberid = evochamber:GetId()
        
    elseif Client then
    
        -- Create glowy "plankton" swimming around hive, along with mist and glow
        local coords = self:GetCoords()
        self:AttachEffect(Hive.kSpecksEffect, coords)
        --self:AttachEffect(Hive.kGlowEffect, coords, Cinematic.Repeat_Loop)
        
        -- For mist creation
        self:SetUpdates(true)
        
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self.glowIntensity = ConditionalValue(self:GetIsBuilt(), 1, 0)
        
    end
    
    InitMixin(self, IdleMixin)
    
end


function CragHive:GetMatureMaxHealth()
    return kMatureCragHiveHealth
end 

function CragHive:GetMatureMaxArmor()
    return kMatureCragHiveArmor
end