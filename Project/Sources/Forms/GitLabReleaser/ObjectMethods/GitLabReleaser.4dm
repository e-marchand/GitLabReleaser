// Form method for GitLabReleaser — GitLab Releaser main form
// Handles: onLoad, onPageChange

var $event : Object:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		// Initialize form data structures
		Form.packages:=[]
		Form.packageFiles:=[]
		Form.releases:=[]
		Form.releaseLinks:=[]
		Form.currentPackage:=Null:C1517
		Form.currentPackageIndex:=0
		Form.currentRelease:=Null:C1517
		Form.currentReleaseIndex:=0
		Form.currentPackageFile:=Null:C1517
		Form.currentReleaseLink:=Null:C1517
		Form.statusText:=""
		Form.connectionInfo:=""
		
		// Load settings
		If (Form.api=Null:C1517)
			Form.api:=cs:C1710.GitLabAPI.new(""; ""; "")
		End if 
		
		var $settings : Object:=Form.api.loadSettings()
		Form.settings:=$settings
		
		// If settings are valid, auto-refresh first page
		If (Length:C16(Form.api.token)>0)
			Form.statusText:="Connected to "+Form.api.instance+" — "+Form.api.projectPath
			
			// Show cached scope info if available
			If (Form.api.tokenInfo#Null:C1517)
				If (Not:C34(Form.api.hasWriteAccess()))
					Form.statusText:=Form.statusText+" (READ-ONLY)"
				End if 
			End if
		Else 
			Form.statusText:="Please configure your GitLab settings (Settings tab)"
			FORM GOTO PAGE:C247(3)
		End if 
		
	: ($event.code=On Page Change:K2:56)
		
		var $page : Integer:=FORM Get current page:C276
		
		Case of 
			: ($page=1)
				// Refresh packages when entering page 1
				If (Length:C16(Form.api.token)>0)
					Form.statusText:="Loading packages…"
					Form.packages:=Form.api.listPackages("")
					Form.packageFiles:=[]
					Form.currentPackage:=Null:C1517
					Form.currentPackageIndex:=0
					If (Form.api.errors.length>0)
						Form.statusText:="Error: "+String:C10(Form.api.errors[0].message)
					Else 
						Form.statusText:=String:C10(Form.packages.length)+" package(s) found"
					End if 
				End if 
				
			: ($page=2)
				// Refresh releases when entering page 2
				If (Length:C16(Form.api.token)>0)
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
				End if 
				
			: ($page=3)
				// Settings page — ensure Form.settings is populated
				If (Form.settings=Null:C1517)
					Form.settings:={instance: "https://gitlab.com"; projectPath: ""; token: ""}
				End if 
				Form.statusText:="Configure your GitLab connection"
				
		End case 
		
End case 
