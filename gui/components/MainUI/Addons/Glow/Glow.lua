require "unicode";
require "table";
require "math";
require "string";

require "lib/lib_InterfaceOptions";
require "lib/lib_Slash";


g_Config = {
	show = false,
	window = {
		width = 680,
		height = 440
	},
};

g_Addons = {};
g_Loaded = {};
g_Save = {};

g_Anim = {
	run = false,
	func = 'fade',
	funcs = {},
	aFreq = 0.01,
	mFreq = 0.1,
	cColor = -1,
	fColor = -1,
	tColor = -1,
	oColor = -1,
	intensity = 3,
	playerId = nil,
	ignited = nil,
	fromFrame = 0,
	toFrame = 0,
	currentFrame = 0,
	firstFrame = false,
	aTransitions = false,
};


g_Anim.funcs['none'] = function()
	g_Anim.cColor = g_Anim.tColor;
	g_Anim.run = false;
end

--experimental and incomplete transition
g_Anim.funcs['fade'] = function()

	if g_Anim.firstFrame then
		g_Anim.fromFrame = 0;
		g_Anim.toFrame = 15;
		g_Anim.currentFrame = 0;
	end
	
	if g_Anim.currentFrame < g_Anim.toFrame then
	
		local fColor = g_Anim.fColor > 0 and g_Anim.fColor or 1;
		local tColor = g_Anim.tColor > 0 and g_Anim.tColor or 1;

		g_Anim.cColor =  fColor + math.floor(((tColor-fColor)/g_Anim.toFrame) * g_Anim.currentFrame);
	else
		g_Anim.cColor = g_Anim.tColor;
		g_Anim.run = false;
	end
	g_Anim.currentFrame = g_Anim.currentFrame + 1;
end



local loaded = false;
local FRAME = Component.GetFrame("WebFrame");

local dragging = 
{
	drag = false,
	last_mx = nil,
	last_my = nil,
}


function SaveWindowLocation()
	local dim = FRAME:GetDims();
	Component.SaveSetting("GLOW_WINDOW_POS", {x=dim.left.offset, y=dim.top.offset});
end

function LoadWindowLocation()
	local loc = Component.GetSetting("GLOW_WINDOW_POS");
	if loc then	
		MoveWindow(loc.x, loc.y);
	end
end

function DragWindow()
	if Component.GetMouseButtonState() and dragging.drag then
		local mp = FRAME:GetCursorPos();
		local dim = FRAME:GetDims();
		local x = dim.left.offset + (mp.x - dragging.last_mx);
		local y = dim.top.offset + (mp.y - dragging.last_my);
		dragging.last_mx = mp.x;
		dragging.last_my = mp.y;
		MoveWindow(x, y);
		callback(DragWindow, nil, 0.01);
	else
		dragging.drag = false;
		SaveWindowLocation();
	end
end

function MoveWindow(x, y)
	FRAME:MoveTo("top: " .. y .."; left: " .. x .. "; bottom: " .. y + g_Config.window.height .."; right: " .. x + g_Config.window.width .. ";", 0);
end

function OnComponentLoad()

	LIB_SLASH.BindCallback({slash_list = "glow", description = "Shows Glow menu.", func = Toggle})
	
	InterfaceOptions.AddMultiArt({
		id = "GLOW_LOGO",
		texture = "Glow";
		height = 394,
		width = 300,
		padding = 100, 
	});
	
	InterfaceOptions.AddMultiArt({
		id = "GLOW_TEXT",
		texture = "Text";
		height = 20,
		width = 512,
		padding =  10,
	});
	
	InterfaceOptions.AddButton({id="GLOW_OPEN", label="Show settings!"});
	
	InterfaceOptions.SetCallbackFunc(function(id, val)
		if id == "GLOW_OPEN" then
			Toggle(true);
		end
	end, "Glow");
	
	LoadWindowLocation();
	SetupFrame();
	g_Save = Component.GetSetting("GLOW_SAVE") or {};
	g_Anim.intensity = Component.GetSetting("GLOW_INTENSITY") or 3;
	g_Anim.aTransitions = Component.GetSetting("GLOW_ATRANSITIONS") or false;
	g_Anim.playerId = Player.GetTargetId();
	callback(Load, nil, 6);
