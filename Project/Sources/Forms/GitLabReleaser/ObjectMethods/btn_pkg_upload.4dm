// btn_pkg_upload — Upload a zip file to the package registry

If (Not:C34(Form.api.hasWriteAccess()))
	ALERT:C41("Your token lacks write access (api scope required).\nCurrent scopes: "+Form.api.getScopes().join(", "))
	return
End if 

// Ask for version — prefill with current package version if available
var $version : Text
var $defaultVersion : Text:="1.0.0"
If (Form.currentPackage#Null:C1517)
	$defaultVersion:=Form.currentPackage.version
End if 
$version:=Request:C163("Package version:"; $defaultVersion)

If (OK=1) && (Length:C16($version)>0)
	
	// Select file
	var $name : Text
	$name:=Select document:C905(""; "zip"; "Select a file to upload"; fk mobileApps folder:K87:18)
	
	If (OK=1)
		var $file : 4D:C1709.File:=File:C1566(Document; fk platform path:K87:2)
		
		If ($file.exists)
			// Determine package name: use current package name or file name without extension
			var $packageName : Text
			If (Form:C1466.currentPackage#Null:C1517)
				$packageName:=Form:C1466.currentPackage.name
			Else 
				$packageName:=$file.name
			End if 
			
			Form:C1466.statusText:="Uploading "+$file.fullName+" as "+$packageName+" v"+$version+"…"
			
			var $resp : Object:=Form:C1466.api.uploadPackage($packageName; $version; $file)
			
			If ($resp.success)
				ALERT:C41("Upload successful: "+$packageName+" v"+$version)
				
				// Refresh packages list
				Form:C1466.statusText:="Loading packages…"
				Form:C1466.packages:=Form:C1466.api.listPackages("")
				Form:C1466.packageFiles:=[]
				Form:C1466.currentPackage:=Null:C1517
				Form:C1466.currentPackageIndex:=0
				
				// Select the uploaded package
				var $i : Integer
				For ($i; 0; Form:C1466.packages.length-1)
					If (Form:C1466.packages[$i].name=$packageName)
						Form:C1466.currentPackageIndex:=$i
						Form:C1466.currentPackage:=Form:C1466.packages[$i]
						// Load its files
						Form:C1466.packageFiles:=Form:C1466.api.getPackageFiles(Form:C1466.currentPackage.id)
						$i:=Form:C1466.packages.length  // break
					End if 
				End for 
				
				Form:C1466.statusText:=String:C10(Form:C1466.packages.length)+" package(s) found"
			Else 
				var $errText : Text:=Form:C1466.api.errors[0].message
				Form:C1466.statusText:="Upload failed: "+$errText
				ALERT:C41("Upload failed\n"+$errText)
			End if 
		End if 
	End if 
End if 
