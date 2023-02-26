ARM9_BIN_START equ 0x02000000
OV29_BIN_START equ 0x022DC240

;-----------------
; OVERLAY 29 DATA
;-----------------

.definelabel OV29_AREA_TIP_FUNC_START, 0x0234cb88
.definelabel OV29_AREA_TIP_FUNC_END, 0x0234cf60
.definelabel OV29_AREA_TIP_DATA_START, 0x02353238
.definelabel OV29_AREA_TIP_DATA_END, 0x023532d0

.definelabel OV29_HOOK_TIP_ENTER_DUNGEON, 0x022df90c
.definelabel OV29_HOOK_TIP_ITEM_0, 0x023451e4
.definelabel OV29_HOOK_TIP_ITEM_1, 0x02345370
.definelabel OV29_HOOK_TIP_ITEM_2, 0x02345504
.definelabel OV29_HOOK_CHECK_RECRUITE, 0x0230e130
.definelabel OV29_HOOK_CHECK_NAME, 0x0230e2a4
.definelabel OV29_HOOK_CHECK_DUPES, 0x0230db34
.definelabel OV29_HOOK_CHECK_ONE_PER_DUNGEON, 0x022df1f8
.definelabel OV29_HOOK_MARK_AS_DEAD, 0x022f84cc
.definelabel OV29_HOOK_SKIP_REVIVE, 0x02309de8
.definelabel OV29_HOOK_SHOW_RECRUITE_STATE, 0x02335b90

.definelabel OV29_LABEL_SKIP_REVIVE_END, 0x0230a5e0

.definelabel OV29_FUNC_COPY_MONSTER_INTO_MEMBER, 0x022fe048
.definelabel OV29_FUNC_ASK_PLAYER_YES_NO, 0x0234d7c0

; bool YesNoMenu(display_portrait_data *portrait,int message_id,int default_option,undefined param_4)
; seems to never return 0 ... only 0x01 for yes and 0x02 for no ... not true and false like in docu
.definelabel OV29_FUNC_SHOW_YES_NO_MENU, 0x0234d518
; void DisplayMessage(display_portrait_data *portrait,monster_id message_id, bool wait_for_input)
.definelabel OV29_FUNC_DISPLAY_MESSAGE2, 0x0234d2ac
; void set_portrait_data(display_portrait_data *portrait, monster_id monster_id, int expression)
.definelabel OV29_FUNC_SET_PORTRAIT_DATA, 0x0234bac0
; int DisplayNumberTextureUi(int16_t x,int16_t y,int n,int ally_mode)
.definelabel OV29_FUNC_DISPLAY_NUMBER_TEXTURE_UI, 0x02335880

.definelabel OV29_TEXT_GROUP_TIP_START, 0x3FCE ; 16334
.definelabel OV29_TEXT_GROUP_TIP_END, 0x3FE8 ; 16360

.definelabel OV29_PTR_DUNGEON_STRUCT, 0x02353538

;-----------------
; ARM9 DATA
;-----------------

.definelabel ARM9_AREA_TIP_FUNC_START, 0x0204d250
.definelabel ARM9_AREA_TIP_FUNC_END, 0x0204d2dc

.definelabel ARM9_AREA_EXCLUSIVE_POKEMON_FUNC_START, 0x0204d14c
.definelabel ARM9_AREA_EXCLUSIVE_POKEMON_FUNC_END, 0x0204d208

.definelabel ARM9_PTR_GLOBAL_PROGRESS, 0x020aff74
.definelabel ARM9_PTR_ADVENTURE_LOG, 0x020aff78

; void set_portrait_expression(display_portrait_data *, portrait, int expression)
.definelabel ARM9_FUNC_SET_PORTRAIT_EXPRESSION, 0x0204d7f4

; uint32_t get_tip_bit(uint32_t bit)
; bit: 0-1e
; return: 0x0,0x1
.definelabel ARM9_FUNC_GLOBAL_PROGRESS_TIP_GET_BIT, 0x0204d290

