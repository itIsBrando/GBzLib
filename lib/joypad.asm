INCLUDE "hardware.inc"

SECTION "libJoypad", ROM0
; ==============================================
; fetches D-PAD data into upper word of `A`
; and BTNs into lower word
; - Outputs: `A`=button mask
;	- Destroys: `C`
; ==============================================
btn_scan::
	ld a, P1F_GET_DPAD
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0F
	swap a
	ld c, a
	ld a, P1F_GET_BTN
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0F	
	or c
	ret