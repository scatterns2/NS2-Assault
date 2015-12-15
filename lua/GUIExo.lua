// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIJetpackFuel.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Manages the marine buy/purchase menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIExo' (GUIScript)

GUIExo.kJetpackFuelTexture = "ui/marine_jetpackfuel.dds"
GUIExo.kOnosTexture = "ui/marine_jetpack.dds"

GUIExo.kFont = Fonts.kMicrogrammaDMedExt_Medium

GUIExo.kBgCoords = {0, 0, 32, 144}

GUIExo.kBarCoords = {39, 10, 39 + 18, 10 + 123}

GUIExo.kFuelBlueIntensity = .8

GUIExo.kBackgroundColor = Color(0, 0, 0, 0.5)
GUIExo.kFuelBarOpacity = 0.8

local function UpdateItemsGUIScale(self)
    GUIExo.kBackgroundWidth = GUIScale(32)
    GUIExo.kBackgroundHeight = GUIScale(144)
    GUIExo.kBackgroundOffsetX = GUIScale(70)
    GUIExo.kBackgroundOffsetY = GUIScale(-440)

    GUIExo.kBarWidth = GUIScale(20)
    GUIExo.kBarHeight = GUIScale(123)
end

function GUIExo:Initialize()    
    
    // jetpack fuel display background
    
    UpdateItemsGUIScale(self)
    
	
	
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(GUIExo.kBackgroundWidth, GUIExo.kBackgroundHeight, 0) )
    self.background:SetPosition(Vector(GUIExo.kBackgroundWidth  / 2 + GUIExo.kBackgroundOffsetX, -GUIExo.kBackgroundWidth / 2 + GUIExo.kBackgroundOffsetY, 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Bottom) 
	//self.background:SetRotation(Vector(0, 0, -GUIExo.kBackgroundHeight / 2 + GUIExo.kBackgroundOffsetY) )
    self.background:SetLayer(kGUILayerPlayerHUD)
    self.background:SetTexture(GUIExo.kJetpackFuelTexture)
    self.background:SetTexturePixelCoordinates(unpack(GUIExo.kBgCoords))
    
    // fuel bar
    
    self.fuelBar = GUIManager:CreateGraphicItem()
    self.fuelBar:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.fuelBar:SetPosition( Vector(-GUIExo.kBarWidth / 2, -GUIScale(10), 0))
    self.fuelBar:SetTexture(GUIExo.kJetpackFuelTexture)
    self.fuelBar:SetTexturePixelCoordinates(unpack(GUIExo.kBarCoords))
 
    self.onosImage = GUIManager:CreateGraphicItem()
    self.onosImage:SetSize( Vector(GUIScale(50), GUIScale(50), 0) )
    self.onosImage:SetAnchor(GUIItem.Bottom, GUIItem.Right) 
    self.onosImage:SetTexture(GUIExo.kOnosTexture)
    self.onosImage:SetPosition(Vector(-40, -180, 0))
	
    self.background:AddChild(self.fuelBar)
	self.background:AddChild(self.onosImage)

    self:Update(0)

end

function GUIExo:SetFuel(fraction)

    self.fuelBar:SetSize( Vector(GUIExo.kBarWidth, -GUIExo.kBarHeight * fraction, 0) )
    self.fuelBar:SetColor( Color( 1 -  fraction * GUIExo.kFuelBlueIntensity, 
                                 GUIExo.kFuelBlueIntensity * fraction * 0.8 , 
                                 GUIExo.kFuelBlueIntensity * fraction ,
                                 GUIExo.kFuelBarOpacity) )
	//Print("%s", fraction)
end

function GUIExo:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
    
    self:Uninitialize()
    self:Initialize()
end

function GUIExo:Update(deltaTime)
    
    PROFILE("GUIExo:Update")
	local player = Client.GetLocalPlayer()

    if player and player.GetExoCompletion then
        self:SetFuel(player:GetExoCompletion())
    end
    

end


function GUIExo:Uninitialize()

    GUI.DestroyItem(self.fuelBar)
    GUI.DestroyItem(self.background)

end