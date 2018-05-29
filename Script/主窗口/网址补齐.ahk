; Ctrl+Enter×Ô¶¯²¹ÆëÍøÖ·
;#IfWinActive,ahk_Group AppMainWindow
;^Enter::
ÍøÖ·²¹Æë:
  Gui, Submit, NoHide
  if dir
  {
    IfNotInString, dir, www
      run http://www.%Dir%.com/
    Else
      Send, {Enter}
  }
Return
;#IfWinActive
