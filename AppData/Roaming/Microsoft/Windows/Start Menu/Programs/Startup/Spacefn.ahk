; Remap Caps Lock to Left Ctrl
*CapsLock::Send, {LCtrl Down}
*CapsLock Up::Send, {LCtrl Up}

; Remap ` to Esc
*`::Send, {Esc}

fnKeyPressed := false

; SpaceFn Setup
#inputlevel,2
$Space::
    fnKeyPressed := false
    Send {Blind}{F24 DownR}
    KeyWait, Space
    Send {Blind}{F24 up}
    if (!fnKeyPressed) {
        Send {Space}
    }
    return

#inputlevel,1

; Define hotkeys for the F24 combinations using up events
F24 & k Up::FnLayer("k", "Up")
F24 & j Up::FnLayer("j", "Down")
F24 & h Up::FnLayer("h", "Left")
F24 & l Up::FnLayer("l", "Right")
F24 & u Up::FnLayer("u", "Home")
F24 & o Up::FnLayer("o", "End")
F24 & n Up::FnLayer("n", "BackSpace")
F24 & m Up::FnLayer("m", "Delete")

F24 & Escape Up::FnLayer("Escape", "``")
F24 & 1 Up::FnLayer("1", "F1")
F24 & 2 Up::FnLayer("2", "F2")
F24 & 3 Up::FnLayer("3", "F3")
F24 & 4 Up::FnLayer("4", "F4")
F24 & 5 Up::FnLayer("5", "F5")
F24 & 6 Up::FnLayer("6", "F6")
F24 & 7 Up::FnLayer("7", "F7")
F24 & 8 Up::FnLayer("8", "F8")
F24 & 9 Up::FnLayer("9", "F9")
F24 & 0 Up::FnLayer("0", "F10")
F24 & - Up::FnLayer("-", "F11")
F24 & = Up::FnLayer("=", "F12")

FnLayer(key, action) {
    global fnKeyPressed
        fnKeyPressed := true
    if (GetKeyState("Space", "P")) {
        Send, {Blind}{%action%}
    } else {
        Send, {Blind}{%key%}
    }
}

#inputlevel,0
