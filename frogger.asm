################################################################################################
#	-------     -----      --------     --------      --------       -------      ----- 
#	|           |    |     |      |     |             |              |            |    |
#	|----       |----      |      |     |   ---|      |   ---|       |----        |---- 
#	|           |\         |      |     |      |      |      |       |            |\
#	|           | \        --------     -------|      -------|       -------      | \
#
################################################################################################
# THIS CODE IS WRITTEN IN ASSEMBLY AND IT HAS BEEN DEPLOYED TO BE EXECUTED ON MARS 4.5
#
# THIS GAME IS INSPIRED FROM THE GAME FROM THE 80's "FROGGER"
# 
# THE TARGET OF THE GAME IS REACHING THE X IN THE TOP LEFT CORNER OF THE SCREEN.
#
# THE RED AND BROWN MOVING RECTANGLES ARE RESPECTIVELY CARS AND LOGS.
#
# TO REACH THE TARGET YOU HAVE TO CROSS THE STREET AVOIDING CARS AND TRAVERSING THE 
# RIVER ON THE LOGS.
################################################################################################
#
# To play this game on Mars 4.5 (link to download it 
# http://courses.missouristate.edu/kenvollmar/mars/) you have to use the tools "Bitmap Display"
# to visualize the game and "Keyboard and Display MMIO Simulator" which are present
# under the tab "Tools"
#
# The settings for the Bitmap Display are the following
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# After having selected the correct parameters you can connect display and keyboard to MIPS
#
#
#	To move press WASD
#	
#	To survive on the log the frog has to be completely on the log
#
#	It is possible to set the difficulty of the game
#	after having lost. To do so, when "END" writing appears
#	press a number 0-4 to select the difficulty where
#	0 is most difficult and 4 is the easiest
#
#	It is possible to restart the game when you lose pressing R
#
#	Also sound effect are reproduced connected to events
#
#	If you have any remark and feedback to give me please
#	do not hesitate	
#
#	I hope you like it:)
#
###############################################################################################

.data
	displayAddress: .word 0x10008000
	frog_col: .word 0xcc5ed9 # 0x10008000 + (128 * 64) = 0x10008000 + 8192
	frog_pos_x: .word 0x38
	frog_pos_y: .word 0x1c
	lev_width: .word 0x10
	lev_pixel: .word 0x200     #number bytes in one level
	lev_1_col: .word  0x46d835   #color of level 1 
	lev_2_col: .word  0x46d835
	lev_3_col: .word  0x354ed8
	lev_4_col: .word  0x354ed8
	lev_5_col: .word  0xedb92f
	lev_6_col: .word  0x46443f
	lev_7_col: .word  0x46443f
	lev_8_col: .word  0x46d835
	length_row: .word 0x80     #number bytes in a row
	limit_pos_y: .word 0x1c
	
	lev_3_pos_y: .word  0x8
	lev_4_pos_y: .word  0xc
	lev_6_pos_y: .word 0x14
	lev_7_pos_y: .word 0x18
	
	car_1_pos_x: .word 0x0   #from left to right
	car_2_pos_x: .word 0xffffff   #from left to right
	car_3_pos_x: .word 0x7c   #from right to left
	car_4_pos_x: .word 0xffffff   #from right to left
	log_1_pos_x: .word 0x18   #from left to right
	log_2_pos_x: .word 0xffffff   #from left to right
	log_3_pos_x: .word 0x50   #from right to left
	log_4_pos_x: .word 0xffffff   #from right to left
	car_1_pos_y: .word 0x14  #car lev 6
	car_2_pos_y: .word 0x14  #car lev 6
	car_3_pos_y: .word 0x18  #car lev 7
	car_4_pos_y: .word 0x18  #car lev 7
	log_1_pos_y: .word 0x8  #log lev 3
	log_2_pos_y: .word 0x8  #log lev 3
	log_3_pos_y: .word 0xc  #log lev 4
	log_4_pos_y: .word 0xc  #log lev 4
	car_1_left:  .word 0x0   #length car remaining to delete	
	car_2_left:  .word 0x0
	car_3_left:  .word 0x0   	
	car_4_left:  .word 0x0
	log_1_left:  .word 0x0   #length log remaining to delete	
	log_2_left:  .word 0x0
	log_3_left:  .word 0x0   	
	log_4_left:  .word 0x0
	time_car_1_left: .word 0xffffff
	time_car_2_left: .word 0xffffff
	time_car_3_left: .word 0xffffff
	time_car_4_left: .word 0xffffff
	time_log_1_left: .word 0xffffff
	time_log_2_left: .word 0xffffff
	time_log_3_left: .word 0xffffff
	time_log_4_left: .word 0xffffff

	
	car_threshold: .word 0x4 #number of cars in total
	
	car_colour: .word 0xff0000
	car_length: .word 0x20 #8 pixels * 4 bit/pixel	
	
	log_colour: .word 0x88743f
	log_length: .word 0x20 #8 pixels * 4 bit/pixel
	
	no_car_value: .word 0xffffff
	no_log_value: .word 0xfffffe
	
	time_sleep: .word 0x10 # 1000/60 ms = 16 ms
	time_interval: .word 0xA0 # time interval for random value generation
	
	game_difficulty: .word 0x0  #0 : really difficult
	time_difficulty: .word 0x0  #time used to set difficulty
	
	target_colour: .word 0xfafe00#colour of target (cross)
