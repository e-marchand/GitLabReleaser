
// ============================================================================
// GitLabAPI — Manage GitLab Package Registry, Releases, and Release Links
// ============================================================================
// Wraps the GitLab REST API v4 for:
//   - Generic Package Registry (list, upload, download, delete)
//   - Releases (CRUD)
//   - Release Links / asset associations (CRUD)
//   - Settings persistence (load/save from user data folder)
//
// Authentication: Personal Access Token with 'api' scope via PRIVATE-TOKEN header
// ============================================================================

property instance : Text
property projectPath : Text
property token : Text
property _encodedPath : Text
property errors : Collection
property lastStatus : Integer
property tokenInfo : Object
property userInfo : Object

// ============================================================================
// Constructor
// ============================================================================

Class constructor($instance : Text; $projectPath : Text; $token : Text)
	
	This:C1470.instance:=Choose:C955(Length:C16($instance)>0; $instance; "https://gitlab.com")
	This:C1470.projectPath:=$projectPath
	This:C1470.token:=$token
	This:C1470._encodedPath:=Replace string:C233($projectPath; "/"; "%2F")
	This:C1470.errors:=[]
	This:C1470.lastStatus:=0
	This:C1470.tokenInfo:=Null:C1517
	This:C1470.userInfo:=Null:C1517
	
	// ============================================================================
	// Internal Helpers
	// ============================================================================
	
Function _baseUrl() : Text
	
	return This:C1470.instance+"/api/v4/projects/"+This:C1470._encodedPath
	
Function _headers($contentType : Text) : Object
	
	var $h : Object:={}
	$h["PRIVATE-TOKEN"]:=This:C1470.token
	If (Length:C16($contentType)>0)
		$h["Content-Type"]:=$contentType
	Else 
		$h["Content-Type"]:="application/json"
	End if 
	$h["Accept"]:="application/json"
	return $h
	
