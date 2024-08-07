MAXX           = 78;
MAXY           = 20;
MAXAFFECT      = 12;
MAX_INV_SIZE   = 22;
MAX_EQ_SIZE    = 4;

ENTITY_BEING    = 1;
ENTITY_ITEM     = 2;

LFEXPLORED = 0;
LFVISIBLE  = 1;
LFLIGHTED  = 2;
LFDAMAGE   = 3;
LFFRESH    = 4;
LFNOSPAWN  = 5;
LFPERMANENT= 6;
LFCORNER   = 7;
LFBLOOD    = 8;
LFMARKER1  = 9;
LFMARKER2  = 10;
LFANIMATING= 11;

DRL_SPRITESHEET_ENVIRO = 1;
DRL_SPRITESHEET_DOODAD = 2;
DRL_SPRITESHEET_ITEMS  = 3;
DRL_SPRITESHEET_BEINGS = 4;
DRL_SPRITESHEET_PLAYER = 5;
DRL_SPRITESHEET_LARGE  = 6;
DRL_SPRITESHEET_FX     = 7;

DRL_SENVIRO = DRL_SPRITESHEET_ENVIRO * 100000;
DRL_SDOODAD = DRL_SPRITESHEET_DOODAD * 100000;
DRL_SITEMS  = DRL_SPRITESHEET_ITEMS  * 100000;
DRL_SBEINGS = DRL_SPRITESHEET_BEINGS * 100000;
DRL_SPLAYER = DRL_SPRITESHEET_PLAYER * 100000;
DRL_SLARGE  = DRL_SPRITESHEET_LARGE  * 100000;
DRL_SFX     = DRL_SPRITESHEET_FX     * 100000;

DRL_COLS    = 16;

HARDSPRITE_PLAYER  = DRL_SPLAYER + 1;
HARDSPRITE_HIT     = DRL_SFX + 4;
HARDSPRITE_EXPL    = DRL_SFX + 8;
HARDSPRITE_SELECT  = DRL_SFX + 14;
HARDSPRITE_MARK    = DRL_SFX + 15;
HARDSPRITE_GRID    = DRL_SFX + DRL_COLS + 16;

CELLSET_WALLS   = 1;
CELLSET_FLOORS  = 2;
CELLSET_CORPSES = 3;

CF_BLOCKMOVE  = 1;
CF_BLOCKLOS   = 2;
CF_CORPSE     = 3;
CF_NOCHANGE   = 4;
CF_NORUN      = 5;
CF_PUSHABLE   = 6;
CF_FRAGILE    = 7;
CF_HAZARD     = 8;
CF_OVERLAY    = 9;

CF_STICKWALL  = 11;
CF_LIQUID     = 12;
CF_OPENABLE   = 13;
CF_CLOSABLE   = 14;
CF_RUNSTOP    = 15;
CF_NUKABLE    = 16;
CF_CRITICAL   = 17;
CF_HIGHLIGHT  = 18;
CF_VBLOODY    = 20;
CF_STAIRS     = 21;
CF_RAISABLE   = 22;
CF_STAIRSENSE = 23;

BF_BOSS         = 1;
BF_ENVIROSAFE   = 2;
BF_CHARGE       = 3;
BF_OPENDOORS    = 4;
BF_NODROP       = 5;
BF_NOEXP        = 6;
BF_QUICKSWAP    = 7;
BF_HUNTING      = 8;
BF_BACKPACK     = 9;
BF_UNIQUENAME   = 10;
BF_IMPATIENT    = 11;
BF_SHOTTYMAN    = 12;
BF_ROCKETMAN    = 13;
BF_BERSERKER    = 14;
BF_DARKNESS     = 15;
BF_DUALGUN      = 16;
BF_POWERSENSE   = 17;
BF_BEINGSENSE   = 18;
BF_LEVERSENSE1  = 19;
BF_LEVERSENSE2  = 20;
BF_NOMELEE      = 21;
BF_CLEAVE       = 22;
BF_MAXDAMAGE    = 23;
BF_SESSILE      = 24;
BF_VAMPYRE      = 25;
BF_REGENERATE   = 26;
BF_ARMYDEAD     = 27;
BF_FIREANGEL    = 28;
BF_GUNKATA      = 29;
BF_AMMOCHAIN    = 30;
BF_MASTERDODGE  = 31;
BF_INV          = 32;
BF_BERSERK      = 33;
BF_NORUNPENALTY = 34;
BF_PISTOLMAX    = 35;
BF_MEDPLUS      = 36;
BF_HARDY        = 37;
BF_SCAVENGER    = 38;
BF_INSTAUSE     = 39;
BF_STAIRSENSE   = 40;
BF_POWERBONUS   = 41;
BF_MAPEXPERT    = 42;
BF_DUALBLADE    = 43;
BF_BLADEDEFEND  = 44;
BF_BULLETDANCE  = 45;
BF_SHOTTYHEAD   = 46;
BF_ENTRENCHMENT = 47;
BF_MODEXPERT    = 48;
BF_SELFIMMUNE   = 49;
BF_KNOCKIMMUNE  = 50;
BF_NOHEAL       = 51;
BF_GUNRUNNER    = 52;