end

function Toggle(bool)
	g_Config.show = bool or not g_Config.show;
	if g_Config.show then
		if not loaded then
			FRAME:LoadUrl("local://../components/MainUI/Addons/Glow/ui/Glow.html");
			loaded = true;
		end;
		Component.SetInputMode("cursor")
		FRAME:Show(true);	
		FRAME:SetDepth(-9999);
	else
		FRAME:Show(false);
		Component.SetInputMode(nil)
	end
end

function OnEscape()
	Toggle(false);
end

function OnPlayerReady()
	
end

function SetupFrame()
	FRAME:SetUrlFilters("*");
	FRAME:AddWebCallback("Close", function() Toggle(false); end);
	FRAME:AddWebCallback("StartDragWindow", function() 
		local mp = FRAME:GetCursorPos();
		dragging.drag = true;
		dragging.last_mx = mp.x;
		dragging.last_my = mp.y;
		DragWindow();
	end);
	FRAME:AddWebCallback("EndDragWindow", function() dragging.drag = false; end);
	FRAME:AddWebCallback("OnPriorityChange", OnPriorityChange);
	FRAME:AddWebCallback("OnColorChange", OnColorChange);
	FRAME:AddWebCallback("OnIntensityChange", OnIntensityChange);
	FRAME:AddWebCallback("OnAnimateTransitionsChange", OnAnimateTransitionsChange);
	FRAME:AddWebCallback("OnGuiReady", OnGuiReady);
end

function OnGuiReady()
	for k, v in PairsByKeys(g_Loaded) do
		AddAction(v.addon, v.action, v.description,  v.defaultColor, v.color);
	end
	local sliderVal = (g_Anim.intensity * 12.5) - 6;
	if sliderVal > 100 then
		sliderVal = 100;
	end
	FRAME:CallWebFunc('SetIntensitySlider', sliderVal);
	FRAME:CallWebFunc('SetAnimateTransitions', g_Anim.aTransitions);
end

function OnIntensityChange(intensity)
	local i = math.floor(intensity / 10);
	if i > 9 then
		i = 9;
	end
	if i < 1 then
		i = 1;
	end
	g_Anim.intensity = i;
	Component.SaveSetting("GLOW_INTENSITY", i);
end

function OnPriorityChange(priorities)
	for k, v in pairs(priorities) do	
		local jKey = v.addon .. '.-.' .. v.action;
		if g_Save[jKey] == nil then
			g_Save[jKey] = {};
		end
		g_Save[jKey].priority = v.priority;
		
		for k, vv in pairs(g_Loaded) do
			if vv.addon == v.addon and vv.action == v.action then
				g_Loaded[k].priority = v.priority;
				break;
			end
		end
	end
	Component.SaveSetting("GLOW_SAVE", g_Save);
end

function OnColorChange(color)
	local jKey = color.addon .. '.-.' .. color.action;
	if g_Save[jKey] == nil then
		g_Save[jKey] = {};
	end
	g_Save[jKey].color = color.color;
	
	for k, v in pairs(g_Loaded) do
		if v.addon == color.addon and v.action == color.action then
			g_Loaded[k].color = color.color;
			break;
		end
	end
	
	Tell(color.addon, {type='colorchange', action=color.action, color=color.color});
	Component.SaveSetting("GLOW_SAVE", g_Save);
end

function OnAnimateTransitionsChange(bool)
	g_Anim.aTransitions = (bool == true);
	Component.SaveSetting("GLOW_ATRANSITIONS", g_Anim.aTransitions);
end

function OnNavigate()
	SetupFrame();
end

function ClearActions()
	FRAME:CallWebFunc('ClearActions');
end

