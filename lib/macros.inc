; Destroys: `A` ONLY IF both paras are `HL` 
ld_indirect: MACRO
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



; Destroys: `A` only if both paras are `HL` 
sto_indirect: MACRO
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




; Creates an enumeration
enum: MACRO
FOR V,_NARG
\1 EQU V-1
SHIFT
ENDR
ENDM


; For use in the header
cart_name: MACRO
__len EQU strlen(\1)
    db \1
IF __len > 15
	FAIL "String length is too long. Must be less than 16, got {d:__len}"
ENDC
REPT 15 - __len
    db 0
ENDR
PURGE __len
ENDM


; push a list of registers
pushl: MACRO
REPT _NARG
	push \1
SHIFT
ENDR
ENDM

; pops a list of registers
popl: MACRO
REPT _NARG
	pop \1
SHIFT
ENDR
ENDM