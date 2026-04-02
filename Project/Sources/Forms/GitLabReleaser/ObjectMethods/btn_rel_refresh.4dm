// btn_rel_refresh — Refresh releases list

Form.statusText:="Loading releases…"
Form.releases:=Form.api.listReleases()
Form.releaseLinks:=[]
Form.currentRelease:=Null:C1517
Form.currentReleaseIndex:=0

If (Form.api.errors.length>0)
	Form.statusText:="Error: "+String:C10(Form.api.errors[0].message)
Else 
	Form.statusText:=String:C10(Form.releases.length)+" release(s) found"
End if 
