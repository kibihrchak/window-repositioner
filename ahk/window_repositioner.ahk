#SingleInstance force

windows := {}
res_x := 0
res_y := 0
filename_base := "windows_"
filename := ""

reload_windows(filename_base
    , ByRef filename, ByRef windows, ByRef res_x, ByRef res_y) {

    if (res_x != A_ScreenWidth or res_y != A_ScreenHeight) {
        res_x := A_ScreenWidth
        res_y := A_ScreenHeight

        filename := filename_base . res_x . "x" res_y . ".txt"

        ;MsgBox, % "Loading data. Filename: " . filename

        windows := load_entries(filename)
    }
}

load_entries(filename) {
    entries := {}

    f := FileOpen(filename, "r")

    if !IsObject(f) {
        MsgBox, Can't open "%filename%" for reading.
        return
    }

    f.ReadLine() ; skips label line
    f.ReadLine() ; skips empty line

    while (f.AtEOF == 0) {
        line := f.ReadLine()

        StringSplit, split_line, line, |, %A_Space%`n`r`t

        new_entry := {}

        Loop, % split_line0 {
            array_element := split_line%A_Index%
            new_entry.Insert(array_element)
        }

        entries.Insert(new_entry)
    }

    f.Close()

    return entries
}


save_entries(filename, entries) {

}


Esc::
    ExitApp


^#m::
    reload_windows(filename_base, filename, windows, res_x, res_y)

    MouseGetPos, , , window_id
    WinGetTitle, window_title, ahk_id %window_id%

    for i, v in windows {
        if (InStr(window_title, v[1], true) != 0) {
            ;MsgBox, % "Match found for """ . window_title . """: " . v[1]

            WinMove, %window_title%, , v[2], v[3], v[4], v[5]

            if (v[6] == "yes") {
                WinMaximize, %window_title%
            } else {
                WinRestore, %window_title%
            }

            break
        }
    }

    return


^#n::
    reload_windows(filename_base, filename, windows, res_x, res_y)

    f := FileOpen(filename, "w")

    f.WriteLine("Name|X|Y|W|H|Maxmized")
    f.WriteLine()

    for k, v in windows {
        for i, j in v {
            f.Write(j)

            if (v.MaxIndex() != i) {
                f.Write("|")
            }
        }

        f.WriteLine()
    }

    f.Close()

    MsgBox, Output written.
