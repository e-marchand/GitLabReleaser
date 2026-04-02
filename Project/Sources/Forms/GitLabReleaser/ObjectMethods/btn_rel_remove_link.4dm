// btn_rel_remove_link — Remove the selected asset link from the release

If (Not:C34(Form.api.hasWriteAccess()))
	ALERT:C41("Your token lacks write access (api scope required).\nCurrent scopes: "+Form.api.getScopes().join(", "))
	return
End if 

If (Form.currentRelease=Null:C1517)
	Form.statusText:="Please select a release first"
Else 
	If (Form.currentReleaseLink=Null:C1517)
		Form.statusText:="Please select a link to remove"
	Else 
		CONFIRM:C162("Remove link \""+String:C10(Form.currentReleaseLink.name)+"\"?")
		
		If (OK=1)
			Form.statusText:="Removing link…"
			var $resp : Object:=Form.api.deleteReleaseLink(\
				Form.currentRelease.tag_name; \
				Form.currentReleaseLink.id)
			
			If ($resp.success)
				Form.statusText:="Link removed"
				Form.releaseLinks:=Form.api.listReleaseLinks(Form.currentRelease.tag_name)
			Else 
				Form.statusText:="Remove failed: "+String:C10(Form.api.errors[0].message)
			End if 
		End if 
	End if 
End if 
