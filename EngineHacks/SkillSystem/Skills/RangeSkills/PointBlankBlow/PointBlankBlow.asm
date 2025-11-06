    .thumb
    .equ gChapterData,   0x202BCF0
    .equ gAttackerData,  0x202BE4C
    .set GetWeaponType,   0x8017548
    .set BonusWeaponType, 0x3

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

    ldr     r6, =gAttackerData
    ldr     r6, [r6]
    add     r6, r6, #0x0B
    ldrb    r4, [r6]

    movs    r5, #0xC0    @ load 0xC0 into r5 (allowed in Thumb‑1)
    and     r4, r4, r5   @ r4 &= 0xC0

    cmp    r3, r4
    bne    SkipCheck

    mov    r0, r1
    _blh   GetWeaponType
    cmp    r0, #BonusWeaponType
    bne    SkipCheck

    mov    r0, #1
    mov    r5, sp
    add    r5, r5, #2
    strh   r0, [r5]

SkipCheck:
    ldrh   r0, [sp]
    add    sp, sp, #4
    pop    {pc}

    .ltorg
    .align
