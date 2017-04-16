/* TheGood
WinMouse
https://autohotkey.com/board/topic/36620-winmouse-move-windows-using-your-mouse/
*/

/*
After checking out WindowPad from Lexikos, I realized that the ability to neatly organize windows is extremely useful, especially across multiple monitors. But I felt like using the keyboard wasn't as intuitive as using the mouse. So, I created WinMouse! Because it feels so intuitive, I found it much faster than WindowPad. Here is the introduction from the documentation:

Quote:
WinMouse allows you to move and resize windows into predefined positions around the screen(s) using
your mouse. All you have to do, is to hover the mouse (no need to click) over the window you wish
to move, then press (and hold) the Capslock key to lock onto the window. As you move the cursor
around the screen, WinMouse will highlight the different locations (or "drop zones") where you can
place (or "drop") the window. Once you've chosen your drop zone, simply release the Capslock key to
drop it to the highlighted drop zone.

Screenshot showing a highlighted drop zone, as well as the AutoHotkey Help window which was dropped in the lower-right drop zone:


The included config file is a good general beginning file which shows the capabilities of WinMouse. The documentation (after INI entries in WinMouse.ini) is quite thorough, but do not hesitate if you have any questions Smile As always, any (constructive) criticism/comments/suggestions are welcome!
*/


/****************************************
PLEASE SEE WinMouse.ini FOR DOCUMENTATION
*/

/* Changelog

Jan 16, 2009

- Added StringReplace -> you can now have spaces and tabs in the drop zone definition
- Added a few more comments in the script
- Added ReverseNumPad key in WinMouse.ini -> allows you to invert NumPad superimposition.
- Added the ability to restore a moved window to its previous position by pressing Capslock + Space
- Fixed up documentation (eg. changed Monitor 2 example to a 16-drop-zone configuration)

*/

;Main sub
ProcessMouse:

	;Get new coords
	MouseGetPos, mX, mY

	If (mX = oldX And mY = oldY)
		Return	;Nothing changed

	;Get the number of the monitor we're on
	iCurMon := GetMonitorFromPos(mX, mY)

	;Transform coord to relative pos for the screen
	mX -= Mon%iCurMon%Left, mY -= Mon%iCurMon%Top
  
	;Get the closest point to the mouse on that screen
	i := GetClosestPoint(iCurMon, mX, mY)

	If (i <> iCurPoint) {	;Check if we need to change GUI
		iCurPoint := i
		DrawShade(iCurMon, iCurPoint) ;Draw the shade corresponding
	}
Return

/*
;Capslock+tab   退出程序
$Tab::
	If Not GetKeyState("Capslock")
		Send {Tab Down}
Return

$Tab Up::Send {Tab Up}

$Space::
	If Not GetKeyState("Capslock")
		Send {Space Down}
Return

$Space Up::Send {Space Up}

;快捷键 Capslock释放后按Shift 移动窗口时保持原窗口 是否”可见“（是否在最上面或激活的）
;鼠标左键自动激活与该功能有冲突，因为在下层的窗口总是自动变为了在上层，所以在窗口没有被自动“激活”时才有效
;注释掉后可能会有shift 被按住的情况出现
;bBringToFront 默认1 bTemp设为0，bBringToFront ，默认0bTemp设为2
;bTemp := bBringToFront ? 0 : 2
$LShift::
	If Not GetKeyState("Capslock")
		Send {LShift Down}
Return

$LShift Up::Send {LShift Up}
*/

