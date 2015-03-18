--[[
What's this file?  It's a script for BizHawk, to dump out observed enemy
collision routines.  This way, I can play the game and collect a list of all
the routines that MAY need to be modified for Samus to defeat the enemy.


BizHawk doesn't pass the bus-address mapping through to Lua, so to read
values, we get to apply some mapping.  For Super Metroid:

  [     Lua    ]   [ SNES ]
     WRAM $ABCD  = $7E:ABCD  (aka mainmemory)
     WRAM $12345 = $7F:2345
  CARTROM $261AE = $84:E1AE  (must use memory object)

$261AE is a "PC File offset", that you can get by hand with Lunar Address.
--]]

--Data to carry cross-frame, polluting the global space as little as possible
if not SUPERCOLLIDER_XFRAME then
	SUPERCOLLIDER_XFRAME = {
		--things we've already processed
		["gfx_seen"] = {},
		["co_ptrs"] = {},
		["log"] = assert(io.open("supercollider.log", "a")),
	}
end
local globals = SUPERCOLLIDER_XFRAME

--enemy RAM table and record size
local etbl = 0x0F78
local stride = 0x40
--ends at etbl + {number of entries}*{size per entry}
local etbl_end = etbl + 0x20*stride

function is_special (e) --> boolean
	local xprop = mainmemory.read_u16_le(e + 0x10) --get extended properties
	return bit.band(xprop, 4) > 0                  --check "special hitbox/gfx" bit
end

function enemy_id (e) --> word
	return mainmemory.read_u16_le(e)
end

function enemy_is_frozen (e) --> boolean
	return mainmemory.read_u16_le(e + 0x26) > 0
end

function enemy_bank (e) --> byte
	return mainmemory.read_u8(e + 0x2E)
end

function enemy_gfx (e) --> word_ptr
	return mainmemory.read_u16_le(e + 0x16)
end

function rom_addr (bank, pointer) --> CARTROM_offset
	return (bank - 0x80)*0x8000 + bit.band(pointer, 0x7FFF)
end

function collect_ptrs (bank, g, enemy_id, is_frozen) --> nil
	local i, j, gctr, co_ptr, co_ctr, routine
	local gscan, gheader, gstride = g, 2, 8
	local co_header, co_stride = 2, 0x0B
	local bank_shift = bank * 0x10000
	local frozen_str = is_frozen and 'F' or '-'

	memory.usememorydomain("CARTROM") --set up for reading the ROM
	gctr = memory.read_u8(gscan) --get count of gfx parts for the enemy
	if gctr <= 0 then
		return nil
	end

	gscan = gscan + gheader --advance past header to first gfx record
	for i = 0, gctr do --for each gfx part
		co_ptr = memory.read_u16_le(gscan + 6) --load its collision pointer
		if co_ptr >= 0x8000 then
			co_ctr = memory.read_u16_le(rom_addr(bank, co_ptr)) --load number of records for this part
			co_ptr = co_ptr + co_header --advance past header to first collision record
			for j = 0, co_ctr do --for each collision part
				--get routine as BBPPPP format (for my own convenience)
				routine = bank_shift + memory.read_u16_le(rom_addr(bank, co_ptr + 0x0A))

				if routine >= 0x8000 and not globals.co_ptrs[routine] then
					globals.co_ptrs[routine] = true
					--log to persistent file
					globals.log:write(string.format("%X %s %X through %X\n", enemy_id, frozen_str, routine, g))
				end

				co_ptr = co_ptr + co_stride --advance to next collision record
			end
		end
		gscan = gscan + gstride --advance to next gfx record
	end

	globals.log:flush()
end

while true do
	--scan RAM for active enemies
	local eram = etbl
	while eram < etbl_end do
		--if this enemy has special graphics/hitbox, catch its collision ptrs
		if is_special(eram) then
			--fish through the graphics/hitbox pointer for the collision pointer(s)
			--load enemy bank into bank, gfx/hitbox pointer into gptr
			local bank = enemy_bank(eram)
			local gptr = enemy_gfx(eram)
			local gaddr = rom_addr(bank, gptr)
			--optimization: if we've processed bank+gptr, don't do anything
			--also beware, don't go there if the gfx/hit pointer is 0000
			if gptr >= 0x8000 and not globals.gfx_seen[gaddr] then
				collect_ptrs(bank, gaddr, enemy_id(eram), enemy_is_frozen(eram))
				globals.gfx_seen[gaddr] = true
			end
		end

		--next enemy pointer
		eram = eram + stride
	end

	emu.frameadvance()
end
