;************************************************************************************************************
; File: group17.asm
;
; Authors (Group 17):
;	Bibiana Andre, 94158
;	Filipe Abreu, 106046
;	Tiago Antunes, 106543
;
; Course: IST, LEIC - ALAMEDA
;
; Description: this file contains our project's code. Load this file onto the CPU (PEPE-16) 
; and run the simulation. Note that the code has been formated properly but sometimes 
; (for reasons unknown to us) it might not be, this usually happens when the code is opened on 
; "notepad". To prevent this, open this file with "Visual Studio Code". 
;
; CHANGELOG: final adjustments made and all bugs corrected.
;
;************************************************************************************************************

;============================================================================================================
; CONSTANTS:
;============================================================================================================

NULL 						EQU 0000H   		; value equal to zero

GAME_START					EQU 0000H			; when the player in in the game's start menu
GAME_PLAY					EQU 0001H 			; when the player is in mid gameplay
GAME_PAUSE   				EQU 0002H			; when the player pauses the game

KEY_NULL        			EQU 0FFFFH  		; value equal to zero
KEYPAD_LINES    			EQU 0C000H  		; peripheral address of the lines
KEYPAD_COLUMN   			EQU 0E000H  		; peripheral address of the columns/PIN
LINE_MASK    				EQU 0008H  			; mask used search every line of the keyboard
MASK_2_LSD					EQU 0011b   		; mask for the 2 LSD
DISPLAYS     				EQU 0A000H  		; address used to access the displays

HEXTODEC_MSD 				EQU 0064H  			; value to get the most significant digit (100 in decimal)
HEXTODEC_LSD 				EQU 000AH  			; value used to get the least significant digit (10 in decimal)
START_ENERGY_HEX			EQU 0064H
MIN_ENERGY_HEX				EQU 0000H
MAX_POSSIBLE_ENERGY			EQU 03E7H			; max value that the display can support (999 in decimal)
MOVEMENT_ENERGY_DECREASE	EQU 0FFFDH			; energy decrease from the spaceship movement
EXPLORER_ENERGY_DECREASE	EQU 0FFFBH			; energy decrease from the lauch of an explorer
ASTEROID_ENERGY_INCREASE	EQU 0019H			; energy increase from mining an asteroid

SCREEN_SELECT				EQU 6004H			; command to select a pixel screen (0-15)
DEF_LINE    				EQU 600AH			; command adress to define a line 
DEF_COLUMN   				EQU 600CH			; command adress to defin e a column
DEF_PIXEL    				EQU 6012H			; command adress to write a pixel
DELETE_WARNING				EQU 6040H			; command adress to delete no background warning
DELETE_SCREENS				EQU 6002H			; command adress to delete all existing pixels
SELECT_BACKGROUND 			EQU 6042H			; command adress to select a background image
SELECT_FOREGROUND 			EQU 6046H  			; address of the command to select a foreground
DELETE_FOREGROUND 			EQU 6044H  			; address of the command to delete a foreground
PLAY_MEDIA					EQU 605AH			; command adress to play a video/sound
MEDIA_CYCLE       			EQU 605CH  			; address of the command to play a video/sound on repeat
MEDIA_STOP        			EQU 6068H  			; address of the command to make all videos/sounds stop
SOUND_PAUSE       			EQU 605EH  			; address of the command to pause a specific sound
SOUND_RESUME      			EQU 6060H  			; address of the command to resume a specific sound
MEDIA_STATE       			EQU 6052H  			; address of the command to obtain the state of a video/sound

;---------------------------------------------- GAME ELEMENTS -----------------------------------------------

HEIGHT_SPACESHIP			EQU		5			; height of the spaceship 
LENGTH_SPACESHIP			EQU		13			; length of the spaceship
SPACESHIP_START_Y			EQU		31			; starting y position of spaceship (bottom left pixel)
SPACESHIP_START_X			EQU		26 			; starting x position of spaceship (bottom left pixel)
SPACESHIP_LEFT_SHOOTER		EQU		28			; column of spaceship left shooter
SPACESHIP_RIGHT_SHOOTER		EQU		36			; column of spaceship right shooter
SPACESHIP_SCREEN			EQU		0001H		; screen to draw the spaceship in

HEIGHT_PANEL				EQU		3			; height of the spaceship LED instrument panel
LENGTH_PANEL				EQU		5			; length of the spaceship LED instrument panel 
PANEL_START_Y				EQU		31			; starting y position of the panel (bottom left pixel)	
PANEL_START_X				EQU		30			; starting x position of the panel (bottom left pixel)
PANEL_SCREEN				EQU		0000H		; screen to draw the panel in 

HEIGHT_ASTEROID				EQU		5			; height of the asteroid
LENGTH_ASTEROID				EQU		5			; length of the asteroid
ASTEROID_START_Y			EQU		4			; starting y position of all asteroids (bottom left pixel)
ASTEROID_LEFT_X				EQU		0			; starting x position of left asteroid (bottom left pixel)
ASTEROID_CENTER_X			EQU		30			; starting x position of middle asteroid (bottom left pixel)
ASTEROID_RIGHT_X			EQU		59			; starting x position of right asteroid (bottom left pixel)
NUM_ASTEROIDS				EQU		0004H		; max possible number of asteroids in the screen at a time
MAX_LINE_SCREEN				EQU		31			; max line (bottom of the screen) the top of the asteroid can be at

EXPLORER_SCREEN				EQU		0001H		; screen to draw the explorer in
EXPLORER_START_Y			EQU		26			; starting y position of all explorers 
EXPLORER_VERTICAL_X			EQU		32			; starting x position of vertical explorer 
EXPLORER_LEFT_X				EQU		27			; starting x position of (diagonal) left explorer 
EXPLORER_RIGHT_X			EQU		37			; starting x position of (diagonal) right explorer 
MAX_EXPLORER_DISTANCE		EQU 	14

NO_MOVE						EQU		0000H		; to indicate that an object does not move
MOVE_LEFT					EQU		0001H		; to indicate that an object moves diagonally to the left
MOVE_DOWN					EQU		0002H		; to indicate that an object moves down vertically
MOVE_RIGHT					EQU		0003H		; to indicate that an object moves diagonally to the right

;------------------------------------------------- COLOURS --------------------------------------------------

VIOLET						EQU		0F80FH		; colour violet  
PINK						EQU		0FF0CH		; colour pink 
RED 						EQU		0FF00H  	; colour red 
DARK_ORANGE					EQU		0FF60H		; colour dark orange
ORANGE						EQU		0FFA0H		; colour orange 
YELLOW						EQU 	0FFF0H		; colour yellow 
LIGHT_KHAKI					EQU		0FBD9H		; colour light khaki 
KHAKI						EQU		0F894H		; colour khaki 
DARK_KHAKI					EQU		0F460H		; colour dark khaki
GREEN						EQU 	0F0F0H 		; colour green 
LIGHT_BLUE					EQU		0F7DFH		; colour light blue 
BLUE						EQU		0F00FH		; colour blue 
NAVY						EQU		0F357H		; colour navy blue
DARK_NAVY					EQU		0F035H		; colour dark navy blue 
LIGHT_GREY					EQU 	0FBBBH		; colour light grey

;============================================================================================================
; VARIABLES:
;============================================================================================================

PLACE 1000H

ENERGY_CHANGE:		LOCK 	NULL				; the value to alter the energy of the ship
ENERGY_HEX:			WORD	START_ENERGY_HEX	; starting value of the spaceship's energy

KEY_PRESSED:		LOCK 	KEY_NULL			; value of the key initially pressed on the current loop
GAME_MODE:			WORD 	GAME_START			; variable that stores the current game state	
NEXT_PATTERN:		WORD 	0					; variable to store the next LED pattern

CHANGE_LED: 		LOCK 	NULL				; indicates (in interruption context) when to change the LEDs
ASTEROID_MOVE:		LOCK 	NULL				; indicates (in interruption context) when to move the asteroids
EXPLORER_MOVE:		LOCK  NULL  				; indicates (in interruption context) when to move the explorer(s)

EXPLORER_VERTICAL_BOOL:		 WORD  NULL  		; to indicate if there is a vertical explorer ongoing
EXPLORER_LEFT_BOOL:          WORD  NULL			; to indicate if there is a left explorer ongoing
EXPLORER_RIGHT_BOOL:         WORD  NULL			; to indicate if there is a right explorer ongoing

;============================================================================================================
; PROCESSES:
;============================================================================================================

	STACK 100H 
SP_initial:

	STACK 100H 
SP_Gameplay:

	STACK 100H
SP_KeyFinder:

