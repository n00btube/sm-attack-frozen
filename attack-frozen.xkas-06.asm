; Copyright 2015 Adam <https://github.com/n00btube>
; MIT license.
; There _could_ be newer versions available on GitHub.

lorom

; main hijack point.  do not edit.
; this overwrites the freeze timer load during the enemy processing loop.
; it precedes a BNE - if attack_check returns with the Z flag set, then the
; "regular" unfrozen enemy code will run.  (Namely, platform detection.)
org $A0A9DC
	JSR attack_check

; another necessary bit.  do not edit.
; the enemy damage routine promptly exits if a freeze timer is set, so without
; this, Samus harmlessly falls through frozen enemies.
org $A0A119
	LDA #$0000           ; replace actual freeze timer with "not frozen"

org $A0FFE0
attack_check:
	LDA $0F9E,X          ; get freeze timer
	BEQ attack_done      ; not frozen: run default code
	LDA $0F78,X          ; enemy type
	CMP #$DD7F           ; metroid?
	BEQ ice_platform     ; use original freeze behavior
	LDA $0A6E            ; Samus/enemy collision damage type
	CMP #$0003           ; screw attacking: do metroid check
attack_done:
	RTS                  ; return decision
ice_platform:
	LDA $0F9E,X          ; platform if frozen
	RTS