.text
start:
	jal drawback
	jal draw_frog
	j main

restart:
	la $t0, frog_pos_x
	li $t1, 0x38
	sw $t1, ($t0)
	la $t0, frog_pos_y
	li $t1, 0x1c
	sw $t1, ($t0)
	j start
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall

reproduce_sound:
	#t0 values  ==== 0: car accident/  1: drown/ 2: victory
	
	li $v0, 31
	li $a0, 72
	li $a1, 1000
	li $a3, 60
	
	beqz $t0, sound_collision 
	beq $t0, 1,  sound_drown
	#sound victory
	li $a0, 0x3b
	j play_sound
	
	sound_collision:
	li $a0, 0x38
	j play_sound
	
	sound_drown:
	li $a0, 0x5e
	j play_sound

	play_sound:
	syscall
	
	jr $ra

win_game:
	li $t0, 2
	jal reproduce_sound
	
	lw $t0, displayAddress
	lw $t1, length_row
 	mulu $t2, $t1, 0xc # 12: y coordinate where to start writing "end game"
 	addu $t2, $t0, $t2
	addu $t2, $t2, 0x20 #starting point
	move $t3, $t2
	
	li $t4, 0xf2f0ec #white(ish) color
	
	sw $t4, ($t3)
	
	addu $t3, $t3, 24
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 24
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)

	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 24
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
			
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)

	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
			
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	j Exit
	

lose_game:
	move $t0, $a0
	jal reproduce_sound
	lw $t0, displayAddress
	lw $t1, length_row
 	mulu $t2, $t1, 0x4 # 8: y coordinate where to start writing "end game"
 	addu $t2, $t0, $t2
	addu $t2, $t2, 0x20 #starting point
	move $t3, $t2
	
	li $t4, 0xf2f0ec #white(ish) color
	
	sw $t4, ($t3)       # ---   - -   -
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row   # |    |   |  
	sw $t4, ($t3)
	
	addu $t3, $t3, 20
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)	
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 20
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)

	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	##UNTIL HERE END WRITING
	
	mulu $t9, $t1, 6
	addu $t2, $t2, $t9
	subu $t2, $t2, 0x8
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 12
	sw $t4, ($t3)
	
	addu $t3, $t3, 24
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 16
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	##### PRESS
	
	addu $t2, $t2, $t1
	addu $t2, $t2, $t1
	addu $t2, $t2, 0x20
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 4
	sw $t4, ($t3)
	
	addu $t2, $t2, $t1
	move $t3, $t2 #new row
	sw $t4, ($t3)
	
	addu $t3, $t3, 8
	sw $t4, ($t3)
	
	wait_restart:
	
	lw $t0, 0xffff0000 #check if any button has been pressed
	bne $t0, 1, wait_restart
	lw $t1, 0xffff0004 #check which button has been pressed
 
	beq $t1, 0x72 , restart # R has been pressed
	
	bge $t1, 0x30 , level_config #input >= 1
	
	j wait_restart
	
	level_config:
	
	bgt $t1, 0x35 , wait_restart #input > 5
	
	la $t2, game_difficulty
	subu $t1, $t1, 0x30 #set level requested # higher level is easier
	sw $t1, ($t2)
	j wait_restart
	

