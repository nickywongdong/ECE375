This folder contains the UniversalGUI tool,
as well as the command line .xsvf runner and avrdude.



UniversalGUI:
--------------------------------------------
Simply run this graphical tool to easily write/read avr chip memories.
The UniversalGUI uses the config file UGUIConfig.xml to load supported
programmers and chips, and to characterize specifics about programmers
and chips such as extra command line options or fuse bits.

If you have a chip which is supported by Avrdude and is not in the config
file, you may add it to the config file.  Check the datasheet for fuse
and lock bits, and ensure your entry for the bits matches the datasheet.



XSVF_Sender.exe:
--------------------------------------------
This command line tool inputs a .xsvf file as a command line parameter
and connects to the OSUisp2 programmer, feeding instructions to the
state machine on the programmer which will perform commands described
in the .xsvf file and program a connected target device.  This tool
is derived from the usbProg xsvf runner firmware and software.
