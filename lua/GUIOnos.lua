// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIJetpackFuel.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Manages the marine buy/purchase menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIOnos' (GUIScript)

GUIOnos.kJetpackFuelTexture = "ui/marine_jetpackfuel.dds"
GUIOnos.kOnosTexture = "ui/onos_stomp.dds"

GUIOnos.kFont = Fonts.kMicrogrammaDMedExt_Medium

GUIOnos.kBgCoords = {0, 0, 32, 144}

GUIOnos.kBarCoords = {39, 10, 39 + 18, 10 + 123}

GUIOnos.kFuelBlueIntensity = .8

GUIOnos.kBackgroundColor = Color(0, 0, 0, 0.5)
GUIOnos.kFuelBarOpacity = 0.8

local function UpdateItemsGUIScale(self)
    GUIOnos.kBackgroundWidth = GUIScale(32)
    GUIOnos.kBackgroundHeight = GUIScale(144)
    GUIOnos.kBackgroundOffsetX = GUIScale(0)
    GUIOnos.kBackgroundOffsetY = GUIScale(-440)

    GUIOnos.kBarWidth = GUIScale(20)
    GUIOnos.kBarHeight = GUIScale(123)
end

function GUIOnos:Initialize()    
    
    // jetpack fuel display background
    
    UpdateItemsGUIScale(self)
    
	
	
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(GUIOnos.kBackgroundWidth, GUIOnos.kBackgroundHeight, 0) )
    self.background:SetPosition(Vector(GUIOnos.kBackgroundWidth  / 2 + GUIOnos.kBackgroundOffsetX, -GUIOnos.kBackgroundWidth / 2 + GUIOnos.kBackgroundOffsetY, 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Bottom) 
	//self.background:SetRotation(Vector(0, 0, -GUIOnos.kBackgroundHeight / 2 + GUIOnos.kBackgroundOffsetY) )
    self.background:SetLayer(kGUILayerPlayerHUD)
    self.background:SetTexture(GUIOnos.kJetpackFuelTexture)
    self.background:SetTexturePixelCoordinates(unpack(GUIOnos.kBgCoords))
    
    // fuel bar
    
    self.fuelBar = GUIManager:CreateGraphicItem()
    self.fuelBar:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.fuelBar:SetPosition( Vector(-GUIOnos.kBarWidth / 2, -GUIScale(10), 0))
    self.fuelBar:SetTexture(GUIOnos.kJetpackFuelTexture)
    self.fuelBar:SetTexturePixelCoordinates(unpack(GUIOnos.kBarCoords))
 
    self.onosImage = GUIManager:CreateGraphicItem()
    self.onosImage:SetSize( Vector(GUIScale(50), GUIScale(50), 0) )
    self.onosImage:SetAnchor(GUIItem.Bottom, GUIItem.Right) 
    self.onosImage:SetTexture(GUIOnos.kOnosTexture)
    self.onosImage:SetPosition(Vector(-30, -180, 0))

	//self.onosImage:SetTexturePixelCoordinates(unpack(GUIExo.kBarCoords))
 
    self.background:AddChild(self.fuelBar)
	self.background:AddChild(self.onosImage)

    self:Update(0)

end

function GUIOnos:SetFuel(fraction)

    self.fuelBar:SetSize( Vector(GUIOnos.kBarWidth, -GUIOnos.kBarHeight * fraction, 0) )
    self.fuelBar:SetColor( Color( 1 -  fraction * GUIOnos.kFuelBlueIntensity, 
                                 GUIOnos.kFuelBlueIntensity * fraction * 0.8 , 
                                 GUIOnos.kFuelBlueIntensity * fraction ,
                                 GUIOnos.kFuelBarOpacity) )

end

function GUIOnos:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
    
    self:Uninitialize()
    self:Initialize()
end

function GUIOnos:Update(deltaTime)
    
    PROFILE("GUIOnos:Update")
	local player = Client.GetLocalPlayer()
	
    if player and player.GetOnosCompletion then
        self:SetFuel(0.5)
    end
    

end


function GUIOnos:Uninitialize()

    GUI.DestroyItem(self.fuelBar)
    GUI.DestroyItem(self.background)

end