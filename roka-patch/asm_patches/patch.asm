
.open "arm9.bin", ARM9_BIN_START
	.org ARM9_FUNC_GLOBAL_PROGRESS_TIP_SET_BIT
	.area ARM9_AREA_TIP_FUNC_END - ARM9_AREA_TIP_FUNC_START, 0
		.func config_set_bit
			ldr r1,=ARM9_PTR_GLOBAL_PROGRESS ; get address to our global progress struct
			ldr r1,[r1,#0x00]
			ldr r2,[r1,#0x94] ; load global_progress->tips_shown
			mov r3,#0x01
			orr r2,r2,r3, lsl r0
			str r2,[r1,#0x94] ; store global_progress->tips_shown
			bx lr
		.endfunc

		.func config_clr_bit
			ldr r1,=ARM9_PTR_GLOBAL_PROGRESS ; get address to our global progress struct
			ldr r1,[r1,#0x00]
			ldr r2,[r1,#0x94] ; load global_progress->tips_shown
			mov r3,#0x01
			mvn r3,r3, lsl r0
			and r2,r2,r3
			str r2,[r1,#0x94] ; store global_progress->tips_shown
			bx lr
		.endfunc

		.pool
		.org ARM9_FUNC_GLOBAL_PROGRESS_TIP_GET_BIT
		.func config_get_bit
			ldr r1,=ARM9_PTR_GLOBAL_PROGRESS ; get address to our global progress struct
			ldr r1,[r1,#0x00]
			ldr r2,[r1,#0x94] ; load global_progress->tips_shown
			mov r3,#0x01
			tst r2,r3, lsl r0
			moveq r0,#0x00
			movne r0,#0x01
			bx lr
		.endfunc

		.func dungeon_clr_bit
			ldr r1,=ARM9_PTR_GLOBAL_PROGRESS ; get address to our global progress struct
			ldr r1,[r1,#0x00]
			add r1,r0, lsr #0x03
			ldrb r2,[r1,#0x00]
			and r0,0x07
			mov r3,#0x01
			mvn r3,r3, lsl r0
			and r2,r2,r3
			strb r2,[r1,#0x00] ; store global_progress->tips_shown
			bx lr
		.endfunc

		.pool
		.endarea

		.org ARM9_FUNC_GLOBAL_PROGRESS_EXCL_SET_BIT
		.area ARM9_AREA_EXCLUSIVE_POKEMON_FUNC_END - ARM9_AREA_EXCLUSIVE_POKEMON_FUNC_START, 0
		.func dungeon_set_bit
			ldr r1,=ARM9_PTR_GLOBAL_PROGRESS ; get address to our global progress struct
			ldr r1,[r1,#0x00]
			add r1,r0, lsr #0x03
			ldrb r2,[r1,#0x00] ; load global_progress->dungeon_bits
			and r0,0x07
			mov r3,#0x01
			orr r2,r2,r3, lsl r0
			strb r2,[r1,#0x00] ; store global_progress->tips_shown
			bx lr
		.endfunc

		.func config_init
			ldr r0,=ARM9_PTR_GLOBAL_PROGRESS ; get address to our global progress struct
			ldr r0,[r0,#0x00]
			mov r1,#0x40000000
			str r1,[r0,#0x94] ; store global_progress->tips_shown
			bx lr
		.endfunc

		.org ARM9_FUNC_GLOBAL_PROGRESS_EXCL_GET_BIT
		.func dungeon_get_bit
			ldr r1,=ARM9_PTR_GLOBAL_PROGRESS
			ldr r1,[r1,#0x00]
			ldrb r2,[r1,r0, lsr #0x03]
			and r0,#0x07
			mov r3,#0x01
			tst r2,r3, lsl r0
			moveq r0,#0x00
			movne r0,#0x01
			bx lr
		.endfunc

		.func dead_get_bit
			add r0,#0x100
			b dungeon_get_bit
		.endfunc

		.func dead_clr_bit
			add r0,#0x100
			b dungeon_clr_bit
		.endfunc

		.func dead_set_bit
			add r0,#0x100
			b dungeon_set_bit
		.endfunc

		; we need the space so just copy the function from the orginial
		; to combine the pools of the area to safe space
		.org ARM9_FUNC_GLOBAL_PROGRESS_MONSTER_FLAG2_SET_BIT
		.func set_monster_flag2
			stmdb sp!,{r3,lr}
			bl ARM9_FUNC_FEMALE_TO_MALE_FORM
			ldr r2,=ARM9_PTR_GLOBAL_PROGRESS
			mov r1,r0, asr #0x4
			ldr r3,[r2,#0x0]
			add r1,r0,r1, lsr #0x1b
			mov r2,r0, lsr #0x1f
			rsb r0,r2,r0, lsl #0x1b
			add lr,r3,#0x98
			mov r12,r1, asr #0x5
			ldr r3,[lr,r12,lsl #0x2]
			add r0,r2,r0, ror #0x1b
			mov r1,#0x1
			orr r0,r3,r1, lsl r0
			str r0,[lr,r12,lsl #0x2]
			ldmia sp!,{r3,pc}
		.endfunc
		.pool
	.endarea

	.org ARM9_AREA_FATAL_ERROR_FUNC_START
	.area ARM9_AREA_FATAL_ERROR_FUNC_END - ARM9_AREA_FATAL_ERROR_FUNC_START, 0
		.func FatalError
			bl ARM9_FUNC_WAIT_FOREVER
		.endfunc

;-------------------------------------------------------------------
; Function to mark pokemon as dead
;-------------------------------------------------------------------

		; Register usage:
		; Params: team_member_id, monster *
		; Params: R0,R1
		; Caller: R4-R11
		.func mark_as_dead
			stmdb sp!,{r0,r1,r2,r3,r4,lr}
			mov r4,r0
			mov r0,#CONFIG_MARK_DEAD
			bl config_get_bit
			cmp r0,#0x01
			moveq r0,r4
			bleq dead_set_bit
			ldmia sp!,{r0,r1,r2,r3,r4,lr}
			b OV29_FUNC_COPY_MONSTER_INTO_MEMBER
		.endfunc

	.endarea

	.org ARM9_AREA_DEBUG_PRINT_TRACE_FUNC_START
	.area ARM9_AREA_DEBUG_PRINT_TRACE_FUNC_END - ARM9_AREA_DEBUG_PRINT_TRACE_FUNC_START, 0
		.func DebugPrintTrace
			bx lr
		.endfunc

		; Check a null terminated list of monsters against
		; the list of all recruited pokemon
		.func check_all_recruited_monsters_against_list
			stmdb sp!,{r4,lr}

			ldr r4,=ARM9_PTR_ADVENTURE_LOG ; get pointer to cought pokemon array
			ldr r4,[r4,#0x00]

			mov r5,#0x00

			; r0 = evo list ptr
			@@check_everyone_loop:
				ldrh r2,[r0,#0x00] ; get monster id from our evo list
				; r2 = monster_id
				cmp r2,#0x00 ; check if end
				beq @@function_end ; break out of the loop

				lsr r1,r2,#0x03 ; calculate byte to look into bit array (pos/8)
				; r1 = byte offset
				add r1,r1,#0x44 ; offset our index to the right bit array
				; r1 = byte offset
				ldrb r3,[r4,r1]	; load actual byte with our bits
				; r3 = byte to check
				and r2,#0x07	; get the bit address we want to check (pos%8)
				; r2 = bit offset
				mov r1,#0x01
				; r1 = 0x01
				tst r3,r2, lsl r1 ; check if our bit is set by shifting 0x01 to the right point
				movne r5,#0x01 ; we found a match set return value
				bne @@function_end ; jump to end of function

				add r0,r0,#0x02 ; move our pointer to the next id
				b @@check_everyone_loop
		@@function_end:
			mov r0,r5
			ldmia sp!,{r4,pc}
		.endfunc
		.pool


	.endarea

	.org ARM9_AREA_DEBUG_PRINT0_FUNC_START
	.area ARM9_AREA_DEBUG_PRINT0_FUNC_END - ARM9_AREA_DEBUG_PRINT0_FUNC_START, 0
		.func DebugPrint0
			bx lr
		.endfunc
		; Check a null terminated list of monster ids
		; against a given monster id
		; params: monster_id, monster_id *
		; return: bool
		.func check_monster_list
		@@check_monster_loop:
			ldrh r2,[r1,#0x00] ; load monster id from list
			cmp r2,#0x00 ; are we at the end of the list?
			beq @@func_end ; break out of the loop

			cmp r0,r2 ; compare with given monster id

			moveq r0,#0x01 ; we got our monster id so set result to false
			bxeq lr ; we return to caller

			add r1,r1,#0x02 ; move our pointer to the next id
			b @@check_monster_loop

		@@func_end:
			mov r0,0x00
			bx lr

		.endfunc

	.endarea

	.org ARM9_AREA_DEBUG_PRINT1_FUNC_START
	.area ARM9_AREA_DEBUG_PRINT1_FUNC_END - ARM9_AREA_DEBUG_PRINT1_FUNC_START, 0
		.func DebugPrint1
			bx lr
		.endfunc

		; CHecks config if we want to differentiate between the genders
		; and gives the changes the given monster id according to it
		; params: monster_id
		; return: monster_id
		.func compute_monster_id
			stmdb sp!,{r4,lr}
			mov r4,r0 ; monster_id
			mov r0,#CONFIG_DUPE_GENDER
			bl config_get_bit
			cmp r0,#0x00
			mov r0,r4

			bleq ARM9_FUNC_FEMALE_TO_MALE_FORM

			ldmia sp!,{r4,pc}
		.endfunc


	.endarea
.close

.open "overlay_0029.bin", OV29_BIN_START

;-------------------------------------------------------------------
; Hooks into the game to manipulate it
;-------------------------------------------------------------------

	; replace function call with call to our function
	.org OV29_HOOK_CHECK_RECRUITE
		bl check_force_recruite_dungeon

	; replace function call with call to our function
	.org OV29_HOOK_CHECK_NAME
		bl check_force_name_dungeon

	; replace function call with call to our function
	.org OV29_HOOK_CHECK_DUPES
		bl check_recruit_allowed

	; replace function call with call to our function
	.org OV29_HOOK_CHECK_ONE_PER_DUNGEON
		bl init_only_one_per_dungeon

	.org OV29_HOOK_MARK_AS_DEAD
		bl mark_as_dead

	; stub out the calls to display_item_tips
	.org OV29_HOOK_TIP_ITEM_0
		nop
	.org OV29_HOOK_TIP_ITEM_1
		nop
	.org OV29_HOOK_TIP_ITEM_2
		nop

	; TODO: call custom function that asks the player
	; for nuzlocke config
	; stub out the call to the dungeon enter tips
	; stub out the call to some empty debug function
	.org OV29_HOOK_TIP_ENTER_DUNGEON
		bl ask_player_for_config
		nop

	.org OV29_HOOK_SKIP_REVIVE
		; ldrb r0,[r4,#0x62]
		b skip_revive_test_insert; tst r0,#0x1 ; 02309de8
		nop ; movne r1,#0x1 ; 02309dec
	skip_revive_test_return:
		and r1,r0,0x1; moveq r1,#0x0 ; 02309df0
		; tst r1,#0xff ; 02309df4
		; beq LAB_02309f44


	; Call function to display custom ui here
	; call original function afterwards when custom display done
	; params: r0 = some struct
	; return: idk
	.org OV29_HOOK_CUSTOM_UI
		bl display_custom_ui


	; Move the HP display to a different x-pos
	.org OV29_HOOK_UI_HP_DISPLAY_X_POSITION0
		mov r6,#HP_DISPLAY_X_POS

	.org OV29_HOOK_UI_HP_DISPLAY_X_POSITION1
		add r0,r0,#HP_DISPLAY_X_POS


	; Move the HP Bar to a different x-pos
	.org OV29_HOOK_UI_HP_BAR_X_POSITION0 ; 0x02335d48
		mov r5,#HP_BAR_X_START

	.org OV29_HOOK_UI_HP_BAR_X_POSITION1 ; 0x02335da0
		mov r2,#HP_BAR_X_START

	.org OV29_HOOK_UI_HP_BAR_X_POSITION2 ; 0x02335dc0
		add r0,r4,#HP_BAR_X_START

	.org OV29_HOOK_UI_HP_BAR_X_POSITION3 ; 0x02335e38
		add r0,r7,#HP_BAR_X_START

	.org OV29_HOOK_UI_HP_BAR_X_POSITION4 ; 0x02335e40
		mov r3,#HP_BAR_X_START

	;iVar3 = r7
	;uVar1 = r3
	;iVar4 = r10
	;max_hp = r4
	;pvVar10 = r10

	; Resize the HP Bar to a drfferent size
	.org OV29_HOOK_UI_HP_BAR_X_SIZE0 ; 0x02335d88
		cmp r7,#HP_BAR_X_SIZE


	.org OV29_HOOK_UI_HP_BAR_X_SIZE1 ; 0x02335db4
		movgt r7,#HP_BAR_X_SIZE
		cmp r4,#HP_BAR_X_SIZE
		movgt r4,#HP_BAR_X_SIZE






;-------------------------------------------------------------------
; Area where the tip related functions where but now our nuzlock stuff is
;-------------------------------------------------------------------

	.org OV29_AREA_TIP_FUNC_START
	.area OV29_AREA_TIP_FUNC_END - OV29_AREA_TIP_FUNC_START, 0

;-------------------------------------------------------------------
; Function to force player to recruite pokemon
;-------------------------------------------------------------------

		; Function to check if we should force the player
		; to recruite a avaliable pokemon.
		; Original function asks if the player wants to
		; recruit a pokemon.
		; We don't need any of the parameter, so forward them
		; Register usage:
		; Params: R0-R3, Stack
		; Caller: R4-R11
		.func check_force_recruite_dungeon
			; Save registers we are going to use on the stack.
			; !!WARNING!!
			; Pop them before returning to caller
			; or if original target gets called.
			stmdb sp!,{r0,r1,r2,r3,lr}
			mov r0,#CONFIG_FORCE_RECRUIT_BIT
			bl config_get_bit
			cmp r0,#0x01
			ldmia sp!,{r0,r1,r2,r3,lr}
			bne @@call_original
			mov r0,#0x01
			bx lr

		@@call_original:
			; call the original function
			b OV29_FUNC_ASK_PLAYER_YES_NO
		.endfunc
		.pool

;-------------------------------------------------------------------
; Function force player to name pokemon
;-------------------------------------------------------------------

		; Function to check if we should force the player
		; to recruite a avaliable pokemon.
		; Original function asks if the player wants to
		; recruit a pokemon.
		; We don't need any of the parameter, so forward them.
		; Register usage:
		; Params: R0-R3, Stack
		; Caller: R4-R11
		.func check_force_name_dungeon
			; Save registers we are going to use on the stack.
			; !!WARNING!!
			; Pop them before returning to caller
			; or if original target gets called.
			stmdb sp!,{r0,r1,r2,r3,lr}

			; at this point we are sure we have a recruit
			; check if we only allow one per dungeon and
			; mark dungeon as "used"
			mov r0,#CONFIG_ONE_PER_DUNGEON
			bl config_get_bit
			cmp r0,#0x01

			ldr r1,=OV29_PTR_DUNGEON_STRUCT ; get address to our dungeon
			ldr r1,[r1,#0x00]

			;bne @@skip_dungeon_not_allow

			moveq r0,#0x00
			streqb r0,[r1,#0x759] ; set recruiting_enabled to false


		;@@skip_dungeon_not_allow:
			ldrb r0,[r1,#0x748] ; load dungeon id
			bl dungeon_set_bit


			mov r0,#CONFIG_FORCE_NAME_BIT
			bl config_get_bit
			cmp r0,#0x01
			ldmia sp!,{r0,r1,r2,r3,lr}
			bne @@call_original
			mov r0,#0x01
			bx lr

		@@call_original:
			; call the original function
			b OV29_FUNC_ASK_PLAYER_YES_NO
		.endfunc
		.pool

		.pool

;-------------------------------------------------------------------
; Function to ask player for config
;-------------------------------------------------------------------

		.func ask_player_for_config
			stmdb sp!,{r0,r1,r2,r3,r4,r5,r6,r7,r8,lr}
			sub sp,sp,#0x10 ; get memory for our portrait struct

			ldr r5,=config_dialog_text_ids

			mov r0,#CONFIG_CONFIG_DONE_BIT
			bl config_get_bit
			cmp r0,#0x01
			beq @@config_done

			mov r0,#CONFIG_CHECK_USED_SAVEGAME_BIT
			bl config_get_bit
			cmp r0,#0x00

			ldreq r4,=CONFIG_TEXT_ID_INTRO_CLEAN_SAVEGAME
			streqh r4,[r5,0x00]

			bl config_init

			; Welcome player depending on state of savegame
			;------------------------------------------------

			mov r0,sp ; should be our pointer to our portrait buffer ...
			ldr r1,=ROKA_POKEMON_ID
			mov r2,#0x01 ; portrait expression happy (take the number skytemple shows and divide it by 2 ... flipped versions don't count towards the id here)
			bl OV29_FUNC_SET_PORTRAIT_DATA

		@@continue_config:

			;; We are ready to ask questions
			;;-------------------------------------------------------------------

			mov r4,#0x00

			; Question loop
			;-------------------------------------------------------------------

			@@ask_loop:

				; load our skip counts
				ldrb r6,[r5,0x02] ; skip count and question type
				ldrb r7,[r5,0x03] ; skip count and default answer

				mov r0,sp ; should be our pointer to our portrait buffer ...
				ldrb r1,[r5,0x04] ; load expression and type
				bl ARM9_FUNC_SET_PORTRAIT_EXPRESSION

				mov r0,sp ; should be our pointer to our portrait buffer ...
				ldrb r1,[r5,#0x00] ; our message id we want to show
				ldrb r2,[r5,#0x01] ; our message id we want to show
				orr r1,r2, lsl #0x08

				tst r6,#0x80 ; check if we have a question or only a message
				beq @@only_display

				; Ask Question
				;-------------------------------------------------------------------

				lsr r2,r7,0x07 ; defaut option choosen when menu is shown
				mov r3,#0x01 ; unknown ... maybe wait for player???
				bl OV29_FUNC_SHOW_YES_NO_MENU
				cmp r0,#0x01
				moveq r6,r7

				sub r0,r4,#0x01
				bleq config_set_bit
				blne config_clr_bit
				b @@loop_test

			@@only_display:

				; Only display message
				;-------------------------------------------------------------------

				mov r2,#0x01 ; wait for player
				bl OV29_FUNC_DISPLAY_MESSAGE2

			@@loop_test:

				mov r0,#0x05
				and r6,r6,#0x7F
				mul r0,r6,r0
				add r5,r5,r0
				add r4,r4,r6
				cmp r4,#CONFIG_QUESTION_COUNT
				blt @@ask_loop

		@@config_done:
			add sp,sp,#0x10 ; free memory for our portrait struct
			ldmia sp!,{r0,r1,r2,r3,r4,r5,r6,r7,r8,pc}
		.endfunc
		.pool

		config_dialog_text_ids:
			; TextID, steps if no, steps if yes, portrait, message type (lower nibble) + default answer (upper nibble)
			.dh CONFIG_TEXT_ID_INTRO_DIRTY_SAVEGAME			:: .db 0x01, 0x01, 0x01
			.dh CONFIG_TEXT_ID_BEFORE_WE_START				:: .db 0x01, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_IF_NUZLOCKE			:: .db 0x81, 0x03, 0x00
			.dh CONFIG_TEXT_ID_STUNNED_THAT_NO				:: .db 0x01, 0x01, 0x11
			.dh CONFIG_TEXT_ID_SIGH_HAVE_FUN				:: .db 0x0F, 0x0F, 0x10
			.dh CONFIG_TEXT_ID_HERE_ARE_THE_QUESTIONS		:: .db 0x01, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_NO_REVIVE			:: .db 0x81, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_MARK_DEAD			:: .db 0x81, 0x81, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_FORCE_RECRUITE		:: .db 0x81, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_FORCE_NAME			:: .db 0x81, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_ONE_PER_DUNGEON		:: .db 0x81, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_CLAUSE			:: .db 0x87, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_EVO_LINE		:: .db 0x81, 0x81, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_ALL_CAUGHT		:: .db 0x81, 0x81, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_HERO			:: .db 0x81, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_PARTNER		:: .db 0x81, 0x01, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_DEAD			:: .db 0x81, 0x81, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_GENDER			:: .db 0x81, 0x01, 0x00
			.dh CONFIG_TEXT_CONFIG_DONE						:: .db 0x01, 0x01, 0x0B

		.db 0x00
;-------------------------------------------------------------------
; Function that checks if we are allowed to recruite a pokemon
;-------------------------------------------------------------------

		; Function to check the dupes clause of a nuzlocke
		; and if we are allowed to to recruite according to
		; one mon per dungeon rule
		; The orginial function is a debug function that
		; always returns true, so we don't need to call
		; the orginal
		; Register usage:
		; Params: monster_id
		; Caller: R4
		.func check_recruit_allowed

			; save register we are going to use on the stack
			; !!WARNING!!
			; pop them before returning to caller
			; or if original target gets called
			stmdb sp!,{r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,lr}

			; r0 = monster_id
			bl compute_monster_id
			mov r4,r0 ; monster_id
			mov r10,#0x01 ; default return value is true
			; r4 = monster_id
			sub sp,sp,#0x10 ; get memory for our evolution data

			; Do we even want to check for dupes?
			;------------------------------------------------

			mov r0,#CONFIG_DUPE_CLAUSE
			bl config_get_bit
			cmp r0,#0x00
			beq @@function_end

			; Get our evolution Data
			;------------------------------------------------
			mov r0,#CONFIG_DUPE_EVO_LINE
			bl config_get_bit
			cmp r0,#0x01

			strh r4,[sp,#0x00] ; store monster id

			movne r5,#0x01 ; we only have the normal monster id
			bne @@init_values

			; we want evo line to count
			mov r0,r4 ; get monster id
			add r1,sp,0x02 ; get our memory where we want our list
			mov r2,#0x01 ; we don't care about size of the sprite
			mov r3,#0x01 ; not sure if we should check for shedinja?
			bl ARM9_FUNC_GET_EVOLUTIONS ; fill our list
			add r5,r0,#0x01

			; todo: check if we neet to translate the evo monster ids because of gender ...

			; stack = null terminated evo list
		@@init_values:
			; Init some values we need
			;------------------------------------------------
			mov r1,#0x00 ; set up null value
			str r1,[sp,r5, lsl #0x01] ; write null to the end of our list

			ldr r4,=ARM9_PTR_TEAM_MEMBERS ; pointer to team member array
			ldr r4,[r4,#0x00]

			; r4 = team_member_ptr
			; r5 =
			; r6 = adventure log
			; r7 =
			; r8 =
			; r9 =
			; r10 = return value
			; stack = null terminated evo list

			; Check every cought pokemon
			;------------------------------------------------
		@@check_everyone:
			; check every cought pokemon if config says so
			mov r0,#CONFIG_DUPE_ALL_CAUGHT
			bl config_get_bit
			cmp r0,#0x01
			bne @@check_team

			mov r0,sp
			bl check_all_recruited_monsters_against_list
			cmp r0,#0x01
			moveq r10,#0x0
			bne @@function_end ; jump to end of function

			; Check team
			;------------------------------------------------
		@@check_team:
			mov r8,#0x00 ; we start with the first team member, the hero

			; r4 = team_member_ptr
			; r5 =
			; r6 = adventure log
			; r7 =
			; r8 = member_iter
			; r9 =
			; r10 = return value


			@@team_loop:
				ldrb r0,[r4,#0x00] ; get bool that shows if team member is valid
				cmp r0,#0x00	; check if team member is valid
				beq @@function_end

				cmp r8,0x02 ; is our member the hero or partner?
				bge @@loop_continue ; not hero or partner
				add r0,r8,#CONFIG_DUPE_HERO ; calculate our offset value (r8 is 0 or 1 here)
				bl config_get_bit
				cmp r0,#0x01
				bne @@loop_continue ; we do not want to check either hero or partner
				beq @@do_checks	; we want to check hero or partner

			@@loop_continue:

				cmp r8,0x05 ; check if we have hero, partner or the other fixed mons we want to skip
				blt @@skip_checks ; skip checks for fixed mons

			@@do_checks:

				ldrh r0,[r4,#0x04] ; get team member monster id
				bl compute_monster_id
				mov r5,r0
				; r5 = team member monster id

				; Do we even want to check dead pokemon?
				;------------------------------------------------
				mov r0,#CONFIG_DUPE_DEAD
				bl config_get_bit
				cmp r0,#1
				beq @@check_monster_id ; we do not want to check if monster is dead

				mov r0,r8
				bl dead_get_bit
				cmp r0,#0x01 ; check if member is dead
				beq @@skip_checks ; we got a hit so return early

				; Check team member id agains evo list
				;------------------------------------------------
			@@check_monster_id:
				mov r0,r5
				mov r1,sp

				bl check_monster_list ; test id against list
				cmp r0,0x01 ; did we have a hit?
				moveq r10,#0x00 ; set our return value
				beq @@function_end ; jump to function end

			@@skip_checks:
				add r4,r4,#ARM9_CONST_TEAM_MEMBER_SIZE ; move pointer to next team member

				ldr r0,=ARM9_PTR_MAX_TEAM_MEMBERS
				ldr r0,[r0,#0x00] ; max count of members
				cmp r8,r0
				add r8,r8,0x01
				blt @@team_loop


		@@function_end:

			cmp r10,#0x00
			moveq r0,#0x00
			ldreq r1,=#LOG_TEXT_ID_NUZLOCKE_RULE_DENIED_RECRUITE
			bleq OV29_FUNC_LOG_MESSAGE_BY_ID_WITH_POPUP

			mov r0,r10
			add sp,sp,#0x10
			ldmia sp!,{r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,pc}
		.endfunc
		.pool



;-------------------------------------------------------------------
; Function to display custom ui
;-------------------------------------------------------------------

		; Function to display custom ui
		; params: r0 = some struct
		; return: idk
		.func display_custom_ui
			stmdb sp!,{r0,lr} ; save the first parameter from the function
			bl OV29_FUNC_UNKNOWN_UI_FUNCTION
			ldmia sp!,{r1,lr} ; reload the first param of the function
			stmdb sp!,{r0,r2,r3,r4,r4,r5,r6,r7,r8,r9,r10,r11,lr}
			sub sp,sp,#0x04 ; we need this as 5th parameter later

			mov r8,r1 ; we need this pointer later ...

			ldr r1,=OV29_PTR_DUNGEON_STRUCT ; get address to our dungeon
			ldr r1,[r1,#0x00]
			ldrb r2,[r1,#0x759] ; load dungeon_recruite_enable

			add r3,r1,#0x21c
			add r3,r3,#0x1a000
			ldrb r9,[r3,#0x2f] ; load leader_pointed
			ldr r7,[r3,#0x10] ; load entity
			ldr r7,[r7,#0xb4] ; load monster

			cmp r9,0x00
			moveq r9,#0x1
			movne r9,#0x0

			ldrb r0,[r1,#0x748] ; lead dungeon_id
			bl ARM9_FUNC_IS_RECRUITING_ALLOWED
			cmp r0,0x00
			moveq r2,0x00

			mov r0,#DUNGEON_STATE_X_POS ; x-pos
			mov r1,#DUNGEON_STATE_Y_POS ; y-pos
			and r3,r2,#0x01 ; ally-mode, (green when 1, white if 0)
			bl OV29_FUNC_DISPLAY_NUMBER_TEXTURE_UI

			mov r0,r7
			mov r1,0x00
			bl get_belly_ui
			mov r2,r0

			mov r4,#BELLY_X_POS ; start x-pos
			cmp r2,#0x64
			addlt r4,0x08
			cmp r2,#0x0A
			addlt r4,0x08

			mov r0,r4 ; x-pos
			mov r1,#BELLY_Y_POS ; y-pos
			mov r3,r9 ; green when 1, white if 0
			bl OV29_FUNC_DISPLAY_NUMBER_TEXTURE_UI
			add r4,r0

		.if SIMPLE_BELLY == 0x00
			mov r0,r8 ; pointer to some struct ... idk
			mov r1,r4 ; x-pos
			mov r2,#BELLY_Y_POS ; y-pos
			mov r3,#0x17 ; the char itself '/'
			str r10,[sp,0x00] ; 5th param goes on the stack
			bl OV29_FUNC_DISPLAY_CHAR_TEXTURE_UI
			add r4,r0
			sub r4,0x03

			mov r0,r7
			mov r1,0x01
			bl get_belly_ui
			mov r2,r0

			mov r0,r4 ; x-pos
			mov r1,#BELLY_Y_POS ; y-pos
			mov r3,r9 ; green when 1, white if 0
			bl OV29_FUNC_DISPLAY_NUMBER_TEXTURE_UI
			; add r4,r0
		.endif

			add sp,sp,#0x04
			ldmia sp!,{r0,r2,r3,r4,r4,r5,r6,r7,r8,r9,r10,r11,pc}
		.endfunc
		.pool


	.endarea


;-------------------------------------------------------------------
; Area where the tip related message ids and stuff were now some helper functions
;-------------------------------------------------------------------

	.org OV29_AREA_TIP_DATA_START
	.area OV29_AREA_TIP_DATA_END - OV29_AREA_TIP_DATA_START, 0

;-------------------------------------------------------------------
; Function that runs at the start of a dungeon to check the one per dungeon rule
;-------------------------------------------------------------------

		.func init_only_one_per_dungeon
			stmdb sp!,{r0,r1,r2,r3,r4,r5,lr}
			mov r0,#CONFIG_CONFIG_DONE_BIT
			bl config_get_bit
			cmp r0,#0x01
			beq @@dungeon_end

			ldr r4,=ARM9_PTR_TEAM_MEMBERS ; pointer to team member array
			ldr r4,[r4,#0x00]
			mov r5,#0x05	; skip fixed team members
			@@team_loop:
				ldrb r0,[r4,#0x00] ; get bool that shows if team member is valid
				cmp r0,#0x00	; check if team member is valid
				beq @@dungeon_end

				ldrb r0,[r4,#0x04] ; get team member dungeon id
				bl dungeon_set_bit

				add r4,r4,#ARM9_CONST_TEAM_MEMBER_SIZE ; move pointer to next team member


				ldr r0,=ARM9_PTR_MAX_TEAM_MEMBERS
				ldr r0,[r0,#0x00] ; max count of members
				cmp r5,r0
				add r5,r5,#0x01
				blt @@team_loop


		@@dungeon_end:

			mov r0,#CONFIG_ONE_PER_DUNGEON
			bl config_get_bit
			cmp r0,#0x01
			bne @@dungeon_done

			ldr r4,=OV29_PTR_DUNGEON_STRUCT ; get address to our dungeon
			ldr r4,[r4,#0x00]
			ldrb r0,[r4,#0x748] ; load dungeon id

			bl dungeon_get_bit
			cmp r0,#0x01
			moveq r0,#0x00
			streqb r0,[r4,#0x759] ; set recruiting_enabled to false

		@@dungeon_done:
			ldmia sp!,{r0,r1,r2,r3,r4,r5,pc}
		.endfunc
		.pool
	.endarea

	.org OV29_AREA_TIP_DATA2_START
	.area OV29_AREA_TIP_DATA2_END - OV29_AREA_TIP_DATA2_START, 0
;-------------------------------------------------------------------
; Code insert to skip revive if so desired
;-------------------------------------------------------------------

		; not a function but an insert to hook into the revive system and skip
		; it if the config says so
		skip_revive_test_insert:
			stmdb sp!,{r0,r1,r2,r3,r4,r5,lr}
			mov r0,#CONFIG_NO_REVIVE
			bl config_get_bit
			mov r5,r0
			cmp r0,#0x01
			bne @@skip_log

			ldrb r0,[r4,#0x06] ; do we have a team member?
			cmp r0,0x00

			moveq r0,#0x00
			ldreq r1,=LOG_TEXT_ID_NUZLOCKE_RULE_DENIED_REVIVE
			bleq OV29_FUNC_LOG_MESSAGE_BY_ID_WITH_POPUP

		@@skip_log:
			cmp r5,#0x01
			ldmia sp!,{r0,r1,r2,r3,r4,r5,lr}
			beq OV29_LABEL_SKIP_REVIVE_END
			b skip_revive_test_return
		.pool
	.endarea


;-------------------------------------------------------------------
; Code insert to draw custom ui
;-------------------------------------------------------------------

	org OV29_AREA_DISPLAY_UI_INSERT_START
	.area OV29_AREA_DISPLAY_UI_INSERT_END - OV29_AREA_DISPLAY_UI_INSERT_START, 0
		; for some reason there is a if in the original code where
		; the if and else part are doing exactly the same ...
		; condense that down and use it to add a function for belly data
		original_display_ui_part:
			ldrb r0,[r5,#0x2f]
			cmp r0,#0x0
			moveq r3,#0x1
			movne r3,#0x0
			mov r1,r7, lsl #0x10
			mov r2,r1, asr #0x10
			mov r0,r6
			mov r1,#0x0
			bl OV29_FUNC_DISPLAY_NUMBER_TEXTURE_UI
			b OV29_AREA_DISPLAY_UI_INSERT_END

		; Get belly data from a monster *
		; params:
		; r0 = monster *
		; r1 = current_belly = 0, max_belly = 1
		; return:
		; r0 = belly
		.func get_belly_ui
			stmdb sp!,{r1,r2,r3,lr}
			ldr r3,=0x146 ; offset to belly data

			cmp r1,0x01 ; check which belly data we want
			addeq r3,#0x04 ; offset by 4 because we want belly_max

			ldrh r1,[r0,r3] ; get belly/belly_max integer part from monster *
			add r3,#0x02
			ldrh r2,[r0,r3] ; get belly/belly_max fractional part from monster *
			orr r0,r1,r2, lsl #0x10 ; shift the fractional part into the upper part

			bl ARM9_FUNC_CEIL_FIXED_POINT
			ldmia sp!,{r1,r2,r3,pc}
		.endfunc
		.pool


	.endarea

.close


