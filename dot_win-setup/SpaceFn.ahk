#Requires AutoHotkey v2.0.12
#SingleInstance

; Map Ctrl to CapsLock 
CapsLock::Ctrl

confFilePath := "./conf.ini"
conf := getConf()

; Obtain the virtual key (vk) and monitoring key mappings
vkKey := map()
optKey := "{Space}"
for k,v in conf["KEY"] {
    optKey := optKey "{" k "}"
    vkKey[GetKeyVK(k)] := v
}


;SpaceFn
+Space::
^Space::
^+Space::
Space::
{
    global startTime := A_TickCount
    global releaseKey := []
    SetKeyDelay -1
    ; If the delay time is reached and there are still keys not released, treat it as Fn layer release
    SetTimer(timeoutReleaseKey,-conf["DEFAULT"]["press_time"])
    hook := InputHook("V L0")
    hook.OnKeyUp := OnKeyUp
    hook.OnKeyDown := OnKeyDown
    hook.KeyOpt(optKey, "N S")
    hook.Start()

    ; Function triggered on key release
    OnKeyUp(ih, vk, sc){
        global StartTime
        global releaseVK := []
        diffTime := A_TickCount - StartTime
        if (GetKeyVK("Space") == vk) {
            if (diffTime <= conf["DEFAULT"]["press_time"]) {
                Hotkey "Space", "OFF"

                ; If there are unreleased keys, press them as in the normal layer
                prefixKey := ""
                if (releaseKey.length > 0) {
                    for k,v in releaseKey {
                        prefixKey := prefixKey "{" GetKeyName(Format("vk{:x}sc{:x}", v["vk"], v["sc"])) "}"
                    }
                }
                Send modifierPress(prefixKey "{Space}")

                ; Clear releaseKey
                releaseKey := []
                Hotkey "Space", "ON"
            }
            ih.Stop()
            return
        }
    }


    ; Function triggered on key press
    OnKeyDown(ih, vk, sc){
        global StartTime
        global releaseKey
        diffTime := A_TickCount - StartTime

        ; Space key should not execute
        if (GetKeyVK("Space") == vk) {
            return
        }

        ; If not timed out, record unreleased keys
        if (diffTime <= conf["DEFAULT"]["press_time"]) {
            releaseKey.Push(map("vk",vk,"sc",sc))
            return
        }

        ; Entered long key press, can release
        timeoutReleaseKey()

        ; If Space is already released, manually release it and output as it is
        if diffTime > conf["DEFAULT"]["press_time"] && !GetKeyState("Space") {
            ih.Stop()
            modifierPress("{" GetKeyName(Format("vk{:x}sc{:x}", vk, sc)) "}")
            return
        }

        ; If there are mapped keys, press them
        if (vkKey.Has(vk)) {
            modifierPress(vkKey[vk])
        }
    }


    ; Function to release unreleased keys after timeout
    timeoutReleaseKey(){
        global releaseKey
        if (releaseKey.length > 0) {
            for k,v in releaseKey {
                if (vkKey.Has(v["vk"])) {
                    modifierPress(vkKey[v["vk"]])
                }
            }
        }
        releaseKey := []
    }
}



; Function to handle key presses with modifiers
modifierPress(key){
    modifierKey := map("Ctrl","^","Shift","+","Alt","!","LWin","#","RWin","#")
    modifier := ""
    for k,v in modifierKey {
        if GetKeyState(k,"P"){
            modifier := v modifier
        }
    }
    Send "{Blind}" modifier key
}

; Function to retrieve configuration from file
getConf(){
    defaultConf := GetDEFAULTConf()
    try{
        conf := FileRead(confFilePath)
        ; If configuration retrieval successful, override default configuration
        data := map()
        data["DEFAULT"] := map("press_time",iniRead(confFilePath,"DEFAULT","press_time",defaultConf["DEFAULT"]["press_time"]),"startup",iniRead(confFilePath,"DEFAULT","startup",defaultConf["DEFAULT"]["startup"]))
        key := iniRead(confFilePath,"KEY")
        data["KEY"] := getSectionMap(key)
        return data
    }catch{
        ; If configuration retrieval failed, write default configuration to file
        for section,sectionValue in defaultConf{
            for key,value in sectionValue{
                ; Handle empty values that require escaping
                value := RegExReplace(value, "=", "\=")
                value := RegExReplace(value, "\[", "\[")
                value := RegExReplace(value, "\]", "\]")
                key := RegExReplace(key, "=", "\=")
                key := RegExReplace(key, "\[", "\[")
                key := RegExReplace(key, "\]", "\]")
                IniWrite value, confFilePath , section, key
            }
        }
        return defaultConf
    }
}

; Function to retrieve default configuration
GetDEFAULTConf(){
    ; Autostart
    startup := 1
    ; Press duration
    pressTime := 300
    ; Keyboard mapping
    keyMap := map()
    keyMap["h"] := "{Left}"
    keyMap["j"] := "{Down}"
    keyMap["k"] := "{Up}"
    keyMap["l"] := "{Right}"
    keyMap["u"] := "{Home}"
    keyMap["i"] := "{End}"
    keyMap["["] := "{PgUp}"
    keyMap["]"] := "{PgDn}"
    keyMap["Enter"] := "{End}{Enter}"
    keyMap["Del"] := "{Ins}"
    keyMap["n"] := "{Backspace}"
    keyMap["m"] := "{Delete}"
    keyMap["Esc"] := "{``}"
    keyMap["1"] := "{F1}"
    keyMap["2"] := "{F2}"
    keyMap["3"] := "{F3}"
    keyMap["4"] := "{F4}"
    keyMap["5"] := "{F5}"
    keyMap["6"] := "{F6}"
    keyMap["7"] := "{F7}"
    keyMap["8"] := "{F8}"
    keyMap["9"] := "{F9}"
    keyMap["0"] := "{F10}"
    keyMap["-"] := "{F11}"
    keyMap["="] := "{F12}"
    keyMap["o"] := "{AppsKey}"
    return map("DEFAULT",map("press_time",pressTime,"startup",startup),"KEY",keyMap)
}

; Function to retrieve section map from configuration file
getSectionMap(conf){
    section := []
    pos := 1 ; Starting matching position
    while (RegExMatch(conf,"([^\n]+)",&subSection,pos)!=0)
    {
        pos := pos + subSection.Len + 1
        section.push(subSection[1])
    }
    data := map()
    for k,v in section{
        ; Retrieve key and value, trim whitespace
        rest := RegExMatch(v,"((?:[^=]|(?<=\\)=)+)=((?:[^=]|(?<=\\)=)+)",&subPat)
        if(rest){
            data[trim(subPat[1])] := trim(subPat[2])
        }
    }
    return data
}

; Function to trim whitespace and remove escape characters
trim(str){
    str := RegExReplace(str, "^\s+|\s+$", "")
    str := RegExReplace(str, "\\\=", "=")
    str := RegExReplace(str, "\\\[", "[")
    str := RegExReplace(str, "\\\]", "]")
    return str
}
