class class_MediaInfo {
    __New(dll_location?) {
        dll_location := this.dll_locator(dll_location?) ;do some light sanity checks on the DLL.
        
        ;get dll handle
        this.dll := DllCall("LoadLibrary", "Str", dll_location, "Ptr")
        
        ;get some important pointers
        this.MediaInfo_New := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_New", "Ptr")
        this.MediaInfo_Open := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Open", "Ptr")
        ; this.MediaInfo_Inform := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Inform", "Ptr")
        ; this.MediaInfo_Close := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Close", "Ptr")
        ; this.MediaInfo_Delete := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Delete", "Ptr")

        ;use this handle during dll calls
        this.handle := DllCall(this.MediaInfo_New, "Ptr")
    }

    Open(file){
        return DllCall(this.MediaInfo_Open, "Ptr", this.handle, "Str", file, "UInt")    ;returns 1 on success
    }



    dll_locator(dll_location?){ ;try to auto-detect a missing MediaInfo.dll
        if IsSet(dll_location)
            If FileExist(dll_location)
                return
            else
                dll_location := unset
        
        checkObj := StrSplit(EnvGet("PATH"),";")
        checkObj.InsertAt(1,[A_ScriptDir "\bin\",A_ScriptDir "\lib\",A_ScriptDir "\dll\",A_ScriptDir]*)

        for k,v in checkObj
            If FileExist(v "\MediaInfo.dll")
                return v "\MediaInfo.dll"  
        ;TODO - ask to auto-download the missing dll
        MsgBox "Unable to locate MediaInfo.dll. Exiting."
        ExitApp
    }
}