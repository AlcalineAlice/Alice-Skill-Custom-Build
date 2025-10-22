#include "global.h"
#include "anime.h"
#include "ekrbattle.h"
#include "efxbattle.h"
#include "proc.h"
#include "bmlib.h"
#include "hardware.h"

#include "BanimUtils.h"

void BanimCmd_EraseDispUp(struct Anim * anim)
{
    if (GetAISLayerId(anim) == 0)
        AsyncEkrDispUP();
}
