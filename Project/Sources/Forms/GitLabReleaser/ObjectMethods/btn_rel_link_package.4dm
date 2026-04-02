// btn_rel_link_package — Link an existing package to the selected release
// Can also upload+link in one step

If (Not:C34(Form.api.hasWriteAccess()))
	ALERT:C41("Your token lacks write access (api scope required).\nCurrent scopes: "+Form.api.getScopes().join(", "))
	return
End if 

If (Form.currentRelease=Null:C1517)
	Form.statusText:="Please select a release first"
Else 
	// Ask: link existing or upload new?
	CONFIRM:C162("Link an EXISTING package? (Cancel to upload a new one instead)")
	
	If (OK=1)
		// === Link existing package ===
		// Use repo name (last part of projectPath "owner/repo")
		var $parts : Collection:=Split string:C1554(Form.api.projectPath; "/")
		var $pkgName : Text:=$parts[$parts.length-1]
		// Use release tag as version, package name as filename
		var $pkgVersion : Text:=Form.currentRelease.tag_name
		var $pkgFileName : Text:=$pkgName+".zip"
		var $pkgUrl : Text:=Form.api.getPackageRegistryUrl($pkgName; $pkgVersion; $pkgFileName)
		
		Form.statusText:="Linking package…"
		var $resp : Object:=Form.api.createReleaseLink(\
			Form.currentRelease.tag_name; \
			$pkgFileName; \
			$pkgUrl; \
			"package")
		
		If ($resp.success)
			Form.statusText:="Package linked to release"
			Form.releaseLinks:=Form.api.listReleaseLinks(Form.currentRelease.tag_name)
		Else 
			Form.statusText:="Link failed: "+String:C10(Form.api.errors[0].message)
		End if  
		
	Else 
		// === Upload new + link ===
		var $path : Text
		$path:=Select document:C905(""; "zip"; "Select a file to upload"; Allow alias files:K87:18)
		
		If (OK=1)
			var $file : 4D.File:=File:C1566($path; fk platform path:K87:2)
			var $version : Text:=Form.currentRelease.tag_name
			
			If ($file.exists)
				var $packageName : Text:=Replace string:C233($file.name; "."+$file.extension; "")
				
				Form.statusText:="Uploading and linking "+$file.name+"…"
				
				var $result : Object:=Form.api.uploadAndLinkToRelease(\
					Form.currentRelease.tag_name; $packageName; $version; $file)
				
				If ($result.success)
					Form.statusText:="Package uploaded and linked to release"
					Form.releaseLinks:=Form.api.listReleaseLinks(Form.currentRelease.tag_name)
				Else 
					If ($result.errors#Null:C1517) && ($result.errors.length>0)
						Form.statusText:="Failed: "+String:C10($result.errors[0].message)
					Else 
						Form.statusText:="Upload+link failed"
					End if 
				End if 
			End if 
		End if 
	End if 
End if 
