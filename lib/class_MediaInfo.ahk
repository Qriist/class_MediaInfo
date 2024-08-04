class class_MediaInfo {
    __New(dll_location?) {
        dll_location := this.dll_locator(dll_location?) ;do some light sanity checks on the DLL.
        this.handle := DllCall("LoadLibrary", "Str", dll_location, "Ptr")
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