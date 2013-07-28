-- CAN example
-- use Loopback
-- ToDo: make cantest function for other micros with CAN (mbed, STM32, Tiva)


can.setup(0, 500000) -- Clock 500 kHz

if pd.board() == "EK-LM3S8962" or pd.board() == "EK-LM4F120" then
-- ToDo: Test on LM3S8962 (uses same memory registers and bits as LM4F)
-- ToDo: 9b92 and 9d92 also have CAN, check what memory register they use

-- control CAN loopback mode (loopon true = make loopback, false = no loopback)
-- silent = true listen only (do not transmit on CAN bus)
-- fixme: Cantest should take CAN ID as argument (handle multiple CAN)

-- Maybe add cantest to elua module/platforms

function cantest(id, loopon, silent)
-- FixMe: implement silent (should make listen only)
  local canctl, cantst

  if not(id == 0) then
	print("Error: cantest only works with CAN0  Needs fixing.")
  end

  canctl = 0x40040000
  cantst = canctl + 0x014

  if loopon or silent then
-- bit 7 set is TEST mode (silent, loopback only work when in test mode)
    cpu.w8(canctl,bit.set(cpu.r8(canctl),7))
  else
    cpu.w8(canctl,bit.clear(cpu.r8(canctl),7))
  end
    
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

-- Loopback
cantest(0, true, false)

local canid, canidtype, message

-- canidtype is can.ID_STD (11 bit ID) or can.ID_EXT (29 bit ID)
local canid_s = 42
local message_s = "CAN1"
can.send(0, canid_s, can.ID_STD, message_s )
canid, canidtype, message = can.recv( 0 )

if not (canid_s == canid) then
	print("canid wrong" .. canid)
else
	print("canid OK")
end

if not (canidtype == can.ID_STD) then
	print("canid type wrong" .. canidtype)
else
	print("canid type OK")
end

if not (message_s == message) then
	print("message wrong" .. message)
else
	print("message OK")
end

-- print(canid)
-- print(canidtype)
-- print(message)