; initial stack pointer of each "Asteroid" process
	STACK 100H 								 ;reserved storage for the stack of the first asteroid process
SP_Asteroid_1:								 ;adress to initialize this process's SP					

	STACK 100H 								; reserved storage for the stack of the second asteroid process
SP_Asteroid_2:								; adress to initialize this process's SP

	STACK 100H 								; reserved storage for the stack of the third asteroid process
SP_Asteroid_3:								; adress to initialize this process's SP	

	STACK 100H 								; reserved storage for the stack of the fourth asteroid process
SP_Asteroid_4:								; adress to initialize this process's SP

	STACK 100H
SP_explorer_vertical:

    STACK 100H
SP_explorer_left:

    STACK 100H
SP_explorer_right:

	STACK 100H								
SP_EnergyHandling:

	STACK 100H
SP_SpaceshipLEDs:
								
;============================================================================================================
; IMAGES:
;============================================================================================================

; ----------------------------------------------- SPACESHIP -------------------------------------------------

; table defining the spaceship image (from bottom to top)
SHIP_PATTERN:	
	WORD	LENGTH_SPACESHIP, HEIGHT_SPACESHIP
	WORD 	NAVY, NAVY, DARK_NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, DARK_NAVY, NAVY, NAVY
	WORD 	NAVY, NAVY, DARK_NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, DARK_NAVY, NAVY, NAVY
	WORD 	NAVY, NAVY, DARK_NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, DARK_NAVY, NAVY, NAVY
	WORD 	NULL, NAVY, NULL, DARK_NAVY, NAVY, NAVY, NAVY, NAVY, NAVY, DARK_NAVY, NULL, NAVY, NULL
	WORD	NULL, NAVY, NULL, NULL, DARK_NAVY, DARK_NAVY, NULL, DARK_NAVY, DARK_NAVY, NULL, NULL, NAVY, NULL

; image of the spaceship in the given position
SHIP:								
	WORD	SPACESHIP_SCREEN
	WORD	SPACESHIP_START_Y, SPACESHIP_START_X
	WORD 	NO_MOVE					
	WORD	SHIP_PATTERN

; ----------------------------------------------- LED PANEL -------------------------------------------------

; table defining the image of the first LED panel (from bottom to top)
PANEL_PATTERN_1:
	WORD	LENGTH_PANEL, HEIGHT_PANEL
	WORD	NULL, GREEN, PINK, RED, NULL
	WORD	LIGHT_BLUE, LIGHT_GREY, YELLOW, VIOLET, GREEN
	WORD	NULL, RED, LIGHT_BLUE, YELLOW, NULL

; table defining the image of the second LED panel (from bottom to top)
PANEL_PATTERN_2:
	WORD	LENGTH_PANEL, HEIGHT_PANEL
	WORD	NULL, PINK, RED, VIOLET, NULL
	WORD	GREEN, LIGHT_BLUE, GREEN, LIGHT_GREY, YELLOW
	WORD	NULL, YELLOW, LIGHT_BLUE, RED, NULL

; table defining the image of the third LED panel (from bottom to top)
PANEL_PATTERN_3:
	WORD	LENGTH_PANEL, HEIGHT_PANEL
	WORD	NULL, RED, VIOLET, GREEN, NULL
	WORD	PINK, YELLOW, YELLOW, BLUE, LIGHT_GREY
	WORD	NULL, LIGHT_BLUE, GREEN, LIGHT_GREY, NULL

; table defining the image of the fourth LED panel (from bottom to top)
PANEL_PATTERN_4:
	WORD	LENGTH_PANEL, HEIGHT_PANEL
	WORD	NULL, GREEN, PINK, LIGHT_BLUE, NULL
	WORD	LIGHT_GREY, VIOLET, YELLOW, BLUE, PINK
	WORD	NULL, RED, RED, GREEN, NULL

; table defining the image of the fifth LED panel (from bottom to top)
PANEL_PATTERN_5:
	WORD	LENGTH_PANEL, HEIGHT_PANEL
	WORD	NULL, YELLOW, GREEN, LIGHT_GREY, NULL
	WORD	RED, BLUE, GREEN, BLUE, LIGHT_BLUE
	WORD	NULL, PINK, LIGHT_GREY, GREEN, NULL

PANEL_1:
	WORD	PANEL_SCREEN 
	WORD	PANEL_START_Y, PANEL_START_X
	WORD	NO_MOVE							
	WORD	PANEL_PATTERN_1

PANEL_2:
	WORD	PANEL_SCREEN 
	WORD	PANEL_START_Y, PANEL_START_X
	WORD	NO_MOVE
	WORD	PANEL_PATTERN_2

PANEL_3:
	WORD	PANEL_SCREEN 
	WORD	PANEL_START_Y, PANEL_START_X
	WORD	NO_MOVE
	WORD	PANEL_PATTERN_3

PANEL_4:
	WORD	PANEL_SCREEN 
	WORD	PANEL_START_Y, PANEL_START_X
	WORD	NO_MOVE
	WORD	PANEL_PATTERN_4

PANEL_5:
	WORD 	PANEL_SCREEN
	WORD	PANEL_START_Y, PANEL_START_X
	WORD	NO_MOVE
	WORD	PANEL_PATTERN_5

; list with all of the LED panels
PANELS:
	WORD	PANEL_1
	WORD	PANEL_2
	WORD	PANEL_3
	WORD	PANEL_4
	WORD	PANEL_5

; ----------------------------------------------- ASTEROIDS -------------------------------------------------

; table defining the bad asteroid image (from bottom to top)
BAD_ASTEROID_PATTERN:		
	WORD	LENGTH_ASTEROID, HEIGHT_ASTEROID
	WORD	DARK_ORANGE, NULL, ORANGE, NULL, DARK_ORANGE
	WORD	NULL, DARK_ORANGE, RED, DARK_ORANGE, NULL
	WORD	ORANGE, RED, LIGHT_BLUE, RED, ORANGE
	WORD	NULL, DARK_ORANGE, RED, DARK_ORANGE, NULL
	WORD	DARK_ORANGE, NULL, ORANGE, NULL, DARK_ORANGE

; table defining the good asteroid image (from bottom to top)
GOOD_ASTEROID_PATTERN:						
	WORD	LENGTH_ASTEROID, HEIGHT_ASTEROID
	WORD	NULL, KHAKI, LIGHT_KHAKI, KHAKI, NULL
	WORD	KHAKI, DARK_KHAKI, KHAKI, LIGHT_KHAKI, DARK_KHAKI
	WORD	DARK_KHAKI, KHAKI, KHAKI, KHAKI, KHAKI
	WORD	KHAKI, LIGHT_KHAKI, KHAKI, DARK_KHAKI, LIGHT_KHAKI
	WORD	NULL, KHAKI, KHAKI, LIGHT_KHAKI, NULL

; table defining the exploded asteroid pattern (from bottom to top)
EXPLOSION_PATTERN:						
	WORD	LENGTH_ASTEROID, HEIGHT_ASTEROID
	WORD	VIOLET, NULL, VIOLET, NULL, VIOLET
	WORD	NULL, VIOLET, NULL, VIOLET, NULL
	WORD	VIOLET, NULL, NULL, NULL, VIOLET 
	WORD	NULL, VIOLET, NULL, VIOLET, NULL
	WORD	VIOLET, NULL, VIOLET, NULL, VIOLET 

ASTEROID_1:
	WORD	0000H 						; asteroid screen
	WORD 	NULL						; asteroid reference line (bottom left pixel)
	WORD	NULL						; asteroid reference column (starting at random)
	WORD 	NO_MOVE						; asteroid random direction (left, down or right) 
	WORD 	NULL						; table of the asteroid image (good, bad or explosion)
										
ASTEROID_2:
	WORD	0001H 						
	WORD 	NULL						
	WORD	NULL						
	WORD 	NO_MOVE						
	WORD 	NULL						

ASTEROID_3:
	WORD	0002H 						
	WORD 	NULL						
	WORD	NULL						
	WORD 	NO_MOVE						
	WORD 	NULL

ASTEROID_4:
	WORD	0003H 						
	WORD 	NULL						
	WORD	NULL						
	WORD 	NO_MOVE						
	WORD 	NULL

ASTEROID_LIST:
	WORD 	ASTEROID_1
	WORD 	ASTEROID_2
	WORD 	ASTEROID_3
	WORD 	ASTEROID_4

; list of all asteroid instances of the process "Asteroid"
ASTEROIDS_SP_TABLE:
	WORD 	SP_Asteroid_1
	WORD 	SP_Asteroid_2
	WORD 	SP_Asteroid_3
	WORD 	SP_Asteroid_4

