.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.equ MugID,        SkillTester+4
.equ MugEvent,     MugID+4

.thumb
push {lr}

@----------------------------------------------------
@ 1. Check if defender is dead
@----------------------------------------------------
ldrb r0, [r5, #0x13]      @ defender currHP
cmp  r0, #0
bne  End                  @ not dead → no Mug

@----------------------------------------------------
@ 2. Check if attacker initiated combat
@----------------------------------------------------
ldrb r0, [r6, #0x11]      @ action taken this turn
cmp  r0, #0x2             @ 0x2 = attack
bne  End

ldrb r0, [r6, #0x0C]      @ allegiance of acting unit
ldrb r1, [r4, #0x0B]      @ allegiance of attacker
cmp  r0, r1
bne  End                  @ must be same unit

@----------------------------------------------------
@ 3. Inventory space check (non‑player only)
@----------------------------------------------------
cmp  r1, #0x40            @ <0x40 = player unit
blo  SkipInventoryCheck

ldr  r0, =0x80179D8       @ inventory space check
mov  lr, r0
mov  r0, r4               @ attacker
.short 0xF800
cmp  r0, #0x04            @ >4 = full
bhi  End

SkipInventoryCheck:

@----------------------------------------------------
@ 4. Check for Mug skill
@----------------------------------------------------
mov  r0, r4               @ attacker
ldr  r1, MugID
ldr  r3, SkillTester
mov  lr, r3
.short 0xF800
cmp  r0, #0
beq  End

@----------------------------------------------------
@ 5. Luck% roll
@----------------------------------------------------
ldr  r0, =0x8019298       @ Luck getter
mov  lr, r0
mov  r0, r4               @ attacker
.short 0xF800             @ r0 = Luck

ldr  r2, =0x802A52C       @ 1RN routine
mov  r1, r4               @ attacker
mov  lr, r2
.short 0xF800             @ r0 = 1 if success
cmp  r0, #1
bne  End

@----------------------------------------------------
@ 6. Scan defender inventory (slots 4 → 0)
@----------------------------------------------------
mov  r7, r5               @ defender pointer
mov  r6, #4               @ start at slot 4

ScanLoop:
cmp  r6, #0
blt  NoItemFound

lsl  r0, r6, #1           @ slot * 2
add  r0, #0x1E            @ inventory offset
ldrh r1, [r7, r0]         @ item halfword
cmp  r1, #0
beq  NextSlot             @ empty slot

@ Extract item ID + durability
mov  r2, r1
lsr  r2, #8               @ r2 = item ID
mov  r3, r1
lsl  r3, #24              @ mask low byte (durability)
lsr  r3, #24              @ r3 = durability

@----------------------------------------------------
@ Check cosmetic Prf bit (Ability 2 bit 0x20)
@----------------------------------------------------
mov  r0, r2               @ item ID
ldr  r4, =0x80177D0       @ GetItemAttributes
mov  lr, r4
.short 0xF800             @ r0 = ability word

lsr  r0, #8               @ shift to Ability 2
mov  r4, #0x20
and  r0, r4
cmp  r0, #0
bne  NextSlot             @ skip Prf‑flagged items

@ Found valid item
b   StoreSlots

NextSlot:
sub  r6, #1
b    ScanLoop

NoItemFound:
b    End                  @ no valid item → no Mug

@----------------------------------------------------
@ 7. Store item ID + durability into event slots
@----------------------------------------------------
StoreSlots:
ldr  r0, =0x030004C4      @ slot 3
str  r2, [r0]             @ item ID

ldr  r0, =0x030004C8      @ slot 4
str  r3, [r0]             @ durability

@----------------------------------------------------
@ 8. Call MugEvent (ASMC GiveItemWithUses)
@----------------------------------------------------
Event:
ldr  r0, =0x800D07C       @ event engine
mov  lr, r0
ldr  r0, MugEvent
mov  r1, #0x01            @ wait for events
.short 0xF800

End:
pop {r0}
bx  r0

.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD MugID
@POIN MugEvent
