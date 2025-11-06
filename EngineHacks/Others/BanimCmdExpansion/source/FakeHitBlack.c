#include "global.h"
#include "anime.h"
#include "ekrbattle.h"
#include "efxbattle.h"
#include "proc.h"

#include "BanimUtils.h"

void EfxFakeHitBlackMain(struct ProcEfxBmExpa * proc)
{
    struct Anim * anim = proc->anim;
    int time = ++proc->timer;

    if (0x01 == time)
    {
        NewEfxFlashBgBlack(anim, 0x10);
        return;
    }

    if (time == 0x12)
    {
        struct Anim *anim1 = gAnims[GetAnimPosition(anim) * 2];
        struct Anim *anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

        anim1->state3 |= ANIM_BIT3_BLOCKEND;
        anim2->state3 |= ANIM_BIT3_BLOCKEND;
        Proc_Break(proc);
    }
}

const struct ProcCmd ProScr_EfxFakeHitBlack[] = {
    PROC_NAME("efxFakeHitBlack"),
    PROC_REPEAT(EfxFakeHitBlackMain),
    PROC_END
};

void NewEfxFakeHitBlack(struct Anim * anim)
{
    struct ProcEfxBmExpa * proc;
    proc = Proc_Start(ProScr_EfxFakeHitBlack, PROC_TREE_3);
    proc->anim = anim;
    proc->timer = 0;
}

void BanimCmd_FakeHitBlack(struct Anim * anim)
{
    anim->pScrCurrent--;

    if (!(anim->state3 & ANIM_BIT3_BLOCKING))
    {
        anim->state3 |= ANIM_BIT3_BLOCKING;
        if (GetAISLayerId(anim) == 0)
            NewEfxFakeHitBlack(anim);
    }
    else
    {
        if (anim->state3 & ANIM_BIT3_BLOCKEND)
        {
            anim->state3 &= ~ANIM_BIT3_BLOCKING;
            anim->state3 &= ~ANIM_BIT3_BLOCKEND;
            anim->pScrCurrent = anim->pScrCurrent + 1;
        }
    }
}
