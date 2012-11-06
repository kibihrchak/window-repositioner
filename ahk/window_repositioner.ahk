#SingleInstance force
Menu, Tray, Icon, window_repositioner.ico

; init ----------------------------------------------------
res := {}
res.x := A_ScreenWidth
res.y := A_ScreenHeight
file_descr := "Name|position X|position Y|Width|Height|Maxmized (yes/no)"
field_sep := "|"
filename_base := "windows_"

filename := filename_base . res.x . "x" res.y . ".ini"

windows := load_entries(filename, field_sep)

OnExit, exit_sub

Return


; functions -----------------------------------------------
load_entries(filename, field_sep) {
    entries := {}

    f := FileOpen(filename, "r")

    if !IsObject(f) {
        ;MsgBox, Can't open "%filename%" for reading.
        Return
    }

    f.ReadLine() ; skips label line
    f.ReadLine() ; skips empty line

    while (f.AtEOF == 0) {
        line := f.ReadLine()

        StringSplit, split_line, line, %field_sep%, %A_Space%`n`r`t

        new_entry := {}

        Loop, % split_line0 {
            array_element := split_line%A_Index%
            new_entry.Insert(array_element)
        }

        entries.Insert(new_entry)
    }

    f.Close()

    Return entries
}


save_entries(filename, entries, file_descr, field_sep) {
    f := FileOpen(filename, "w")

    f.WriteLine(file_descr)
    f.WriteLine()

    for k, v in entries {
        for i, j in v {
            f.Write(j)

            if (v.MaxIndex() != i) {
                f.Write(field_sep)
            }
        }

        f.WriteLine()
    }

    f.Close()
}


find_entry(entries, title) {
    entry_index := 0

    for i, v in entries {
        if (InStr(title, v[1], true) != 0) {
            entry_index := i
            Break
        }
    }

    Return entry_index
}


exit_sub:
    ;MsgBox Exiting script.
    save_entries(filename, windows, file_descr, field_sep)

    ExitApp


; hotkey --------------------------------------------------
^#m::
    if (hotkey_presses > 0) {
        hotkey_presses += 1
    } else {
        hotkey_presses := 1
        SetTimer, HotkeyTimerExpired, -400
    }

    Return


; operations ----------------------------------------------

HotkeyTimerExpired:
    if (hotkey_presses == 1) {
        hotkey_presses := 0
        Gosub, GetWindowPosition
    }
    if (hotkey_presses == 2) {
        hotkey_presses := 0
        Gosub, SetWindowPosition
    }

    Return


GetWindowPosition:
    MouseGetPos, , , window_id
    WinGetTitle, window_title, ahk_id %window_id%

    entry_index := find_entry(windows, window_title)

    if (entry_index > 0) {
        ;MsgBox, % "Match found for """ . window_title . """: " . v[1]

        found_entry := windows[entry_index]

        WinMove, %window_title%, 
            , found_entry[2]
            , found_entry[3]
            , found_entry[4]
            , found_entry[5]

        if (found_entry[6] == "yes") {
            WinMaximize, %window_title%
        } else {
            WinRestore, %window_title%
        }
    }

    Return
    
SetWindowPosition:
    MouseGetPos, , , window_id
    WinGetTitle, window_title, ahk_id %window_id%

    found_text := ""
    entry_index := find_entry(windows, window_title)
    
    current_entry := {}

    temp_title := ""
    temp_x := 0
    temp_y := 0
    temp_w := 0
    temp_h := 0
    temp_max := "no"

    if (entry_index > 0) {
        temp_title := windows[entry_index][1]
        found_text = 
            (
-- Found matching item (full window name below) --
%window_title%
`n
            )
    } else {
        temp_title := window_title
    }

    InputBox, temp_title, Write window title
        ,% found_text . "Window title (partial match, no '"
            . field_sep . "' in name):"
        ,,350,170,,,,
        ,% temp_title

    if (ErrorLevel == 1) {
        Return
    }

    WinGet, temp_max, MinMax, % window_title

    if (temp_max == 1) {
        temp_max := "yes"
    } else {
        temp_max := "no"
    }

    if (entry_index > 0 and temp_max == "yes") {
        temp_x := windows[entry_index][2]
        temp_y := windows[entry_index][3]
        temp_w := windows[entry_index][4]
        temp_h := windows[entry_index][5]
    } else {
        WinGetPos, temp_x, temp_y, temp_w, temp_h, % window_title
    }

    current_entry.Insert(1, temp_title
        , temp_x, temp_y
        , temp_w, temp_h
        , temp_max)

    if (entry_index > 0) {
        windows[entry_index] := current_entry
    } else {
        windows.Insert(current_entry)
    }

    Return