draw_target:
	lw $t0, displayAddress
	lw $t1, length_row
	addu $t0, $t0, $t1
	subu $t0, $t0, 4 #starting point of cross
	move $t3, $t0
	
	lw $t2, target_colour
	
	sw $t2, ($t3)
	
	subu $t3, $t3, 8
	sw $t2, ($t3)
	
	addu $t0, $t0, $t1
	move $t3, $t0
	
	subu $t3, $t3, 4
	sw $t2, ($t3)
	
	addu $t0, $t0, $t1
	move $t3, $t0
	sw $t2, ($t3)
	
	subu $t3, $t3, 8
	sw $t2, ($t3)
	
	
	jr $ra

draw_level:
	subu $t4, $t2, $t3
	bltz $t4 ,continue_lev
	jr $ra 
	continue_lev:
	sw $t1, ($t2)
	addu $t2, $t2, 4
	j draw_level

drawback:
	move $a0, $ra
	la $t7, lev_1_col
	lw $t2, displayAddress
	lw $t3, displayAddress
	lw $t5, lev_pixel
	li $t6, 0 #counter
	li $t9, 4
	drawback_loop:
	multu $t9, $t6   #counter * 4
	mflo $t0
	addu $t0, $t7, $t0 #select correct color address
	lw $t1, ($t0)      #retrieve colour
	addu $t3, $t3, $t5  #update end line
	jal draw_level
	move $t2, $t3      #update start line
	addu $t6, $t6, 1   #increase count
	subu $t8, $t6, 8    #check end of loop
	bltz $t8, drawback_loop
	
	jal draw_target #draw the frog target
	
	jr $a0

draw_frog:

	lw $t1, displayAddress
	lw $t2, frog_pos_y
	lw $t3, length_row
	multu $t2, $t3
	mflo $t2
	addu $t1, $t1, $t2
	lw $t2, frog_pos_x
	addu $t1, $t1, $t2 #initial frog point
	
	lw $t4, frog_col
	sw $t4, ($t1)
		
	li $t2, 12
	addu $t3, $t1, $t2
	sw $t4, ($t3)
	
	
	lw $t2, length_row #new row
	addu $t1, $t1, $t2
	sw $t4, ($t1)
	
	li $t5, 4
	addu $t3, $t1, $t5
	sw $t4, ($t3)
	
	addu $t3, $t3, $t5
	sw $t4, ($t3)
	
	addu $t3, $t3, $t5
	sw $t4, ($t3)

	
	addu $t1, $t1, $t2  #new row
	addu $t3, $t1, $t5
	sw $t4, ($t3)
	
	addu $t3, $t3, $t5
	sw $t4, ($t3)
	
	addu $t1, $t1, $t2  #new row
	sw $t4, ($t1)

	addu $t3, $t1, $t5
	sw $t4, ($t3)
	
	addu $t3, $t3, $t5
	sw $t4, ($t3)
	
	addu $t3, $t3, $t5
	sw $t4, ($t3)
	
	jr $ra


draw_obj:

	la $t1, car_1_pos_x
	addu $t1, $t1, $t0 #t0 contains the offset of the obj selected
	lw $t2, ($t1)  #pos obj x
	
	lw $t3, no_car_value
	beq $t2, $t3, exit_drawobj
	
	la $t1, car_1_pos_y
	addu $t1, $t1, $t0
	lw $t3, ($t1)   #pos obj y

	lw $t4, displayAddress
	lw $t1, length_row
	multu $t1, $t3
	mflo $t1
	addu $t4, $t4, $t1
	addu $t2, $t2, $t4 #t2 contains frog position

	
	lw $t1, car_threshold
	li $t7, 4
	divu $t0, $t7
	mflo $t8
	bge $t8, $t1, draw_log_pos
	lw $t1, car_colour
	lw $t5, lev_6_pos_y #check car direction
	j draw_car_pos
	draw_log_pos:
	lw $t1, log_colour
	lw $t5, lev_3_pos_y #check log direction
	draw_car_pos:
	
	move $t7, $t4 #y pos wrt initial point
	
	move $t8, $t3 #save pos obj y in t8 to determine direction later on
		
	move $t3, $t2 #save initial point
	drawobj_loop_out:
	subu $t4, $t2, $t3
	lw $t6, lev_pixel
	beq $t4, $t6, exit_drawobj
	move $t0, $t2
	drawobj_loop_in:
	lw $t4, length_row
		
	beq $t5, $t8, obj_going_right_1
	subu $t4, $t2, $t0 #obj_going_left
	lw $t6, length_row
	addu $t6, $t7, $t6
	bge  $t2, $t6, end_drawobj_loop   #check if the pointer is equal/bigger than the y coordinate of the first pixel of the following row
	j obj_going_left_1
	obj_going_right_1:
	blt $t2, $t7, end_drawobj_loop   #check if the pointer is less than the y coordinate of the first pixel of the row
	subu $t4, $t0, $t2
	obj_going_left_1:
	lw $t6, car_length
	beq $t4, $t6, end_drawobj_loop #check end of obj
	
	sw $t1, ($t2)
	
	bne  $t5, $t8, obj_going_left_2
	subu $t2, $t2, 4 # obj_going_right_2
	j obj_going_right_2
	obj_going_left_2:
	addu $t2, $t2, 4
	obj_going_right_2:
	
	j drawobj_loop_in
	
	end_drawobj_loop:
	
	lw $t4, length_row
	addu $t2, $t0, $t4
	addu $t7, $t7, $t4 #update coordinate of the first pixel of the row
	j drawobj_loop_out
	
	exit_drawobj:
	
	jr $ra