function AddAction(addon, action, description, defaultColor, color)
	FRAME:CallWebFunc('AddAction', addon, action, description, defaultColor, color);
end

function out(_string)
	Component.GenerateEvent("MY_SYSTEM_MESSAGE", {channel="whisper", text=tostring(_string)});
end

function LibGlowAnnounce(e)
	if g_Addons[e.addon] == nil then
		if e.type == 'heartbeat' then
			Tell(e.addon, {type='announce'});
		elseif e.type == 'full' then
			local actions = jsontotable(e.actions);
			g_Addons[e.addon] = actions;
		end
	end
end

function LibGlowIgnite(e)
	for k, v in pairs(g_Loaded) do
		if v.addon == e.addon and v.action == e.action then
			g_Loaded[k].ignite = e.ignite;
			break;
		end
	end
end

function AnimUpdate()
	
	local ignite = nil;
	for k, v in pairs(g_Loaded) do
		if v.ignite then
			if ignite == nil or v.priority < ignite.priority then
				ignite = v;
			end
		end
	end
	
	if g_Anim.ignited ~= ignite then
	
		g_Anim.ignited = ignite;
		
		if g_Anim.aTransitions then
			g_Anim.func = ignite ~= nil and ignite.transition or 'fade';
		else
			g_Anim.func = 'none';
		end
		
		g_Anim.run = true;
		g_Anim.firstFrame = true;
		g_Anim.fColor = g_Anim.oColor;
		
		if ignite == nil then
			g_Anim.tColor = -1;
		else
			g_Anim.tColor = ignite.color;
		end
		
	end
	
	if g_Anim.run then
		Animate();
		callback(AnimUpdate, nil, g_Anim.aFreq);
	else
		g_Anim.oColor = g_Anim.cColor;
		callback(AnimUpdate, nil, g_Anim.mFreq);
	end
	
	if g_Anim.tColor ~= -1 or g_Anim.run then
		Game.HighlightEntity(g_Anim.playerId, (g_Anim.cColor * 10.0) + 10.0 + g_Anim.intensity);
	else
		Game.HighlightEntity(g_Anim.playerId, 0);
	end
	
end

function ReMap( a1, a2, b1, b2, s )
    return b1 + (s-a1)*(b2-b1)/(a2-a1)
end

function Animate()
	if g_Anim.funcs[g_Anim.func] ~= nil then
		g_Anim.funcs[g_Anim.func]();
	else 
		if g_Anim.aTransitions then		
			g_Anim.funcs['fade'](); 
		else
			g_Anim.funcs['none'](); 
		end
	end
	g_Anim.firstFrame = false;
end

function Load()
	local priox = 5;
	for addon, actions in pairs(g_Addons) do
		priox = priox + 1;
		local prioy = priox * 100;		
		for k, v in pairs(actions) do 
			priox = priox + 1;
			local jKey = addon .. '.-.' .. v.action;
			local prio = prioy + v.priority;
			local color = v.color;
			
			if g_Save[jKey] ~= nil then 
				if g_Save[jKey].priority ~= nil then
					prio = g_Save[jKey].priority;
				end
				if g_Save[jKey].color ~= nil then
					color = g_Save[jKey].color;
				end
			end
			
			while g_Loaded[prio] ~= nil do
				prio = prio + 1;
			end
			
			local data = {addon = addon, action = v.action, description = v.description, transition = v.transition, defaultColor = v.color, color = color, priority = prio};
			g_Loaded[tonumber(prio)] = data;
			
			Tell(addon, {type='colorchange', action=v.action, color=color});
			
		end
	end
	AnimUpdate();
end

function Tell(addon, data)
	data.addon = addon;
	Component.GenerateEvent("LIBGLOW", data);
end

PairsByKeys = function(t, f)
	local a = {};
	for n in pairs(t) do table.insert(a, n); end;
	table.sort(a, f);
	local i = 0;
	local iter = function ()
		i = i + 1;
		if a[i] == nil then return nil;
		else return a[i], t[a[i]];
		end
	end
	return iter;
end