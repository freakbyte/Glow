Selected = undefined;
Picker = undefined;

function Select(select)
{
	$('.sortable').children('li').each(function ()
	{
		var elm = $(this);
		if(elm.hasClass('sortable-selected'))
		{
			elm.removeClass('sortable-selected');
		}
		Selected = $(select);
		Selected.addClass('sortable-selected');
	})
	
	if (Selected !== undefined)
	{
		var hue = parseInt(Selected.children('.sortable-color').attr('hue')) / 360;
		$.farbtastic('#colorpicker').setHSL([hue, 1, 0.5]);
	}
}

$(function() {
	
	$('#colorpicker').farbtastic(ColorChange);

	$('.overlay').off();
	
	$( "#master" ).slider({
      value: 30,
      orientation: "horizontal",
      range: "min",
      animate: "fast",
	  slide: function (event, ui) { intensity = ui.value; }
    });
	
	$('.sortable').sortable({
      placeholder: "sortable-placeholder",
		change: function(change)
		{
			var x = 0;
			var helper = undefined;
			var helperX = 0;

			$('.sortable').children('li').each(function ()
			{
				var elm = $(this);
				
				if(elm.hasClass('ui-sortable-helper'))
				{
					helper = elm;
				}
				else if(elm.hasClass('sortable-placeholder'))
				{
					helperX = x;
					x++;
				} 
				else
				{
					var id = elm.children('.sortable-id');
					if (id.text() != '')
					{
						id.html('<a>' + x + '</a>');
					}
					x++;
				}
			});
			helper.children('.sortable-id').html('<a>' + helperX + '</a>');		
		},
		update: function(event, ui)
		{
			var ret = [];

			$('.sortable').children('li').each(function ()
			{
				var elm = $(this);
				var prio = parseInt(elm.children('.sortable-id').text());
				var addon = elm.children('.sortable-addon');
				
				ret.push({
					addon: addon.text(),
					action: addon.attr('action'),
					priority: prio
				});
				
			});
			
			if(Red5)
			{
				Red5.OnPriorityChange(ret);
			}
		}
    });
	
	$( "button" ).button().click(function( event ) {
        event.preventDefault();
		
		if (Selected !== undefined)
		{
			var hue = parseInt(Selected.children('.sortable-color').attr('default-color')) / 360;
			$.farbtastic('#colorpicker').setHSL([hue, 1, 0.5]);
		}
	});
	 
	$("input[type=checkbox]").switchButton({
		on_label: 'ON',
		off_label: 'OFF',
		checked: false,
		width: 40,
		height: 16,
		button_width: 20
	});
	
	$("input[type=checkbox]").change(function() {
		if (Red5)
		{
			Red5.OnAnimateTransitionsChange(this.checked);
		}
    });
	
    $('#scroll').slimScroll({
        height: '306px',
		position: 'left',
		color: '#dd0099',
		railVisible: true,
		alwaysVisible: true
    });
	
	Ready();
});

function ColorChange(color)
{
	
	if(Selected !== undefined)
	{
		var hsl =  $.farbtastic('#colorpicker').hsl;
		if (hsl[0] !== undefined)
		{
			var hue = Math.floor(hsl[0]*360);
			
			Selected.children('.sortable-color').css('background', 'hsl('+hue+', 100%, 50%)');	
			Selected.children('.sortable-color').attr('hue', hue);
			
			if(Red5)
			{
				var addon = Selected.children('.sortable-addon');
				colors[JSON.stringify([addon.text(), addon.attr('action')])] = hue;				
			}

		}
	}
}

colors = {};
oldColors = {};
intensity = 0;
oldIntensity = 0;

setInterval(function() {
	for(var key in colors)
	{
		var color = colors[key];
		if(oldColors[key] != color)
		{
			var o = JSON.parse(key);
			if(Red5)
			{
				Red5.OnColorChange({
					addon: o[0],
					action: o[1],
					color: color
				});
			}
		}
	}
	
	if(intensity != oldIntensity)
	{
		if(Red5)
		{
			oldIntensity = intensity;
			Red5.OnIntensityChange(intensity);
		}			
	}
	
	oldColors =JSON.parse( JSON.stringify( colors ) );
}, 100);

numActions = 0;
Red5Callbacks = 
{
	AddAction: function(addon, action, description, defaultColor, color)
	{
		$('#actions').append('<li class="sortable-default" onmousedown="Select(this);"><div class="sortable-id"><a>'+numActions+'</a></div><div class="sortable-addon" action="'+action+'"><a>'+addon+'</a></div><div class="sortable-divider"></div><div class="sortable-action"><a>'+description+'</a></div><div class="sortable-color" default-color="'+defaultColor+'" hue="'+color+'" style="background: hsl('+color+', 100%, 50%);"></div></li>');
		numActions++; 
		
		if(numActions == 1)
		{
			Select($(".sortable").children());
		}
		
		OhNoes();
	},
	
	ClearActions: function()
	{
		numActions = 0;
		$('#actions').html('');
		OhNoes();
	},
	
	SetIntensitySlider: function(intensity)
	{
		$( "#master" ).slider( "value", intensity );
	},
	
	SetAnimateTransitions: function(bool)
	{
		$("input[type=checkbox]").switchButton("option", "checked", bool);
	},
};

function OhNoes()
{
	if(numActions > 0)
	{
		$('.ohnoes').css('display', 'none');
		$('.ohyesh').css('display', 'block');
	}
	else
	{
		$('.ohnoes').css('display', 'block');
		$('.ohyesh').css('display', 'none');		
	}
}

function HexToRgb(hex) {
    var bigint = parseInt(hex, 16);
    var r = (bigint >> 16) & 255;
    var g = (bigint >> 8) & 255;
    var b = bigint & 255;

    return r + "," + g + "," + b;
}

function RgbTohex(red, green, blue) {
	var rgb = Math.round(blue) | (Math.round(green) << 8) | (Math.round(red) << 16);
	return ('#' + (0x1000000 + rgb).toString(16).slice(1)).toUpperCase();
}
  
function StartDragWindow()
{
	if(Red5)
	{
		Red5.StartDragWindow();
	}
}

function EndDragWindow()
{
	if(Red5)
	{
		Red5.EndDragWindow();
	}
}

function Close()
{
	if(Red5)
	{
		Red5.Close();
	}
}

function Ready()
{
	if(Red5)
	{
		Red5.OnGuiReady();
	}
	OhNoes();
}

