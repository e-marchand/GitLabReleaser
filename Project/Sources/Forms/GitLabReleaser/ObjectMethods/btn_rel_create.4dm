// btn_rel_create — Create a new release

If (Not:C34(Form.api.hasWriteAccess()))
	ALERT:C41("Your token lacks write access (api scope required).\nCurrent scopes: "+Form.api.getScopes().join(", "))
	return
End if 

var $tagName : Text
$tagName:=Request:C163("Tag name (e.g. v1.0.0):"; "")

If (OK=1) && (Length:C16($tagName)>0)
	
	var $relName : Text
	$relName:=Request:C163("Release name:"; $tagName)
	
	If (OK=1)
		var $description : Text
		$description:=Request:C163("Description (Markdown):"; "")
		
		If (OK=1)
			var $ref : Text
			$ref:=Request:C163("Ref (branch/commit, leave empty if tag exists):"; "")
			
			Form.statusText:="Creating release "+$tagName+"…"
			
			var $resp : Object:=Form.api.createRelease($tagName; $relName; $description; $ref)
			
			If ($resp.success)
				Form.statusText:="Release "+$tagName+" created"
				// Refresh
				Form.releases:=Form.api.listReleases()
			Else 
				Form.statusText:="Create failed: "+String:C10(Form.api.errors[0].message)
			End if 
		End if 
	End if 
End if 
