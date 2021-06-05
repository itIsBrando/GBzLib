INCLUDE "hardware.inc"

cart_name: MACRO
    db \1
REPT 15 - strlen(\1)
    db 0
ENDR
ENDM


SECTION "Start", ROM0[$100]
    nop
    jp Start
    
    ds $134 - $104
    

SECTION "Header", ROM0[$134]
    cart_name "Hello"
    db $11  ; CGB Compatibility	
    db "OK" ; License code
    db 0    ; SGB Compatibility
    db 0    ; ROM only
    db 0    ; 32Kb
    db 0    ; No RAM
    db 1    ; International
    db $33  ; License code
    db 0    ; Revision number
    db 0, 0, 0 ; checksum
    
SECTION "Main", ROM0
Start:
    ld sp, stack_end

    xor a
    ldh [rLCDC], a

	xor a
    ld b, 40
    ld de, tileset
    call bg_load_tiles
    
    ld a, 3
    ld [$9800], a
    
;    BG_FILL 2, 2, 3, 3, 4
    ld a, 3
    ld hl, HIGH(0) | LOW(2)
    ld bc, $0303
    call bg_fill
    
    call bg_init

    ld a, IEF_VBLANK
    ldh [rIE], a
	
	xor a
	ld d, 4
	call obj_set_tile
	
	xor a
	ld hl, ((18+8) << 8) | LOW(5+16) ;xy
	call obj_set_position
	
	call obj_blit

    ei
.loop:
    halt
	xor a
	call obj_get_position
	inc h
	call obj_set_position
	
	call obj_blit
    jr .loop


tileset:
    INCBIN "tiles.2bpp"

SECTION "vblank", ROM0[$40]
vblank:
	push af
	push bc
	push de
	push hl
	call obj_blit
	ld hl, $9801
	inc [hl]
	pop af
	pop bc
	pop de
	pop hl
	reti
	
	
SECTION "stack", WRAM0
stack:
	ds 40
stack_end: