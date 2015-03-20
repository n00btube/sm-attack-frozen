--[[
What's this file?  It's a script for BizHawk, to dump out observed enemy
collision routines.  This way, I can play the game and collect a list of all
the routines that MAY need to be modified for Samus to defeat the enemy.

It's also a red herring.  I came up with a new approach that obsoleted this.


BizHawk doesn't pass the bus-address mapping through to Lua, so to read
values, we get to apply some mapping.  For Super Metroid:

  [     Lua    ]   [ SNES ]
     WRAM $ABCD  = $7E:ABCD  (aka mainmemory)
     WRAM $12345 = $7F:2345
  CARTROM $261AE = $84:E1AE  (must use memory object)

$261AE is a "PC File offset", that you can get by hand with Lunar Address.
--]]

--Data to carry cross-frame, polluting the global space as little as possible
local globals
if not SUPERCOLLIDER then
	SUPERCOLLIDER = {
		--things we've already processed
		["gfx_seen"] = {},
		["co_ptrs"] = {},
		--things that are constants:
		["log"] = assert(io.open("supercollider.log", "a")),
		["etbl"] = 0x0F78,  --base of enemy table in RAM (as offset from 7E:0000)
		["stride"] = 0x40,  --size of entry in enemy table
	}
	globals = SUPERCOLLIDER
	--calculated values from other constants:
	globals.etbl_end = globals.etbl + 0x20*globals.stride --end of enemy table, exclusive
	--bosses that flood the log and can't be frozen anyway:
	globals.boring = {
		--IMPORTANT: sorted by ID.  we take advantage of this later!
		0xDDBF, --Crocomire[1]
		0xDDFF, --Crocomire[2]
		0xDE3F, --Draygon[1]
		0xDE7F, --Draygon[2]
		0xDEBF, --Draygon[3]
		0xDEFF, --Draygon[4]
		0xDF3F, --Spore Spawn
		0xDF7F, --???Spore Spawn???
		0xE13F, --Ridley [Ceres]
		0xE17F, --Ridley
		0xE1BF, --Ridley Mode7
		0xE2BF, --Kraid[1]
		0xE2FF, --Kraid[2]
		0xE33F, --Kraid[3]
		0xE37F, --Kraid[4]
		0xE3BF, --Kraid[5]
		0xE3FF, --Kraid[6]
		0xE43F, --Kraid[7]
		0xE47F, --Kraid[8][lol]
		0xE4BF, --Phantoon[1]
		0xE4FF, --Phantoon[2]
		0xE53F, --Phantoon[3]
		0xE57F, --Phantoon[4]
		0xEC3F, --Mother Brain[1]
		0xEC7F, --Mother Brain[2]
		0xECBF, --SM During Fight
		0xECFF, --MB Standing
		0xEEFF, --Torizo
		0xEF3F, --Torizo?
		0xEF7F, --Gold Torizo
		0xEFBF, --Gold Torizo?
		0xF293  --Botwoon
	}
else
	globals = SUPERCOLLIDER
end

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

function is_interesting (id) --> boolean
	local b = globals.boring
	local n = #b
	local i

	if b[n] < id then
		return true --after last boring enemy (quick check)
	end

	--check all boring enemies
	--I'm lazy, so linear search instead of binary search
	for i=1, n do
		if b[i] == id then
			return false --enemy is boring
		elseif b[i] > id then
			return true --current & all later boring enemies are after the enemy
		end
	end

	return true --after last boring enemy; should not get here
end

function rom_addr (bank, pointer) --> CARTROM_offset
	return (bank - 0x80)*0x8000 + bit.band(pointer, 0x7FFF)
end

function collect_ptrs (bank, g, enemy_id, is_frozen) --> nil
	local i, j, gctr, co_ptr, co_ctr, r_ptr, routine
	local gscan, gheader, gstride = g, 2, 8
	local co_header, co_stride = 2, 0x0B
	local frozen_str = is_frozen and 'F' or '-'

	memory.usememorydomain("CARTROM") --set up for reading the ROM
	gctr = memory.read_u8(gscan) --get count of gfx parts for the enemy
	if gctr <= 0 then
		return nil
	end

	gscan = gscan + gheader --advance past header to first gfx record
	for i = 0, gctr do --for each gfx part
		co_ptr = memory.read_u16_le(gscan + 0x06) --load its collision pointer
		if co_ptr >= 0x8000 then
			co_ctr = memory.read_u16_le(rom_addr(bank, co_ptr)) --load number of records for this part
			co_ptr = co_ptr + co_header --advance past header to first collision record
			for j = 0, co_ctr do --for each collision part
				--get routine as BB:PPPP format (for my own convenience)
				r_ptr = memory.read_u16_le(rom_addr(bank, co_ptr + 0x08))
				routine = string.format("%X:%X", bank, r_ptr)

				if r_ptr >= 0x8000 and not globals.co_ptrs[routine] then
					globals.co_ptrs[routine] = true
					--log to persistent file
					globals.log:write(string.format("%X [%s] routine %s via gfxptr %X\n",
						enemy_id, frozen_str, routine, g))
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
	local eram = globals.etbl
	while eram < globals.etbl_end do
		--if this enemy has special graphics/hitbox, catch its collision ptrs
		if is_special(eram) and is_interesting(enemy_id(eram)) then
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
		eram = eram + globals.stride
	end

	emu.frameadvance()
end
