
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


	; Call function to display dungeon status here
	; will get called as long as we are not inside a boss fight
	; call original function afterwards when custom display done
	; params: r0 = dungeon_id
	; return: if dungeon goes up
	.org OV29_HOOK_SHOW_RECRUITE_STATE
		bl display_custom_ui




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

			bne @@skip_dungeon_not_allow

			moveq r0,#0x00
			streqb r0,[r1,#0x759] ; set recruiting_enabled to false


		@@skip_dungeon_not_allow:
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

		.pool

;-------------------------------------------------------------------
; Function to ask player for config
;-------------------------------------------------------------------

		.func ask_player_for_config
			stmdb sp!,{r0,r1,r2,r3,r4,r5,r6,r7,r8,lr}
			sub sp,sp,#0x10 ; get memory for our portrait struct

			mov r0,#CONFIG_CONFIG_DONE_BIT
			bl config_get_bit
			cmp r0,#0x01
			beq @@config_done

			mov r0,#CONFIG_CHECK_USED_SAVEGAME_BIT
			bl config_get_bit
			cmp r0,#0x00
			ldreq r4,=CONFIG_TEXT_ID_INTRO_CLEAN_SAVEGAME
			ldrne r4,=CONFIG_TEXT_ID_INTRO_DIRTY_SAVEGAME

			bl config_init

			; Welcome player depending on state of savegame
			;------------------------------------------------

			mov r0,sp ; should be our pointer to our portrait buffer ...
			ldr r1,=ROKA_POKEMON_ID
			mov r2,#0x01 ; portrait expression happy (take the number skytemple shows and divide it by 2 ... flipped versions don't count towards the id here)
			bl OV29_FUNC_SET_PORTRAIT_DATA

			mov r0,sp ; should be our pointer to our portrait buffer ...
			mov r1,r4 ; our message id we want to show
			mov r2,#0x01 ; wait for player to acknowledge the message
			bl OV29_FUNC_DISPLAY_MESSAGE2

		@@continue_config:

			;; We are ready to ask questions
			;;-------------------------------------------------------------------

			mov r4,#0x00
			ldr r5,=config_dialog_text_ids

			; Question loop
			;-------------------------------------------------------------------

			@@ask_loop:

				; load our skip counts
				ldrb r6,[r5,0x02]
				ldrb r7,[r5,0x03]
				ldrb r8,[r5,0x05] ; question type and default answer

				mov r0,sp ; should be our pointer to our portrait buffer ...
				ldrb r1,[r5,0x04] ; lead expression and type
				bl ARM9_FUNC_SET_PORTRAIT_EXPRESSION

				mov r0,sp ; should be our pointer to our portrait buffer ...
				ldrh r1,[r5,#0x00] ; our message id we want to show

				tst r8,#0x01 ; check if we have a question or only a message
				beq @@only_display

				; Ask Question
				;-------------------------------------------------------------------

				lsr r2,r8,0x04 ; defaut option choosen when menu is shown
				mov r3,#0x01 ; unknown ... maybe wait for player???
				bl OV29_FUNC_SHOW_YES_NO_MENU
				cmp r0,#0x01
				moveq r6,r7

				mov r0,r4
				bleq config_set_bit
				blne config_clr_bit
				b @@loop_test

			@@only_display:

				; Only display message
				;-------------------------------------------------------------------

				mov r2,#0x01 ; wait for player
				bl OV29_FUNC_DISPLAY_MESSAGE2

			@@loop_test:

				mov r0,#0x06
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
			.dh CONFIG_TEXT_ID_BEFORE_WE_START				:: .db 0x01, 0x01, 0x00, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_IF_NUZLOCKE			:: .db 0x01, 0x03, 0x00, 0x01
			.dh CONFIG_TEXT_ID_STUNNED_THAT_NO				:: .db 0x01, 0x01, 0x11, 0x00
			.dh CONFIG_TEXT_ID_SIGH_HAVE_FUN				:: .db 0x0F, 0x0F, 0x10, 0x00
			.dh CONFIG_TEXT_ID_HERE_ARE_THE_QUESTIONS		:: .db 0x01, 0x01, 0x00, 0x00
			.dh CONFIG_TEXT_ID_QUESTION_NO_REVIVE			:: .db 0x01, 0x01, 0x00, 0x01
			.dh CONFIG_TEXT_ID_QUESTION_MARK_DEAD			:: .db 0x01, 0x01, 0x00, 0x11
			.dh CONFIG_TEXT_ID_QUESTION_FORCE_RECRUITE		:: .db 0x01, 0x01, 0x00, 0x01
			.dh CONFIG_TEXT_ID_QUESTION_FORCE_NAME			:: .db 0x01, 0x01, 0x00, 0x01
			.dh CONFIG_TEXT_ID_QUESTION_ONE_PER_DUNGEON		:: .db 0x01, 0x01, 0x00, 0x01
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_CLAUSE			:: .db 0x07, 0x01, 0x00, 0x01
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_EVO_LINE		:: .db 0x01, 0x01, 0x00, 0x11
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_ALL_CAUGHT		:: .db 0x01, 0x01, 0x00, 0x11
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_HERO			:: .db 0x01, 0x01, 0x00, 0x01
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_PARTNER		:: .db 0x01, 0x01, 0x00, 0x01
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_DEAD			:: .db 0x01, 0x01, 0x00, 0x11
			.dh CONFIG_TEXT_ID_QUESTION_DUPE_GENDER			:: .db 0x01, 0x01, 0x00, 0x01
			.dh CONFIG_TEXT_CONFIG_DONE						:: .db 0x01, 0x01, 0x0B, 0x00


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
			bne @@skip_get_evo

			strh r4,[sp,#0x00] ; store monster id

			; we want evo line to count
			mov r0,r4 ; get monster id
			add r1,sp,0x02 ; get our memory where we want our list
			mov r2,#0x01 ; we don't care about size of the sprite
			mov r3,#0x01 ; not sure if we should check for shedinja?
			bl ARM9_FUNC_GET_EVOLUTIONS ; fill our list
			add r5,r0,#0x01

			; todo: check if we neet to translate the evo monster ids because of gender ...

			b @@init_values
		@@skip_get_evo:
			mov r5,#0x01 ; we only have the normal monster id

			; stack = null terminated evo list
		@@init_values:
			; Init some values we need
			;------------------------------------------------
			mov r1,#0x00 ; set up null value
			str r1,[sp,r5, lsl #0x01] ; write null to the end of our list

			ldr r4,=ARM9_PTR_TEAM_MEMBERS ; pointer to team member array
			ldr r4,[r4,#0x00]

			ldr r6,=ARM9_PTR_ADVENTURE_LOG ; get pointer to cought pokemon array
			ldr r6,[r6,#0x00]
			; .definelabel ARM9_CONST_TEAM_MEMBER_SIZE, 0x44

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

			mov r3,sp
			; r3 = evo list ptr
			@@check_everyone_loop:
				ldrh r2,[r3,#0x00] ; get monster id from our evo list
				; r2 = monster_id
				cmp r2,#0x00 ; check if end
				beq @@check_team ; break out of the loop

				lsr r1,r2,#0x03 ; calculate byte to look into bit array (pos/8)
				; r1 = byte offset
				add r1,r1,#0x44 ; offset our index to the right bit array
				; r1 = byte offset
				ldrb r0,[r6,r1]	; load actual byte with our bits
				; r0 = byte to check
				and r2,#0x07	; get the bit address we want to check (pos%8)
				; r1 = bit offset
				mov r1,#0x01
				; r2 = 0x01
				tst r0,r2, lsl r1 ; check if our bit is set by shifting 0x01 to the right point
				movne r10,#0x00 ; we found a match set return value
				bne @@function_end ; jump to end of function


				add r3,r3,#0x02 ; move our pointer to the next id
				b @@check_everyone_loop


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
			mov r0,r10
			add sp,sp,#0x10
			ldmia sp!,{r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,pc}
		.endfunc
		.pool


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


;-------------------------------------------------------------------
; Area where the tip related message ids and stuff were now some helper functions
;-------------------------------------------------------------------

	.org OV29_AREA_TIP_DATA_START
	.area OV29_AREA_TIP_DATA_END - OV29_AREA_TIP_DATA_START, 0
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



;-------------------------------------------------------------------
; Function to display custom ui
;-------------------------------------------------------------------

		; Function to display custom ui
		; params: r0 = dungeon_id
		; return: if dungeon goes up
		.func display_custom_ui
			stmdb sp!,{r0,r1,r2,r3,lr}

			ldr r1,=OV29_PTR_DUNGEON_STRUCT ; get address to our dungeon
			ldr r1,[r1,#0x00]
			ldrb r2,[r1,#0x759] ; load dungeon_recruite_enable

			mov r0,#0xF8 ; x-pos
			mov r1,#0x00 ; y-pos
			and r3,r2,#0x01 ; ally-mode, (green when 1, white if 0)

			bl OV29_FUNC_DISPLAY_NUMBER_TEXTURE_UI

			ldmia sp!,{r0,r1,r2,r3,lr}

			b ARM9_FUNC_DUNGEON_GOES_UP
		.endfunc
		.pool

;-------------------------------------------------------------------
; Code insert to skip revive if so desired
;-------------------------------------------------------------------

		; not a function but an insert to hook into the revive system and skip
		; it if the config says so
		skip_revive_test_insert:
			stmdb sp!,{r0}
			mov r0,#CONFIG_NO_REVIVE
			bl config_get_bit
			cmp r0,#0x01
			ldmia sp!,{r0}
			beq OV29_LABEL_SKIP_REVIVE_END
			b skip_revive_test_return
	.endarea
.close


