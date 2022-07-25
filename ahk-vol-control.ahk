;-- Vista Audio Control Functions --;
;-- https://ahkscript.github.io/VistaAudio/ --;

SetBatchLines, -1
#Include lib\VA.ahk


volOSD(volume) {
	static init_gui := 1
	static VolSlider
	static VolText
	if init_gui {
		Gui, VOL_OSD: Add, Progress, w100 h30 x0 y0 c3e7061 Background222d32 Range0-100 vVolSlider, 0
		Gui, VOL_OSD: Add, Text, w100 h20 x0 y5 vVolText cffffff BackgroundTrans Center +0x200, 0
		Gui, VOL_OSD: +AlwaysOnTop -Caption +ToolWindow +HwndGuiHwnd
		Gui, VOL_OSD: Show, Hide w100 h30 x0 y0, Volume
		init_gui := 0
	}
	GuiControl,VOL_OSD:,VolSlider, % Round(Volume,1)
	GuiControl,VOL_OSD:,VolText, % Round(Volume,1) . (VA_GetMasterMute() ? " X" : "")
	Gui, VOL_OSD: Show, NA xCenter y537
	SetTimer, ClearOSD, -2000
	return
}

ClearOSD:
	Gui, VOL_OSD: Show, Hide
return

handleVolume(volstate:="up",procname := "focused",step := 1) {
	Amount := step
	if (volstate != "up") 
		Amount := -step
	if (procname != "focused") {
		Process Exist, %procname%
		PID := ErrorLevel
		if (PID == 0) {
			PID := -1
		}
	} else {
		WinGet, PNAME, ProcessName, A
		if (PNAME == "msedge.exe" || PNAME == "chrome.exe") {
			PID := handleBrowserVolume(PNAME)
		} else PID := PNAME
	}
		VA_SetAppVolume(PID, VA_GetAppVolume(PID) + Amount)
		manageVolumeOSD(PID)
}

manageVolumeOSD(PID) {
	Volume := VA_GetAppVolume(PID)
	volOSD(Volume)
}

handleBrowserVolume(app) {
	For proc in ComObjGet("winmgmts:").ExecQuery("SELECT ProcessID, CommandLine FROM Win32_Process WHERE Name = """ app """ AND CommandLine LIKE '%audio.mojom.AudioService%'")
		return proc.ProcessID
	if !proc.ProcesID 
		return -1
}

VA_GetISimpleAudioVolume(Param)
{
	static IID_IASM2 := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
	, IID_IASC2 := "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
	, IID_ISAV := "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"
	
	; Turn empty into integer
	if !Param
		Param := 0
	
	; Get PID from process name
	if Param is not Integer
	{
		Process, Exist, %Param%
		Param := ErrorLevel
	}
	
	; GetDefaultAudioEndpoint
	DAE := VA_GetDevice()
	
	; activate the session manager
	VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
	
	; enumerate sessions for on this device
	VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
	VA_IAudioSessionEnumerator_GetCount(IASE, Count)
	
	; search for an audio session with the required name
	Loop, % Count
	{
		; Get the IAudioSessionControl object
		VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
		
		; Query the IAudioSessionControl for an IAudioSessionControl2 object
		IASC2 := ComObjQuery(IASC, IID_IASC2)
		ObjRelease(IASC)
		
		; Get the session's process ID
		VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
		
		; If the process name is the one we are looking for
		if (SPID == Param)
		{
			; Query for the ISimpleAudioVolume
			ISAV := ComObjQuery(IASC2, IID_ISAV)
			
			ObjRelease(IASC2)
			break
		}
		ObjRelease(IASC2)
	}
	ObjRelease(IASE)
	ObjRelease(IASM2)
	ObjRelease(DAE)
	return ISAV
}

;
; ISimpleAudioVolume : {87CE5498-68D6-44E5-9215-6DA47EF883D8}
;
VA_ISimpleAudioVolume_GetMasterVolume(this, ByRef fLevel) {
	return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "float*", fLevel)
}
VA_ISimpleAudioVolume_SetMasterVolume(this, ByRef fLevel, GuidEventContext="") {
	return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "float", fLevel, "ptr", VA_GUID(GuidEventContext))
}
VA_ISimpleAudioVolume_GetMute(this, ByRef Muted) {
	return DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "int*", Muted)
}
VA_ISimpleAudioVolume_SetMute(this, ByRef Muted, GuidEventContext="") {
	return DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "int", Muted, "ptr", VA_GUID(GuidEventContext))
}


VA_GetAppVolume(App)
{
	ISAV := VA_GetISimpleAudioVolume(App)
	VA_ISimpleAudioVolume_GetMasterVolume(ISAV, fLevel)
	ObjRelease(ISAV)
	return fLevel * 100
}

VA_SetAppVolume(App, fLevel)
{
	ISAV := VA_GetISimpleAudioVolume(App)
	fLevel := ((fLevel>100)?100:((fLevel < 0)?0:fLevel))/100
	VA_ISimpleAudioVolume_SetMasterVolume(ISAV, fLevel)
	ObjRelease(ISAV)
}