.thumb

@ Tome Harmony: Allies within 2 tiles equipped with Staff/Anima/Light/Dark
@ deal +2 damage in combat.

@ r0 = attacker
@ r1 = defender

.equ AuraSkillCheck, TomeHarmonyData+0
.equ ItemTable,     TomeHarmonyData+4
.equ TomeHarmonyID, TomeHarmonyData+8

.global TomeHarmony
.type TomeHarmony, %function

TomeHarmony:
    push {r4-r7, lr}
    mov  r4, r0        @ attacker
    mov  r5, r1        @ defender

    @ --- Check equipped weapon type: Staff (4), Anima (5), Light (6), Dark (7) ---
    mov  r0, #0x1E
    ldrb r0, [r4, r0]      @ item ID
    cmp  r0, #0
    beq  Done              @ no weapon equipped

    ldr  r1, ItemTable
    mov  r2, #36
    mul  r2, r0
    add  r1, r2
    ldrb r1, [r1, #0x7]    @ weapon type byte

    cmp  r1, #4
    blt  Done
    cmp  r1, #7
    bgt  Done

    @ --- Call AuraSkillCheck ---
    ldr  r0, AuraSkillCheck
    mov  lr, r0
    mov  r0, r4            @ unit to center aura on (attacker)
    ldr  r1, TomeHarmonyID @ skill ID
    mov  r2, #0            @ allegiance: same team
    mov  r3, #2            @ max range = 2 tiles
    .short 0xF800          @ AuraSkillCheck

    cmp  r0, #0
    beq  Done

    @ --- Apply +2 damage ---
    mov  r0, r4
    add  r0, #0x5A
    ldrh r3, [r0]
    add  r3, #2
    strh r3, [r0]

Done:
    pop  {r4-r7}
    pop  {r0}
    bx   r0

.align
.ltorg

TomeHarmonyData:
@ POIN AuraSkillCheck
@ POIN ItemTable
@ WORD TomeHarmonyID