;------------------------------------------------ EXPLORER --------------------------------------------------

VERTICAL_EXPLORER:						
	WORD	EXPLORER_SCREEN
	WORD	EXPLORER_START_Y, EXPLORER_VERTICAL_X
	
LEFT_EXPLORER:
	WORD	EXPLORER_SCREEN
	WORD	EXPLORER_START_Y, EXPLORER_LEFT_X

RIGHT_EXPLORER:
	WORD	EXPLORER_SCREEN
	WORD	EXPLORER_START_Y, EXPLORER_RIGHT_X

;============================================================================================================
; INTERRUPTIONS TABLE:
;============================================================================================================

interruptionsTable:
	WORD 	int_MoveAsteroid
	WORD 	int_MoveExplorer
	WORD 	int_EnergyDecrease
	WORD	int_LEDs

;============================================================================================================
; MAIN
;============================================================================================================

PLACE      0000H

init:
	MOV SP, SP_initial
	MOV BTE, interruptionsTable
	MOV [DELETE_WARNING], R0

	CALL gameStart

	EI0
	EI1
	EI2
	EI3
	EI
	
	CALL 	gameControl
	CALL 	keyFinder						; starts the keyboard detection

	MOV  	R11, NUM_ASTEROIDS
	startAsteroids:
		SUB  	R11, 1       	  			; calculate the instance number of each asteroid
		CALL 	Asteroid		  			; new instance of the process "Asteroid"
		JNZ  	startAsteroids	  			; next asteroid instance

	CALL 	explorer_key_handle_left
	CALL 	explorer_key_handle_right
	CALL 	explorer_key_handle_vertical
	CALL 	energyHandling
	CALL 	changeLEDs						; spaceship LED lights loop
	
main:
	YIELD
	JMP 	main

;============================================================================================================
; PROCEDURES:
;============================================================================================================

PROCESS SP_Gameplay

; *************************************************************************************************
; gameControl: controls the game changes done by the player during gameplay.
; *************************************************************************************************

gameControl:
	MOV  	R0, [KEY_PRESSED]   			; locks the process until a key is pressed
	MOV  	R1, 000BH			 			; value to start the game ('B' for 'begin')
	SUB  	R0, R1              			; check if the pressed key was 'B'
	JZ   	gameBegin           			; if so, init the game
	CMP  	R0, 0002H           			; else, check if the 'D' key was pressed (BH + 2H = DH)
	JZ   	gamePause  						; if so, pauses the game
	CMP  	R0, 0003H           			; else, check if the 'E' key was pressed ('E' for 'exit')
	JZ   	gameExit			 			; if so, the game ends
	JMP  	gameControl      	 			; if no 'valid' key was pressed, wait until one is read.

; -------------------------------------------------------------------------------------------------
; gameStart: Shows the starting menu image
; -------------------------------------------------------------------------------------------------

gameStart:
	PUSH 	R0	
	
	CALL 	gameReset
	MOV 	R0, 0
	MOV 	[MEDIA_CYCLE], R0

	POP 	R0
	RET

gameBegin:
	MOV 	R0, [GAME_MODE]					; obtain current state of the game
	CMP 	R0, GAME_START					; check if the game is at starting point state (main menu)
	JNZ 	gameControl						; can't begin a game from a non-start state, back to game control

	CALL 	energyReset						; initializes the spaceship's starting energy
	MOV 	R0, 0
	MOV 	[MEDIA_STOP], R0
	MOV 	R0, 0
	MOV 	[SELECT_BACKGROUND], R0			; main gameplay background
	
gameBeginDraw:
	MOV 	R0, SHIP						; argument containing the spaceship information
	CALL 	draw_image						; draw spaceship
	MOV 	R1, START_ENERGY_HEX			; starting energy value
	MOV  	[ENERGY_HEX], R1          		; updates the energy value
	CALL 	hextodecConvert          			; converts the value
	MOV 	R0, GAME_PLAY					; obtain gameplay status
	MOV 	[GAME_MODE], R0					; change the game state to gameplay/in game
	MOV 	R0, 2
	MOV 	[MEDIA_CYCLE], R0				; plays the game main music on loop
	JMP 	gameControl

; -------------------------------------------------------------------------------------------------
; gamePause: either pauses or unpauses the current gameplay state.
; -------------------------------------------------------------------------------------------------

gamePause:
	MOV 	R0, [GAME_MODE]					; obtain current game state
	CMP 	R0, GAME_PLAY
	JZ 		gameStop						; if so, pauses the game
	CMP		R0, GAME_PAUSE
	JZ 		gameResume
	JMP 	gameControl						; ... cannot pause or unpause a game in a starting state

gameStop:
	MOV 	R1, GAME_PAUSE					; obtain pause game status
	MOV 	[GAME_MODE], R1					; change game state to paused
	MOV 	R1, 2
	MOV 	[SOUND_PAUSE], R1				; pauses the game main music
	MOV 	R1, 9
	MOV 	[PLAY_MEDIA], R1				; play pause sound effect
	JMP		gameControl

gameResume:
	MOV 	R1, 10
	MOV 	[PLAY_MEDIA], R1				; play unpause sound effect

gameResumeWait:							
	MOV 	R1, [MEDIA_STATE]
	CMP 	R1, NULL
	JNZ 	gameResumeWait					; wait for the sound effect to wear off

	MOV 	R1, GAME_PLAY					; obtain gameplay/in game status
	MOV 	[GAME_MODE], R1					; change the game's state to gameplay
	MOV 	R1, 2
	MOV 	[SOUND_RESUME], R1				; resumes the game's main music 
	JMP 	gameControl

; -------------------------------------------------------------------------------------------------
; gameExit: ends the game according to the player.
; -------------------------------------------------------------------------------------------------

gameExit:
	MOV 	R0, [GAME_MODE]					; obtain the current game state
	CMP 	R0, GAME_PLAY					; check if the game is in gameplay state
	JNZ 	gameControl						; cannot end a game in pause state or start state

	MOV  	[DELETE_SCREENS], R0      		; clears all the pixels in all screens (value of R0 is irrelevant)
	MOV 	R0, 2
	MOV 	[MEDIA_STOP], R0				; stops the game music
	MOV 	R1, 9
	MOV 	[PLAY_MEDIA], R1				; play sound effect for exiting the game
	MOV 	R0, 1	
	MOV 	[PLAY_MEDIA], R0				; play exit video

gameExitWait:
	MOV 	R0, [MEDIA_STATE]				; check if the exit video has finished
	CMP 	R0, NULL 						
	JNZ 	gameExitWait					; if not, wait until it ends

	CALL 	gameStart						; restarts the game by playing the starting animation
	JMP 	gameControl

gameReset:
	PUSH 	R1
	PUSH 	R2

	MOV  	R1, GAME_START
	MOV  	[GAME_MODE], R1         		; resets the game state to its starting menu
	CALL 	asteroidResetAll				; resets the asteroids to their initial values
	MOV 	R2, LEFT_EXPLORER				; resets all the explorers 
	CALL 	resetLeftExplorer
	MOV 	R2, VERTICAL_EXPLORER
	CALL	resetVerticalExplorer
	MOV 	R2, RIGHT_EXPLORER
	CALL 	resetRightExplorer

	POP 	R2
	POP 	R1
	RET

; -------------------------------------------------------------------------------------------------

PROCESS SP_KeyFinder

;**************************************************************************************************
; keyFinder - searches for the key that was pressed in the keyboard
;
; Registers used:
; - R2 -> line of the key being pressed
; - R3 -> column of the key being pressed
; - R5 -> pressed key (a value between 00H - 0FH)
; *************************************************************************************************

keyFinder:
	MOV 	R0, KEYPAD_LINES				; obtain peripheral adress of the lines
	MOV 	R1, KEYPAD_COLUMN				; obtain periferal adress of the columns
	MOV 	R2, LINE_MASK			
	MOV 	R4, 000FH				

keyFinderWait:
	YIELD 									; waits for a key to be pressed
	MOVB 	[R0], R2          				; sends the value of the current line to the peripheral
	MOVB 	R3, [R1]          				; saves the value of the column from the peripheral
	AND  	R3, R4            				; obtains the bits 0-3 from the column peripheral
	JNZ  	keyConvert        				; converts the key if a key is pressed (!= 0)

	SHR 	R2, 1             				; checks the next line
	JNZ 	keyFinderWait
	
	MOV 	R2, LINE_MASK     				; resets to the first line
	JMP 	keyFinderWait  

