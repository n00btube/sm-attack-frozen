; Copyright 2015 Adam <https://github.com/n00btube>
; MIT license.
; There _could_ be newer versions available on GitHub.

lorom

; main hijack point: intercepts where Samus *has* collided with a platform
; enemy, either because it's a platform, or because it's frozen.
org $A0AA24
	JMP attack_check ; overwrite an LDA that overwrites the collision overlap

; extra implementation, can be anywhere in bank $A0 free space
org $A0FFD0
attack_check:
	LDA $0A6E        ; Samus/enemy collision damage type
	BEQ platform     ; zero: nothing special
	CMP #$0004       ; speedrun/shinespark/screw attack?
	BCS platform     ; no, some unknown value, do not mess with it

	LDA $0B02
	CMP #$0003       ; downward collision type?
	BEQ landing      ; just land on it, kthx

	LDX $18A6        ; load enemy index
	LDA $0F9E,X      ; get freeze timer
	BEQ platform     ; not frozen (platform enemy), normal reaction

	STZ $0F9E,X      ; unfreeze enemy, normal AI/collision applies later
	JMP $AABF        ; platform miss
platform:
	LDA $0B02        ; collision direction, what we overwrote to hijack
landing:
	JMP $AA27        ; resume after hijack