ReadINI() {
	Local iMonCount, i, j

	;Get general settings
	IniRead, cShade, %ScriptINI%, WinMouse, ShadeColor
	IniRead, iTrans, %ScriptINI%, WinMouse, Transparency
	IniRead, iMonCount, %ScriptINI%, WinMouse, MonitorCount
	IniRead, bBringToFront, %ScriptINI%, WinMouse, BringToFront
	IniRead, bActivateOnFront, %ScriptINI%, WinMouse, ActivateOnFront
	IniRead, bReverseNumPad, %ScriptINI%, WinMouse, ReverseNumPad

	;Go through each mon.
	Loop %iMonCount% {
		IniRead, i, %ScriptINI%, % "Monitor " A_Index, Index, %A_Index%	;Get index
		IniRead, Mon%i%PointCount, %ScriptINI%, % "Monitor " A_Index, PointCount

		;Loop through each point of this monitor
		j := A_Index	;Keep index before entering new loop
		Loop % Mon%i%PointCount {
			IniRead, Mon%i%Point%A_Index%, %ScriptINI%, % "Monitor " j, % "Point" A_Index
			CleanPoint(Mon%i%Point%A_Index%)	;Remove spaces and tabs
			TranslatePoint(i, Mon%i%Point%A_Index%, Mon%i%Point%A_Index%A, Mon%i%Point%A_Index%B, Mon%i%Point%A_Index%C)
			;MsgBox % X(Mon%i%Point%A_Index%A) "," Y(Mon%i%Point%A_Index%A) " - " X(Mon%i%Point%A_Index%B) "," Y(Mon%i%Point%A_Index%B)
		}
	}
}

;Remove spaces and tabs
CleanPoint(ByRef s) {
	StringReplace s, s, %A_Space%
	StringReplace s, s, %A_Tab%
}

;Reads settings from INI file
;Puts the hotspot point in C, the upper-left corner of the zone in A and the lower-right in B. Coords relative to monitor.
TranslatePoint(iMonitor, sPoint, ByRef pA, ByRef pB, ByRef pC) {
	Local i, j

	i := InStr(sPoint, ":")	;Get colon location
	j := InStr(sPoint, "-")	;Get hyphen location
	If Not i {	;No colons
		If Not j {	;No hyphen as well -> It's a hotspot for maximize
			pA := 0
			pB := 0
			pC := PointFromText(iMonitor, sPoint)
		} Else { ;Colon -> Range alone -> Hotspot is the middle of the range.
			pA := PointFromText(iMonitor, SubStr(sPoint, 1, j - 1))
			pB := PointFromText(iMonitor, SubStr(sPoint, j + 1))
			pC := PointFromCoord((X(pA) + X(pB)) / 2, (Y(pA) + Y(pB)) / 2)
			RangeFromPoints(iMonitor, pA, pB)	;Fix points up
		}
	} Else {	;We've got colons. Get the hotspot first
		pC := PointFromText(iMonitor, SubStr(sPoint, 1, i - 1))

		If Not j {	;No hyphen means that the other corner is the hotspot
			pA := pC
			pB := PointFromText(iMonitor, SubStr(sPoint, i + 1))
		} Else {
			pA := PointFromText(iMonitor, SubStr(sPoint, i + 1, j - i - 1))
			pB := PointFromText(iMonitor, SubStr(sPoint, j + 1))
		}
		RangeFromPoints(iMonitor, pA, pB)	;Fix points up
	}
}

;Translates pixel locations (eg. "1024,728") and multi-digit locations into points (eg. "48")
PointFromText(iMonitor, s) {
	Local p, i

	;Check for comma
	i := InStr(s, ",")
	If Not i {

		;It's a multi-num. Calculate the mean value of all the combined points
		Loop, Parse, s
			p += PointFromDigit(iMonitor, A_LoopField)
		i := StrLen(s)
		Return PointFromCoord(X(p) / i, Y(p) / i)

	} Else Return PointFromCoord(SubStr(s, 1, i - 1), SubStr(s, i + 1))	;It's a pixel location
}

