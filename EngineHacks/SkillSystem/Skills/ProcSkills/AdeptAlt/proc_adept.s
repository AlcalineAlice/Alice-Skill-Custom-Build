.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.equ AdeptAltID, SkillTester+4
.equ BattleGetFollowupOrder, 0x802af90

@ r0 is attacker, r1 is defender, r2 is current buffer, r3 is battle data
push {r4-r7,lr}
mov r4, r0 @attacker
mov r5, r1 @defender
mov r6, r2 @battle buffer
mov r7, r3 @battle data
@it's fine if we miss or another skill is active, we still want to proc the skill

@check if we're already in astra
ldrb r0, [r2, #4] @active skill
@make sure no other skill is active
cmp r0, #0
bne End

@check for AdeptAlt proc
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, AdeptAltID
.short 0xf800
cmp r0, #0
beq End

@if user has AdeptAlt, check if speed is high enough to proc, and we're on the followup attack
mov r2, #0x5E
ldrh r0, [r4, r2] @get attacking unit's AS
ldrh r1, [r5, r2] @get defending unit's AS
sub r0, r1 
cmp r0, #8 
blt End 

@Now check we're on the follow up attack
ldr r0, [r6]      @get current attack bitfield
mov r1, #4        
tst r0, r1        @check if follow up attack bit is set
beq End           @if not we don't proc


@if we proc, set the brave effect flag for the NEXT hit
ldrb r1, AdeptAltID @first mark AdeptAlt active
strb r1, [r6,#4]

@Don't really need to set the proc flag either since this isn't a % based proc
add     r6, #8 @double width battle buffer   
ldrb r0, AdeptAltID
strb r0, [r6,#4] @save the skill ID at byte #4

@now add the number of rounds - 
mov r1, #0x38
mov r2, sp
ldr r0, [r2,r1] @location of number of rounds on the stack... hopefully
add r0, #1
str r0, [r2,r1]

End:
pop {r4-r7}
pop {r15}

.align
.ltorg
SkillTester:
@POIN SkillTester
@WORD AdeptAltID