; void set_tip_bit(uint32_t bit)
; bit: 0-1e
.definelabel ARM9_FUNC_GLOBAL_PROGRESS_TIP_SET_BIT, 0x0204d250

; uint32_t excl_tip_bit(uint32_t bit)
; bit: 0-1e
; return: 0x0,0x1
.definelabel ARM9_FUNC_GLOBAL_PROGRESS_EXCL_GET_BIT, 0x0204d188

; void set_excl_bit(uint32_t bit)
; bit: 0-1e
.definelabel ARM9_FUNC_GLOBAL_PROGRESS_EXCL_SET_BIT, 0x0204d14c

.definelabel ARM9_FUNC_GLOBAL_PROGRESS_MONSTER_FLAG2_SET_BIT, 0x0204d1c4
.definelabel ARM9_FUNC_FEMALE_TO_MALE_FORM, 0x02054be0

; Get a list of evolutions for this monster
; returns number of evolutions
; int GetEvolutions(monster_id monster_id,monster_id *output_list,bool skip_sprite_size_check, bool skip_shedinja_check)
.definelabel ARM9_FUNC_GET_EVOLUTIONS, 0x02053e88

; returns if the dungeon goes up or down
; bool DungeonGoesUp(dungeon_id dungeon_id)
.definelabel ARM9_FUNC_DUNGEON_GOES_UP, 0x02051288

.definelabel ARM9_PTR_TEAM_MEMBERS, 0x020b0a48
.definelabel ARM9_CONST_TEAM_MEMBER_SIZE, 0x44
.definelabel ARM9_PTR_MAX_TEAM_MEMBERS, 0x0205564c

;-----------------
; CONFIG DATA
;-----------------

CONFIG_TEXT_ID_INTRO_CLEAN_SAVEGAME equ 0x3FCE ; 16334
CONFIG_TEXT_ID_INTRO_DIRTY_SAVEGAME equ 0x3FCF ; 16335
CONFIG_TEXT_ID_BEFORE_WE_START equ 0x3FD0 ; 16336
CONFIG_TEXT_ID_QUESTION_IF_NUZLOCKE equ 0x3FD1 ; 16337
CONFIG_TEXT_ID_STUNNED_THAT_NO equ 0x3FD2 ; 16338
CONFIG_TEXT_ID_SIGH_HAVE_FUN equ 0x3FD3 ; 16339
CONFIG_TEXT_ID_HERE_ARE_THE_QUESTIONS equ 0x3FD4 ; 16340
CONFIG_TEXT_CONFIG_DONE equ 0x3FD5 ; 16341

CONFIG_TEXT_ID_QUESTION_FORCE_RECRUITE equ 0x3FD6 ; 16342
CONFIG_TEXT_ID_QUESTION_FORCE_NAME equ 0x3FD7 ; 16343
CONFIG_TEXT_ID_QUESTION_ONE_PER_DUNGEON equ 0x3FD8 ; 16344
CONFIG_TEXT_ID_QUESTION_DUPE_CLAUSE equ 0x3FD9 ; 16345
CONFIG_TEXT_ID_QUESTION_DUPE_EVO_LINE equ 0x3FDA ; 16346
CONFIG_TEXT_ID_QUESTION_DUPE_ALL_CAUGHT equ 0x3FDB ; 16347
CONFIG_TEXT_ID_QUESTION_DUPE_HERO equ 0x3FDC ; 16348
CONFIG_TEXT_ID_QUESTION_DUPE_PARTNER equ 0x3FDD ; 16349
CONFIG_TEXT_ID_QUESTION_DUPE_DEAD equ 0x3FDE ; 16350
CONFIG_TEXT_ID_QUESTION_DUPE_GENDER equ 0x3FDF ; 16351
CONFIG_TEXT_ID_QUESTION_MARK_DEAD equ 0x3FE0 ; 16352
CONFIG_TEXT_ID_QUESTION_NO_REVIVE equ 0x3FE1 ; 16353

; MAX 16360