;Returns the point of one of the NumPoint (7, 8, 9, 4, 5, 6, 1, 2, 3)
PointFromDigit(iMonitor, iNum) {
	Local iW, iH

	;Get monitor info
	iW := Mon%iMonitor%Right - Mon%iMonitor%Left
	iH := Mon%iMonitor%Bottom - Mon%iMonitor%Top

	;Check if we're mirroring or not
	If Not bReverseNumPad {	;We're not reversing
		If (iNum = 7)	;Upper-left
			Return PointFromCoord(0, 0)
		If (iNum = 8)	;Upper-middle
			Return PointFromCoord(iW / 2, 0)
		If (iNum = 9)	;Upper-right
			Return PointFromCoord(iW, 0)
		If (iNum = 4)	;Middle-left
			Return PointFromCoord(0, iH / 2)
		If (iNum = 5)	;Middle
			Return PointFromCoord(iW / 2, iH / 2)
		If (iNum = 6)	;Middle-right
			Return PointFromCoord(iW, iH / 2)
		If (iNum = 1)	;Lower-left
			Return PointFromCoord(0, iH)
		If (iNum = 2)	;Lower-middle
			Return PointFromCoord(iW / 2, iH)
		If (iNum = 3)	;Lower-right
			Return PointFromCoord(iW, iH)
	} Else {
		If (iNum = 1)	;Upper-left
			Return PointFromCoord(0, 0)
		If (iNum = 2)	;Upper-middle
			Return PointFromCoord(iW / 2, 0)
		If (iNum = 3)	;Upper-right
			Return PointFromCoord(iW, 0)
		If (iNum = 4)	;Middle-left
			Return PointFromCoord(0, iH / 2)
		If (iNum = 5)	;Middle
			Return PointFromCoord(iW / 2, iH / 2)
		If (iNum = 6)	;Middle-right
			Return PointFromCoord(iW, iH / 2)
		If (iNum = 7)	;Lower-left
			Return PointFromCoord(0, iH)
		If (iNum = 8)	;Lower-middle
			Return PointFromCoord(iW / 2, iH)
		If (iNum = 9)	;Lower-right
			Return PointFromCoord(iW, iH)
	}
}

;Reorganizes points so that p1 represents the upper-left corner and p2 represents the lower-right corner of the surface they describe.
RangeFromPoints(iMonitor, ByRef p1, ByRef p2) {
	Local iW, iH, t

	;Get monitor info
	iW := Mon%iMonitor%Right - Mon%iMonitor%Left
	iH := Mon%iMonitor%Bottom - Mon%iMonitor%Top

	;Check if we're drawing a pane (a surface that touches the two ends of the monitor)
	If (X(p1) = X(p2)) {	;We're drawing a pane which touches the left and the right sides
		p1 := PointFromCoord(0, Y(p1))
		p2 := PointFromCoord(iW, Y(p2))
	} Else If (Y(p1) = Y(p2)) {	;We're drawing a pane which touches the top and the bottom sides
		p1 := PointFromCoord(X(p1), 0)
		p2 := PointFromCoord(X(p2), iH)
	}

	;Sort them out so that p1 is the upper left and p2 is the lower right
	t := PointFromCoord(Min(X(p1), X(p2)), Min(Y(p1), Y(p2)))
	p2 := PointFromCoord(Max(X(p1), X(p2)), Max(Y(p1), Y(p2)))
	p1 := t
}

PointFromCoord(x, y) {	;Combine coords to form 32-bit point
	Return (y << 16) + x
}
Min(i, j) {	;Returns the smallest of the two
	Return (i > j) ? j : i
}
Max(i, j) {	;Returns the highest of the two
	Return (i < j) ? j : i
}
X(p) {	;Get low word
	Return Mod(p, 0x10000)
}
Y(p) {	;Get high word
	Return p >> 16 ;(p - X(p)) / 0x10000
}

;Returns the number of the monitor the coordinates are in
GetMonitorFromPos(mX, mY) {
	Global
	Loop %iMonitorCount%
		If (Mon%A_Index%Left <= mX AND Mon%A_Index%Right > mX) AND (Mon%A_Index%Top <= mY AND Mon%A_Index%Bottom > mY)
			Return %A_Index%
	Return 0	;If we got here, then the mouse is off the work area
}


;Returns the index of the point closest to the given coordinates
GetClosestPoint(iMonitor, x, y) {
	Local d, iWinningI, iWinningD := 0xFFFFFFFF	;Set really high number so that the first match always wins

	;Loop through every hotspot of the current monitor and calculate the distance
	Loop % Mon%iMonitor%PointCount {
		d := GetDistance(Mon%iMonitor%Point%A_Index%C, x, y)
		If (d < iWinningD) {
			iWinningD := d
			iWinningI := A_Index
		}
	}

	;Done analysis
	Return iWinningI
}

;Returns the distance between two points
GetDistance(p, x, y) {
	x -= X(p), y -= Y(p)
	Return Sqrt(x**2 + y**2)
}

