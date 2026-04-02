// btn_rel_edit — Edit the selected release (name and description)

If (Not:C34(Form.api.hasWriteAccess()))
	ALERT:C41("Your token lacks write access (api scope required).\nCurrent scopes: "+Form.api.getScopes().join(", "))
	return
End if 

If (Form.currentRelease=Null:C1517)
	Form.statusText:="Please select a release to edit"
Else 
	var $newName : Text
	$newName:=Request:C163("Release name:"; String:C10(Form.currentRelease.name))
	
	If (OK=1)
		var $newDesc : Text
		$newDesc:=Request:C163("Description (Markdown):"; String:C10(Form.currentRelease.description))
		
		If (OK=1)
			var $data : Object:={}
			$data.name:=$newName
			$data.description:=$newDesc
			
			Form.statusText:="Updating release "+Form.currentRelease.tag_name+"…"
			
			var $resp : Object:=Form.api.updateRelease(Form.currentRelease.tag_name; $data)
			
			If ($resp.success)
				Form.statusText:="Release updated"
				// Refresh
				Form.releases:=Form.api.listReleases()
			Else 
				Form.statusText:="Update failed: "+String:C10(Form.api.errors[0].message)
			End if 
		End if 
	End if 
End if 
