//%attributes = {}

// ============================================================================
// test_GitLabAPI — Unit tests for GitLabAPI class
// ============================================================================
// Uses saved settings from the GUI (gitlab_settings.json in data folder)
// to run integration tests against the configured GitLab instance.
//
// Run via tool4d or as a project method.
// Results are logged to system standard output as JSON.
// ============================================================================

var $ts : cs:C1710.TestStats:=cs:C1710.TestStats.new()
var $testName : Text

// ---------------------------------------------------------------------------
// Setup — Load settings saved by the form
// ---------------------------------------------------------------------------
var $api : cs:C1710.GitLabAPI:=cs:C1710.GitLabAPI.new(""; ""; "")
var $settings : Object:=$api.loadSettings()

If (Length:C16($api.token)=0) || (Length:C16($api.projectPath)=0)
	LOG EVENT:C667(Into system standard outputs:K38:9; JSON Stringify:C1217({error: "No saved settings found. Please configure GitLab settings in the GUI first."}; *); Error message:K38:3)
	return 
End if 

// Helper — now using TestStats class
// (Formula with multiple statements is not supported in 4D)

// ============================================================================
// TEST 1 — Constructor & properties
// ============================================================================
$testName:="Constructor sets properties"
var $api2 : cs:C1710.GitLabAPI:=cs:C1710.GitLabAPI.new("https://gitlab.example.com"; "group/project"; "tok123")
If ($api2.instance="https://gitlab.example.com") && ($api2.projectPath="group/project") && ($api2.token="tok123") && ($api2._encodedPath="group%2Fproject")
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Unexpected property values")
End if 

// ============================================================================
// TEST 2 — Constructor default instance
// ============================================================================
$testName:="Constructor default instance"
var $api3 : cs:C1710.GitLabAPI:=cs:C1710.GitLabAPI.new(""; "group/project"; "tok")
If ($api3.instance="https://gitlab.com")
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Expected https://gitlab.com, got "+$api3.instance)
End if 

// ============================================================================
// TEST 3 — _baseUrl
// ============================================================================
$testName:="_baseUrl format"
var $url : Text:=$api2._baseUrl()
If ($url="https://gitlab.example.com/api/v4/projects/group%2Fproject")
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Got: "+$url)
End if 

// ============================================================================
// TEST 4 — _headers default
// ============================================================================
$testName:="_headers default Content-Type"
var $h : Object:=$api2._headers("")
If ($h["PRIVATE-TOKEN"]="tok123") && ($h["Content-Type"]="application/json") && ($h["Accept"]="application/json")
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Headers mismatch")
End if 

// ============================================================================
// TEST 5 — _headers custom Content-Type
// ============================================================================
$testName:="_headers custom Content-Type"
var $h2 : Object:=$api2._headers("application/octet-stream")
If ($h2["Content-Type"]="application/octet-stream")
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Got: "+$h2["Content-Type"])
End if 

// ============================================================================
// TEST 6 — loadSettings round-trip
// ============================================================================
$testName:="loadSettings reads saved settings"
If (Length:C16($api.instance)>0) && (Length:C16($api.projectPath)>0) && (Length:C16($api.token)>0)
	$ts.log($testName; True:C214; "instance="+$api.instance+" project="+$api.projectPath)
Else 
	$ts.log($testName; False:C215; "Settings incomplete after loadSettings")
End if 

// ============================================================================
// TEST 7 — saveSettings / loadSettings round-trip
// ============================================================================
$testName:="saveSettings then loadSettings round-trip"
var $apiRT : cs:C1710.GitLabAPI:=cs:C1710.GitLabAPI.new($api.instance; $api.projectPath; $api.token)
$apiRT.saveSettings()
var $apiRT2 : cs:C1710.GitLabAPI:=cs:C1710.GitLabAPI.new(""; ""; "")
$apiRT2.loadSettings()
If ($apiRT2.instance=$api.instance) && ($apiRT2.projectPath=$api.projectPath) && ($apiRT2.token=$api.token)
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Round-trip mismatch")
End if 