clean_frog:
	#clean path left by frog
	lw $t1, frog_pos_y
	la $t2, lev_1_col #obtain address color level
	addu $t1, $t1, $t2
	lw $t0, ($t1)	#right color to cover frog traces
	
	lw $t3, lev_3_col #special case it passes on the wood
	bne $t0, $t3, not_log_color
	lw $t0, log_colour
	not_log_color:
	
	lw $t1, displayAddress
	lw $t2, frog_pos_y
	lw $t3, length_row
	multu $t2, $t3
	mflo $t2
	addu $t1, $t1, $t2
	lw $t2, frog_pos_x
	addu $t1, $t1, $t2 # initial frog point
	
	lw $t6, length_row
	li $t9, 4
	multu $t6, $t9
	mflo $t2 #limit for outer loop
	li $t9, 16 #limit for inner loop
	li $t5, 0 #outer counter
	clean_frog_loop_out:
	addu $t4, $t1, $t5 #first element of new row
	li $t3, 0 #inner counter
	clean_frog_loop_in:
	sw $t0, ($t4)
	addu $t4, $t4, 4
	addu $t3, $t3, 4
	subu $t7, $t9 , $t3
	bgtz $t7, clean_frog_loop_in
	addu $t5, $t5, $t6
	subu $t7, $t2, $t5
	bgtz $t7, clean_frog_loop_out
	jr $ra #return previous callee position



move_top:
	lw $t9, frog_pos_y
	beq $t9, 0, main
	jal clean_frog
	#updating frog_pos_y value
	lw $t1, frog_pos_y
	la $t2, frog_pos_y #obtain address frop_pos_y
	li $t3, 4
	subu $t1, $t1, $t3
	sw $t1, 0($t2)
	jal draw_frog
	j input_elaborated

move_down:
	lw $t9, frog_pos_y
	lw $t8, limit_pos_y
	beq $t9, $t8, main
	jal clean_frog
	#updating frog_pos_x value
	lw $t1, frog_pos_y
	la $t2, frog_pos_y #obtain address frop_pos_y
	li $t3, 4
	addu $t1, $t1, $t3
	sw $t1, 0($t2)
	jal draw_frog
	j input_elaborated

move_left:
	lw $t9, frog_pos_x
	beq $t9, 0, main
	jal clean_frog
	#updating frog_pos_x value
	lw $t1, frog_pos_x
	la $t2, frog_pos_x #obtain address frop_pos_x
	li $t3, 8
	subu $t1, $t1, $t3
	sw $t1, 0($t2)
	jal draw_frog
	j input_elaborated
	
move_right:
	lw $t9, frog_pos_x
	lw $t8, length_row
	subu $t9, $t8, $t9
	beq $t9, 16, main #the length of the frog is 4 pixels which is 16 bits(4*4)
	jal clean_frog
	#updating frog_pos_x value
	lw $t1, frog_pos_x
	la $t2, frog_pos_x #obtain address frop_pos_x
	li $t3, 8
	addu $t1, $t1, $t3
	sw $t1, 0($t2)
	jal draw_frog
	j input_elaborated

