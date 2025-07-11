.thumb
.equ AuraSkillCheck, SkillTester+4
.equ AversionID, AuraSkillCheck+4
push {r4-r7,lr}
@goes in the battle loop.
@r0 is the attacker
@r1 is the defender
mov r4, r0
mov r5, r1

CheckSkill:
@now check for the skill
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker
ldr r1, AversionID
.short 0xf800
cmp r0, #0
beq Done

@First, check if there are allies within 1 tiles
AllyCheck:
ldr r0, AuraSkillCheck
mov lr, r0
mov r0, r4 @attacker
mov r1, #0
mov r2, #0 @can_trade
mov r3, #1 @range
.short 0xf800

@Apply bonuses for each found ally
AllyBonusLoop:
cmp r0, #0
beq EnemyCheck

mov r2, r4
add     r2,#0x5a    @Move to the attacker's damage.
ldrh    r3,[r2]     @Load the attacker's damage into r3.
add     r3,#1       @add 1.
strh    r3,[r2]     @Store.

mov r2, r4
add     r2,#0x60    @Move to the attacker's hit.
ldrh    r3,[r2]     @Load the attacker's hit into r3.
sub     r3,#5       @sub 10.
strh    r3,[r2]     @Store.

mov r2, r4
add     r2,#0x66    @Move to the attacker's crit.
ldrh    r3,[r2]     @Load the attacker's crit into r3.
add     r3,#5       @add 5.
strh    r3,[r2]     @Store.

sub     r0,#1
b       AllyBonusLoop


@Now check if there are enemies within 1 tiles
EnemyCheck:
ldr r0, AuraSkillCheck
mov lr, r0
mov r0, r4 @attacker
mov r1, #0
mov r2, #3 @is_enemy
mov r3, #1 @range
.short 0xf800

@Apply bonuses for each found enemy
EnemyBonusLoop:
cmp r0, #0
beq Done

mov r2, r4
add     r2,#0x5a    @Move to the attacker's damage.
ldrh    r3,[r2]     @Load the attacker's damage into r3.
add     r3,#1       @add 1.
strh    r3,[r2]     @Store.

mov r2, r4
add     r2,#0x60    @Move to the attacker's hit.
ldrh    r3,[r2]     @Load the attacker's hit into r3.
sub     r3,#5       @sub 10.
strh    r3,[r2]     @Store.

mov r2, r4
add     r2,#0x66    @Move to the attacker's crit.
ldrh    r3,[r2]     @Load the attacker's crit into r3.
add     r3,#5       @add 5.
strh    r3,[r2]     @Store.

sub     r0,#1
b       EnemyBonusLoop

Done:
pop {r4-r7}
pop {r0}
bx r0
.align
.ltorg
SkillTester:
@ POIN SkillTester
@ POIN AuraSkillCheck
@ WORD AversionID