Function _request($method : Text; $url : Text; $body : Variant; $timeout : Integer) : Object
	
	This:C1470.errors:=[]
	This:C1470.lastStatus:=0
	
	var $result : Object:={success: False:C215; body: Null:C1517; status: 0}
	var $options : Object:={}
	$options.method:=$method
	
	If ($method="PUT") && (Value type:C1509($body)=Is BLOB:K8:12)
		$options.headers:=This:C1470._headers("application/octet-stream")
	Else 
		$options.headers:=This:C1470._headers("")
	End if 
	
	If ($body#Null:C1517)
		$options.body:=$body
	End if 
	
	If ($timeout=0)
		$timeout:=30
	End if 
	
	var $request : 4D:C1709.HTTPRequest:=4D:C1709.HTTPRequest.new($url; $options)
	$request.wait($timeout)
	
	var $response:=$request.response
	
	If ($response=Null:C1517)
		This:C1470.errors:=[{message: "No response from GitLab API"; details: $request.errors}]
		$result.success:=False:C215
		return $result
	End if 
	
	This:C1470.lastStatus:=$response.status
	$result.status:=$response.status
	$result.body:=$response.body
	
	If (($response.status>=200) && ($response.status<300))
		$result.success:=True:C214
	Else 
		var $errMsg : Text:="HTTP "+String:C10($response.status)
		If (Value type:C1509($response.body)=Is object:K8:27)
			If ($response.body.error_description#Null:C1517)
				$errMsg:=$errMsg+" — "+String:C10($response.body.error_description)
			Else 
				If ($response.body.message#Null:C1517)
					$errMsg:=$errMsg+" — "+String:C10($response.body.message)
				End if 
			End if 
		End if 
		This:C1470.errors:=[{message: $errMsg; details: $response.body}]
		$result.success:=False:C215
	End if 
	
	return $result
	
	// ============================================================================
	// Token & User Introspection
	// ============================================================================
	
Function checkToken() : Object
	// GET /personal_access_tokens/self — returns token name, scopes, expiry
	// Requires GitLab 14.0+
	
	var $url : Text:=This:C1470.instance+"/api/v4/personal_access_tokens/self"
	var $resp : Object:=This:C1470._request("GET"; $url; Null:C1517; 15)
	
	If ($resp.success)
		This:C1470.tokenInfo:=$resp.body
	Else 
		This:C1470.tokenInfo:=Null:C1517
	End if 
	
	return $resp
	
Function getCurrentUser() : Object
	// GET /user — returns username, name, email, avatar, etc.
	
	var $url : Text:=This:C1470.instance+"/api/v4/user"
	var $resp : Object:=This:C1470._request("GET"; $url; Null:C1517; 15)
	
	If ($resp.success)
		This:C1470.userInfo:=$resp.body
	Else 
		This:C1470.userInfo:=Null:C1517
	End if 
	
	return $resp
	
Function getScopes() : Collection
	// Returns cached token scopes, or empty collection if unknown
	
	If (This:C1470.tokenInfo#Null:C1517)
		return (This:C1470.tokenInfo.scopes || [])
	End if 
	return []
	
Function hasScope($scope : Text) : Boolean
	// Check if the token has a specific scope
	
	var $scopes : Collection:=This:C1470.getScopes()
	return ($scopes.indexOf($scope)>=0)
	
Function hasWriteAccess() : Boolean
	// 'api' scope gives full read/write access
	// 'read_api' is read-only — write operations will fail
	// If scopes are unknown (token info not fetched), assume yes
	
	If (This:C1470.tokenInfo=Null:C1517)
		return True:C214  // Unknown — don't block
	End if 
	
	return This:C1470.hasScope("api")
	
Function scopeSummary() : Text
	// Returns a human-readable summary of token capabilities
	
	If (This:C1470.tokenInfo=Null:C1517)
		return "Token scopes unknown (could not introspect)"
	End if 
	
	var $scopes : Collection:=This:C1470.getScopes()
	
	If ($scopes.length=0)
		return "No scopes detected"
	End if 
	
	var $summary : Text:="Scopes: "+$scopes.join(", ")
	
	If (This:C1470.hasScope("api"))
		$summary:=$summary+" — Full read/write access"
	Else 
		If (This:C1470.hasScope("read_api"))
			$summary:=$summary+" — Read-only (write operations will fail)"
		Else 
			$summary:=$summary+" — Limited access"
		End if 
	End if 
	
	// Add expiry info
	If (This:C1470.tokenInfo.expires_at#Null:C1517)
		$summary:=$summary+"\nExpires: "+String:C10(This:C1470.tokenInfo.expires_at)
	Else 
		$summary:=$summary+"\nNo expiration set"
	End if 
	
	return $summary
	
Function tokenPageUrl() : Text
	// Returns the URL to create a new personal access token on the GitLab instance
	
	return This:C1470.instance+"/-/user_settings/personal_access_tokens"
	
	// ============================================================================
	// Package Registry
	// ============================================================================
	
Function listPackages($packageName : Text) : Collection
	// GET /projects/:id/packages?package_type=generic[&package_name=X]
	
	var $url : Text:=This:C1470._baseUrl()+"/packages?package_type=generic"
	
	If (Length:C16($packageName)>0)
		$url+="&package_name="+$packageName
	End if 
	
	var $resp : Object:=This:C1470._request("GET"; $url; Null:C1517; 30)
	
	If ($resp.success)
		return ($resp.body || [])
	Else 
		return []
	End if 
	
Function uploadPackage($packageName : Text; $version : Text; $file : 4D:C1709.File) : Object
	// PUT /projects/:id/packages/generic/:package_name/:version/:file_name
	
	var $url : Text:=This:C1470._baseUrl()+"/packages/generic/"+$packageName+"/"+$version+"/"+$file.fullName
	var $blob : Blob:=$file.getContent()
	
	return This:C1470._request("PUT"; $url; $blob; 120)
	
Function getPackageFiles($packageId : Variant) : Collection
	// GET /projects/:id/packages/:package_id/package_files
	
	var $url : Text:=This:C1470._baseUrl()+"/packages/"+String:C10($packageId)+"/package_files"
	var $resp : Object:=This:C1470._request("GET"; $url; Null:C1517; 30)
	
	If ($resp.success)
		return ($resp.body || [])
	Else 
		return []
	End if 
	
Function downloadPackage($packageName : Text; $version : Text; $fileName : Text) : Object
	// GET /projects/:id/packages/generic/:package_name/:version/:file_name
	// Returns blob — uses special dataType handling
	
	var $url : Text:=This:C1470._baseUrl()+"/packages/generic/"+$packageName+"/"+$version+"/"+$fileName
	
	This:C1470.errors:=[]
	This:C1470.lastStatus:=0
	
	var $headers : Object:={}
	$headers["PRIVATE-TOKEN"]:=This:C1470.token
	$headers["Accept"]:="application/octet-stream"
	
	var $options : Object:={method: "GET"; headers: $headers; dataType: "blob"}
	
	var $request : 4D:C1709.HTTPRequest:=4D:C1709.HTTPRequest.new($url; $options)
	$request.wait(120)
	
	var $response:=$request.response
	var $result : Object:={success: False:C215; body: Null:C1517; status: 0}
	
	If ($response=Null:C1517)
		This:C1470.errors:=[{message: "No response from GitLab API"; details: $request.errors}]
		return $result
	End if 
	
	This:C1470.lastStatus:=$response.status
	$result.status:=$response.status
	
	If ($response.status=200)
		$result.success:=True:C214
		$result.body:=$response.body
	Else 
		This:C1470.errors:=[{message: "Download failed: HTTP "+String:C10($response.status)}]
	End if 
	
	return $result
	
Function deletePackage($packageId : Variant) : Object
	// DELETE /projects/:id/packages/:package_id
	
	var $url : Text:=This:C1470._baseUrl()+"/packages/"+String:C10($packageId)
	return This:C1470._request("DELETE"; $url; Null:C1517; 30)
	
	// ============================================================================
	// Releases
	// ============================================================================
	
Function listReleases() : Collection
	// GET /projects/:id/releases
	
	var $url : Text:=This:C1470._baseUrl()+"/releases"
	var $resp : Object:=This:C1470._request("GET"; $url; Null:C1517; 30)
	
	If ($resp.success)
		return ($resp.body || [])
	Else 
		return []
	End if 
	
Function getRelease($tagName : Text) : Object
	// GET /projects/:id/releases/:tag_name
	
	var $url : Text:=This:C1470._baseUrl()+"/releases/"+$tagName
	var $resp : Object:=This:C1470._request("GET"; $url; Null:C1517; 30)
	
	If ($resp.success)
		return $resp.body
	Else 
		return Null:C1517
	End if 
	
Function createRelease($tagName : Text; $name : Text; $description : Text; $ref : Text) : Object
	// POST /projects/:id/releases
	
	var $url : Text:=This:C1470._baseUrl()+"/releases"
	var $data : Object:={tag_name: $tagName}
	
	If (Length:C16($name)>0)
		$data.name:=$name
	End if 
	If (Length:C16($description)>0)
		$data.description:=$description
	End if 
	If (Length:C16($ref)>0)
		$data.ref:=$ref
	End if 
	
	return This:C1470._request("POST"; $url; $data; 30)
	
Function updateRelease($tagName : Text; $data : Object) : Object
	// PUT /projects/:id/releases/:tag_name
	// $data can contain: name, description, milestones, released_at
	
	var $url : Text:=This:C1470._baseUrl()+"/releases/"+$tagName
	return This:C1470._request("PUT"; $url; $data; 30)
	
Function deleteRelease($tagName : Text) : Object
	// DELETE /projects/:id/releases/:tag_name
	
	var $url : Text:=This:C1470._baseUrl()+"/releases/"+$tagName
	return This:C1470._request("DELETE"; $url; Null:C1517; 30)
	
	// ============================================================================
	// Release Links (Asset Associations)
	// ============================================================================
	
Function listReleaseLinks($tagName : Text) : Collection
	// GET /projects/:id/releases/:tag_name/assets/links
	
	var $url : Text:=This:C1470._baseUrl()+"/releases/"+$tagName+"/assets/links"
	var $resp : Object:=This:C1470._request("GET"; $url; Null:C1517; 30)
	
	If ($resp.success)
		return ($resp.body || [])
	Else 
		return []
	End if 
	
Function createReleaseLink($tagName : Text; $name : Text; $url : Text; $linkType : Text) : Object
	// POST /projects/:id/releases/:tag_name/assets/links
	
	var $apiUrl : Text:=This:C1470._baseUrl()+"/releases/"+$tagName+"/assets/links"
	var $data : Object:={name: $name; url: $url}
	
	If (Length:C16($linkType)>0)
		$data.link_type:=$linkType
	Else 
		$data.link_type:="package"
	End if 
	
	return This:C1470._request("POST"; $apiUrl; $data; 30)
	
Function updateReleaseLink($tagName : Text; $linkId : Integer; $data : Object) : Object
	// PUT /projects/:id/releases/:tag_name/assets/links/:link_id
	
	var $url : Text:=This:C1470._baseUrl()+"/releases/"+$tagName+"/assets/links/"+String:C10($linkId)
	return This:C1470._request("PUT"; $url; $data; 30)
	
Function deleteReleaseLink($tagName : Text; $linkId : Integer) : Object
	// DELETE /projects/:id/releases/:tag_name/assets/links/:link_id
	
	var $url : Text:=This:C1470._baseUrl()+"/releases/"+$tagName+"/assets/links/"+String:C10($linkId)
	return This:C1470._request("DELETE"; $url; Null:C1517; 30)
	
	// ============================================================================
	// Convenience
	// ============================================================================
	
Function getPackageRegistryUrl($packageName : Text; $version : Text; $fileName : Text) : Text
	// Build the direct URL for a package file in the generic registry
	
	return This:C1470.instance+"/api/v4/projects/"+This:C1470._encodedPath+"/packages/generic/"+$packageName+"/"+$version+"/"+$fileName
	
Function uploadAndLinkToRelease($tagName : Text; $packageName : Text; $version : Text; $file : 4D:C1709.File) : Object
	// Upload a package, then create a release link pointing to it
	
	var $result : Object:={success: False:C215; upload: Null:C1517; link: Null:C1517}
	
	// Step 1: Upload
	var $uploadResp : Object:=This:C1470.uploadPackage($packageName; $version; $file)
	$result.upload:=$uploadResp
	
	If (Not:C34($uploadResp.success))
		$result.errors:=This:C1470.errors.copy()
		return $result
	End if 
	
	// Step 2: Create release link
	var $pkgUrl : Text:=This:C1470.getPackageRegistryUrl($packageName; $version; $file.fullName)
	var $linkResp : Object:=This:C1470.createReleaseLink($tagName; $packageName+" "+$version; $pkgUrl; "package")
	$result.link:=$linkResp
	$result.success:=$linkResp.success
	
	If (Not:C34($linkResp.success))
		$result.errors:=This:C1470.errors.copy()
	End if 
	
	return $result
	
	// ============================================================================
	// Settings Persistence
	// ============================================================================
	
Function loadSettings() : Object
	// Load settings from user data folder
	
	var $file : 4D:C1709.File:=Folder:C1567(fk user preferences folder:K87:10; *).file("gitlab_settings.json")
	
	If ($file.exists)
		var $text : Text:=$file.getText("utf-8")
		var $settings : Object:=JSON Parse:C1218($text)
		
		If ($settings#Null:C1517)
			This:C1470.instance:=Choose:C955(Length:C16(String:C10($settings.instance))>0; $settings.instance; "https://gitlab.com")
			This:C1470.projectPath:=String:C10($settings.projectPath)
			This:C1470.token:=String:C10($settings.token)
			This:C1470._encodedPath:=Replace string:C233(This:C1470.projectPath; "/"; "%2F")
			
			// Restore cached token/user info
			If ($settings.tokenInfo#Null:C1517)
				This:C1470.tokenInfo:=$settings.tokenInfo
			End if 
			If ($settings.userInfo#Null:C1517)
				This:C1470.userInfo:=$settings.userInfo
			End if 
		End if 
		
		return $settings
	Else 
		return {instance: "https://gitlab.com"; projectPath: ""; token: ""}
	End if 
	
Function saveSettings()
	// Save current settings to user data folder (includes cached token info)
	
	var $settings : Object:={instance: This:C1470.instance; projectPath: This:C1470.projectPath; token: This:C1470.token}
	
	// Cache token/user info so we can check scopes without hitting the API each time
	If (This:C1470.tokenInfo#Null:C1517)
		$settings.tokenInfo:=This:C1470.tokenInfo
	End if 
	If (This:C1470.userInfo#Null:C1517)
		$settings.userInfo:=This:C1470.userInfo
	End if 
	
	var $folder : 4D:C1709.Folder:=Folder:C1567(fk user preferences folder:K87:10; *)
	If (Not:C34($folder.exists))
		$folder.create()
	End if 
	
	var $file : 4D:C1709.File:=$folder.file("gitlab_settings.json")
	$file.setText(JSON Stringify:C1217($settings; *); "utf-8")
	