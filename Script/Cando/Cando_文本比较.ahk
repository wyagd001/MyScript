Cando_文本比较:
  IfWinExist,文字比较 ahk_class AutoHotkeyGUI
{
Gui,66:Default 
fileread,default2,%CandySel%
GuiControl,, textfile2,%CandySel%
t2.SetText(default2)
}
else
{
Gui,66:Destroy
Gui,66:Default 
gui +ReSize +hwndGuiID
fileread,default1,%CandySel%
twidth := 600, bwidth := 150, bwidth2 := 100, opts := "x5 y30 r40  0x100000"
Gui, Add,text ,,%CandySel%
Gui, Add,text,x600 yp w600 vtextfile2, 
t1 := new RichEdit(66, opts " w" twidth)
t2 := new RichEdit(66, opts " w" twidth " xp" twidth)
Gui, Add, Button, Default w%bwidth% x520 gcompare, 比较/更新
gui show,,文字比较
t1.SetText(default1)
}
return

; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=59029
; https://github.com/oif2003/RichEditBox/blob/master/textCompare.ahk
; 修改为 v1 版本  不区分大小写
compare()
{
	global t1, t2, c, t1Arr := [], t2Arr := []

t1text:=t1.GetText(), t2text:=t2.GetText()

t1.WordWrap("on"), t2.WordWrap("on")
		de := [" ", "`n", "`r"]
	
	a := strsplit(t1text, de), b := strsplit(t2text, de), c := lcs(a, b)

	t1s := 1, t1e := 1, t2s := 1, t2e := 1, t1m := [], t2m := []
	for _, v in c {
		
		;Deleted
		while (a[t1e] != v)
{
			t1e++
}
		if (t1e > t1s)
{
			t1m.push([t1s, t1e-1])
}
		t1s := ++t1e

		;Inserted
		while (b[t2e] != v)
			t2e++
		if (t2e > t2s)
			t2m.push([t2s, t2e-1])
		t2s := ++t2e
	}
	consolidate(t1m, a)
	for _, v in t1m {
			start := wordStart(a, v[1]), end := wordStart(a, v[2]) + StrLen(a[v[2]])
		 t1.SetSel(start, end), t1.SetFont({BkColor:"RED", Color:"WHITE"})
		,t1Arr.Push(SubStr(t1text, start + 1, end - start))
	}
	
	consolidate(t2m, b)
	for _, v in t2m {
			start := wordStart(b, v[1]), end := wordStart(b, v[2]) + StrLen(b[v[2]])
		 t2.SetSel(start, end), t2.SetFont({BkColor:"GREEN", Color:"WHITE"})
		,t2Arr.Push(SubStr(t2text, start + 1, end - start))
	}
	
	;Leftovers
		start1 := wordStart(a, t1s), start2 := wordStart(b, t2s)
	 t1.SetSel(start1, -1), t1.SetFont({BkColor:"RED", Color:"WHITE"})
	,t1.SetSel(0, 0), t1.ScrollCaret(), t1Arr.Push(SubStr(t1text, start1 + 1))
	,t2.SetSel(start2, -1), t2.SetFont({BkColor:"GREEN", Color:"WHITE"})
	,t2.SetSel(0, 0), t2.ScrollCaret(), t2Arr.Push(SubStr(t2text, start2 + 1))

return
}

consolidate(tm, t) 
{
	if tm.Length() > 1 
	{
		loop 
		{
			skip := false
			for k, v in tm
			if (k > 1) && (tm[k-1][2] + 1 = v[1])
			{
				tm[k-1][2] := v[2], skip := k
				break
			}
			if !skip 
			{
				for k, v in tm 
				{
					if (t[v[2]] = t[v[1]-1])
					{
						tm[k][1] := v[1]-1, tm[k][2] := v[2]-1
						break
					}
					if (k = tm.Length())
					break 2
				}
			}
			else 
				tm.RemoveAt(skip)
		}
	}
}

	lineStart(lineArr, index) {		;find line start position
		len := 0
		loop % index - 1
			_len := StrLen(lineArr[A_Index]) ,len += _len + 1
		return len
	}

	wordStart(wordArr, index) { ;find word start position
		len := 0
		loop % index - 1
			len += StrLen(wordArr[A_Index]) + 1
		return len
	}

	lcs(a, b) { ; Longest Common Subsequence of strings, using Dynamic Programming
				; https://rosettacode.org/wiki/Longest_common_subsequence#AutoHotkey
				; https://en.wikipedia.org/wiki/Longest_common_subsequence_problem
				; modified to accept array of strings. Comparison is CASE SENSITIVE.

		len := [], t:= []

		Loop % a.Length() + 2 {   	; Initialize
			i := A_Index - 1
 
			Loop % b.Length() + 2 
{
				j := A_Index - 1, len[i, j] := 0

}

		}
		
		for i, va in a {			; scan a
			i1 := i + 1, x := va
			for j, vb in b {		; scan b
				j1 := j + 1, y := vb
				,len[i1, j1] := x = y ? len[i, j] + 1
							 : (u := len[i1, j]) > (v := len[i, j1]) ? u : v
			}
		}

		x := a.Length() + 1, y := b.Length() + 1
		While x * y {            	; construct solution from lengths
			x1 := x - 1, y1 := y - 1
			If (len[x, y] = len[x1, y])
				x := x1
			Else If  (len[x, y] = len[x, y1])
				y := y1
			Else
				x := x1, y := y1, t.InsertAt(1, a[x])
		}
		Return t
	}