keyConvert:
	MOV 	R5, 0000H          				; initializes the pressed key at 0
	MOV 	R6, R2             				; backs up the value of the line into R6

keyConvertLine:
	SHR 	R6, 1              				; used to find the line of the pressed key
	JZ  	keyConvertColumn				; if it is zero then the line of the pressed key was found
	ADD 	R5, 0004H          				; every line has 4 keys
	JMP 	keyConvertLine

keyConvertColumn:
	SHR 	R3, 1             				; used to find the column of the pressed key
	JZ  	keySave	        				; if it is zero then the column of the pressed key was found
	ADD 	R5, 0001H          				; adds 1 for every key that was checked
	JMP 	keyConvertColumn

keySave:
	MOV 	[KEY_PRESSED], R5   			; saves the value of the pressed key (value between 00H - 0FH)

keyVerifyChange:
	YIELD
	MOVB [R0], R2            				; line with key that was previously pressed
	MOVB R3, [R1]            				; value of the column of the pressed key
	AND R3, R4								; obtains the bits 0-3 from the column peripheral
	JNZ keyVerifyChange						; if it is zero, then the key has been released 
	JMP keyFinder							; wait for a new key

;--------------------------------------------------------------------------------------------------
; draw_image - draws an image in the given line and column with the dimensions
;			   and colour(s) defined in its respective table.
; Registers used:
; - R0 -> argument containing the position and table of the image
; - R1 -> screen containing the image
; - R2 -> reference line
; - R3 -> reference column
; - R4 -> length (obtained from the image table)
; - R5 -> height (obtained from the image table)
; - R6 -> colour of the pixel (obtained from the image table)
; - R7 -> table of the image
; - R8 -> copy of the original adress of R7
;--------------------------------------------------------------------------------------------------

draw_image:
	PUSH R0
	PUSH R1              
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
    PUSH R7
	PUSH R8

	MOV 	R1, [R0]						; obtain the screen containing the image
	MOV 	[SCREEN_SELECT], R1				; select the screen containing the image
	ADD 	R0, 2							; adress of the image's reference line
	MOV 	R2, [R0]            			; obtain the image's reference line
	ADD 	R0, 2               			; adress of the image's reference column
	MOV 	R3, [R0]						; obtain the image's reference column
    ADD 	R0, 4               			; adress of the image's table
    MOV 	R7, [R0]            			; obtain the image's table
	MOV 	R8, R7 							; copy the original adress of the table
	SUB 	R0, 6 							; back to the adress of the reference line 
	MOV 	R4, [R7]            			; obtain the image's length
	ADD 	R7, 2               			; adress of the image's height
	MOV 	R5, [R7]            			; obtain the image's height
	ADD		R7, 2							; adress of the colour of 1st pixel (2 because length is a word)
	JMP 	draw_line						; starts drawing lines

draw_next_line:
	ADD 	R0, 2      	       				; adress of the image's initial column
	MOV 	R3, [R0]           				; back to initial column
	SUB 	R0, 2			   				; back to the adress of the reference line
	MOV 	R4, [R8]          				; reinitialize the image's length 
	SUB 	R2, 1              				; starts writing in the line above (on MediaCenter)
	SUB 	R5, 1              				; decreses the height of the image (one less line)
	JNZ 	draw_line						; draws the new line
	JMP 	exit_image_draw 				; if there are no more lines, exit 

draw_line:									; draws a line of pixels of the image from its table 
    MOV 	R6, [R7]						; obtain the colour of the next pixel of the image
	CALL 	write_pixel						; writes the current pixel
	ADD 	R7, 2	            			; adress of the colour of the next pixel (2 because each pixel colour is a word)
	ADD 	R3, 1               			; next column
	SUB 	R4, 1               			; decreses the length of the image (one less column)
	JNZ 	draw_line						; draws the next column
	JMP 	draw_next_line					; if there are no more columns, skip to the next line

exit_image_draw:
	POP 	R8
    POP 	R7
	POP 	R6
	POP 	R5
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	POP 	R0
	RET

write_pixel:
	MOV 	[DEF_LINE], R2					; select line
	MOV 	[DEF_COLUMN], R3				; select column
	MOV 	[DEF_PIXEL], R6 				; change the colour of the pixel in the given position
	RET

;--------------------------------------------------------------------------------------------------
; delete_image - deletes an image in the given line and column with the dimensions
; 				 defined in its respective table
; Registers used:
; - R0 - argument containing the position, screen and table of the image
; - R1 - screen containing the image
; - R2 - reference line
; - R3 - reference column
; - R4 - length (obtained from the image table)
; - R5 - height (obtained from the image table)
; - R6 - colour of the pixel (always 0)
; - R7 - table of the image
; - R8 - copy of the original adress of R7
;--------------------------------------------------------------------------------------------------

delete_image:
	PUSH 	R0
	PUSH 	R1
	PUSH 	R2
	PUSH 	R3
	PUSH 	R4
	PUSH 	R5
	PUSH 	R6
	PUSH 	R7
	PUSH 	R8

	MOV 	R1, [R0]							; obtain the image's screen
	MOV 	[SCREEN_SELECT], R1					; select the screen containing the image
	ADD 	R0, 2								; adress of the image's reference line
	MOV 	R2, [R0] 							; obtain the image's reference line
	ADD 	R0, 2    							; adress of the image's reference column
	MOV 	R3, [R0] 							; obtain the image's reference column
	ADD 	R0, 4    							; adress of the image's table
	MOV 	R7, [R0] 							; obtain the image's table
	MOV 	R8, R7  							; copy the original adress of the table
	MOV 	R4, [R7] 							; obtain the image's length
	ADD 	R7, 2    							; adress of the image's height
	MOV 	R5, [R7] 							; obtain the image's height
	SUB 	R0, 6    							; back to the adress of the reference line
	JMP 	delete_line 						; starts deleting lines

delete_next_line:
	ADD		R0, 2              					; adress of the image's initial column
	MOV 	R3, [R0]		   					; back to initial column
	SUB 	R0, 2			   					; back to the adress of the reference line
	MOV 	R4, [R8]         					; reinitialize the image's length
	SUB 	R2, 1              					; starts writing in the line above (on MediaCenter)
	SUB 	R5, 1              					; decreses the height of the image (one less line)
	JNZ 	delete_line							; deletes the new line
	JMP 	exit_delete_image   				; if there are no more lines, exit

delete_line:       								; deletes a line of pixels of the image 
	MOV		R6, 0								; colour of the next pixel
	CALL 	write_pixel							; writes the current pixel
    ADD 	R3, 1          						; next column
    SUB 	R4, 1								; one less column
    JNZ 	delete_line   						; continues through all the length of the image
	JMP 	delete_next_line  					; if there are no more columns, skip to the next line

exit_delete_image:
	POP 	R8
	POP 	R7
	POP 	R6
	POP 	R5
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	POP 	R0
	RET

; -----------------------------------------------------------------------------------------------------------

PROCESS SP_Asteroid_1							; declaration of the process with the given initial SP value
												; the SP value will be adjusted according to the process's
												; instance

;============================================================================================================
; Asteroid: process that generates and controls each of four 'randomly' generated asteroids.
;		 This process can have several instances, each for one of the asteroids, the argument 
;		 (R11) used to select the intended asteroid instance from the table containing the 
;		 initial SPs of those same instances and load the information into the ASTEROID_LIST.
;	
; Argument: R11 - number of the process's instance (each instance saves an independent copy of
;			the registers, with the values they stored by the time of creation of the process. 
;			The value of R11 must be kept along all the 'life' of the process).
;============================================================================================================

Asteroid:
	MOV  	R10, R11            				; copy of the process's number
	SHL  	R10, 1              				; multiply by two to then access the table's WORDs
	MOV  	R9, ASTEROIDS_SP_TABLE				; table containing the initial SP of the process's instances
	MOV  	SP, [R9 + R10]      				; restarts SP according to the instance selected from the table
	MOV  	R9, ASTEROID_LIST			 
	MOV  	R0, [R9 + R10]      				; saves the respective asteroid from the asteroid list in R0

asteroidControl:
	MOV  	R1, [ASTEROID_MOVE]    				; variable that controls the movement of asteroids
	MOV  	R1, [GAME_MODE]						; obtain game current state
	CMP  	R1, GAME_PLAY          				; verify if the game is in gameplay state (not paused/at the start)
	JNZ  	asteroidControl						; can't control asteroids if the game is paused or at the start

	MOV  	R1, [R0 + 6]             			; obtains the direction of the asteroid
	CMP  	R1, NO_MOVE							; see if its value is a valid direction value
	JZ  	randomAsteroid	        			; in case of null value, the meteor is new: has to be generated

	CALL 	delete_image

	MOV 	R1, [R0 + 2]						; obtain the current line of the asteroid's bottom left pixel
	SUB 	R1, 4
	MOV 	R7, MAX_LINE_SCREEN					; max line value of the screen
	CMP 	R1, R7		
	JZ 		randomAsteroid						; bottom of the screen

