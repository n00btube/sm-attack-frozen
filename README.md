# sm-attack-frozen

Make Screw Attack effective on frozen enemies in Super Metroid.

# Description

Unlike the original NES Metroid, in Super Metroid, enemies are normally invulnerable to Screw Attack while frozen.
It seems kind of ridiculous that the most powerful weapon in the game can’t handle some puny ice.

It turns out that this happens because the normal collision-detect code doesn’t even bother to check if Samus is trying to attack the enemies.
This patch fixes that.

Uses a dollop of free space near the top of bank $A0.
It’s a pretty full bank, so I worked hard to keep it small.

## Gameplay

Jumping into (most) frozen enemies with Screw Attack kills them.
If they’re immune to Screw Attack and not a platform-type enemy, they’ll be thawed instead.

Samus can still land on any frozen enemy from above, but it does ruin her ability to walljump off of them.

## Issues

1. Possessors like Kihunters still leave frozen bits floating in the air.
I haven’t tested any other possesors because I don’t have a list of them.
2. Some enemies can be collided with, without actually causing damage.
Like screw-attack resistant enemies, they just thaw instantly.
3. Landing on a metroid will register a bounce in the AI.
You can’t refreeze it until it thaws and bounces.
But, you can still destroy it before it thaws.

All that said, I think this may be as good as it gets.
Doing much more to fix the glitches would be a truly epic adventure through all of the AI code.
(I think.)

The game actually does collision detection twice.
The first time, platform detection runs, and always uses the basic enemy hitbox.
Later, if the enemy is neither a platform nor frozen, the enemy can specify a series of hitboxes with a custom routine (per hitbox) to run on collision.
But by then, this patch has thawed the enemy based on their _basic_ hitbox, so if the AI code decides “not a hit,” the enemy has thawed without being hit.
The patch uses that method because otherwise, enemies like the Space Pirates detect that they’re frozen and avoid registering any damage.
Chasing down all the pointers they _could_ set for collision, to nullify each freeze detection, is a huge job.

# Applying it

    xkas patchfile.asm unheadered.sfc

I’ve decided, as long as nobody ever requests patches for any other assembler, to always use xkas v06.

# Credits

This would have been immensely difficult without Kejardon’s notes: not only RAMMap as usual, but Enemy\_Mem.

I’ve discovered Scyzer’s enhanced RAM map and pjboy’s ongoing ROM disassembly, thanks to a gentle nudge from Grime.

This is yet another idea from [metconst](http://metroidconstruction.com) in general and MetroidMst in particular (currently, last post in the ASM Wishlist thread.)

# License

MIT.
