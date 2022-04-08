#SingleInstance,Force

; Open Windows Terminal on Windows+Enter
LWin & Enter::
    Run, wt.exe
    return

^x::ExitApp