asteroidMovement:
	MOV 	R1, [R0 + 6]						; obtain direction of movement of asteroid
	CMP 	R1, MOVE_LEFT						; move left
	JZ 		moveAsteroidLeft
	CMP 	R1, MOVE_DOWN						; move down
	JZ 		moveAsteroidDown		
	JMP 	moveAsteroidRight					; move right

moveAsteroidLeft:								; either the asteroid was generated on the top right or the center 
												; of the screen. The latter can only collide with an explorer.
	MOV 	R1, [R0 + 2]						; current line
	MOV 	R2, [R0 + 4]						; current column
	SUB 	R2, 1								; one column to the left
	MOV 	[R0 + 4], R2						; update column
	ADD 	R1, 1								; one line lower
	MOV 	[R0 + 2], R1						; update line
	MOV 	R4, R2								; copy of the asteroid column
	MOV 	R3, SPACESHIP_RIGHT_SHOOTER
	SUB 	R2, R3
	JZ 		asteroidShipCollision

	CMP 	R3, R4
	JLT 	rightExplorerCollision
	JMP 	leftExplorerCollision
	
moveAsteroidDown:
	MOV 	R1, [R0 + 2]						; current line
	ADD 	R1, 1								; one line lower
	MOV 	[R0 + 2], R1						; update line
	MOV 	R2, 27								; reference line of the top of the spaceship
	CMP 	R1, R2								; check if the lines are coincident
	JZ 		asteroidShipCollision				; if so, it's game over due to asteroid collision
	
	MOV 	R3, [EXPLORER_VERTICAL_BOOL]
	CMP 	R3, 1
	JZ 		verticalExplorerCollision			; check if a collision happens in that instant
	JMP 	asteroidDraw						; else, draw the asteroid as default

moveAsteroidRight:								; either the asteroid was generated on the top left or the center 
												; of the screen. The latter can only collide with an explorer.
	MOV 	R1, [R0 + 2]						; current line
	ADD 	R1, 1
	MOV 	[R0 + 2], R1						; one line above
	MOV 	R2, [R0 + 4]						; current column
	ADD 	R2, 1
	MOV 	[R0 + 4], R2						; one column to the right
	MOV 	R4, R2								; copy of the column
	ADD 	R2, 4
	MOV 	R3, SPACESHIP_LEFT_SHOOTER
	MOV 	R7, R3
	SUB 	R3, R2
	JZ 		asteroidShipCollision

	CMP 	R7, R4
	JGT 	leftExplorerCollision
	JMP 	rightExplorerCollision

asteroidShipCollision:
	CALL 	gameOverCollision
	JMP 	asteroidControl

;--------------------------------------------------------------------------------------------------
; randomAsteroidInfo: pseudo-random method of getting the type and position of an asteroid
; and saves the newly obtained info into the table to generate an asteroid
;
; Registers used: 
;   R0 -> PIN (also the peripheral adress of the keypad columns)
;	R1 -> type of asteroid (0, 1, 2 -> bad asteroid, and 3 -> good asteroid)
;	R2 -> position and direction of the asteroid:
;		 0 - left corner, movement is diagonal right
;		 1 - center, movement is diagonal left
;		 2 - center, movement is vertical
;		 3 - center, movement is diagonal right
;		 4 - right, movement is diagonal left
;   R3 -> used to obtain the module
;	R4 -> used to obtain the 2 LSD mask
;	R5 -> used to obtain the adress of the generated asteroid table to store info
;--------------------------------------------------------------------------------------------------

randomAsteroid:
	MOV  	R6, KEYPAD_COLUMN				; obtain adress of the PIN
	MOVB 	R1, [R6]						; stores one byte in R1
	SHR		R1, 4							; saves the pseudo-random bits into R1
    MOV     R2, R1							; backup copy in R2
    MOV 	R3, 5							; to calculate the position and direction
	MOV 	R4, MASK_2_LSD					; to calculate the type

	MOD     R2, R3							; calculate asteroid position and direction
	AND     R1, R4							; calculate asteroid type

	MOV 	R4, ASTEROID_START_Y			; obtain the starting line of the bottom left pixel
	MOV 	[R0 + 2], R4					; sets the asteroid bottom starting line 
	CMP 	R1, 3							; verify asteroid type
	JZ		generateGoodAsteroid			; if it's equal to 3, generates a good asteroid
	MOV		R1, BAD_ASTEROID_PATTERN		; else, generates a bad asteroid
	MOV		[R0 + 8], R1					; store bad asteroid pattern 
	JMP 	generateAsteroidPosition		; obtains asteroid initial position and direction
	
generateGoodAsteroid:
	MOV		R1, GOOD_ASTEROID_PATTERN		; set the asteoroid type
	MOV		[R0 + 8], R1					; store type into the random asteroid table

generateAsteroidPosition:
	CMP		R2, 0							; check if the value is zero
	JZ		asteroidTopLeft					; if so, generates asteroid on the top left of the screen
	CMP		R2, 4							; check if the value is four
	JZ		asteroidTopRight				; if so, generates asteroid on the top right of the screen 

	MOV		R1, ASTEROID_CENTER_X			; obtain the center column to generate an asteroid
	MOV		[R0 + 4], R1					; asteroid generates in the center og the screen 
	CMP		R2, 1							; check if the value is one
	JZ		asteroidCenterLeft				; if so, the center asteroid will move to the left diagonally
	CMP		R2, 3							; check if the value is three
	JZ 		asteroidCenterRight				; if so, the center asteroid will move to the right diagonally	
	MOV 	R2,	MOVE_DOWN					; if none of the above, the center asteroid moves 
	MOV		[R0 + 6], R2					; down vertically 
	JMP 	randomAsteroidEnd

asteroidTopLeft:
	MOV 	R2, ASTEROID_LEFT_X				; obtain column of top left asteroid
	MOV 	[R0 + 4], R2					; asteroid starts at top left corner of the screen
	MOV 	R2, MOVE_RIGHT
	MOV 	[R0 + 6], R2					; and set it to move to the right diagonally
	JMP 	randomAsteroidEnd

asteroidTopRight:
	MOV		R2, ASTEROID_RIGHT_X			; obtain starting column of top right asteroid
	MOV 	[R0 + 4], R2					; asteroid starts at top right corner of the screen
	MOV 	R2, MOVE_LEFT
	MOV 	[R0 + 6], R2					; and set it to move to the left diagonally
	JMP 	randomAsteroidEnd

asteroidCenterLeft:							; asteroid start in the top center
	MOV 	R2, MOVE_LEFT
	MOV 	[R0 + 6], R2					; and moves to the left diagonally
	JMP 	randomAsteroidEnd

asteroidCenterRight:						; asteroid start in the top center			
	MOV 	R2, MOVE_RIGHT
	MOV 	[R0 + 6], R2					; and moves to the right diagonally
	JMP 	randomAsteroidEnd

randomAsteroidEnd:
	CALL 	draw_image						; finally, draws the asteroid on its initial position
	JMP 	asteroidControl

; ------------------------------------------------
; Collisions
; ------------------------------------------------

asteroidDraw:
	CALL 	draw_image
	JMP 	asteroidControl

rightExplorerCollision:
	MOV 	R3, [EXPLORER_RIGHT_BOOL]		; obtain bool variable of the right explorer
	CMP 	R3, NULL 						; check if there is a right explorer ongoing
	JZ 		asteroidDraw					; if not, animates the asteroid as default

	MOV 	R2, RIGHT_EXPLORER
	MOV 	R3, [R2 + 2]					; line of explorer
	CMP 	R3, R1
	JGT 	asteroidDraw					; asteroid is too far above
	SUB 	R1, R3
	CMP 	R1, 4
	JLE 	rightExplorerCollisionCheck
	JMP 	asteroidDraw		 			; asteroid is too far below

rightExplorerCollisionCheck:
	MOV 	R3, [R2 + 4]					; column of explorer
	SUB 	R4, R3							; see if explorer and asteroid have the same column
	CMP 	R4, 0
	JLE 	rightCollision
	JMP 	asteroidDraw

