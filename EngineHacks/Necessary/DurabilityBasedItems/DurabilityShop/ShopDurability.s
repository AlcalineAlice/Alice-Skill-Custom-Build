.thumb
.align

.global NewShopMakeItem
.type NewShopMakeItem, %function

NewShopMakeItem:
push {r4,r14} 
mov r4,r0 @r4 = item halfword 

@is the durability half of this 0?
mov r0,r4
lsr r0,r0,#8
cmp r0,#0
beq GetNormalDurability

@it's not so we can just take the full thing that was passed in and add it
mov r0,r4
b GoBack

.ltorg
.align

GetNormalDurability:
mov r0,r4
mov r1,#0xFF
and r0,r1
mov r1,#36
mul r0,r1
ldr r1,=ItemTable
add r2,r0,r1
ldr r1,[r2,#8]
mov r0,#8
and r1,r0
mov r0,#0xFF
cmp r1,#0
bne IsUnbreakable
ldrb r0,[r2,#0x14]
b AddDurability

IsUnbreakable:
mov r0,#0

AddDurability:
lsl r1,r0,#8
mov r0,r4
mov r2,#0xFF
and r0,r2
orr r0,r1

GoBack:
pop {r4}
pop {r1}
bx r1

.ltorg
.align



.global NewGetItemCost
.type NewGetItemCost, %function


NewGetItemCost:
push {r4-r5,r14}
mov r4,r0 @r4 = item halfword

@return (cost per use * current durability)
@get cost per use first

mov r0,r4
mov r1,#0xFF
and r0,r1
mov r1,#36
mul r0,r1
ldr r1,=ItemTable
add r3,r0,r1
ldrh r0,[r3,#0x1A]
mov r5,r0 @r5 = cost per use

@Is this an item with variable price? Look in the table.
ldr r2,=VariablePriceItemPointerList
mov r0,r4
mov r1,#0xFF
and r0,r1

LoopStart:
ldrb r1,[r2]
cmp r1,#0
beq GetAdjustedPrice
cmp r0,r1
beq SearchThePrice

LoopRestart:
add r2,#8
b LoopStart

SearchThePrice:
@Now use the durability to find the price in the correspondent table
mov r1, #0x04 @4th byte is the pointer
ldr r2, [r2, r1] @Pointer to table
mov r1, r4
lsr r1, r1,#8 @Durability
mov r0, #0x02 @Price is halfword
mul r1, r0
ldrh r0, [r2, r1] @Load price by durability
b Cost_GoBack

.ltorg
.align

GetAdjustedPrice:
@check if unsellable flag is set
ldr r0,[r3,#0x8]
mov r1,#8
and r0,r1
cmp r0,#0
beq DoNormalCostPerUse @equal if flag is not set
mov r0,r5
b Cost_GoBack

.ltorg
.align

@multiply durability & cost per use
DoNormalCostPerUse:
mov r0,r4
lsr r0,r0,#8
mov r1,r5
mul r0,r1

Cost_GoBack:
pop {r4-r5}
pop {r1}
bx r1

.ltorg
.align
