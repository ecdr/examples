-- eLua lightswitch, turn led on and off with button press
-- TODO: translate to button object encapsulating change and debounce

-- Button object - handles debounce, provides pressed
--
-- Polling - need to call poll periodically
-- Debounce - after a change it ignores further changes for a few (clockdebounce) calls
--
-- Button is assumed to connect to ground (so 1 on pin indicates no press)
-- Button states reported as 1 for pressed, 0 for not pressed (reverse of pin state)

do
  local UNPRESSED = 1
  local PRESSED = 0
  local clockdebounce = 3

-- Create button object on given PIO pin
  local function new(pin) 
    pio.pin.setdir( pio.INPUT, pin )
    pio.pin.setpull( pio.PULLUP, pin )
    return {pin=pin, state=UNPRESSED, clock=clockdebounce, fpressed = false }
  end

--  local function peek() return not pio.pin.getval( pin ) end

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
      return not but.state
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
local uartid, invert, ledpin = 0, false
local button1pin, button2pin
local light = false

if pd.board() == "EK-LM3S8962" then
  ledpin = pio.PF_0
  button1pin = pio.PE_0
  button2pin = pio.PE_1
elseif pd.board() == "EK-LM4F120" then
  ledpin = pio.PF_1			-- Red is PF 1, Blue is PF 2, Green is PF 3
  button1pin = pio.PF_4
  button2pin = pio.PF_0			-- PF_0 Requires special handling to use
else
  print( "\nError: Unknown board " .. pd.board() .. " !" )
  return
end

function setled( bled )
  if bled and not invert then
    pio.pin.sethigh( ledpin )
  else
    pio.pin.setlow( ledpin )
  end
end
 
pio.pin.setdir( pio.OUTPUT, ledpin )

print( "Hello from eLua on " .. pd.board() )
print "Lightswitch, press button to turn LED on or off"
print "Press any key to end this demo.\n"


local b1 = button.new(button1pin)
while uart.getchar( uartid, 0 ) == "" do
  if button.pressed(b1) then
	light = not light
	setled( light )
  end
  tmr.delay( 0, 10000 )
end	

