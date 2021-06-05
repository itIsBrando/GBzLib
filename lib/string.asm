SECTION "libSTRING", ROM0
; ==========================================
; Copies string from `HL` to `DE`
; - Parameters: `DE` = destination,`HL` = source
; - Outputs: `none`
; - Destroys: `AF`, `DE`, `HL`
; ==========================================
strcpy::
    ld a, [hl+]
    or a
    ret z
    ld [de], a
    inc de
    jr strcpy
    

; ==========================================
; Gets the length of a string
; - Parameters: `HL` = string pointer
; - Outputs: `BC` = count
; - Destroys: `AF`, `HL`
; ==========================================
strlen::
	ld bc, 0
.loop
    ld a, [hl+]
    or a
    ret z
	inc bc
    jr .loop
    
	
; ==========================================
; Compares two strings
; - Parameters: `DE` = string1,`HL` = string2
; - Outputs: `Z` if strings equal, `C` if string2 > string1
; - Destroys: `ALL`
; ==========================================
strcmp::
    ld a, [de]
    or a
    jr z, .terminator
    cp [hl]
    ret nz
	ld a, [hl+]
	or a
	jr z, .terminator
    inc de
	jr strcmp

.terminator:
    inc a
    ret
    
