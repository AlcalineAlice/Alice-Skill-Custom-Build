.thumb
.equ ContemptuousID, SkillTester+4
.equ gBattleData, 0x203A4D4

@ r0 = attacker battle struct
@ r1 = defender battle struct

Contemptuous:
    push {r4-r7, lr}
    mov  r4, r0          @ attacker
    mov  r5, r1          @ defender

    @ --- Optional: same battle-type guard as Bushido ---
    ldrb r3, =gBattleData
    ldrb r3, [r3]
    cmp  r3, #4
    beq  End             @ skip in link/multi etc, same as Bushido

    @ --- Skill check (attacker has Contemptuous?) ---
    ldr  r0, SkillTester
    mov  lr, r0
    mov  r0, r4          @ attacker
    ldr  r1, ContemptuousID
    .short 0xF800
    cmp  r0, #0
    beq  End

    @ --- Effective level: attacker -> r6 ---
    ldrb r0, [r4, #0x08]   @ level
    ldr  r1, [r4, #4]      @ class pointer
    mov  r2, #41
    ldrb r1, [r1, r2]      @ class ability byte
    mov  r2, #0x1          @ promotion bit
    and  r1, r2
    cmp  r1, r2
    bne  NoPromA
    add  r0, #0x14         @ +20 if promoted
NoPromA:
    mov  r6, r0

    @ --- Effective level: defender -> r7 ---
    ldrb r1, [r5, #0x08]   @ level
    ldr  r2, [r5, #4]      @ class pointer
    mov  r3, #41
    ldrb r2, [r2, r3]      @ class ability byte
    mov  r3, #0x1          @ promotion bit
    and  r2, r3
    cmp  r2, r3
    bne  NoPromB
    add  r1, #0x14         @ +20 if promoted
NoPromB:
    mov  r7, r1

    @ --- Condition flags ---
    mov  r2, #0            @ r2 = atk bonus (0/2/4)
    mov  r3, #0            @ r3 = triggered flag (0/1)

    @ --- Condition 1: enemy lower level? ---
    cmp  r7, r6
    bge  CheckFemale       @ if enemy >= user, no bonus here
    add  r2, #2
    mov  r3, #1

CheckFemale:
    @ --- Condition 2: enemy is female? ---
    ldr  r0, [r5]          @ char pointer
    ldr  r0, [r0, #0x28]   @ char abilities
    ldr  r1, [r5, #4]      @ class pointer
    ldr  r1, [r1, #0x28]   @ class abilities
    orr  r0, r1
    mov  r1, #0x40
    lsl  r1, #8            @ 0x4000 = IsFemale
    tst  r0, r1
    beq  ApplyIfTriggered
    add  r2, #2            @ +2 damage
    mov  r3, #1            @ mark that at least one condition is true

ApplyIfTriggered:
    cmp  r3, #0
    beq  End               @ neither condition true → no effect

    @ --- Apply -10 Avoid (once, if any condition met) ---
    mov  r0, #0x62         @ BattleAvoid (dodge)
    ldrh r1, [r4, r0]
    sub  r1, #10
    strh r1, [r4, r0]

    @ --- Apply damage bonus (2 or 4) ---
    mov  r0, #0x5A         @ BattleAttack
    ldrh r1, [r4, r0]
    add  r1, r2
    strh r1, [r4, r0]

End:
    pop  {r4-r7, r15}

.align
.ltorg
SkillTester:
@ POIN SkillTester
@ WORD ContemptuousID
