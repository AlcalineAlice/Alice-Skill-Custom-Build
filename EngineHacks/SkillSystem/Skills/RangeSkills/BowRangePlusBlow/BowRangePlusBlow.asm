    .thumb
    .equ gChapterData,      0x202BCF0
    .equ gAttackerData,     0x202BE4C
    .set GetWeaponType,     0x8017548
    .set BonusWeaponType,   0x3
    .set MaxRangeBonus,     0x1

    .macro _blh to, reg=r3
        ldr   \reg, =\to
        mov   lr, \reg
        .short 0xF800
    .endm

    push   {lr}
    sub    sp, sp, #4
    str    r2, [sp]

    ldr    r3, =gChapterData
    add    r3, r3, #0x0F
    ldrb   r3, [r3]

	ldrb    r4, [r0, #0x0B]    @ r4 = raw_flag
    movs    r5, #0xC0         @ 0b11000000
    and     r4, r4, r5   
	
    movs   r5, #0xC0
    and    r4, r4, r5

    cmp    r3, r4
    bne    End

    mov    r0, r1
    _blh   GetWeaponType
    cmp    r0, #BonusWeaponType
    bne    End

    mov    r5, sp
    ldrh   r0, [r5]
    add    r0, r0, #MaxRangeBonus
    cmp    r0, #0xF
    bls    NotOverMax
    movs   r0, #0xF
NotOverMax:
    strh   r0, [r5]

End:
    ldr    r0, [sp]
    add    sp, #0x4
    pop    {r3}
	bx r3

    .ltorg
    .align
