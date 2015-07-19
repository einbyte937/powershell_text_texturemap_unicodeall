# powershell_font_to_texturemap

*******************
Background: OpenGL the 3D graphics engine does not provide a native capability to draw a text within a GLView
One of the accepted methods of drawing a text involves using two triangles to draw a rectangle and then texture
the rectangle with an image taken from the co-ordinates of a larger image which is commonly reffered to as able
texture map. I found that creating the texture map required some programming skill and some time and additional
patience. As well I found that I wanted a PowerShell way of creating the texture map and a cursory search did
not find any available so I created this project...
*******************

Use one of these in the PowerShell before you use the script:

	[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding
	$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
	
The noto font kit from Google is what I am currently using it seems to do the best job:
https://www.google.com/get/noto/

Other fonts can be obtained by searching the internet and installing programs on your PC.

Use the script: fonttopng.ps1
*****
Unpack the ImageMagick binary distribution to C:\ImageMagick so that you can find the file C:\ImageMagick\convert.exe
Some programming knowledge of the PowerShell is useful at current I would expect that you look over the source code
of the script and make whatever adjustments and additions need to be made for the script to function. I will later
be adding some command line parameters as the script becomes more mature.
******
You will need to list available fonts C:\ImageMagick\convert.exe -list font from the command line to check each font
is installed on your system or

convert.exe -list font > output.txt to write the output to a file if the output is chopped off. You can also increase
the buffer size in the console properties window to store more text.

Tutorial:
https://www.youtube.com/watch?v=FLiaEqhTwKc

contact: einbyte937@gmail.com