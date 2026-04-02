//%attributes = {}

// ============================================================================
// GitLab Releaser — Entry Point
// ============================================================================
// Opens the main form as a dialog.
// The form handles all UI interaction via the GitLabAPI class.
// ============================================================================

var $formData : Object:={}
$formData.api:=cs:C1710.GitLabAPI.new(""; ""; "")

// Load saved settings into the API object
$formData.api.loadSettings()

// Initialize collections for the form
$formData.packages:=[]
$formData.packageFiles:=[]
$formData.releases:=[]
$formData.releaseLinks:=[]
$formData.currentPackage:=Null:C1517
$formData.currentPackageIndex:=0
$formData.currentRelease:=Null:C1517
$formData.currentReleaseIndex:=0
$formData.currentPackageFile:=Null:C1517
$formData.currentReleaseLink:=Null:C1517
$formData.statusText:=""
$formData.settings:={instance: $formData.api.instance; projectPath: $formData.api.projectPath; token: $formData.api.token}

DIALOG:C40("GitLabReleaser"; $formData)
