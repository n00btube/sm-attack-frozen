# sm-attack-frozen

Make Screw Attack effective on frozen enemies in Super Metroid.

# Warning

This is an early, buggy version of the patch.

Limitations:

1. Metroids are still platforms when frozen, or else they’d latch onto Samus when she jumps through them.
2. Kihunters die, but their wings remain until thawing.
I assume this is a problem due to them being possessors.
3. Finding a way to clip into a frozen enemy (jump-through-ceiling glitch) probably hurts Samus.
4. Any enemy with a non-standard hitbox doesn’t die; Samus passes through harmlessly.  E.g. Space Pirates.

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

This is yet another idea from [metconst](http://metroidconstruction.com) in
general and MetroidMst in particular (currently, last post in the ASM Wishlist
thread.)

# License

MIT.