generate_obj_func:
	lw $t1, no_car_value
	
	la $t7 , time_car_1_left
	addu $t7, $t7, $t0 #selecting the right time_obj_x_left variable
	lw $t8, ($t7)
	
	beq $t8, $t1, generate_rand #generate random number as time in which next obj appears
	
	lw $t2, time_sleep
	
	subu $t8, $t8, $t2 #16 ms
	
	blez $t8, rand_time_end	#check time is passed
	sw $t8, ($t7)
	jr $ra
	rand_time_end:
	sw $t1, ($t7) #reset time counter
	#set the initial position x
	la $t7 , car_1_pos_x
	addu $t7, $t7, $t0 #selecting the right obj_x_pos_x variable

	la $t1, car_1_pos_y
	addu $t1, $t1, $t0
	lw $t3, ($t1)   #pos obj y
	
	lw $t1, car_threshold
	li $t8, 4
	divu $t0, $t8
	mflo $t9
	bge $t9, $t1, generate_log_pos
	lw $t1, car_colour
	lw $t5, lev_6_pos_y #check car direction
	j generate_car_pos
	generate_log_pos:
	lw $t1, log_colour
	lw $t5, lev_3_pos_y #check log direction
	generate_car_pos:
	
	beq $t5, $t3, generate_obj_going_right	
	li $t8, 0x7c
	j generate_obj_going_left
	generate_obj_going_right:
	li $t8, 0x0
	generate_obj_going_left:
	sw $t8, ($t7) #saving initial value inside obj_x_pos_x variable
	move $a0, $ra
	j draw_obj#draw initial obj
	jr $a0
	
	generate_rand:
	lw $t2, time_interval #160 ms = 10 * 16 (16 ms is the sleep interval)
	
	li $v0, 42
	li $a0, 0
	move $a1, $t2
	syscall
	
	sw $a0, ($t7)
	jr $ra

move_obj:
	move $a2, $t0 #to check other objs to generate
	mulu $t0,$t0, 4
	move $a0, $ra
	move $a1, $t0
	la $t1, car_1_pos_x
	addu $t6, $t1, $t0 #t0 contains the offset of the obj selected
	lw $t2, ($t6)  #pos obj x
	
	lw $t1, no_car_value
	xor $t1, $t2,  $t1 #check if generating a new obj
	la $t7 ,car_1_left
	addu $t7, $t7, $t0 #selecting the right obj_x_left variable
	lw $t8, ($t7)
	addu $t1, $t1, $t8 #t1 equals 0 only if t8 == 0 and pos obj x == no_car_value
	beqz $t1, generate_obj
	
	la $t1, car_1_pos_y
	addu $t1, $t1, $t0
	lw $t3, ($t1)   #pos obj y
	move $a3, $t3 #save obj y position
	
	lw $t1, car_threshold
	bge $a2, $t1, move_log_pos
	lw $t5, lev_6_pos_y #check car direction
	j move_car_pos
	move_log_pos:
	lw $t5, lev_3_pos_y #check log direction
	move_car_pos:
	
	beq $t5, $t3, move_obj_going_right
	subu $t2, $t2, 4 #move_obj_going_left
	move $a2, $t2 #save new x position
	li $t3, 0
	subu $t3, $t3, 4
	bne $t2, $t3, notset_objleft_left #it sets the initial value of the remaining amount of obj inside the image
	j set_objleft
	move_obj_going_right:
	addu $t2, $t2, 4
	move $a2, $t2 #save new x position
	lw $t3, length_row
	bne $t2, $t3, notset_objleft_right #it sets the initial value of the remaining amount of obj inside the image
	
	set_objleft:
	la $t7 ,car_1_left
	addu $t7, $t7, $t0 #selecting the right obj_x_left variable
	lw $t8, car_length
	sw $t8, ($t7)  #set initial value of obj_x_left variable
	lw $t8, no_car_value 
	sw $t8, ($t6) #setting obj position as invalid
	
	notset_objleft_left:
	lw  $t8, no_car_value
	subu $t8, $t8, 4 #case when only cleaning the obj
	beq $t8, $t2, cont_notset_objleft_left
	bgt   $t2, $t3, draw_cleanobj #check if obj has not reached end of the figure
	j cont_notset_objleft_left
	notset_objleft_right:
	blt  $t2, $t3, draw_cleanobj #check if obj has not reached end of the figure
	cont_notset_objleft_left: # if obj has reached the end of the figure
	la $t7 ,car_1_left
	addu $t7, $t7, $t0 #selecting the right obj_x_left variable
	lw $t8, ($t7)
	beqz $t8, delete_obj
	subu $t8, $t8, 4
	sw $t8, ($t7) #updating obj_x_left value
	
	beq $t5, $a3, move_obj_going_right_2
	li $t2, 0 #move_obj_going_left_2
	lw $t9, car_length
	subu $t9, $t9, $t8
	subu $t2, $t2, $t9 #advance (virtually) obj
	move $a2, $t2 #save new x position
	j only_cleanobj
	move_obj_going_right_2:
	lw $t9, length_row
	subu $t2, $t9, 4 #setting t2 initial value as the end of the row
	lw $t9, car_length
	subu $t9, $t9, $t8 #compute advancement of obj
	addu $t2, $t2, $t9 #advance (virtually) obj
	move $a2, $t2 #save new x position
	j only_cleanobj
	
	draw_cleanobj:
	sw $t2, ($t6)  #pos obj x
	jal draw_obj
	
	only_cleanobj:
	
	move $t0, $a1 #a1 contains value of initial offset * 4
	
	move $t2, $a2 #recover new x position
	
	move $t3, $a3 #recover y position
	
	#clean_obj variables:
	#	- t0 : initial_offset * 4
	#	- t2 : x position 
	#	- t3 : y position
		
	jal clean_obj
	
	exit_moveobj:
	jr $a0
	
	delete_obj:
	jr $a0
	
	generate_obj:
	move $t1, $a2 #retrieve initial offset to check other objs
	
	move $a2, $a0 #save returning point
	
	xor $t1, $t1, 1 # for now the objs are only 4 so xoring with 1 interchange between 2 possible objs
	
	#t1 is the offset of the other obj to check
	mulu $t1,$t1, 4
	
	la $t2, car_1_pos_x
	addu $t2, $t2, $t1
	lw $t3, ($t2) # pos x of other obj
	
	la $t6, car_1_pos_y
	addu $t6, $t6, $t0
	lw $t4, ($t6)   #pos y of new obj
	
	lw $t2, car_threshold
	li $t7, 4
	divu $t0, $t7
	mflo $t6
	bge $t6, $t2, move_log_pos_2
	lw $t5, lev_6_pos_y #check car direction
	j move_car_pos_2
	move_log_pos_2:
	lw $t5, lev_3_pos_y #check log direction
	move_car_pos_2:
	
	lw $t2, car_length
	lw $t6, length_row
	
	beq $t5, $t4, generate_newobj_going_right
	lw $t5, no_car_value
	beq $t5, $t3, continue_generate
	subu $t6, $t6, $t3
	ble $t6, $t2, no_generate_obj
	j continue_generate
	generate_newobj_going_right:
	ble $t3, $t2, no_generate_obj
	
	continue_generate:
	jal generate_obj_func
	
	no_generate_obj:
	jr $a2

