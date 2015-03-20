; Copyright 2015 Adam <https://github.com/n00btube>
; MIT license.
; There _could_ be newer versions available on GitHub.

lorom

; main hijack point: intercepts where Samus *has* collided with a platform
; enemy, either because it's a platform, or because it's frozen.
org $A0AA2C
	JMP attack_check

; extra implementation, can be anywhere in bank $A0 free space
; 34 ($22) bytes so far
org $A0FFD0
attack_check:
	PHX
	LDX $18A6        ; reload enemy index

	LDA $0F9E,X      ; get freeze timer
	BEQ platform     ; not frozen: run default code

	LDA $0A6E        ; Samus/enemy collision damage type
	BEQ platform     ; not special: run default code
	CMP #$0004       ; first unknown value (1 + screw attack)
	BCS platform     ; >= unknown? better use the default

	; Samus is speedrunning (1), shinesparking (2), or screw attacking (3)
	; we should try killing the enemy, if it's not dangerous to do so.

	; exclude super-special enemies
	LDA $0F78,X      ; enemy type
	CMP #$DD7F       ; metroid?
	BEQ platform     ; use original freeze behavior

	; frozen, and not excluded for any reason
	STZ $0F9E,X      ; unfreeze enemy before processing collision
platform:
	PLX
	JMP ($AA2F,X)
