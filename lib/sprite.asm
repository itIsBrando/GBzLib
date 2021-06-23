MAX_SPRITE EQU 40

INCLUDE "lib/macros.inc"
INCLUDE "hardware.inc"
    
SECTION "libSprite", ROM0

; ==========================================
; Enables the use of sprites
; - Destroys: `ALL`
; ==========================================
obj_init::
    ld hl, obj_shadow_oam
    ld b, sizeofRAM
    xor a
.loop:
    ld [hl+], a
    dec b
    jr nz, .loop

	; copy over DMA routine
	ld hl, dma_routine
	ld de, _HRAM
	ld b, dma_routine_end - dma_routine
.loop2:
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loop2
    ret


; ==========================================
; Copies sprites from shadow OAM to the real OAM
; - Destroys: `AF`
; ==========================================
obj_blit::
	jp obj_hram


; this routine gets copied to HRAM
dma_routine:
	ld a, HIGH(obj_shadow_oam)
	ldh [$FF46], a
	ld a, MAX_SPRITE
.wait:
	dec a
	jr nz, .wait
	ret
dma_routine_end:

; ==========================================
; Sets the tile number of the sprite
; - Parameters: `A` = sprite number, `D` = tile number
; - Destroys: `BC`, `HL`
; ==========================================
obj_set_tile::
	ld c, a
	sla c
	sla c

	ld b, 0
	ld hl, obj_shadow_oam + 2
	add hl, bc
	
	ld [hl], d
	ret

	
; ==========================================
; Sets the tile number of the sprite
; - Parameters: `A` = sprite number
; - Outputs: `D` = tile number
; - Destroys: `BC`, `HL`
; ==========================================
obj_get_tile::
	ld c, a
	sla c
	sla c

	ld b, 0
	ld hl, obj_shadow_oam + 2
	add hl, bc
	
	ld d, [hl]
	ret

	
; ==========================================
; Sets the flags byte of the sprite
; - Parameters: `A` = sprite number, `D` = flag
; - Destroys: `BC`, `HL`
; ==========================================
obj_set_flag::
	ld b, 0
	ld c, a
	sla c
	sla c
	
	ld hl, obj_shadow_oam + 3
	add hl, bc
	
	ld [hl], d
	ret

	
; ==========================================
; Gets the flags byte of the sprite
; - Parameters: `A` = sprite number
; - Outputs: `D` = flag
; - Destroys: `BC`, `HL`
; ==========================================
obj_get_flag::
	ld b, 0
	ld c, a
	sla c
	sla c
	
	ld hl, obj_shadow_oam + 3
	add hl, bc
	
	ld d, [hl]
	ret

	
; ==========================================
; Moves a sprite to a coordinate
; - Parameters: `A` = sprite number, `L` = y, `H` = x
; - Destroys: `F`, `DE`, `HL`
; ==========================================
obj_set_position::
	ld d, 0
	ld e, a
	sla e
	sla e
	
	push hl
	ld hl, obj_shadow_oam
	add hl, de
	pop de
	
	ld [hl], e
	inc hl
	ld [hl], d
	ret
	
	
; ==========================================
; Gets the position of a sprite
; - Parameters: `A` = sprite number
; - Outputs: `L` = y, `H` = x
; - Destroys: `F`, `DE`, `HL`
; ==========================================
obj_get_position::
	ld d, 0
	ld e, a
	sla e
	sla e
	
	push hl
	ld hl, obj_shadow_oam
	add hl, de
	pop de
	
	ld e, [hl]
	inc hl
	ld h, [hl]
	ld l, e
	ret

    
SECTION "libSpriteRAM", WRAM0

obj_shadow_oam:
    ds 4 * MAX_SPRITE
    
    
endWRAM:   
    
sizeofRAM EQU endWRAM - obj_shadow_oam
PRINTLN "sprite.asm uses {sizeofRAM} bytes of WRAM0."

SECTION "wram", HRAM

obj_hram:
	ds dma_routine_end - dma_routine