clean_obj_loop:
	lw $t7, length_row
	li $t2, 0 #outer counter
	clean_obj_loop_out:
	#addu $t4, $t1, $t5 #first element of new row
	li $t3, 0 #inner counter
	move $t4, $t1
	clean_obj_loop_in:
	sw $t9, ($t4)
	sub $t4, $t4, 4
	addu $t3, $t3, 1
	bne  $t3, 1,clean_obj_loop_in #horizontally move inside the rectangle to clean
	addu $t1, $t1, $t7
	addu $t2, $t2, 1
	bne  $t2, 4, clean_obj_loop_out #vertically move inside the rectangle to clean
	jr $ra

clean_obj:
	move $a1, $ra # save returning point
	lw $t6, car_length
	lw $t8, length_row
	
	lw $t1, displayAddress
	multu $t3, $t8
	mflo $t9
	addu $t1, $t1, $t9 #y pos wrt displayAddress
	
	lw $t9, car_threshold
	li $t4, 4
	divu $t0, $t4
	mflo $t7
	bge $t7, $t9, clean_log_pos
	lw $t5, lev_6_pos_y #check car direction
	lw $t9, lev_7_col # set color pavement
	j clean_car_pos
	clean_log_pos:
	lw $t9, lev_3_col
	lw $t5, lev_3_pos_y #check log direction
	clean_car_pos:
	
	beq $t5, $t3, clean_obj_going_right
	
	clean_obj_going_left:
	subu $t7, $t8, $t2
	ble $t7, $t6, exit_cleanobj
	
	addu $t2, $t2, $t6 
	addu $t1, $t1, $t2 # initial obj's tail point
	#addu $t1, $t1, 4 #end obj's tail point
	
	jal clean_obj_loop
	
	j exit_cleanobj
	clean_obj_going_right:
	
	subu $t7, $t2, $t6
	bltz  $t7, exit_cleanobj #check if the part to clean is inside the screen or not
	
	addu $t1, $t1, $t7 # initial point to clean
	
	jal clean_obj_loop
	
	exit_cleanobj:
	jr $a1


