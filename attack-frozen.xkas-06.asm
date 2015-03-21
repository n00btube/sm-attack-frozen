; Copyright 2015 Adam <https://github.com/n00btube>
; MIT license.
; There _could_ be newer versions available on GitHub.

lorom

; main hijack point: intercepts where Samus *has* collided with a platform
; enemy, either because it's a platform, or because it's frozen.
org $A0AA2C
	JMP attack_check

; extra implementation, can be anywhere in bank $A0 free space
org $A0FFD0
attack_check:
	CPX #$0006       ; downward collision type? (*2, it's a word-offset)
	BEQ landing      ; just land on it, kthx

	PHX
	LDX $18A6        ; reload enemy index

	LDA $0F9E,X      ; get freeze timer
	BEQ platform     ; not frozen (platform enemy), normal reaction

	LDA $0A6E        ; Samus/enemy collision damage type
	BEQ platform     ; zero: nothing special
	CMP #$0004       ; speedrun/shinespark/screw attack?
	BCS platform     ; no, some unknown value, do not mess with it

	STZ $0F9E,X      ; unfreeze enemy
	PLX              ; fix the stack
	JMP $AABF        ; platform miss
platform:
	PLX
landing:
	JMP ($AA2F,X)
