﻿; Remap Caps Lock to Left Ctrl
*CapsLock::Send, {LCtrl Down}
*CapsLock Up::Send, {LCtrl Up}

; Remap ` to Esc
*`::Send, {Esc}

; SpaceFn Setup
#inputlevel,2
$Space::
    SetMouseDelay -1
    Send {Blind}{F24 DownR}
    KeyWait, Space
    Send {Blind}{F24 up}
    if (A_ThisHotkey = "$Space" and A_TimeSinceThisHotkey < 300)
        Send {Blind}{Space DownR}
    return

#inputlevel,1
F24 & k::Up
F24 & j::Down
F24 & h::Left
F24 & l::Right
F24 & u::Home
F24 & o::End
F24 & n::BackSpace

F24 & Escape::Send, ``
F24 & 1::F1
F24 & 2::F2
F24 & 3::F3
F24 & 4::F4
F24 & 5::F5
F24 & 6::F6
F24 & 7::F7
F24 & 8::F8
F24 & 9::F9
F24 & 0::F10
F24 & -::F11
F24 & =::F12

#inputlevel,0
