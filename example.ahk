;=== Load ahk-vol-control ===;
#Include ahk-vol-control.ahk


;== Control Volume of focused application (Ctrl + Shift + Insert / Ctrl + Shift + Home) ==;
+^Insert::
handleVolume("up","focused",0.5)
Return

+^Home::
handleVolume("down","focused",0.5)
Return

;== Control Volume of spotify (z / x) ==;
z::
handleVolume("up","spotify.exe",0.5)
Return

x::
handleVolume("down","spotify.exe",0.5)
Return 
