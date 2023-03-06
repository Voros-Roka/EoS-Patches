;-----------------
; CONFIG_DATA
;-----------------

.nds

.definelabel ROKA_POKEMON_ID, _param_roka_pokemon_id

.definelabel CONFIG_QUESTION_COUNT, 0x12

.definelabel MAX_TEAM_MEMBERS, 0x22B

.definelabel SIMPLE_BELLY, _param_simple_belly

.if SIMPLE_BELLY == 0x00
	.definelabel BELLY_X_POS, 0xCB
	.definelabel HP_BAR_X_SIZE, 0x36 ; orgininal was 0x70 (112)
.else
	.definelabel BELLY_X_POS, 0xE8
	.definelabel HP_BAR_X_SIZE, 0x53 ; orgininal was 0x70 (112)
.endif

.definelabel BELLY_Y_POS, 0x00


.definelabel HP_DISPLAY_X_POS, 0x48 ; orgininal is 0x48 (72)
.definelabel HP_BAR_X_START, 0x90 ; orgininal is 0x90 (144)

.definelabel DUNGEON_STATE_X_POS, 0xF8
.definelabel DUNGEON_STATE_Y_POS, 0xB7

.definelabel CONFIG_CHECK_USED_SAVEGAME_BIT, 0x00
.definelabel CONFIG_WANTS_NUZLOCKE, 0x01
.definelabel CONFIG_NO_REVIVE, 0x05
.definelabel CONFIG_MARK_DEAD, 0x06
.definelabel CONFIG_FORCE_RECRUIT_BIT, 0x07
.definelabel CONFIG_FORCE_NAME_BIT, 0x08
.definelabel CONFIG_ONE_PER_DUNGEON, 0x09
.definelabel CONFIG_DUPE_CLAUSE, 0x0A
.definelabel CONFIG_DUPE_EVO_LINE, 0x0B
.definelabel CONFIG_DUPE_ALL_CAUGHT, 0x0C
.definelabel CONFIG_DUPE_HERO, 0x0D
.definelabel CONFIG_DUPE_PARTNER, 0x0E
.definelabel CONFIG_DUPE_DEAD, 0x0F
.definelabel CONFIG_DUPE_GENDER, 0x10


.definelabel CONFIG_CONFIG_DONE_BIT, 0x1e
