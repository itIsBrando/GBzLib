SECTION "libMemory", ROMX
; ==========================================
; Copies data from `HL` to `DE`
; - Parameters: `BC` = count, `DE` = destination, `HL` = source
; - Destroys: `ALL`
; ==========================================
memcpy::
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, memcpy
    ret 
    

; ==========================================
; Sets data starting at `HL` to `A`
; - Parameters: `BC` = count, `HL` = source
; - Destroys: `AF`, `D`, `BC`, `HL`
; ==========================================
memset::
    ld d, a
.loop:
    ld [hl], d
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, .loop
    ret