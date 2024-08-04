#Include <cJSON>    ;https://github.com/G33kDude/cJson.ahk  ;shout out to G33k for his amazing coding wizardry
class class_MediaInfo {
    __New(dll_location?,ReturnJsonAsMap := 1) {
        dll_location := this.__dll_locator(dll_location?) ;do some light sanity checks on the DLL.
        
        ;get dll handle
        this.dll := DllCall("LoadLibrary", "Str", dll_location, "Ptr")
        
        ;get pointers to make functions cleaner
        this.MediaInfo_New := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_New", "Ptr")
        this.MediaInfo_Open := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Open", "Ptr")
        this.MediaInfo_Inform := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Inform", "Ptr")
        this.MediaInfo_Option := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Option", "Ptr")
        this.MediaInfo_Close := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Close", "Ptr")
        this.MediaInfo_Delete := DllCall("GetProcAddress", "Ptr", this.dll, "AStr", "MediaInfo_Delete", "Ptr")


        ;use this.handle during subsequent dll calls
        this.handle := DllCall(this.MediaInfo_New, "Ptr")

        ;set some defaults
        this.ReturnJsonAsMap := ReturnJsonAsMap
        this.Option("Inform","JSON")
    }
    Info(file){ ;use this to get a one-line read on any given file
        this.Open(file)
        ret := this.Inform()
        this.Close()
        return ret
    }

    Open(file){
        return this.__Open(file)
    }
    Inform(){
        ret := this.__Inform()
        return this.ReturnJsonAsMap=1?this.__TryJson(&ret):ret
    }
    Close(){
        return this.__Close()
    }
    Option(option,value := ""){
        switch option { ;catch anything that needs special processing
            case "Inform" :
                option!="Inform"?"":value:=this.__SetInformFormat(value)
        }
        this.__Option(option,value)
    }


    ;class helper functions
    __dll_locator(dll_location?){ ;try to auto-detect a missing MediaInfo.dll
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
    __TryJson(&inStr){   ;allows non-json data to be safely returned
        try{
            return JSON.Load(inStr)
        } catch Error as err {
            return inStr
        }
    } 
    __SetInformFormat(InformFormat := "JSON"){
        formats := Map()
        ;JSON/TEXT/XML/CSV/HTML are probably the most useful formats
        ;go to the following helper function for more obscure stuff
        known := this.__knownFormats()
        
        for k,v in StrSplit(known,",")
            formats[v] := 1

        If !formats.Has(InformFormat)
            InformFormat := "JSON"  ;fallback
        
        ;TODO - check and correct case if required
        this.InformFormat := InformFormat  
        ; this.__Option("Inform", this.InformFormat)
        return InformFormat
    }
    __knownFormats(){
        ;NOTE: the DLL is case sensitive. When in doubt, copy and paste.
        known := "JSON,TEXT,XML,CSV,HTML" ;probably the most useful formats

        ;other known formats
        known .= ",EBUCore_1.5,EBUCore_1.6,EBUCore_1.8,EBUCore_1.8_parameterSegment,EBUCore_1.8_ps,EBUCore_1.8_segmentParameter,EBUCore_1.8_sp"
            .   ",EBUCore_1.5_JSON,EBUCore_1.6_JSON,EBUCore_1.8_JSON,EBUCore_1.8_parameterSegment_JSON,EBUCore_1.8_ps_JSON"
            .   ",EBUCore_1.8_segmentParameter_JSON,EBUCore_1.8_sp_JSON,EBUCore,EBUCore_JSON"
        known .= ",FIMS_1.1,FIMS_1.2,FIMS_1.3,FIMS"
        known .= ",MPEG-7,MPEG-7_Strict,MPEG-7_Relaxed,MPEG-7_Extended_If_Needed,MPEG-7_Extended"
        known .= ",PBCore_1,PBCore1,PBCore_1.2,PBCore_2,PBCore2,PBCore_2.0,PBCore_2.1,PBCore"
        known .= ",NISO_Z39.87"
        known .= ",Graph_Dot,Graph_Svg,Graph_Ac4_Dot,Graph_Ac4_Svg,Graph_Ed2_Dot,Graph_Ed2_Svg,Graph_Adm_Dot,Graph_Adm_Svg,Graph_Mpegh3da_Dot"
            .   ",Graph_Mpegh3da_Svg"
        ; known .= "reVTMD" ;paywalled or something idk
        known .= ",OLDXML,MAXML,MIXML"
        ; known .= "JSON_URL,Conformance_JSON"  ;seems depreciated/nonfunctional
        known .= ",Details"
        return known
    }



    ;internal DLL functions
    __Open(file){
        return DllCall(this.MediaInfo_Open, "Ptr", this.handle, "Str", file, "UInt")    ;returns 1 on success
    }
    __Inform(){
        return DllCall(this.MediaInfo_Inform, "Ptr", this.handle, "UInt", 0, "Str")
    }
    __Option(option, value := "") {
        ;pass an empty string as the value to get the current setting
        return DllCall(this.MediaInfo_Option, "Ptr", this.handle, "Str", option, "Str", value, "Str")
    }
    __Close() {
        ;Close the media file
        return DllCall(this.MediaInfo_Close, "Ptr", this.handle, "UInt")
    }
    __Delete() {
        DllCall(this.MediaInfo_Delete, "Ptr", this.handle)
        DllCall("FreeLibrary", "Ptr", this.dll)
    }
}