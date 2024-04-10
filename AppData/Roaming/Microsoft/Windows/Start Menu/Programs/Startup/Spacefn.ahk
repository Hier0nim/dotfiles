; Remap Caps Lock to Left Ctrl
*CapsLock::Send, {LCtrl Down}
*CapsLock Up::Send, {LCtrl Up}

; Remap ` to Esc
*`::Send, {Esc}

; Initialize a variable to track if the spacebar was released before the FN layer key
spaceReleasedEarly := false

; SpaceFn Setup
#inputlevel,2
$Space::
    spaceReleasedEarly := false
    fnKeyPressed := false
    SetMouseDelay -1
    Send {Blind}{F24 DownR}
    KeyWait, Space
    Send {Blind}{F24 up}
    if (spaceReleasedEarly and !fnKeyPressed)
    {
        Send {Space}
    }
    else if (A_ThisHotkey = "$Space" and A_TimeSinceThisHotkey < 300)
    {
        Send {Blind}{Space DownR}
    }
    return

#inputlevel,1

; Modified Fn layer keys to check the state of spaceReleasedEarly
F24 & k::FnLayer("k", "Up")
F24 & j::FnLayer("j", "Down")
F24 & h::FnLayer("h", "Left")
F24 & l::FnLayer("l", "Right")
F24 & u::FnLayer("u", "Home")
F24 & o::FnLayer("o", "End")
F24 & n::FnLayer("n", "BackSpace")
F24 & m::FnLayer("m", "Delete")

F24 & Escape::FnLayer("Escape", "``")
F24 & 1::FnLayer("1", "F1")
F24 & 2::FnLayer("2", "F2")
F24 & 3::FnLayer("3", "F3")
F24 & 4::FnLayer("4", "F4")
F24 & 5::FnLayer("5", "F5")
F24 & 6::FnLayer("6", "F6")
F24 & 7::FnLayer("7", "F7")
F24 & 8::FnLayer("8", "F8")
F24 & 9::FnLayer("9", "F9")
F24 & 0::FnLayer("0", "F10")
F24 & -::FnLayer("-", "F11")
F24 & =::FnLayer("=", "F12")

FnLayer(key, action) {
    global spaceReleasedEarly, fnKeyPressed
    if (spaceReleasedEarly) {
        Send, {Blind}{%key%}
    } else {
        fnKeyPressed := true
        Send, {Blind}{%action%}
    }
}

$Space Up::
    spaceReleasedEarly := true
return

#inputlevel,0