leftExplorerCollision:
	MOV 	R3, [EXPLORER_LEFT_BOOL]		; obtain bool variable of the left explorer
	CMP 	R3, NULL						; check if there is a left explorer ongoing
	JZ 		asteroidDraw

	MOV 	R2, LEFT_EXPLORER
	MOV 	R3, [R2 + 2]					; line of explorer
	CMP 	R3, R1
	JGT 	asteroidDraw					; asteroid is too far above
	SUB 	R1, R3
	CMP 	R1, 4
	JLE 	leftExplorerCollisionCheck
	JMP 	asteroidDraw		 			; asteroid is too far below

leftExplorerCollisionCheck:
	MOV 	R3, [R2 + 4]					; column of explorer
	ADD 	R4, 4
	SUB 	R3, R4							; see if explorer and asteroid have the same column
	CMP 	R3, 0
	JLE 	leftCollision
	JMP 	asteroidDraw
	
verticalExplorerCollision:
	MOV 	R2, VERTICAL_EXPLORER
	MOV 	R3, [R2 + 2]					; current line of vertical explorer
	SUB 	R3, R1
	CMP 	R3, 0001H
	JLE 	verticalCollision
	JMP 	asteroidDraw

verticalCollision:
	CALL 	resetVerticalExplorer
	JMP 	explodeAsteroid

rightCollision:
	CALL 	resetRightExplorer
	JMP 	explodeAsteroid

leftCollision:
	CALL 	resetLeftExplorer
	JMP 	explodeAsteroid
	
; -------------------------------------------------------------------------------------------------
; gameOverCollision: invoked when an asteroid, either good or bad, collides with the spaceship, 
; thus ending the game.
; -------------------------------------------------------------------------------------------------

gameOverCollision:
	PUSH 	R0
	PUSH 	R1
	PUSH 	R2

	MOV 	R1, 3							; selects the game over sound
	MOV 	R2, 5							; selects the asteroid game over video
	MOV  	[DELETE_SCREENS], R0      		; clears all the pixels in all screens (value of R0 is irrelevant)
	MOV 	R0, 2
	MOV 	[MEDIA_STOP], R0				; stop the game music 
	MOV 	[PLAY_MEDIA], R1				; play the game over sound
	MOV 	[PLAY_MEDIA], R2				; play asteroid game over video

gameOverCollisionWait:
	MOV 	R0, [MEDIA_STATE]				; check if the video has finished
	CMP 	R0, NULL 						
	JNZ 	gameOverCollisionWait			; if not, wait until it ends

	CALL 	gameStart						; resets and restarts the game by playing the starting animation

	POP 	R2
	POP 	R1
	POP 	R0
	RET

;--------------------------------------------------------------------------------------------------
; explodeAsteroid:
;--------------------------------------------------------------------------------------------------

explodeAsteroid:
	MOV 	R3, [R0 + 8]
	MOV 	R4, GOOD_ASTEROID_PATTERN
	CMP 	R3, R4
	JZ 		increaseEnergy

	MOV 	R3, 7
	MOV 	[PLAY_MEDIA], R3

explodeAsteroidAnimation:
	CALL 	delete_image						; deletes the current asteroid
	MOV 	R1, EXPLOSION_PATTERN				; object containing info of the explosion image
	MOV 	[R0 + 8], R1						; replace the asteroid default pattern with explosion pattern
	CALL	draw_image							; draws the new asteroid with an explosion pattern
	MOV 	R5, 700								; time delay to hold the explosion pattern on the screen

explodeAsteroidWait:
	SUB 	R5, 1								; delays screen time of explosion for a while
	YIELD
	JNZ 	explodeAsteroidWait

	CALL 	delete_image						; finally, deletes the explosion from the screen 
	MOV 	R2, NULL
	MOV 	[R0 + 8], R2						; reset pattern
	JMP 	randomAsteroid

increaseEnergy:
	MOV 	R3, ASTEROID_ENERGY_INCREASE
	MOV 	[ENERGY_CHANGE], R3
	MOV 	R3, 8
	MOV 	[PLAY_MEDIA], R3
	JMP 	explodeAsteroidAnimation

; ------------------------------------------------------------------------------------------------
; asteroidReset: resets all the asteroids from the asteroid list to their starting state.
; -------------------------------------------------------------------------------------------------

asteroidResetAll:
	PUSH 	R0
	PUSH 	R1
	PUSH 	R2
	PUSH 	R3

	MOV 	R0, ASTEROID_LIST		 			; obtain the first asteroid of the list

asteroidResetLoop:	
	MOV  	R1, [R0]                 			; stores the address of the asteroid in R1
	MOV  	R2, ASTEROID_START_Y	 			; starting line of the asteroid on the top os the screen
	MOV  	[R1 + 2], R2             			; resets the asteroid's reference line of the bottom left pixel
	MOV  	R2, NULL  				 			; set the column value to NULL
	MOV  	[R1 + 4], R2             			; resets the asteroid reference column of the bottom left pixel
	MOV  	R2, NO_MOVE
	MOV 	[R1 + 6], R2			 			; sets the initial state of movement of the asteroid as immobile
	ADD 	R0, 2					 			; moves to the next asteroid (the patterns dont need to be reset)
	MOV  	R3, [ASTEROID_4 + 6]	 			; adress of the last asteroid movement direction					 
	CMP  	R3, R2             	 	 			; if the last asteroid just got reset, then stops the loop
	JNZ  	asteroidResetLoop

	POP  	R3
	POP  	R2
	POP  	R1
	POP  	R0
	RET

;---------------------------

PROCESS  SP_explorer_vertical

explorer_key_handle_vertical:
    MOV 	R0, [KEY_PRESSED]					; detect the key pressed from the keyboard
    CMP 	R0, 0001H							; check if the pressed key was '1'
    JNZ 	explorer_key_handle_vertical		; if not, try a new key detection
	MOV 	R0, [GAME_MODE]						; obtain current game mode
	CMP 	R0, GAME_PLAY						; check is the game is ongoing
	JNZ 	explorer_key_handle_vertical		; can't proceed if the game is paused or at start

explorer_vertical_bool:
	MOV		R1, 1                             	; set vertical explorer bool to 1
    MOV 	[EXPLORER_VERTICAL_BOOL], R1		; there's now a vertical explorer ongoing
    MOV		R2, VERTICAL_EXPLORER    			; image table of the vertical explorer
	CALL	draw_explorer						; draws the initial explorer
	CALL 	drainEnergy							; drains the respective energy value from the spaceship
	MOV 	R5, MAX_EXPLORER_DISTANCE			; obtain max (vertical) distance the explorer can reach

explorer_vertical_mov:
	MOV 	R0, [EXPLORER_MOVE]    			 			
    MOV 	R0, [GAME_MODE]						; obtain current game mode
    CMP 	R0, GAME_PAUSE						; check if the game is paused
	JZ		explorer_vertical_mov				; cannot animate an explorer if the game is paused

    CALL 	delete_explorer						; deletes the current explorer
	CALL 	moveExplorerUp						; updates the explorer's reference line
	MOV 	R0, [R2 + 2]						; obtain the explorer's new reference line
	CMP 	R0, R5								; check if the explorer reached the maximum distance
	JZ 		explorer_vertical_reached_end			; if so, resets the explorer to its initial state

	MOV 	R3, [EXPLORER_VERTICAL_BOOL]		; check if the explorer has collided with an asteroid
	CMP 	R3, NULL							
	JZ  	explorer_key_handle_vertical		; if so, reset the vertical explorer
	CALL  	draw_explorer						; else, draws the explorer on the updated position and
    JMP   	explorer_vertical_mov				; continue animation

explorer_vertical_reached_end:
    CALL 	resetVerticalExplorer				; reset vertical explorer to its initial position
    JMP  	explorer_key_handle_vertical		; detect next vertical explorer shooting

;---------------------------

PROCESS  SP_explorer_left

explorer_key_handle_left:
    MOV 	R0, [KEY_PRESSED]					; detect the key pressed from the keyboard
    CMP 	R0, 0000H							; check if the pressed key was '0'
	JNZ 	explorer_key_handle_left			; if not, try a new key detection
	MOV 	R0, [GAME_MODE]						; obtain current game mode
	CMP 	R0, GAME_PLAY						; check is the game is ongoing
	JNZ 	explorer_key_handle_left			; can't proceed if the game is paused or at start

explorer_left_bool:
	MOV 	R1, 1                             	; set left explorer bool to 1
    MOV 	[EXPLORER_LEFT_BOOL], R1			; there's now a left explorer ongoing
    MOV 	R2, LEFT_EXPLORER                 	; image table of the explorer
    CALL	draw_explorer						; draws the initial explorer
	CALL 	drainEnergy 						; drains the respective energy value from the spaceship
	MOV  	R5, MAX_EXPLORER_DISTANCE			; obtain max (vertical) distance the explorer can reach

