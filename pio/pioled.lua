-- eLua lightswitch, turn led on and off with button press
-- TODO: translate to button object encapsulating change and debounce

local uartid, invert, ledpin = 0, false
local button1pin, button2pin
local button1, button1old = 0, 0
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
pio.pin.setdir( pio.INPUT, button1pin )
pio.pin.setpull( pio.PULLUP, button1pin )

print( "Hello from eLua on " .. pd.board() )
print "Lightswitch, press button to turn LED on or off"
print "Press any key to end this demo.\n"

-- Delays are not well tuned
while uart.getchar( uartid, 0 ) == "" do
  button1 = pio.pin.getval(button1pin)
  if button1 == 1 then
    tmr.delay( 0, 10000 )
  else
    tmr.delay( 0, 1000 )
    if button1 == pio.pin.getval(button1pin) then
	light = not light
	setled( light )
	while pio.pin.getval(button1pin) == button1 do
	  tmr.delay( 0, 1000 )
	end
    end
  end
end

