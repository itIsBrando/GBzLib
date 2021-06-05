MAX_SPRITE EQU 40

;LD_IND hl, [hl]
; Destroys: `A` ONLY IF both paras are `HL` 
LD_IND: MACRO
IF strcmp(strlwr("\2"), "[hl]") != 0
    FAIL "Indirection only allowed with HL"
ENDC
IF strlen("\1") != 2
	PRINTLN \1
	PRINTLN strlen("\1")
	FAIL "First parameter register must be 16-bit"
ENDC
__rp1 EQUS strsub("\1", 1, 1) ; high
__rp2 EQUS strsub("\1", 2, 1) ; low

; optimize if register != HL
IF strcmp(strlwr("\1"), "hl") != 0
	ld __rp2, [hl]
	inc hl
	ld __rp1, [hl]
	dec hl
ELSE
	ld a, [hl+]
	ld __rp1, [hl]
	ld __rp2, a
ENDC
	PURGE __rp1, __rp2
ENDM


;STO_IND [hl], xx
; Destroys: `A` only if both paras are `HL` 
STO_IND: MACRO
IF strcmp("\1", "[hl]") != 0
    FAIL "Indirection only allowed with HL"
ENDC
IF strlen("\2") != 2
	FAIL "First parameter register must be 16-bit"
ENDC
__rp1 EQUS strsub("\2", 1, 1) ; high
__rp2 EQUS strsub("\2", 2, 1) ; low

IF strcmp(strlwr("\2"), "hl") != 0
	ld [hl], __rp2
	inc hl
	ld [hl], __rp1
	dec hl
ELSE
	FAIL "What the heck dude"
ENDC
	PURGE __rp1, __rp2
ENDM

    
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
    ret


; ==========================================
; Copies sprites from shadow OAM to the real OAM
; - Destroys: `AF`, `B`, `DE`, `HL`
; ==========================================
obj_blit::
	ld hl, obj_shadow_oam
	ld de, $FE00
	ld b, MAX_SPRITE * 4
.loop:
	call vid_vram_readable
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	ret


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
obj_set_flag::
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