explorer_left_mov:
    MOV 	R0, [EXPLORER_MOVE]         
    MOV 	R0, [GAME_MODE]						; obtain current game mode
    CMP 	R0, GAME_PAUSE						; check if the game is paused
	JZ		explorer_left_mov					; cannot animate an explorer if the game is paused

    CALL 	delete_explorer						; deletes the current explorer
	CALL 	moveExplorerUp						; updates the explorer's reference line
	MOV 	R0, [R2 + 2]						; obtain the explorer's new reference line
	CMP 	R0, R5								; check if the explorer reached the maximum distance
	JZ 		explorer_left_reached_end			; if so, resets the explorer to its initial state

	MOV 	R0, [R2 + 4]						; obtain reference column
    SUB 	R0, 1                            	; previous column
    MOV 	[R2 + 4], R0						; update left explorer column
	MOV 	R3, [EXPLORER_LEFT_BOOL]			; check if the explorer has collided with an asteroid
	CMP 	R3, NULL
	JZ  	explorer_key_handle_left			; if so, reset the left explorer
	CALL  	draw_explorer						; else, draws the explorer on the updated position and
    JMP   	explorer_left_mov					; continue animation

explorer_left_reached_end:
    CALL 	resetLeftExplorer					; reset left explorer to its initial position
    JMP  	explorer_key_handle_left			; detect next left explorer shooting

;---------------------------

PROCESS  SP_explorer_right

explorer_key_handle_right:
    MOV 	R0, [KEY_PRESSED]					; detect the key pressed from the keyboard
    CMP 	R0, 0002H							; check if the pressed key was '2'
	JNZ 	explorer_key_handle_right			; if not, try a new key detection
	MOV 	R0, [GAME_MODE]						; obtain current game mode
	CMP 	R0, GAME_PLAY						; check is the game is ongoing
	JNZ 	explorer_key_handle_right			; can't proceed if the game is paused or at start

explorer_right_bool:
	MOV 	R1, 1                             	; set right explorer bool to 1
    MOV 	[EXPLORER_RIGHT_BOOL], R1			; there's now a right explorer ongoing
    MOV 	R2, RIGHT_EXPLORER                 	; image table of the explorer
    CALL	draw_explorer						; draws the initial explorer
	CALL 	drainEnergy 						; drains the respective energy value from the spaceship
	MOV  	R5, MAX_EXPLORER_DISTANCE			; obtain max (vertical) distance the explorer can reach

explorer_right_mov:
    MOV 	R0, [EXPLORER_MOVE]         
    MOV 	R0, [GAME_MODE]						; obtain current game mode
    CMP 	R0, GAME_PAUSE						; check if the game is paused
	JZ		explorer_right_mov					; cannot animate an explorer if the game is paused

    CALL 	delete_explorer						; deletes the current explorer
	CALL 	moveExplorerUp						; updates the explorer's reference line
	MOV 	R0, [R2 + 2]						; obtain the explorer's new reference line
	CMP 	R0, R5								; check if the explorer reached the maximum distance
	JZ 		explorer_right_reached_end			; if so, resets the explorer to its initial state

	MOV 	R0, [R2 + 4]						; obtain reference column
    ADD 	R0, 1                            	; next column
    MOV 	[R2 + 4], R0						; update right explorer column
	MOV 	R1, [EXPLORER_RIGHT_BOOL]			; check if the explorer has collided with an asteroid
	CMP 	R1, NULL
	JZ  	explorer_key_handle_right			; if so, reset the right explorer
	CALL  	draw_explorer						; else, draws the explorer on the updated position and
    JMP   	explorer_right_mov					; continue animation

explorer_right_reached_end:
    CALL 	resetRightExplorer					; reset right explorer to its initial position
    JMP  	explorer_key_handle_right			; detect next right explorer shooting

; -------------------------------------------------------------------------------------------------
; drainEnergy: depletes energy from the spaceship after shooting an explorer.
; -------------------------------------------------------------------------------------------------

drainEnergy:
	PUSH 	R0

	MOV 	R0, EXPLORER_ENERGY_DECREASE		; obtain energy spent to shoot an explorer
    MOV 	[ENERGY_CHANGE], R0					; drain the energy value from the spaceship
	MOV 	R0, 6								; obtain shooting sound
	MOV 	[PLAY_MEDIA], R0					; plays the sound after shooting an explorer

	POP 	R0
	RET

; -------------------------------------------------------------------------------------------------
; moveExplorer: updates the explorer's position one line above.
;
; Argument:	R2 -> object storing the info of the explorer to move
; -------------------------------------------------------------------------------------------------

moveExplorerUp:
	PUSH 	R0
	PUSH 	R2

	MOV 	R0, [R2 + 2] 						; obtain current reference line of the explorer
    SUB 	R0, 1								; one line above
	MOV 	[R2 + 2], R0						; update the explorer's line

	POP		R2
	POP 	R0
	RET

; -------------------------------------------------------------------------------------------------
; resetVerticalExplorer: resets the vertical explorer's table to its initial information and its 
;					  	 respective bool variable to NULL.
; Argument: R2 -> object VERTICAL_EXPLORER
; -------------------------------------------------------------------------------------------------

resetVerticalExplorer:
	PUSH 	R1
	PUSH 	R2

	MOV 	R1, NULL
	MOV 	[EXPLORER_VERTICAL_BOOL], R1		; set vertical explorer bool to NULL
	CALL 	delete_explorer						; delete image of the vertical explorer
	MOV 	R1, EXPLORER_START_Y				; obtain starting reference line
	MOV 	[R2 + 2], R1						; reset reference line

	POP 	R2
	POP 	R1
	RET

; -------------------------------------------------------------------------------------------------
; resetLeftExplorer: resets the left explorer's table to its initial information and its 
;					 respective bool variable to NULL.
; Argument: R2 -> object LEFT_EXPLORER
; -------------------------------------------------------------------------------------------------

resetLeftExplorer:
	PUSH 	R1
	PUSH 	R2

	MOV 	R1, NULL
	MOV 	[EXPLORER_LEFT_BOOL], R1			; set left explorer bool to NULL
	CALL 	delete_explorer						; delete image of the left explorer
	MOV 	R1, EXPLORER_START_Y				; obtain starting reference line
	MOV 	[R2 + 2], R1						; reset reference line
	MOV 	R1, EXPLORER_LEFT_X					; obtain starting reference column
	MOV 	[R2 + 4], R1						; reset reference column

	POP 	R2
	POP 	R1
	RET

; -------------------------------------------------------------------------------------------------
; resetRightExplorer: resets the right explorer's table to its initial information and its 
;					  respective bool variable to NULL.
; Argument: R2 -> object RIGHT_EXPLORER
; -------------------------------------------------------------------------------------------------

resetRightExplorer:						
	PUSH 	R1
	PUSH 	R2

	MOV 	R1, NULL
	MOV 	[EXPLORER_RIGHT_BOOL], R1			; set right explorer bool to NULL
	CALL 	delete_explorer						; delete image of the right explorer
	MOV 	R1, EXPLORER_START_Y				; obtain starting reference line
	MOV 	[R2 + 2], R1						; reset reference line
	MOV 	R1, EXPLORER_RIGHT_X				; obtain starting reference column
	MOV 	[R2 + 4], R1						; reset reference column

	POP 	R2
	POP 	R1
	RET

; -------------------------------------------------------------------------------------------------
; draw_explorer: draws the image of an explorer on the respective screen.
;
; Arguments: R2 -> object with the information of the explorer (screen, line and column).
; -------------------------------------------------------------------------------------------------

draw_explorer:
	PUSH  	R1
    PUSH  	R2
    PUSH  	R3
	PUSH  	R4
	PUSH  	R5

	MOV 	R1, [R2]							; obtain explorer's screen
	MOV 	[SCREEN_SELECT], R1					; select explorer's screen
	MOV 	R3, [R2 + 2]						; obtain the reference line of the explorer
	MOV 	R4, [R2 + 4]						; obtain the reference column of the explorer
	MOV 	R5, PINK							; obtain colour of the explorer
    MOV   	[DEF_LINE], R3						; select line
    MOV   	[DEF_COLUMN], R4					; select column
	MOV   	[DEF_PIXEL], R5						; set colour of the pixel in the given position to pink

	POP   	R5
	POP   	R4
    POP   	R3
    POP   	R2
	POP   	R1
	RET

