.thumb
.equ MugPendingDropFlag, 0x03003F48
.equ MugID, SkillTester+4

push {lr}

@ attacker BattleUnit = r4

@ skill check
mov  r0, r4
ldr  r1, MugID
ldr  r3, SkillTester
mov  lr, r3
.short 0xF800
cmp  r0, #0
beq  EndPre

@ always set flag
mov  r0, #1
ldr  r1, =MugPendingDropFlag
strb r0, [r1]

EndPre:
pop {r0}
bx  r0

.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD MugID
