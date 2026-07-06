.thumb
.equ MugMemory, 0x03003F48      @ start of Mug memory block
.equ MugFlag,   MugMemory       @ byte 0
.equ MugItem,   MugMemory+2     @ halfword at offset 2
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

@ write flag = 1
mov  r0, #1
ldr  r1, =MugFlag
strb r0, [r1]

@ write item ID (Slim Sword = 0x02) into Mug memory, NOT slot 3
mov  r0, #0x02
ldr  r1, =MugItem
strh r0, [r1]

EndPre:
pop {r0}
bx  r0

.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD MugID
