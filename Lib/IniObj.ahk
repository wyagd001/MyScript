; 已修改
; OrderedArray code by Lexikos
; http://tinyurl.com/lhtvalv
; Modifications and additional methods by rbrtryn
; https://autohotkey.com/board/topic/94043-ordered-array/

OrderedArray(prm*)
{
    ; Define prototype object for ordered arrays:
    static base := Object("__Set", "oaSet", "_NewEnum", "oaNewEnum", "Remove", "oaRemove", "Insert", "oaInsert", "InsertBefore", "oaInsertBefore")
    ; Create and return new ordered array object:
    return Object("_keys", Object(), "base", base, prm*)
}

oaSet(obj, prm*)
{
    ; If this function is called, the key must not already exist.
    ; Sub-class array if necessary then add this new key to the key list
    if prm.maxindex() > 2
        ObjInsert(obj, prm[1], OrderedArray())
    ObjInsert(obj._keys, prm[1])
}

oaNewEnum(obj)
{
    ; Define prototype object for custom enumerator:
    static base := Object("Next", "oaEnumNext")
    ; Return an enumerator wrapping our _keys array's enumerator:
    return Object("obj", obj, "enum", obj._keys._NewEnum(), "base", base)
}

oaEnumNext(e, ByRef k, ByRef v:="")
{
    ; If Enum.Next() returns a "true" value, it has stored a key and
    ; value in the provided variables. In this case, "i" receives the
    ; current index in the _keys array and "k" receives the value at
    ; that index, which is a key in the original object:
    if r := e.enum.Next(i,k)
        ; We want it to appear as though the user is simply enumerating
        ; the key-value pairs of the original object, so store the value
        ; associated with this key in the second output variable:
        v := e.obj[k]
    return r
}

oaRemove(obj, prm*)
{
    r := ObjRemove(obj, prm*)         ; Remove keys from main object
    Removed := []
    for k, v in obj._keys             ; Get each index key pair
        if not ObjHasKey(obj, v)      ; if key is not in main object
            Removed.Insert(k)         ; Store that keys index to be removed later
    for k, v in Removed               ; For each key to be removed
        ObjRemove(obj._keys, v, "")   ; remove that key from key list
    return r
}

oaInsert(obj, prm*)
{
    r := ObjInsert(obj, prm*)            ; Insert keys into main object
    enum := ObjNewEnum(obj)              ; Can't use for-loop because it would invoke oaNewEnum
    while enum[k] {                      ; For each key in main object
        if (k = "_keys")
            continue
        for i, kv in obj._keys           ; Search for key in obj._keys
            if (k = kv)                  ; If found...
                continue 2               ; Get next key in main object
        ObjInsert(obj._keys, k)          ; Else insert key into obj._keys
    }
    return r
}

oaInsertBefore(obj, key, prm*)
{
    OldKeys := obj._keys                 ; Save key list
    obj._keys := []                      ; Clear key list
    for idx, k in OldKeys {              ; Put the keys before key
        if (k = key)                     ; back into key list
            break
        obj._keys.Insert(k)
    }

    r := ObjInsert(obj, prm*)            ; Insert keys into main object
    enum := ObjNewEnum(obj)              ; Can't use for-loop because it would invoke oaNewEnum
    while enum[k] {                      ; For each key in main object
        if (k = "_keys")
            continue
        for i, kv in OldKeys             ; Search for key in OldKeys
            if (k = kv)                  ; If found...
                continue 2               ; Get next key in main object
        ObjInsert(obj._keys, k)          ; Else insert key into obj._keys
    }

    for i, k in OldKeys {                ; Put the keys after key
        if (i < idx)                     ; back into key list
            continue
        obj._keys.Insert(k)
    }
    return r
}

/*
有内容并非;开头 (条件A)? 开头为[并结束为](条件B)?段:有等号(条件C)?f[段,键]=值:f[段,键]=空:空

条件A
有内容并非;开头：开头为[并结束为](条件B)?段:有等号(条件C)?f[段,键]=值:f[段,键]=空
没有内容或;开头：空

条件B
开头为[并结束为]：段
开头非[或结束非]：有等号(条件C)?f[段,键]=值:f[段,键]=空

条件C
有等号：f[段,键]=值
没等号：f[段,键]=空
*/

IniObj(d,byref n:=""){
	If d:=Trim(InStr(d,"`n") ? d : CF_FileRead(d)," `t`r`n")
	{
		f:=n?n:[]
		Loop, Parse, d, `r`n, `r `t
			(A_LoopField and (b:=SubStr(i:=A_LoopField,1,1)) != ";")
				? (b = "[" and b:=InStr(i,"]",0,0))
					? n:=SubStr(i,2,b-2) : ((b:=InStr(i,"="))
						? f[n,RTrim(SubStr(i, 1, b-1))] := LTrim(SubStr(i, b+1)) : (f[n,i]:=""))
				: ""
		return f
}
}