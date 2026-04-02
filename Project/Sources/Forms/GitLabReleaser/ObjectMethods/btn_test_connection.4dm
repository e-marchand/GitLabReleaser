// btn_test_connection — Test GitLab connection, show user & token scope info

// Apply current form values first
Form.api.instance:=Choose:C955(Length:C16(Form.settings.instance)>0; Form.settings.instance; "https://gitlab.com")
Form.api.projectPath:=Form.settings.projectPath
Form.api.token:=Form.settings.token
Form.api._encodedPath:=Replace string:C233(Form.api.projectPath; "/"; "%2F")

Form.statusText:="Testing connection to "+Form.api.instance+"…"

// Step 1: Check current user
var $userResp : Object:=Form.api.getCurrentUser()

If (Not:C34($userResp.success))
	Form.statusText:="Connection FAILED: "+String:C10(Form.api.errors[0].message)
	Form.connectionInfo:=""
Else 
	var $info : Text:=""
	var $user : Object:=Form.api.userInfo
	$info:="User: "+String:C10($user.username)
	If (Length:C16(String:C10($user.name))>0)
		$info:=$info+" ("+String:C10($user.name)+")"
	End if 
	
	// Step 2: Check token scopes
	var $tokenResp : Object:=Form.api.checkToken()
	
	If ($tokenResp.success)
		$info:=$info+"\nToken: "+String:C10(Form.api.tokenInfo.name)
		$info:=$info+"\n"+Form.api.scopeSummary()
	Else 
		// Token introspection may fail on older GitLab — not critical
		$info:=$info+"\nToken scopes: could not retrieve (GitLab 14.0+ required)"
	End if 
	
	// Step 3: Test project access by listing packages
	var $packages : Collection:=Form.api.listPackages("")
	
	If (Form.api.errors.length>0)
		$info:=$info+"\nProject access: FAILED — "+String:C10(Form.api.errors[0].message)
		Form.statusText:="Connected as "+String:C10($user.username)+" but project access failed"
	Else 
		$info:=$info+"\nProject: "+Form.api.projectPath+" — "+String:C10($packages.length)+" package(s)"
		Form.statusText:="Connection OK — "+String:C10($user.username)+" @ "+Form.api.instance
		
		If (Not:C34(Form.api.hasWriteAccess()))
			Form.statusText:=Form.statusText+" (READ-ONLY)"
		End if 
	End if 
	
	Form.connectionInfo:=$info
End if 
