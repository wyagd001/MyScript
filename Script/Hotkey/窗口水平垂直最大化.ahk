垂直最大化:
WinGet, hw_active, ID, A
WinGetPos, a_x, a_y, a_w, a_h, A
If (a_y!= 0 || a_h != work_area_h)
{
      windows[%hw_active%]_y := a_y
      windows[%hw_active%]_h := a_h
	  windows[%hw_active%]_max_h := false
}

if ( windows[%hw_active%]_max_h )
	WinMove, A,,, windows[%hw_active%]_y,,windows[%hw_active%]_h
Else
    WinMove, A,,,0,, work_area_h   ; maxheight

    windows[%hw_active%]_max_h := !windows[%hw_active%]_max_h
return

水平最大化:
WinGet, hw_active, ID, A
WinGetPos, a_x, a_y, a_w, a_h, A
If (a_x != 0 || a_w != work_area_w)
{
	  windows[%hw_active%]_x := a_x
      windows[%hw_active%]_w := a_w
	  windows[%hw_active%]_max_w := false
}

if ( windows[%hw_active%]_max_w )
	WinMove, A,, windows[%hw_active%]_x,, windows[%hw_active%]_w
Else
    WinMove, A, ,0, , work_area_w ; maxwidth

    windows[%hw_active%]_max_w := !windows[%hw_active%]_max_w
return