check_event:
	#a0 contains info if event related to log or car (it is used as offset)
	lw $t0, frog_pos_y #determine which level the frog is in
	
	lw $t1, car_threshold
	
	move $a1, $a0
	beqz $a0, offset_car_case    #offset to select car (0) or log (1)
	move $a1, $t1
	mulu $a1, $a1, 4
	li $a3, 0 #counter used for logs
	offset_car_case:
	
	xor $a2, $a0, 1
	mulu $a2, $a2, 8 #offset for levels y checks
	li $t9, 0 #select level 3/6 (0) or level 4/7 (1)
	la $t2, lev_3_pos_y
	addu $t2, $t2, $a2  #to select lev_3_pos_y or lev_6_pos_y depenging on $a0
	lw $t3, ($t2)
	move $t2, $t3
	beq  $t0, $t2, check_event_frog_lev3_6 #check if frog is in level 3/6
	
	check_event_frog_lev4_7:
	li $t9, 1
	la $t2, lev_4_pos_y
	addu $t2, $t2, $a2  #to select lev_4_pos_y or lev_7_pos_y depenging on $a0
	lw $t3, ($t2)
	move $t2, $t3
	bne $t0, $t2, no_event #check if frog is in level 4/7
	check_event_frog_lev3_6:
	
	li $t3, 0 #index
	beq $a0, 0, event_car_1 # case in which it is a car
	#event_log_1
	lw $t3, car_threshold #the beginning and end of the for loop are shifted of car_threshold
	addu $t1, $t1, $t3
	event_car_1:
	
	
	check_event_loop:
	beq $t3, $t1, no_event #check if all the cars/logs have been checked (it is assumed number of cars and logs is the same = car_threshold)
	la $t4, car_1_pos_y
	mulu $t5, $t3, 4
	#addu $t5, $t5, $a1 #to select a car or a log depending on a1 (if a0 == 1 a1 = car_threshold * 4 else a1 = 0)
	addu $t3, $t3, 1 # increment index by 1
	addu $t4, $t4, $t5
	lw $t6, ($t4) #loading car_x_pos_y value to check if it is on the same level
	
	bne, $t6, $t2, check_event_loop
	
	#car/log and frog are on the same level
	la $t4, car_1_pos_x
	addu $t4, $t4, $t5 #find car_x_pos_x
	lw $t6, ($t4) #t5 contains car_x_pos_x
	
	lw $t4, no_car_value
	bne  $t6, $t4, no_special_case_car_event #checking car existence
	#special_case_car_event: #car could be defined as non existant but it exists #check car_left
	
	lw $t6, frog_pos_x
	li $t7, 0xc #frog_width in bytes - 4 (the 4th element is already included)
	addu $t7, $t6, $t7 #position opposite point of frog
	
	la $t4, car_1_left
	addu $t5, $t5, $t4
	lw $t4, ($t5) #obtain value saved into car_x_left
	beqz $t4, check_event_loop
	beq $a0, 1, special_case_log #it is referred to log
	beq $t9, 1, special_case_car_lev7
	li $t5, 0x7c #end of row
	subu $t4, $t5, $t4 # $t4 = end_of_row - car_x_left
	j spec_car_check_collision_condit_lev6
	
	special_case_car_lev7:
	li $t5, 0x0 #beginning of row
	j spec_car_check_collision_condit_lev7
	
	special_case_log: #log cases
	beq $t9, 1, special_case_log_lev4
	li $t5, 0x7c #end of row
	subu $t4, $t5, $t4 # $t4 = end_of_row - log_x_left
	j spec_log_check_drown_condit_lev3
	
	special_case_log_lev4:
	li $t5, 0x0 #beginning of row
	j spec_log_check_drown_condit_lev4
	
	no_special_case_car_event:
	move $t5, $t6
	lw $t4, car_length
	subu $t4, $t4, 1 #if not it would count 9 pixels
	
	lw $t6, frog_pos_x
	li $t7, 0xc #frog_width in bytes - 4 
	addu $t7, $t6, $t7 #position opposite point of frog
	
	beq $a0, 1, check_drown_log
	beq $t9, 1, check_collision_condit_lev7
	check_collision_condit_lev6:
	subu $t4, $t5, $t4 #position opposite point of car
	spec_car_check_collision_condit_lev6:
	bgt $t6, $t5, check_event_loop #frog is at the right of the car
	blt $t7, $t4, check_event_loop #frog is at the left of the car
	li $t0, 1 #there is collision
	j exit_event
	
	check_collision_condit_lev7:
	addu $t4, $t5, $t4 #position opposite point of car
	spec_car_check_collision_condit_lev7:
	blt $t7, $t5, check_event_loop #frog is at the left of the car
	bgt $t6, $t4, check_event_loop #frog is at the right of the car
	li $t0, 1 #there is collision
	j exit_event
	
	check_drown_log: #check if drown
	beq $t9, 1, check_drown_condit_lev4
	check_drown_condit_lev3:
	subu $t4, $t5, $t4 #position opposite point of log
	spec_log_check_drown_condit_lev3:
	bgt  $t6, $t5, lev3_drown_happens #frog is at the right of the log
	bgt  $t7, $t5, lev3_drown_happens #frog has to stay entirely on the log
	blt $t7, $t4, lev3_drown_happens #frog is at the left of the log
	blt $t6, $t4, lev3_drown_happens #frog has to stay entirely on the log
	j no_event
	lev3_drown_happens:
	lw $t8, car_threshold
	divu $t8, $t8, 2 #it assumes equal number logs in both ways
	addu $a3, $a3, 1
	blt $a3, $t8, check_event_loop
	li $t0, 1 #there is drown
	j exit_event
	
	check_drown_condit_lev4:
	addu $t4, $t5, $t4 #position opposite point of log
	spec_log_check_drown_condit_lev4:
	blt $t7, $t5, lev4_drown_happens #frog is at the left of the log
	blt  $t6, $t5, lev4_drown_happens #frog has to stay entirely on the log
	bgt $t6, $t4, lev4_drown_happens #frog is at the right of the log
	bgt  $t7, $t4, lev4_drown_happens #frog has to stay entirely on the log
	j no_event
	lev4_drown_happens:
	lw $t8, car_threshold
	divu $t8, $t8, 2 #it assumes equal number logs in both ways
	addu $a3, $a3, 1
	blt $a3, $t8, check_event_loop
	li $t0, 1 #there is drown
	j exit_event
	
	no_event:
	li $t0, 0 #t0 contains returned value 
	
	exit_event:
	jr $ra

