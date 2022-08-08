
--
-- Bored HUD 2, by Fesiug
-- github.com/Fesiug/bored-hud-2
-- Workshop pending
-- Started on 2022-08-08
--
-- Styling:
-- Use "!" instead of "not"
-- Use "and" instead of "&&"
-- Tab indent, not spaces
-- ( fluff everything )
--

-- Setup convars
CreateClientConVar("bh2", 1, true, false, "Enable the HUD", 0, 1)
CreateClientConVar("bh2_scale", 1, true, false, "Scale of the HUD and related")

CreateClientConVar("bh2_dead_x", 0, true, false, "Deadzone X")
CreateClientConVar("bh2_dead_y", 0, true, false, "Deadzone Y")

CreateClientConVar("bh2_health", 1, true, false, "Enable the Health", 0, 1)
CreateClientConVar("bh2_health_pos_x", 0, true, false, "Health X")
CreateClientConVar("bh2_health_pos_y", 0, true, false, "Health Y")

CreateClientConVar("bh2_ammo", 1, true, false, "Enable the Ammo", 0, 1)
CreateClientConVar("bh2_ammo_pos_x", 0, true, false, "Ammo X")
CreateClientConVar("bh2_ammo_pos_y", 0, true, false, "Ammo Y")

local BH2 = {}

BH2.Palette = {
	["main"] = { 200, 200, 200, 255 },
	["shadow"] = { 0, 0, 0, 100 },
}

-- Prerequisites
do
	local COLOR_HELP	= Color(100, 0, 0, 60)
	local CORN_8	= surface.GetTextureID( "gui/corner8" )
	local CORN_16	= surface.GetTextureID( "gui/corner16" )
	local CORN_32	= surface.GetTextureID( "gui/corner32" )
	local CORN_64	= surface.GetTextureID( "gui/corner64" )
	local CORN_512	= surface.GetTextureID( "gui/corner512" )
	local IORN_8	= surface.GetTextureID( "gui/bh2_invert/corner8" )
	local IORN_16	= surface.GetTextureID( "gui/bh2_invert/corner16" )
	local IORN_32	= surface.GetTextureID( "gui/bh2_invert/corner32" )
	local IORN_64	= surface.GetTextureID( "gui/bh2_invert/corner64" )
	local IORN_512	= surface.GetTextureID( "gui/bh2_invert/corner512" )
	BH2.GetPallete = function(name, alpha)
		assert( name, "GetPallete: No input!" )
		alpha = alpha or 1
		if IsColor(name) then
			return { name.r, name.g, name.b, name.a * alpha }
		end

		name = BH2.Palette[ name ]
		assert( name, "GetPallete: Palette doesn't exist!" )

		return { name[1], name[2], name[3], name[4] * alpha }
	end
	BH2.RectangleBordered = function(feed)
		local x, y = feed.pos_x, feed.pos_y
		local w, h = feed.size_w, feed.size_h
		local bo = feed.border

		-- Help
		--surface.SetDrawColor(COLOR_HELP)
		--surface.DrawRect(x, y, w, h)

		-- Get pallete info
		surface.SetDrawColor( BH2.GetPallete(feed.color, feed.alpha) )

		-- Start drawing a outlined rectangle

		-- Top bar
		surface.DrawRect( x + bo, y, w - ( bo * 2 ), bo )
		-- Bottom bar
		surface.DrawRect( x + bo, y + h - bo, w - ( bo * 2 ), bo )

		-- Left wall
		surface.DrawRect( x, y + bo, bo, h - ( bo * 2 ) )
		-- Right wall
		surface.DrawRect( x + w - bo, y + bo, bo, h - ( bo * 2 ) )

		-- Corners
		do
			local tex = CORN_8
			if ( bo > 8 ) then tex = CORN_16 end
			if ( bo > 16 ) then tex = CORN_32 end
			if ( bo > 32 ) then tex = CORN_64 end
			if ( bo > 64 ) then tex = CORN_512 end
			surface.SetTexture( tex )
		end

		-- Top left
		surface.DrawTexturedRectUV( x, y, bo, bo, 0, 0, 1, 1 )
		-- Top right
		surface.DrawTexturedRectUV( x + w - bo, y, bo, bo, 1, 0, 0, 1 )
		-- Bottom left
		surface.DrawTexturedRectUV( x, y + h - bo, bo, bo, 0, 1, 1, 0 )
		-- Bottom right
		surface.DrawTexturedRectUV( x + w - bo, y + h - bo, bo, bo, 1, 1, 0, 0 )

		-- Corner set 2, insides
		do
			local tex = IORN_8
			if ( bo > 8 ) then tex = IORN_16 end
			if ( bo > 16 ) then tex = IORN_32 end
			if ( bo > 32 ) then tex = IORN_64 end
			if ( bo > 64 ) then tex = IORN_512 end
			surface.SetTexture( tex )
		end
		-- Top left
		surface.DrawTexturedRectUV( x + bo, y + bo, bo, bo, 0, 0, 1, 1 )
		-- Top right
		surface.DrawTexturedRectUV( x + w - ( bo * 2 ), y + bo, bo, bo, 1, 0, 0, 1 )
		-- Bottom left
		surface.DrawTexturedRectUV( x + bo, y + h - ( bo * 2 ), bo, bo, 0, 1, 1, 0 )
		-- Bottom right
		surface.DrawTexturedRectUV( x + w - ( bo * 2 ), y + h - ( bo * 2 ), bo, bo, 1, 1, 0, 0 )

	end
end

-- Fonts
do
	local sizes = {
		6,
		8,
		10,
		12,
		14,
		16,
	}
end

-- HUDPaint, the big fish!
do
	hook.Add("HUDPaint", "BH2_HUDPaint", function()
		if GetConVar("bh2"):GetBool() then
			local test = {
				pos_x = 200,
				pos_y = 200,
				size_w = 300,
				size_h = 100,
				border = 8,
				color = "main"
			}
			BH2.RectangleBordered(test)
		end
	end)
end

-- Don't draw the HL2 HUD
do
	local hide = {
		["CHudHealth"] = true,
		["CHudBattery"] = true,
		["CHudDamageIndicator"] = true,
		["CHudAmmo"] = true,
		["CHudSecondaryAmmo"] = true,
	}

	hook.Add("HUDShouldDraw", "BH2_HUDShouldDraw", function(name)
		if GetConVar("bh2"):GetBool() and hide[name] then return false end
	end)
end