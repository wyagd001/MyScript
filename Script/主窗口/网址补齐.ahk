; Ctrl+Enter自动补齐网址
;#IfWinActive,ahk_Group AppMainWindow
;^Enter::
网址补齐:
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
