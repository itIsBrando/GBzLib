SECTION "libSTRING", ROM0
; ==========================================
; Copies string from `HL` to `DE`
; - Parameters: `DE` = destination,`HL` = source
; - Outputs: `none`
; - Destroys: `AF`, `DE`, `HL`
; ==========================================
strcpy:
    ld a, [hl+]
    or a
    ret z
    ld [de], a
    inc de
    jr strcpy
    

; ==========================================
; Compares two strings
; - Parameters: `DE` = string1,`HL` = string2
; - Outputs: `Z` if strings equal 
; - Destroys: `ALL`
; ==========================================
strcmp:
    ld a, [de]
    or a
    jr nz, .terminator
    cp [hl]
    ret nz
    inc hl
    inc de

.terminator:
    cp [hl]
    ret
    
