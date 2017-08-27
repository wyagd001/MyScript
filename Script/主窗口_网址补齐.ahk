; Ctrl+Enter×Ô¶¯²¹ÆëÍøÖ·
#IfWinActive,ahk_Group AppMainWindow
^Enter::
  Gui, Submit, NoHide
  if dir
  {
    IfNotInString, dir, www
      run http://www.%Dir%.com/
    Else
      Send, {Enter}
  }
Return
#IfWinActive