IF_UNIQUE         = 21;
IF_EXOTIC         = 22;
IF_MODIFIED       = 23;
IF_CURSED         = 24;
IF_CHAMBEREMPTY   = 25;
IF_HALFKNOCK      = 26;
IF_GLOBE          = 27;
IF_RECHARGE       = 28;
IF_CLEAVE         = 29;
IF_NOAMMO         = 30;
IF_NECROCHARGE    = 31;
IF_PUMPACTION     = 32;
IF_SINGLERELOAD   = 33;
IF_PISTOL         = 34;
IF_SHOTGUN        = 35;
IF_ROCKET         = 36;
IF_SPREAD         = 37;
IF_SCATTER        = 38;
IF_SINGLEMOD      = 39;
IF_DUALSHOTGUN    = 40;
IF_AIHEALPACK     = 41;
IF_NOUNLOAD       = 42;
IF_NUKERESIST     = 43;
IF_NODROP         = 44;
IF_AUTOHIT        = 45;
IF_SETITEM        = 46;
IF_NODURABILITY   = 47;
IF_NODESTROY      = 48;
IF_NONMODABLE     = 49;
IF_NOREPAIR       = 50;
IF_ASSEMBLED      = 51;
IF_DESTROY        = 52;
IF_BLADE          = 53;
IF_DESTRUCTIVE    = 54;
IF_FARHIT         = 55;
IF_UNSEENHIT      = 56;
IF_NODEGRADE      = 57;
IF_MODABLE        = 58;
IF_THROWDROP      = 59;
IF_PLURALNAME     = 60;

LF_NOHOMING       = 1;
LF_UNIQUEITEM     = 2;
LF_BONUS          = 3;
LF_SCRIPT         = 4;
LF_NORESPAWN      = 5;
LF_NUKED          = 6;
LF_NONUKE         = 7;
LF_ITEMSVISIBLE   = 8;
LF_BEINGSVISIBLE  = 9;
LF_RESPAWN        = 10;
LF_SHARPFLUID     = 11;
LF_BOSS           = 12;

SF_LARGE    = 1;
SF_OVERLAY  = 2;
SF_COSPLAY  = 3;
SF_GLOW     = 4;
SF_FLOW     = 5;
SF_FLUID    = 6;
SF_MULTI    = 7;
SF_FLOOR    = 8;

EF_NOBLOCK  = 0;
EF_NOBEINGS = 1;
EF_NOITEMS  = 2;
EF_NOVISION = 3;
EF_NOSTAIRS = 4;
EF_NOTELE   = 5;
EF_NOHARM   = 6;
EF_NOSAFE   = 7;
EF_NOSPAWN  = 8;

DIFF_EASY      = 1;
DIFF_MEDIUM    = 2;
DIFF_HARD      = 3;
DIFF_VERYHARD  = 4;
DIFF_NIGHTMARE = 5;

SLOT_ARMOR    = EFTORSO;
SLOT_WEAPON   = EFWEAPON;
SLOT_BOOTS    = EFBOOTS;
SLOT_PREPARED = EFWEAPON2;

MF_RAY      = 1;
MF_HARD     = 2;
MF_EXACT    = 3;
MF_IMMIDATE = 4;

MULTIBLUE   = 17;
MULTIYELLOW = 18;
MULTIPORTAL = 20;

COLOR_WATER = 21;
COLOR_ACID  = 22;
COLOR_LAVA  = 23;

FRAME_TIME  = 500;


