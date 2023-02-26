ARM9_BIN_START equ 0x02000000
OV29_BIN_START equ 0x022DCB80

;-----------------
; OVERLAY 29 DATA
;-----------------

.definelabel OV29_AREA_TIP_FUNC_START, 0x0234d788
.definelabel OV29_AREA_TIP_FUNC_END, 0x0234db60
;.definelabel OV29_AREA_TIP_DATA_START, 0x02353e50
;.definelabel OV29_AREA_TIP_DATA_END, 0x02353f30

.definelabel OV29_HOOK_TIP_ENTER_DUNGEON, 0x022e024c
.definelabel OV29_HOOK_TIP_ITEM_0, 0x02345dcc
.definelabel OV29_HOOK_TIP_ITEM_1, 0x02345f58
.definelabel OV29_HOOK_TIP_ITEM_2, 0x0234d8b4
.definelabel OV29_HOOK_CHECK_RECRUITE, 0x0230eba4
.definelabel OV29_HOOK_CHECK_NAME, 0x0230ed18
.definelabel OV29_HOOK_CHECK_DUPES, 0x0230e5a8

.definelabel OV29_FUNC_ASK_PLAYER_YES_NO, 0x0234e3c0

; bool YesNoMenu(display_portrait_data *portrait,int message_id,int default_option,undefined param_4)
; seems to never return 0 ... only 0x01 for yes and 0x02 for no ... not true and false like in docu
.definelabel OV29_FUNC_SHOW_YES_NO_MENU, 0x0234e118
; some function that is called before display message ... idk what it does ...
.definelabel OV29_UNKNOWN_FUNCTION, 0x022eb66c
; void DisplayMessage(display_portrait_data *portrait,monster_id message_id, bool wait_for_input)
.definelabel OV29_FUNC_DISPLAY_MESSAGE, 0x0234de58
; void set_portrait_data(display_portrait_data *portrait, monster_id monster_id, int expression)
.definelabel OV29_FUNC_SET_PORTRAIT_DATA, 0x0234c6c0

.definelabel OV29_TEXT_GROUP_TIP_START, 0x3FD0 ; 16336
.definelabel OV29_TEXT_GROUP_TIP_END, 0x3FEA ; 16362

;-----------------
; ARM9 DATA
;-----------------

.definelabel ARM9_AREA_TIP_FUNC_START, 0x0204d588
.definelabel ARM9_AREA_TIP_FUNC_END, 0x0204d614

.definelabel ARM9_PTR_GLOBAL_PROGRESS, 0x020b0890
.definelabel ARM9_PTR_ADVENTURE_LOG, 0x020b0894

; void set_portrait_expression(display_portrait_data *, portrait, int expression)
.definelabel ARM9_FUNC_SET_PORTRAIT_EXPRESSION, 0x0204db2c

; uint32_t get_tip_bit(uint32_t bit)
; bit: 0-1e
; return: 0x0,0x1
.definelabel ARM9_FUNC_GLOBAL_PROGRESS_TIP_GET_BIT, 0x0204d5c8

; void set_tip bit(uint32_t bit)
; bit: 0-1e
.definelabel ARM9_FUNC_GLOBAL_PROGRESS_TIP_SET_BIT, 0x0204d588

;-----------------
; CONFIG DATA
;-----------------

CONFIG_TEXT_ID_INTRO_CLEAN_SAVEGAME equ 0x3FD0 ; 16336
CONFIG_TEXT_ID_INTRO_DIRTY_SAVEGAME equ 0x3FD1 ; 16337
CONFIG_TEXT_ID_BEFORE_WE_START equ 0x3FD2 ; 16338
CONFIG_TEXT_ID_QUESTION_IF_NUZLOCKE equ 0x3FD3 ; 16339
CONFIG_TEXT_ID_STUNNED_THAT_NO equ 0x3FD4 ; 16340
CONFIG_TEXT_ID_SIGH_HAVE_FUN equ 0x3FD5 ; 1631
CONFIG_TEXT_ID_HERE_ARE_THE_QUESTIONS equ 0x3FD6 ; 16342
CONFIG_TEXT_CONFIG_DONE equ 0x3FD7 ; 16343

CONFIG_TEXT_ID_QUESTION_FORCE_RECRUITE equ 0x3FD8 ; 16344
CONFIG_TEXT_ID_QUESTION_FORCE_NAME equ 0x3FD9 ; 16345
CONFIG_TEXT_ID_QUESTION_ONE_PER_DUNGEON equ 0x3FDA ; 16346
CONFIG_TEXT_ID_QUESTION_DUPE_CLAUSE equ 0x3FDB ; 16347
CONFIG_TEXT_ID_QUESTION_DUPE_EVO_LINE equ 0x3FDC ; 16348
CONFIG_TEXT_ID_QUESTION_DUPE_ALL_CAUGHT equ 0x3FDD ; 16349
CONFIG_TEXT_ID_QUESTION_DUPE_HERO equ 0x3FDE ; 16350
CONFIG_TEXT_ID_QUESTION_DUPE_PARTNER equ 0x3FDF ; 16351
CONFIG_TEXT_ID_QUESTION_DUPE_DEAD equ 0x3FE0 ; 16352
CONFIG_TEXT_ID_QUESTION_DUPE_GENDER equ 0x3FE1 ; 16353
CONFIG_TEXT_ID_QUESTION_MARK_DEAD equ 0x3FE2 ; 16354
CONFIG_TEXT_ID_QUESTION_NO_REVIVE equ 0x3FE3 ; 16355

; MAX 16362