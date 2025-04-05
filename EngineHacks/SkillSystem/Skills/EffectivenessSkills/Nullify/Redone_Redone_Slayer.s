.thumb

@jumped to from 16C88

@r0=attacker battle struct, r1=defender battle struct

@Slayer table outline: BYTE class_ID multiplier is_there_another_entry 0; SHORT class_types 0

@tequila why the h*ck are you checking the slayer table after checking the skill making it still hardcoded to classes
@this version just checks a given class type EA literal

.equ SlayerID, SkillTester+4
.equ NullifyID, SlayerID+4
.equ SlayerClassType, NullifyID+4
.equ SkybreakerID, SlayerClassType+4
.equ SkybreakerClassType,SkybreakerID+4
.equ ResourcefulID,SkybreakerClassType+4
.equ SwordKillerID, ResourcefulID+4
.equ LanceKillerID, SwordKillerID+4
.equ AxeKillerID, LanceKillerID+4
.equ BowKillerID, AxeKillerID+4

@ These have to be set to double the regular values because Add_Weapon_Might.s performs an lsr #1 
@ on the effectiveness multiplier to halve it before applying it to the attack as it's less computationally expensive
.equ KillerEffectiveness, 4
.equ BaseEffectiveness, 6

.equ SwordType, 0
.equ LanceType, 1
.equ AxeType, 2
.equ BowType, 3

push	{r4-r6,r14}
mov		r4,r0
mov		r5,r1
ldr		r0,[r5,#0x4]
cmp		r0,#0                   @check if the defender unit is null
beq		NotEffective            @if so, we branch to NotEffective and set the effectiveness to 0

@effective damage against monsters
Slayer:
mov		r0,r4
ldr		r1,SlayerID
ldr		r3,SkillTester
mov		r14,r3
.short	0xF800
cmp		r0,#0
beq		Skybreaker              @the unit doesn't have slayer, so we branch to check for skybreaker
ldr		r2,[r5,#4]
mov		r1,#0x50
ldrh	r2,[r2,r1]			    @weaknesses defender unit has
ldrh 	r0,SlayerClassType
and		r0,r2
cmp		r0,#0
bne		SetSlayerEffectiveness  @the unit is facing a class slayer will trigger against, so we don't need to check for other effectivness skills
b       Skybreaker              @otherwise, we branch to check for skybreaker

SetSlayerEffectiveness:
mov     r6,#BaseEffectiveness    @start off with an effectivness multiplier of 3
b       NullifyCheck

@effective damage against flying units
Skybreaker:
mov		r0,r4
ldr		r1,SkybreakerID
ldr		r3,SkillTester
mov		r14,r3
.short	0xF800
cmp		r0,#0
beq		SwordKiller             @the unit doesn't have skybreaker, so we branch to the sword killer check
ldr		r2,[r5,#4]
mov		r1,#0x50
ldrh	r2,[r2,r1]			    @weaknesses defender unit has
ldrh 	r0,SkybreakerClassType
mov     r6,#BaseEffectiveness    @start off with an effectivness multiplier of 3
and		r0,r2
cmp		r0,#0
bne		SetSkybreakerEffectiveness @the unit is facing a class skybreaker will trigger against, so we don't need to check for other effectivness skills
b       SwordKiller                @otherwise, we branch to sword killer

SetSkybreakerEffectiveness:
mov     r6,#BaseEffectiveness    @start off with an effectivness multiplier of 3
b       NullifyCheck

@Deal x2 effective damage if the enemy has a sword equipped
SwordKiller:
mov		r0,r4
ldr		r1,SwordKillerID
ldr		r3,SkillTester
mov		r14,r3
.short	0xF800
cmp		r0,#0
beq     LanceKiller      @if the unit doesn't have sword killer, then we check for lance killer
mov     r0, #0x50        @load the battle unit byte for the enemy unit's equipped weapon type
ldrb    r1,[r5,r0]       @load the equipped weapon type
cmp     r1, #SwordType   @check if the weapon type is 0 (sword)
bne     LanceKiller      @if not, we branch to the lance killer check
mov     r6, #KillerEffectiveness  @otherwise, we set the multiplier to 2
b       NullifyCheck     @and branch to the nullify check

@Deal x2 effective damage if the enemy has a lance equipped
LanceKiller:
mov		r0,r4
ldr		r1,LanceKillerID
ldr		r3,SkillTester
mov		r14,r3
.short	0xF800
cmp		r0,#0
beq     AxeKiller        @if the unit doesn't have lance killer, then we check for axe killer
mov     r0, #0x50        @load the battle unit byte for the enemy unit's equipped weapon type
ldrb    r1,[r5,r0]       @load the equipped weapon type
cmp     r1, #LanceType   @check if the weapon type is 1 (lance)
bne     AxeKiller        @if not, we branch to the axe killer check
mov     r6, #KillerEffectiveness @otherwise, we set the multiplier to 2
b       NullifyCheck     @and branch to the nullify check

@Deal x2 effective damage if the enemy has an axe equipped
AxeKiller:
mov		r0,r4
ldr		r1,AxeKillerID
ldr		r3,SkillTester
mov		r14,r3
.short	0xF800
cmp		r0,#0
beq     BowKiller        @if the unit doesn't have a axe killer, then we check for bow killer
mov     r0, #0x50        @load the battle unit byte for the enemy unit's equipped weapon type
ldrb    r1,[r5,r0]       @load the equipped weapon type
cmp     r1, #AxeType     @check if the weapon type is 2 (axe)
bne     BowKiller        @if not, we branch to the bow killer check
mov     r6, #KillerEffectiveness @otherwise, we set the multiplier to 2
b       NullifyCheck     @and branch to the nullify check

@Deal x2 effective damage if the enemy has a bow equipped
BowKiller:
mov		r0,r4
ldr		r1,BowKillerID
ldr		r3,SkillTester
mov		r14,r3
.short	0xF800
cmp		r0,#0
beq     NotEffective     @if the unit doesn't have bow killer, then all effectiveness checks have failed and we can set the effectiveness straight to 0
mov     r0, #0x50        @load the battle unit byte for the enemy unit's equipped weapon type
ldrb    r1,[r5,r0]       @load the equipped weapon type
cmp     r1, #BowType     @check if the weapon type is 3 (bow)
bne     NotEffective     @if not, we again branch to set the effectivness to 0
mov     r6, #KillerEffectiveness @otherwise, we set the multiplier to 2

@we set the effectiveness to 0 ahead of time if the enemy has nullify
NullifyCheck:
mov		r0,r5
ldr		r1,NullifyID
ldr		r3,SkillTester
mov		r14,r3
.short	0xF800
cmp		r0,#0
bne		NotEffective     @the enemy unit has nullify, branch to NotEffective

@Double effectiveness multiplier
ResourcefulCheck:
ldr		r0,SkillTester
mov		r14,r0
mov		r0,r4
ldr		r1,ResourcefulID	
.short	0xF800
cmp		r0,#0
beq		GoBack           @if the resourceful skill is not found, we skip doubling the multiplier
lsl		r6,#1            @otherwise, we double the current value of the multiplier
b       GoBack           @now branch here to avoid setting the effectiveness multiplier to 0

@set the effectiveness multiplier to 0
NotEffective:
mov		r6,#0
GoBack:
mov		r0,r6
pop		{r4-r6}
pop		{r1}
bx		r1

.ltorg
.align
SkillTester:
@
