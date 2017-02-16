UrJtag can be used to perform complex JTAG operations through the
OSUisp2 programmer (or many other programmers).

For documentation on UrJtag, see http://urjtag.org/

To start UrJtag, run the runUrJtag.bat batch file.  This file simply
runs jtag.exe from the bin folder.


To connect to the OSUisp2 programmer, type "cable usbasp"
(yes, its mascarading as the old modified usbasp programmer still...)
Obviously, the OSUisp2 programmer must be connected,
as well as the target device.

To detect the JTAG chip chain, type "detect"

To run a .svf file, type "svf filename.svf"
The svf file will program very slowly, usually 5 minutes or so.
There is no progress output of any kind, so grab a sandwich and enjoy.