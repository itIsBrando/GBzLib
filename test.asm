INCLUDE "hardware.inc"
INCLUDE "lib/macros.inc"

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
	
    ld a, 3
    ld hl, HIGH(0) | LOW(2)
    ld bc, $0303
    call bg_fill
	
	; coordinate (10, 11)
	; width: 5, height: 3
	ld hl, ((10) << 8) | (11)
	ld de, map
	ld bc, ((5) << 8) | (3)
	call bg_draw_tiles
    
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
	call btn_scan
	
	bit PADB_RIGHT, a
	call nz, moveRight
	
	call obj_blit
    jr .loop

	
moveRight:
	xor a
	call obj_get_position
	inc h
	jp obj_set_position
	
map:
	db 1,2,3,4,5
	db 1,2,3,4,5
	db 2,3,4,5,1

tileset:
    INCBIN "tiles.2bpp"

SECTION "vblank", ROM0[$40]
vblank:
	pushl af, bc, de, hl
	call obj_blit
	ld hl, $9801
	inc [hl]
	popl hl, de, bc, af
	reti
	
	
SECTION "stack", WRAM0
stack:
	ds 40
stack_end: