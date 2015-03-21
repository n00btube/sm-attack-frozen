# sm-attack-frozen

Make Screw Attack effective on frozen enemies in Super Metroid.

# Warning

This is not fully tested yet.  Bugs may lurk.

Current status:

1. Metroids thaw and bounce off Samus when she screw attacks them.
2. Possessors like Kihunters still leave frozen wings floating in the air.
3. Glitching into frozen enemies *probably* mimics the vanilla game.
4. Space Pirates (“special gfx/hitbox” enemies) **do** die.
5. Samus’ motion is interrupted and her screw attack ends when she collides with an enemy.
This turns Screw Attack into a high-powered pseudo screw attack vs. frozen enemies.

# Description

Unlike the original NES Metroid, in Super Metroid, enemies are normally
invulnerable to Screw Attack while frozen.  It seems kind of ridiculous that
the most powerful weapon in the game can’t handle some puny ice.

It turns out that this happens because the normal collision-detect code
doesn’t even bother to check if Samus is trying to attack the enemies.  This
patch fixes that… but if you want to _land_ on a frozen enemy, you’d better
break out of Screw Attack first.  (My favorite way is tapping Up on the
D-pad.)

Uses a dollop of free space near the top of bank $A0.

# Applying it

    xkas patchfile.asm unheadered.sfc

I’ve decided, as long as nobody ever requests patches for any other assembler,
to always use xkas v06.

# Credits

This would have been immensely difficult without Kejardon’s notes: not only
RAMMap as usual, but Enemy\_Mem.

I’ve discovered Scyzer’s enhanced RAM map and pjboy’s ongoing ROM disassembly,
thanks to a gentle nudge from Grime.

This is yet another idea from [metconst](http://metroidconstruction.com) in
general and MetroidMst in particular (currently, last post in the ASM Wishlist
thread.)

# License

MIT.