check_target:
	lw $t0, frog_pos_x
	lw $t1, frog_pos_y
	li $t4, 0xc #frog width
	addu $t0, $t0, $t4
	
	bgt $t1, 2, no_target
	
	lw $t2, length_row
	subu $t2, $t2, 12
	
	blt $t0, $t2, no_target
	li $t0, 1
	j exit_target 
	
	no_target:
	li $t0, 0
	
	exit_target:
	jr $ra

main:
	lw $t0, time_sleep
	li $v0, 32
	move $a0, $t0
	syscall
	
	lw $t2, time_difficulty
	lw $t3, game_difficulty
	blt $t2,  $t3, skip_move_difficulty
	la $t2, time_difficulty
	li $t3, 0
	sw $t3, ($t2) #reset time_difficulty value
	#objects movement takes place
	
	li $t1, 0
	
	loop_main: #loop to iterate among different objects (car and logs)
	
	move $t0, $t1  
	jal move_obj 
	
	li $t2, 4
	divu $t0, $t2 #t0 is multiplied by 4 during move_obj call
	mflo $t1   #t1 is modified during move_obj call
	
	addu $t1, $t1, 1
	blt $t1, 8, loop_main #in this case there are 8 objects (4 cars and 4 logs)
	j move_difficulty
	
	skip_move_difficulty: #depends on game difficulty
	lw $t3, time_difficulty
	la $t2, time_difficulty
	addu $t3, $t3, 1
	sw $t3, ($t2) #reset time_difficulty value
	
	move_difficulty: #if move takes place
	
	lw $t0, 0xffff0000 #check if any button has been pressed
	bne $t0, 1, input_elaborated
	lw $t1, 0xffff0004 #check which button has been pressed
 
	beq $t1, 0x61 , move_left # A has been pressed

	beq $t1, 0x64 , move_right # D has been pressed

	beq $t1, 0x77 , move_top # W has been pressed

	beq $t1, 0x73 , move_down # S has been pressed
	
	input_elaborated:
	
	jal draw_frog #in case there is no move
	
	li $a0, 0 # 0: car case; 1: log case
	
	loop_main_event:
	
	beq $a0, 2, events_elaborated
	jal check_event
	
	beq $t0, 1, lose_game
	addu $a0, $a0, 1
	j loop_main_event
	
	events_elaborated:
	jal check_target
	
	beq $t0, 1, win_game
	
	j main
	
	
	
	
	
	
	
	
	
		
