// btn_rel_add_link — Add a custom asset link to the selected release

If (Not:C34(Form.api.hasWriteAccess()))
	ALERT:C41("Your token lacks write access (api scope required).\nCurrent scopes: "+Form.api.getScopes().join(", "))
	return
End if 

If (Form.currentRelease=Null:C1517)
	Form.statusText:="Please select a release first"
Else 
	var $linkName : Text
	$linkName:=Request:C163("Link name:"; "")
	
	If (OK=1) && (Length:C16($linkName)>0)
		var $linkUrl : Text
		$linkUrl:=Request:C163("Link URL:"; "https://")
		
		If (OK=1) && (Length:C16($linkUrl)>0)
			var $linkType : Text
			$linkType:=Request:C163("Link type (other, runbook, image, package):"; "other")
			
			If (OK=1)
				Form.statusText:="Adding link…"
				var $resp : Object:=Form.api.createReleaseLink(\
					Form.currentRelease.tag_name; $linkName; $linkUrl; $linkType)
				
				If ($resp.success)
					Form.statusText:="Link added"
					Form.releaseLinks:=Form.api.listReleaseLinks(Form.currentRelease.tag_name)
				Else 
					Form.statusText:="Add link failed: "+String:C10(Form.api.errors[0].message)
				End if 
			End if 
		End if 
	End if 
End if 
