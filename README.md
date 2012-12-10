# Window Repositioner

## Goal

Goal is to provide a facility that will reorganize windows on screen depending on current resolution. This includes move, resize, maximizing/minimizing. Reuqirements are:

-   easy window repositioning (either all at once or one by one)
-   recording current window parameters
-   multiple presets for each possible screen resolution

Switching between different resolution presets is done externally (by reloading the script).


## Usage

This looks at the case where windows are manipulated one by one.

User will move curson on a window. Then, by pressing a key combination this window will be moved based on configuration for current resolution. By some alternate key combination current window position will be recorded. Eg:

-   reposition: Ctrl + Win + m
-   record position: Ctrl + Win + m (twice)

Also, there should be a possibility to reposition all opened windows based on current preset (if there is information for given window in preset). Eg:

-   reposition opened windows: Ctrl + Win + m (three times)


## Implementation

The most appropriate way to implement requirements from above is via AutoHotkey.

### Implementation Specifics

-   presets are recorded in separate files, one per resolution (see `/ahk/windows_*.ini` for examples)
-   preset is found by checking if window title contains content of `Name` field from preset file, going through lines in given order
