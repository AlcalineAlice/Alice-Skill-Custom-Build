#include "global.h"
#include "anime.h"
#include "ekrbattle.h"

#include "BanimUtils.h"

void SetAnimStateFrozen(struct Anim *anim)
{
    struct Anim *anim1, *anim2;

    anim1 = gAnims[GetAnimPosition(anim) * 2];
    anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    anim->state3 |= 0x20;
    anim->state |= 0x8;

    anim1->state3 |= 0x20;
    anim1->state |= 0x8;

    anim2->state3 |= 0x20;
    anim2->state |= 0x8;
}

void SetAnimStateUnfrozen(struct Anim *anim)
{
    struct Anim *anim1, *anim2;

    anim1 = gAnims[GetAnimPosition(anim) * 2];
    anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    anim->state3 |= 0x40;
    anim->state &= ~0x8;

    anim1->state3 |= 0x40;
    anim1->state &= ~0x8;

    anim2->state3 |= 0x40;
    anim2->state &= ~0x8;
}
