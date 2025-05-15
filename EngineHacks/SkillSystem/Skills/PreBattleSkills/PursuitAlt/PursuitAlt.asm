.thumb
.equ ItemTable, SkillTester+4
.equ PursuitAltID, ItemTable+4

.equ gBattleData, 0x203A4D4

push {r4-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

@has PursuitAlt
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @Attacker data
ldr r1, PursuitAltID
.short 0xf800
cmp r0, #0
beq End

@make sure we're in combat (or combat prep)
ldr r3, =gBattleData
ldrb r3, [r3]
mov r0, #0x4
tst r3, r0
beq End

@store attacker as in r2
mov r3,#0x5E
ldrb r2,[r4,r3]

@store defender as in r3
mov r3,#0x5E
ldrb r3,[r5,r3]

cmp r2, r3
bge givestat
b End

givestat:

sub r1, r2, r3
cmp r1, #4
beq fine
add r2, #1
b givestat

fine:

mov r1, #0x5E
ldrh r0, [r4,r1]
strh r0, [r4,r2]

End:
pop {r4-r7, r15}
.align
.ltorg
SkillTester:
@Poin SkillTester
@POIN ItemTable
@WORD PursuitAltID