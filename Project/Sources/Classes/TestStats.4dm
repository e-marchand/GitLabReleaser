//%attributes = {"shared": false}

// ============================================================================
// TestStats — Lightweight test-result tracker
// ============================================================================

property results : Collection
property passed : Integer
property failed : Integer

Class constructor()
	This:C1470.results:=[]
	This:C1470.passed:=0
	This:C1470.failed:=0

Function log($testName : Text; $ok : Boolean; $detail : Text)
	This:C1470.results.push({test: $testName; passed: $ok; detail: $detail})
	If ($ok)
		This:C1470.passed+=1
	Else 
		This:C1470.failed+=1
	End if 

Function summary()->$obj : Object
	$obj:={total: This:C1470.passed+This:C1470.failed; passed: This:C1470.passed; failed: This:C1470.failed; tests: This:C1470.results}
