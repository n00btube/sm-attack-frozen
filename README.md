# sm-attack-frozen

Make Screw Attack effective on frozen enemies in Super Metroid.

# Warning

This is not fully tested yet.  Bugs may lurk.

## Known issues

1. Possessors like Kihunters still leave frozen bits floating in the air.
2. Touching, but not colliding with, an enemy will unfreeze it.

## Solved issues and style points

1. Special-tilemap enemies like Space Pirates can be destroyed.
2. Metroids can be safely attacked.
They just unfreeze and bounce, at least for screw attack.
I don’t think I can easily test speedboost+Metroid collisions.
3. You can land on frozen enemies, if you’re falling down onto them.
But, you can’t walljump off them.
What good is only being able to kill them by jumping upward into them?
4. Speed-running through frozen enemies kills them, too.

# Description

Unlike the original NES Metroid, in Super Metroid, enemies are normally invulnerable to Screw Attack while frozen.
It seems kind of ridiculous that the most powerful weapon in the game can’t handle some puny ice.

It turns out that this happens because the normal collision-detect code doesn’t even bother to check if Samus is trying to attack the enemies.
This patch fixes that.

Uses a dollop of free space near the top of bank $A0.

# Applying it

    xkas patchfile.asm unheadered.sfc

I’ve decided, as long as nobody ever requests patches for any other assembler, to always use xkas v06.

# Credits

This would have been immensely difficult without Kejardon’s notes: not only RAMMap as usual, but Enemy\_Mem.

I’ve discovered Scyzer’s enhanced RAM map and pjboy’s ongoing ROM disassembly, thanks to a gentle nudge from Grime.

This is yet another idea from [metconst](http://metroidconstruction.com) in general and MetroidMst in particular (currently, last post in the ASM Wishlist thread.)

# License

MIT.