// ============================================================================
// TEST 8 — getPackageRegistryUrl
// ============================================================================
$testName:="getPackageRegistryUrl format"
var $pkgUrl : Text:=$api2.getPackageRegistryUrl("myPkg"; "1.0.0"; "archive.zip")
var $expected : Text:="https://gitlab.example.com/api/v4/projects/group%2Fproject/packages/generic/myPkg/1.0.0/archive.zip"
If ($pkgUrl=$expected)
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Got: "+$pkgUrl)
End if 

// ============================================================================
// TEST 9 — listPackages (live API call)
// ============================================================================
$testName:="listPackages returns collection"
var $packages : Collection:=$api.listPackages("")
If (Value type:C1509($packages)=Is collection:K8:32)
	$ts.log($testName; True:C214; String:C10($packages.length)+" package(s)")
Else 
	$ts.log($testName; False:C215; "Expected collection, errors: "+JSON Stringify:C1217($api.errors))
End if 

// ============================================================================
// TEST 10 — listReleases (live API call)
// ============================================================================
$testName:="listReleases returns collection"
var $releases : Collection:=$api.listReleases()
If (Value type:C1509($releases)=Is collection:K8:32)
	$ts.log($testName; True:C214; String:C10($releases.length)+" release(s)")
Else 
	$ts.log($testName; False:C215; "Expected collection, errors: "+JSON Stringify:C1217($api.errors))
End if 

// ============================================================================
// TEST 11 — getRelease with invalid tag returns Null
// ============================================================================
$testName:="getRelease invalid tag returns Null"
var $rel : Object:=$api.getRelease("__nonexistent_tag_test__")
If ($rel=Null:C1517)
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Expected Null for invalid tag")
End if 

// ============================================================================
// TEST 12 — listReleaseLinks with invalid tag returns empty
// ============================================================================
$testName:="listReleaseLinks invalid tag returns empty"
var $links : Collection:=$api.listReleaseLinks("__nonexistent_tag_test__")
If ($links.length=0)
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "Expected empty collection")
End if 

// ============================================================================
// TEST 13 — deletePackage with invalid id fails gracefully
// ============================================================================
$testName:="deletePackage invalid id fails gracefully"
var $delPkg : Object:=$api.deletePackage(-1)
If (Not:C34($delPkg.success))
	$ts.log($testName; True:C214; "status="+String:C10($delPkg.status))
Else 
	$ts.log($testName; False:C215; "Expected failure for invalid package id")
End if 

// ============================================================================
// TEST 14 — deleteRelease with invalid tag fails gracefully
// ============================================================================
$testName:="deleteRelease invalid tag fails gracefully"
var $delRel : Object:=$api.deleteRelease("__nonexistent_tag_test__")
If (Not:C34($delRel.success))
	$ts.log($testName; True:C214; "status="+String:C10($delRel.status))
Else 
	$ts.log($testName; False:C215; "Expected failure for invalid tag")
End if 

// ============================================================================
// TEST 15 — errors collection reset between calls
// ============================================================================
$testName:="errors reset between calls"
$api.getRelease("__nonexistent_tag_test__")
var $errCount1 : Integer:=$api.errors.length
$api.listPackages("")
var $errCount2 : Integer:=$api.errors.length
// After a successful call, errors should be empty
If ($errCount1>0) && ($errCount2=0)
	$ts.log($testName; True:C214; "OK")
Else 
	$ts.log($testName; False:C215; "err after getRelease="+String:C10($errCount1)+" err after listPackages="+String:C10($errCount2))
End if 

// ============================================================================
// Summary
// ============================================================================
var $summary : Object:=$ts.summary()

LOG EVENT:C667(Into system standard outputs:K38:9; JSON Stringify:C1217($summary; *); Choose:C955($ts.failed>0; Error message:K38:3; Information message:K38:1))
