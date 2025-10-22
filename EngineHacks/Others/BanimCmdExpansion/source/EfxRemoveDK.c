#include "global.h"
#include "anime.h"
#include "ekrbattle.h"
#include "efxbattle.h"
#include "ekrdragon.h"
#include "proc.h"
#include "bmlib.h"

#include "BanimUtils.h"

void EfxRemoveDkOnEnd(struct ProcEkrDragon * proc)
{
    struct Anim * anim = proc->anim;
    struct Anim * anim1 = gAnims[GetAnimPosition(anim) * 2];
    struct Anim * anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    SetAnimStateUnfrozen(anim);
    SetAnimStateUnfrozen(anim1);
    SetAnimStateUnfrozen(anim2);

    // LZ77UnCompVram((void *)0x085BC188, (void *)0x06008000);
    // LZ77UnCompWram((void *)0x085BE7F4, gEkrTsaBuffer);
    // sub_8070EF4(gEkrTsaBuffer, -1, (void *)0x0201D428, 66, 46, 20, 6, 0);

    gBanimValid[GetAnimPosition(proc->anim)] = true;
    SetAnimStateUnHidden(GetAnimPosition(proc->anim));

    gEkrDragonStatusLeft.type = EKRDRGON_TYPE_NORMAL;
    gEkrDragonStatusRight.type = EKRDRGON_TYPE_NORMAL;
}

void EfxRemoveDkOnEnd2(struct ProcEkrDragon * proc)
{
    proc->anim->state3 |= ANIM_BIT3_BLOCKEND;
}

const struct ProcCmd ProScr_EfxRemoveDK[] = {
    PROC_NAME("efxRemoveDK"),
    PROC_YIELD,
    PROC_REPEAT(EkrDK_ReloadTerrainEtc),
    PROC_REPEAT(EkrDK_ReloadCustomBgAndFadeOut),
    PROC_CALL(EfxRemoveDkOnEnd),
    PROC_CALL(EfxRemoveDkOnEnd2),
    PROC_END
};

void NewEfxRemoveDK(struct Anim * anim)
{
    struct Anim * anim1, * anim2;
    struct ProcEkrDragon *proc = Proc_Start(ProScr_EfxRemoveDK, PROC_TREE_3);
    proc->timer = 0;
    proc->anim = anim;

    anim1 = gAnims[GetAnimPosition(anim) * 2];
    anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    SetAnimStateFrozen(anim);
    SetAnimStateFrozen(anim1);
    SetAnimStateFrozen(anim2);
}

void BanimCmd_RemoveDK(struct Anim * anim)
{
    anim->pScrCurrent = anim->pScrCurrent - 1;

    if (!(anim->state3 & ANIM_BIT3_BLOCKING))
    {
        anim->state3 |= ANIM_BIT3_BLOCKING;
        if (GetAISLayerId(anim) == 0)
            NewEfxRemoveDK(anim);
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
