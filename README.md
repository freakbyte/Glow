# Glow
Glow modifies the default outline shader in Firefall, giving us the option to make the player glow in all the rainbows colors!
Glow also adds a centralized way for the player to change colors and what order the colors should be prioritized in.
Comments and feedback are very welcome right [here](http://forums.firefall.com/community/threads/mod-lib-glow.6337721/).

[![Everything Is AWESOME](http://i.imgur.com/0lRflsS.png)](https://youtu.be/0nLXXfdLrRg "Firefall ~ Glow Mod")

#### Want to use glow in an addon you're developing for Firefall?
```lua
<Event name="LIBGLOW" bind="libglow"/>			    -- First you'll have to register an eventlistener in your addons xml file so libglow can communicate with the glow mod.

require './lib_glow';                               -- require the lib from wherever you placed it, you can find this file in /gui/lib

Glow = LibGlow({					                -- LibGlow should be initialized like this, outside of any functions.
    addon = 'Your addons name',				        -- Your addons name, this will show up in the glow menu and be used as a reference to your addon. 
    actions = {						                -- the actions table contains all your different actions, the way you order them here will be used as a default priority list.
        {
            action = 'health',				        -- action, is not displayed anywhere to the end-user but is used as a key to that specific action, must be unique.
            color = 110,				            -- color, is the default color you want if the glow mod is installed, this variable can be either a hue color 0 - 360, a hex value '#FF00CC', or a table containing r, g and b values normalized from 0 to 1.
            fallbackColor = 9,				        -- fallbackColor, this is the shader color we fall back to if the mod is not installed. must be a number between 1 and 9.
            transition = 'fade',			        -- transition, what animation should be used while switching to this color? right now there's only 'fade' and 'none'. fade is the default animation right now. The user can decide to turn these on/off.
            description = 'Health pack equipped'	-- description, the description will be show in the glow settings.
        },
        {
            action = 'ammo',
            color = '#AABBCC',				        -- while you can set any hex color you want here, we don't have full rgb and your color will be converted to the closest hue possible.
            fallbackColor = 7,--
            transition = 'fade',
            description = 'Ammo pack equipped'
        },
        {
            action = 'sonic',
            color = {					            -- you can pass a normalized (0 to 1 value) rgb table here if you want to, but we don't have full rgb and your color will be converted to the closest hue possible.
                r = 0.3,				            -- 30% reds, the lowest color value will be ignored when converting to hue.
                g = 0.5,			            	-- 50% greens
                b = 1				            	-- 100% blues
            },
            fallbackColor = 2,
            transition = 'fade',
            description = 'Sonic detonator equipped'
        }
    },
    onColorChange = function(action, color)	    	-- onColorChange, this function gets called if the user changes any of your colors.
                                                    -- color contains 3 functions, Hex, RGB and Hue, you can call each of these depending on your needs.
        local hex = color.Hex();			        -- calling color.Hex() will give you the hex representation of the color.
        local rgb = color.RGB();			        -- calling color.RGB() will give you the table containing r, g, and b. Each of these values represents a color channel and are normalized from 0 to 1.
        local hue = color.Hue();		        	-- calling color.Hue() will give you the hue representation of the color. 0 - 360 degrees.

        if action == 'health' then						  
        elseif action == 'ammo' then
        elseif action == 'sonic' then
        end

    end,
    onReady = function(modInstalled)		   	    -- onReady, this function gets called once everything is ready.
    end							                    -- the modInstalled argument (boolean) tells you id the glow mod is installed or not.
});


Glow('health', true);					            -- will light up the player with the action 'health's color. 
Glow('health', false);					            -- will disable the action 'health's glow.

Glow('health', true);					            -- 'health' will glow. 
Glow('ammo', true);					                -- will be ignored until 'health' is false, since its longer down on the default priority list.
Glow('health', false);					            -- 'health' will stop glowing and 'ammo' start glowing.
Glow('ammo', false);					            -- 'ammo' will stop glowing.		
```
