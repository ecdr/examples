-- eLua lightswitch, turn led on and off with button press
-- TODO: translate to button object encapsulating change and debounce

-- Button object - handles debounce, provides pressed
--
-- Polling - need to call poll periodically
-- Debounce - after a change it ignores further changes for a few (clockdebounce) calls
--
-- Button is assumed to connect to ground, with no external pullup (so 1 on pin indicates no press)
-- Button states reported as true for pressed, false for not pressed

do
  local UNPRESSED = 1
  local PRESSED = 0
  local clockdebounce = 3

-- Create button on given PIO pin
  local function new(pin) 
    pio.pin.setdir( pio.INPUT, pin )
    pio.pin.setpull( pio.PULLUP, pin )
    return {pin=pin, state=UNPRESSED, clock=clockdebounce, fpressed = false }
  end

--  local function peek(but) return (pio.pin.getval( but.pin ) == PRESSED) end

-- Poll current state of button
  local function poll(but) 
	local curstate
	
	but.clock = but.clock + 1
	if but.clock >= clockdebounce then
	   curstate=pio.pin.getval(but.pin)
	   if not (curstate == but.state) then
		if curstate == PRESSED then
		   but.fpressed = true
		end
		but.state = curstate
		but.clock = 0
	   end
	end
      return (but.state == PRESSED)
  end

-- Report if button pressed since last call to pressed
  local function pressed(but)
    poll(but)
    if but.fpressed then
	but.fpressed = false
	return true
    else
	return false
    end 
  end

  button = {
    new = new,
    peek = peek,
    poll = poll,
    pressed = pressed
  }
end	-- button


-- 
local uartid, invert = 0, false
local ledpin, ledpin2
local button1pin, button2pin
local light = false

if pd.board() == "EK-LM3S8962" then
  ledpin = pio.PF_0
  button1pin = pio.PE_0
  button2pin = pio.PE_1
elseif pd.board() == "EK-LM4F120" then
  ledpin = pio.PF_1			-- Red is PF 1, Blue is PF 2, Green is PF 3
  ledpin2 = pio.PF_2
  button1pin = pio.PF_4
  button2pin = pio.PF_0			-- PF_0 Requires special handling to use
else
  print( "\nError: Unknown board " .. pd.board() .. " !" )
  return
end

-- Turn LED on lpin on if bled true, else turn off
function setled( lpin, bled )
  if bled and not invert then
    pio.pin.sethigh( lpin )
  else
    pio.pin.setlow( lpin )
  end
end
 
pio.pin.setdir( pio.OUTPUT, ledpin )
pio.pin.setdir( pio.OUTPUT, ledpin2 )


print( "Hello from eLua on " .. pd.board() )
print "Lightswitch, press button to turn LED on or off"
print "Second LED is on while button pressed"
print "Press any key to end this demo.\n"


local b1 = button.new(button1pin)
while uart.getchar( uartid, 0 ) == "" do
  if ledpin2 then setled( ledpin2, button.poll(b1)) end
  tmr.delay( 0, 10000 )
  if button.pressed(b1) then
	light = not light
	setled( ledpin, light )
  end
end	

