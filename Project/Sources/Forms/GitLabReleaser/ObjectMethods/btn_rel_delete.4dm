// btn_rel_delete — Delete the selected release

If (Not:C34(Form.api.hasWriteAccess()))
	ALERT:C41("Your token lacks write access (api scope required).\nCurrent scopes: "+Form.api.getScopes().join(", "))
	return
End if 

If (Form.currentRelease=Null:C1517)
	Form.statusText:="Please select a release to delete"
Else 
	CONFIRM:C162("Delete release "+Form.currentRelease.tag_name+"? (The tag will NOT be deleted)")
	
	If (OK=1)
		Form.statusText:="Deleting release…"
		var $resp : Object:=Form.api.deleteRelease(Form.currentRelease.tag_name)
		
		If ($resp.success)
			Form.statusText:="Release deleted"
			// Refresh
			Form.releases:=Form.api.listReleases()
			Form.releaseLinks:=[]
			Form.currentRelease:=Null:C1517
			Form.currentReleaseIndex:=0
		Else 
			Form.statusText:="Delete failed: "+String:C10(Form.api.errors[0].message)
		End if 
	End if 
End if 
