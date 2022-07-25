# ahk-vol-control
AHK script to changes volume of the focused program in the window using hotkeys. It will also display an OSD.

Games must be borderless/windowed.

# How to use
Simply add ahk-vol-control.ahk into your script and invoke handleVolume().

It has three parameters: (up/down | focused window / executable | step to increase/decrease volume).

```
#Include ahk-vol-control.ahk

;== Control Volume of focused application (Ctrl + Shift + Insert / Ctrl + Shift + Home) ==;
+^Insert::
handleVolume("up","focused",0.5)
Return

+^Home::
handleVolume("down","focused",0.5)
Return

;== Control Volume of spotify (Ctrl + Insert / Ctrl + Home) ==;
^Insert::
handleVolume("up","spotify.exe",0.5)
Return

^Home::
handleVolume("down","spotify.exe",0.5)
Return 
```
# Credits
This script is a wrapper of [Volume.ahk](https://old.reddit.com/r/AutoHotkey/comments/87colk/controlling_volume_of_specific_applications/dx2r5vb/) from [G33kDude](https://github.com/G33kDude).
