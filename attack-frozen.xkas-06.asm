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
	BEQ platform     ; not frozen: run default code

	LDA $0A6E        ; Samus/enemy collision damage type
	CMP #$0003       ; screw attacking?
	BNE platform     ; nope, run default code

	STZ $0F9E,X      ; unfreeze enemy before processing collision
platform:
	PLX
landing:
	JMP ($AA2F,X)
