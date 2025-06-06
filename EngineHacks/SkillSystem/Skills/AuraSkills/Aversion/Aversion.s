.equ AuraSkillCheck, SkillTester+4
.equ AversionID, AuraSkillCheck+4
.thumb
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

@First check if unit is rescuing someone - can jump to bonuses if so
ldr r0, [r4, #0xC]  @Load unit state bitfield
mov r1, #0x10       @Offset of rescuing someone
and r1, r0
cmp r1, #0
bne Bonuses         @If we're rescuing someone, apply the bonuses


@Check if there are adjacent allies
ldr r0, AuraSkillCheck
mov lr, r0
mov r0, r4 @attacker
mov r1, #0
mov r2, #0 @can_trade
mov r3, #1 @range
.short 0xf800
cmp r0, #0
bne Bonuses

@Check if there are adjacent enemies
ldr r0, AuraSkillCheck
mov lr, r0
mov r0, r4 @attacker
mov r1, #0
mov r2, #3 @is_enemy
mov r3, #1 @range
.short 0xf800
cmp r0, #0
beq Done


Bonuses:
mov r0, r4
add     r0,#0x5a    @Move to the attacker's damage.
ldrh    r3,[r0]     @Load the attacker's damage into r3.
add     r3,#2       @add 1.
strh    r3,[r0]     @Store.

mov r0, r4
add     r0,#0x64    @Move to the attacker's hit.
ldrh    r3,[r0]     @Load the attacker's hit into r3.
sub     r3,#5       @add 10.
strh    r3,[r0]     @Store.

mov r0, r4
add     r0,#0x6A    @Move to the attacker's crit.
ldrh    r3,[r0]     @Load the attacker's crit into r3.
sub     r3,#5       @add 5.
strh    r3,[r0]     @Store.

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