; -------------------------------------------------------------------------------------------------
; delete_explorer: deletes the image of an explorer from the respective screen.
;
; Arguments: R2 -> object with the information of the explorer (screen, line and column).
; -------------------------------------------------------------------------------------------------

delete_explorer:
    PUSH  	R1
    PUSH  	R2
    PUSH  	R3
	PUSH  	R4
	PUSH  	R5

	MOV 	R1, [R2]							; obtain explorer's screen
	MOV 	[SCREEN_SELECT], R1					; select explorer's screen
	MOV 	R3, [R2 + 2]						; obtain the reference line of the explorer
	MOV 	R4, [R2 + 4]						; obtain the reference column of the explorer
	MOV 	R5, NULL						
    MOV   	[DEF_LINE], R3						; select line
    MOV   	[DEF_COLUMN], R4					; select column
	MOV   	[DEF_PIXEL], R5						; delete colour of the pixel in the given position

	POP   	R5
	POP   	R4
    POP   	R3
    POP   	R2
	POP   	R1
	RET

; -------------------------------------------------------------------------------------------------

PROCESS SP_EnergyHandling

;==================================================================================================
; energyHandling: handles the energy updates
;
; Registers used: 
;	R0 - holds the energy change value (positive or negative)
;	R1 - holds the current energy value
;	R2 - holds the max energy value for the spaceship
;==================================================================================================

energyHandling:
    MOV		R0, [ENERGY_CHANGE]       			; obtain the value to increase/decrease the ship's energy
    MOV 	R4, [GAME_MODE]
    CMP 	R4, GAME_PLAY
    JNZ 	energyHandling               		; changes in energy only occur during gameplay state

    MOV 	R1, [ENERGY_HEX]          			; obtains the current energy
    ADD 	R1, R0                    			; adds the current energy with the amount to increase or decrease
	MOV 	R2, MAX_POSSIBLE_ENERGY   			; obtains the maximum value of energy
    CMP		R1, R2
    JGE 	energyCheck_Max           			; if the energy value surpasses 999 then it remains unchanged

    CMP 	R1, NULL
    JLE  	energyCheck_Min              		; if the energy is below zero then it is set to 0 and a game over happens
    JMP  	energyHandling_Display

energyCheck_Max:
    MOV  	R1, MAX_POSSIBLE_ENERGY   			; updates the value to 999
    CALL 	energyHandling_Display

energyCheck_Min:
    MOV  	R1, MIN_ENERGY_HEX        			; updates the value to 0
	MOV  	[DISPLAYS], R1
    CALL 	gameOverEnergy            			
	JMP 	energyHandling

energyHandling_Display:
    MOV  	[ENERGY_HEX], R1          			; updates the energy value
    CALL 	hextodecConvert 					; converts the value
    MOV  	[DISPLAYS], R0            			; updates the value in the displays
    JMP  	energyHandling

; -------------------------------------------------------------------------------------------------
; gameOverEnergy: invoked when the energy of the spaceship is depleted, thus ending the game.
; -------------------------------------------------------------------------------------------------

gameOverEnergy:
	PUSH 	R0
	PUSH 	R1
	PUSH 	R2

	MOV 	R1, 3								; selects the game over sound
	MOV 	R2, 4								; selects the energy game over video
	MOV  	[DELETE_SCREENS], R0      			; clears all the pixels in all screens (value of R0 is irrelevant)
	MOV 	R0, 2
	MOV 	[MEDIA_STOP], R0					; stop the game music 
	MOV 	[PLAY_MEDIA], R1					; play the game over sound
	MOV 	[PLAY_MEDIA], R2					; play energy game over video

gameOverEnergyWait:								; waits for the game over video to end before transitioning
	MOV 	R0, [MEDIA_STATE]					; check if the video has finished
	CMP 	R0, NULL 						
	JNZ 	gameOverEnergyWait					; if not, wait until it ends
	CALL 	gameStart							; restarts the game by playing the starting animation

	POP 	R2
	POP 	R1
	POP 	R0
	RET

; -------------------------------------------------------------------------------------------------
; energyReset: Resets the energy back to 100% everytime a new game begins.
; -------------------------------------------------------------------------------------------------

energyReset:
	PUSH 	R0
	PUSH 	R1

	MOV  	R1, START_ENERGY_HEX				; obtain value of the starting energy
	MOV  	[ENERGY_HEX], R1    				; resets the current energy to maximum start energy
	CALL 	hextodecConvert    					; value in R1 is going to be converted and stored in R0
	MOV  	[DISPLAYS], R0      				; resets the value in the display in decimal form

	POP  	R1
	POP  	R0
	RET

; -------------------------------------------------------------------------------------------------
; hextodecConvert: Given any hexadecimal value it converts it into 12 bits, where each group of 
; 4 bits represent a digit of the decimal version.
; - R0 -> hexadecimal converted into decimal in the form of 12 bits
; - R1 -> hexadecimal number to convert
; -------------------------------------------------------------------------------------------------

hextodecConvert:
	PUSH 	R1
	PUSH 	R2
	PUSH 	R3
	PUSH 	R4
         
	MOV  	R0, NULL
	MOV  	R3, HEXTODEC_MSD
	MOV  	R4, HEXTODEC_LSD

hextodecCycle:
	MOV  	R2, R1								; obtains the value to convert
	DIV  	R2, R3								; obtains a digit
	MOD  	R1, R3								; obtains the remaining value to convert
	OR	 	R0, R2								; adds the digit to the converted value
	SHL  	R0, 4								; shifts the digits to their correct order
	DIV  	R3, R4
	CMP  	R3, 0001H							; if it's zero, it means that the value was converted
	JNZ  	hextodecCycle
	OR  	R0, R1								; adds the remaining digit to the converted value

	POP  	R4
	POP  	R3
	POP  	R2
	POP  	R1
	RET

;--------------------------------------------------------------------------------------------------

PROCESS SP_SpaceshipLEDs

;==================================================================================================
; changeLEDs: updates the LED light pattern of the spaceship in loop, in a total
; of five LED light patterns.
;==================================================================================================

changeLEDs:
	MOV 	R3, [CHANGE_LED]					; locks the process 
	MOV 	R3, [GAME_MODE]						; obtain current game state
	CMP 	R3, GAME_PLAY						; check if the game is paused
	JNZ 	changeLEDs							; the LED animation only occurs during gameplay

	MOV 	R3, 0008H
	MOV 	R2, [NEXT_PATTERN]					; obtain the value of the next pattern
	SUB 	R3, R2								; check if it's a pattern within the list of patterns
	JGE 	updateLEDs							; if so, draw the new LED pattern
	MOV 	R2, 0								; else, if the list limit is reached, reset the list
	MOV 	[NEXT_PATTERN], R2					; the next pattern to be drawn is the first of the list

updateLEDs:
	MOV 	R1, PANELS							; table containing the panel LED patterns
	ADD 	R1, R2								; select the intended pattern
	MOV 	R0, [R1]							; obtain argument of the pattern to draw
	CALL 	draw_image							; draw the new pattern
	ADD 	R2, 2								; next pattern
	MOV 	[NEXT_PATTERN], R2					; update next pattern
	JMP 	changeLEDs

;==================================================================================================
; INTERRUPTION IMPLEMENTATION: handling of the game's interruptions
;==================================================================================================

; -------------------------------------------------------------------------------------------------
; int_MoveAsteroid: Interruption used to indicate a movement of the asteroids (every 500 ms)
; -------------------------------------------------------------------------------------------------

int_MoveAsteroid:
	MOV 	[ASTEROID_MOVE], R0		
	RFE

; -------------------------------------------------------------------------------------------------
; int_MoveAsteroid: Interruption used to indicate a movement of the explorer(s) (every 200 ms)
; -------------------------------------------------------------------------------------------------

int_MoveExplorer:
    MOV 	[EXPLORER_MOVE], R0
    RFE

; -------------------------------------------------------------------------------------------------
; int_EnergyDecrease: Interruption used to decrease the spaceship energy during gameplay
;					  (3% every 3 seconds)
; -------------------------------------------------------------------------------------------------

int_EnergyDecrease:
	PUSH 	R0

	MOV 	R0, MOVEMENT_ENERGY_DECREASE
	MOV  	[ENERGY_CHANGE], R0  

	POP  	R0
	RFE

; -------------------------------------------------------------------------------------------------
; int_LEDs: Interruption used to indicate a change of pattern in the spaceship
; 			LED lights panel (every 300 ms)
; -------------------------------------------------------------------------------------------------

int_LEDs:
	MOV 	[CHANGE_LED], R0			
	RFE