;Draws the shade corresponding to the point given
DrawShade(iMonitor = 0, iPointIndex = 0) {
	Local i

	;Check if we just have to hide the GUI
	If Not iMonitor {
		bShowing := False
		Gui,4: Cancel
	} Else {

		;Check if it's maximized
		bMaximize := Not (Mon%iMonitor%Point%iPointIndex%A Or Mon%iMonitor%Point%iPointIndex%B)

		cx := X(Mon%iMonitor%Point%iPointIndex%A)
		cy := Y(Mon%iMonitor%Point%iPointIndex%A)
		If bMaximize {
			cw := Mon%iMonitor%Right - Mon%iMonitor%Left
			ch := Mon%iMonitor%Bottom - Mon%iMonitor%Top
		} Else {
			cw := X(Mon%iMonitor%Point%iPointIndex%B) - cx
			ch := Y(Mon%iMonitor%Point%iPointIndex%B) - cy
		}
		cx += Mon%iMonitor%Left
		cy += Mon%iMonitor%Top
		bShowing := True
		Gui,4: Show, W%cw% H%ch% X%cx% Y%cy%
	}
}

;Moves the window
MoveWindow:

	;Get info
	WinGetPos, wX, wY, wW, wH, ahk_id %mW%	;Position
	WinGet, iMinMax, MinMax, ahk_id %mW%	;Min/Max status
	WinGet, iStyles, Style, ahk_id %mW%		;Enabled styles (to check for resize and max ability)

	;Add window pos to array before moving it
	UpdateMovedWinArr(mW, wX, wY, wW, wH, iMinMax)

	;Check if we have to toggle setting
	If GetKeyState("Shift", "P")
		bTemp := bBringToFront ? 0 : 2
	Else bTemp := bBringToFront
 
	;Check if we'll have to un-maximize it
	If Not bMaximize And iMinMax
		WinRestore, ahk_id %mW%	;un-maximize
	Else If bMaximize And iMinMax {
		;Check if center is in the current monitor
		If (GetMonitorFromPos(wX + (wW / 2), wY + (wH / 2)) = iCurMon)
			Return	;We don't have to do anything
		Else WinRestore, ahk_id %mW%	;un-maximize
	}

	;Move the window (and resize it if supported)
	If (iStyles & 0x40000)
		WinMove, ahk_id %mW%,, cx, cy, cw, ch
	Else WinMove, ahk_id %mW%,, cx, cy

	;Check if we have to (and can) maximize
	bMaximize := bMaximize And (iStyles & 0x10000)
	If bMaximize
		WinMaximize, ahk_id %mW%

	;Get the boolean value representing whether or not the window will be brought to the front
	bTemp := (bTemp = 1 And Not bMaximize) Or (bTemp = 2)

;msgbox % bTemp
	;Apply settings
	If bTemp And bActivateOnFront
		WinActivate, ahk_id %mW%
	Else If bTemp {	;Toggle Always on top so that the window comes on top, but is not necessarily focused.
		WinSet, Topmost,, ahk_id %mW%
		WinSet, Topmost,, ahk_id %mW%
	}

Return

;Either adds to the array or edits the one already in there with the new info
UpdateMovedWinArr(mW, wX, wY, wW, wH, iMinMax) {
	Local i := CheckWinMovedArr(mW)

	;Check if we already have it
	If Not i {	;Create new entry
		Win0 += 1
		i := Win0
		Win%i% := mW
	}

	Win%i%X := wX
	Win%i%Y := wY
	Win%i%W := wW
	Win%i%H := wH
	Win%i%M := iMinMax

}

;Checks if the given window handle has been moved before and returns its index if yes
CheckWinMovedArr(mW) {
	Global
	Loop %Win0%
		If (Win%A_Index% = mW)
			Return A_Index
	Return 0
}

;Restores a window to its previous position
RestoreWinMoved(i) {
	Global

	If Not i
		Return

	;Set maximize
	bMaximize := (Win%i%M = 1)

	;Set vals
	cx := Win%i%X
	cy := Win%i%Y
	cw := Win%i%W
	ch := Win%i%H

	;Call sub
	Gosub, MoveWindow

}