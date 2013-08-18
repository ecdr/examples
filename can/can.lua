-- CAN example
-- use Loopback

-- Todo: Test fifo (fill it up, empty it partway, see what happens to new message)
--

-- ToDo: make cantest function for other micros with CAN (mbed, STM32, Tiva)


assert(can, "No CAN do")

can.setup(0, 500000) -- Clock 500 kHz


if pd.board() == "EK-LM3S8962" or pd.board() == "EK-LM4F120" then
-- ToDo: Works on 8962
-- ToDo: 9b92 and 9d92 also have CAN, check what memory register they use

-- Caveat programmer -
--  The CAN registers are not like normal memory addresses
--  You have to read them twice (allowing a delay of 5 times through an empty loop in C) to get the actual value
--  Likewise, when writing, you have to wait 5 times through empty loop before the value actually takes effect
--  Found this from the stellarisware code, did not see where covered in documentation


-- control CAN loopback mode (loopon true = make loopback, false = no loopback)
-- silent = true listen only (do not transmit on CAN bus)
-- fixme: Cantest should handle multiple CAN

-- Maybe add cantest to elua module/platforms

function cantest(id, loopon, silent)
-- FixMe: implement silent (should make listen only)
  local canctl, cantst

  if not(id == 0) then
	print("Error: cantest only works with CAN0  Needs fixing.")
  end

  canctl = 0x40040000
  cantst = canctl + 0x014

  cpu.r8(canctl)			-- Pre-read (need to read then delay then read again)

  if loopon or silent then
-- bit 7 set is TEST mode (silent, loopback only work when in test mode)
    cpu.w8(canctl,bit.set(cpu.r8(canctl),7))
  else
    cpu.w8(canctl,bit.clear(cpu.r8(canctl),7))
  end

  cpu.r8(cantst)			    -- Pre-read (need to read then delay then read again)

-- bit 4 set LBACK loopback
  if loopon then
    cpu.w8(cantst, bit.set(cpu.r8(cantst), 4))
  else
    cpu.w8(cantst, bit.clear(cpu.r8(cantst), 4))
  end
-- bit 3 is SILENT
  if silent then
    cpu.w8(cantst, bit.set(cpu.r8(cantst), 3))
  else
    cpu.w8(cantst, bit.clear(cpu.r8(cantst), 3))
  end

end

elseif pd.board() == "MBED" then

else

end

canctl = 0x40040000
cannewdat = canctl+0x120


print("Can loopback")
cantest(0, true, false)

local canid, canidtype, message

-- canidtype is can.ID_STD (11 bit ID) or can.ID_EXT (29 bit ID)
local canid_s = 42
local message_s = "CAN1"
print("Can send")

can.send(0, canid_s, can.ID_STD, message_s )

tmr.delay(0,50)			-- Allow some time for send/receive to happen

print("Can receive")
for i=1, 50 do
--	print(cpu.r16(cannewdat))
	canid, canidtype, message = can.recv( 0 )
	if canid then
		break
	end
end

if not (canid_s == canid) then
	print("canid wrong")
	print(canid)
else
	print("canid OK")
end

if not (canidtype == can.ID_STD) then
	print("canid type wrong")
	print(canidtype)
else
	print("canid type OK")
end

if not (message_s == message) then
	print("message wrong")
	print(message)
else
	print("message OK")
end

-- print(canid)
-- print(canidtype)
-- print(message)

