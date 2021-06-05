INCLUDE "hardware.inc"


; Destroys: HL
__VID_GET_MAP_BASE: MACRO
    ld hl, rLCDC
    bit 5, [hl]
    jr nz, .b1\@
    ld \1, $9C00 
    jr .end\@
.b1\@:
    ld \1, $9800
.end\@:
ENDM


SECTION "libVideo", ROMX

; ==========================================
; Turns on the screen
; - Destroys: `ALL`
; ==========================================
bg_init::
    ld a, %10010011 ; enable sprites and bg. Map tile base at $8000
    ldh [rLCDC], a
	
	ld a, %11100100
	ldh [rBGP], a
	ldh [rOBP0],a
	ldh [rOBP1],a
    ret


; ==========================================
; Copies data from `HL` into VRAM
; - Parameters: `BC` = size, `HL` = source pointer, `DE` = destination pointer
; - Destroys: `ALL`
; ==========================================
memcpy_vram::
    call vid_vram_readable
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, memcpy_vram



; ==========================================
; Waits until VRAM can be read. Poor power efficacy
; - Destroys: `AF`
; ==========================================
vid_vram_readable::
    ldh a, [rLCDC]
    bit 7, a
    ret z
.loop:
    ldh a, [rSTAT]
    bit 1, a
    ret z
    jr .loop
    

; ==========================================
; Sets data starting at `HL` to `A`
; - Parameters: `A` = tile number, `B` = number of tiles, `DE` = pointer to tile data
; - Destroys: `AF`, `D`, `BC`, `HL`
; ==========================================
bg_load_tiles::
    push bc
    
    ld h, 0
    ld l, a
    add hl, hl ; x2
    add hl, hl ; x4
    add hl, hl ; x8
    add hl, hl ; x16
    
    ld bc, _VRAM
    add hl, bc
    
    ; HL = VRAM pointer
    
    pop af
    ; A = number of tiles to copy
    ; A *= 16
    ld bc, 4
.loop:
    sla a
    rl b
    dec c
    jr nz, .loop
    
    ld c, a
    ; BC = tiles * 16
    
    ; EX de, hl
    ld a, d
    ld d, h
    ld h, a
    ld a, l
    ld l, e
    ld e, a
    jp  memcpy_vram

    
; ==========================================
; - Parameters: `x`, `y`, `w`, `h`, `tile`
; - Destroys: `ALL`
; ==========================================
BG_FILL: MACRO
    ld hl, HIGH(\2) | LOW(\1)
    ld bc, HIGH(\3) | LOW(\4)
    ld a, \5
    call bg_fill
ENDM

; ==========================================
; Fills a rectangle in VRAM with a tile
; - Parameters: `A` = tile number, `L` = x, `H` = y, `B` = width, `C` = height
; - Destroys: `ALL`
; ==========================================
bg_fill::
    ld e, l ; x
    push hl
;    __VID_GET_MAP_BASE hl
    ld hl, $9800
    ld d, 0
    add hl, de
    
    pop de  ; yx
    ld e, 0 ; y *= 32 @TODO THIS IS *=256 NOT *=32!!!!!!
REPT 3
    srl d
    rr e
ENDR
    
    add hl, de
    
    ld e, b ; save width in `e`
    ld d, a
.loop_y:
    push hl
.loop_x:
    call vid_vram_readable
    ld [hl], d
    inc hl
    dec b
    jr nz, .loop_x
    
    pop hl
    ld b, e
    ld a, d
    
    ld de, 32
    add hl, de
    
    ld d, a
    ld e, b
    dec c
    jr nz, .loop_y
    
    ret
    

; ==========================================
; Moves the background to a pixel cooridnate
; - Parameters: `H` = x, `L` = y
; - Destroys: `A`
; ==========================================
bg_move:
    ld a, h
    ldh [rSCX], a
    ld a, l
    ldh [rSCY], a
    ret