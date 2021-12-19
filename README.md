# frogger

	-------     -----      --------     --------      --------       -------      ----- 
	|           |    |     |      |     |             |              |            |    |
	|----       |----      |      |     |   ---|      |   ---|       |----        |---- 
	|           |\         |      |     |      |      |      |       |            |\
	|           | \        --------     -------|      -------|       -------      | \


 THIS CODE IS WRITTEN IN ASSEMBLY AND IT HAS BEEN DEPLOYED TO BE EXECUTED ON MARS 4.5

 THIS GAME IS INSPIRED FROM THE GAME FROM THE 80's "FROGGER"
 
 THE TARGET OF THE GAME IS REACHING THE X IN THE TOP LEFT CORNER OF THE SCREEN.

 THE RED AND BROWN MOVING RECTANGLES ARE RESPECTIVELY CARS AND LOGS.

 TO REACH THE TARGET YOU HAVE TO CROSS THE STREET AVOIDING CARS AND TRAVERSING THE 
 RIVER ON THE LOGS.


 To play this game on Mars 4.5 (link to download it 
 http://courses.missouristate.edu/kenvollmar/mars/) you have to use the tools "Bitmap Display"
 to visualize the game and "Keyboard and Display MMIO Simulator" which are present
 under the tab "Tools"

 The settings for the Bitmap Display are the following

 Bitmap Display Configuration:
 - Unit width in pixels: 8
 - Unit height in pixels: 8
 - Display width in pixels: 256
 - Display height in pixels: 256
 - Base Address for Display: 0x10008000 ($gp)

 After having selected the correct parameters you can connect display and keyboard to MIPS


	To move press WASD
	
	To survive on the log the frog has to be completely on the log

	It is possible to set the difficulty of the game
	after having lost. To do so, when "END" writing appears
	press a number 0-4 to select the difficulty where
	0 is most difficult and 4 is the easiest

	It is possible to restart the game when you lose pressing R

	Also sound effect are reproduced connected to events

	If you have any remark and feedback to give me please
	do not hesitate	

	I hope you like it:)


