Cando_ÎÄ¼ş×ª»»±àÂë:
	FileRead,V_Candy_2UTF8,%CandySel%
	FileDelete,%CandySel%
	FileAppend,%V_Candy_2UTF8%,%CandySel%,UTF-8
	Run,notepad "%CandySel%"
	V_Candy_2UTF8:=
Return