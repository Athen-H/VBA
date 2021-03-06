#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         Ethan Harris 11/26/21

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>

;opt("wintitlematchmode",2)
Const $sFld = "S:\XI-Online\!-Other Products\Sublimation\"
Global $r, $q, $fl, $sku, $prod, $suff, $prodUP, $rngFld
Global $aGUI, $combo, $input, $btnAdd, $btnAddQ, $btnAddReg, $btnDup, $btnRot
Local $gMsg = 0

	Initialize() ;-add arrow down to expand combo dropdown, make qty. add its own simple gui

While 1
	$gMsg = GUIGetMsg()

	Switch $gMsg
		Case $btnAdd
			$prod = GUICtrlRead($combo)
			$sku = GUICtrlRead($input)
			$q = 1
			If CheckSKU() Then AddSKU()

		Case $btnAddQ
			$prod = GUICtrlRead($combo)
			$sku = GUICtrlRead($input)

			If CheckSKU() Then
				$q = InputBox("Add Quantity", "Enter quantity")
				If $q <> "" Then AddSKU()
			EndIf

		Case $btnAddReg
			$prod = GUICtrlRead($combo)
			$sku = "reg"
			$q = 1
			AddSKU()
			Send("{CTRLDOWN}")
			Send("{CTRLUP}")     ;fixes stuck ctrl key thing

		Case $btnDup
			WinActivate("ErgoSoft")
			Send("^d")
			WinActivate("Auto Import")

		Case $btnRot
			WinActivate("ErgoSoft")
			Send("r")
			WinActivate("Auto Import")

		Case $combo
			$prod = GUICtrlRead($combo)

			;If $prod <> "M11" And $prod <> "15M" And $prod <> "Coolie" And $prod <> "Slim Coolie" And $prod <> "AWB" And $prod <> "DMT" Then
			;ConsoleWrite($prod)
			;MsgBox($MB_OK, "Warning", "Selected product not yet supported")
			;GUICtrlSetData($combo, "M11")

			GUICtrlSetState($input, $GUI_FOCUS)

		Case $GUI_EVENT_CLOSE
			ExitLoop
	EndSwitch
WEnd

Func Initialize()
	$aGUI = GUICreate("Auto Import", 268, 94, 985, 180) ;Add "automatically add reg bars" checkbox for FBA?
	GUISetFont(10)

	$combo = GUICtrlCreateCombo("M11", 12, 12, 158, 1)
		GUICtrlSetData($combo, "15M|Coolie|Slim Coolie") ;|3RCO|ACL|AOK|ARK|ARL|ASK|AWB|BDSC|CSK|CST|DMT|DSC|FBM|HFG|LP|LPF|MBO|MWO|PFM|PHS|PNT|RGS|SPH|SST|SYS|THT|TM20|WBBF46|WBBF57|WTT")
		GUICtrlSetFont(-1, 14)
	$input = GUICtrlCreateInput("", 182, 12, 74, 29, -1)
		GUICtrlSetLimit($input, 4)
		GUICtrlSetFont(-1, 14)

	$btnAddQ = GUICtrlCreateButton("Add Qty.", 97, 53, 73, 29)
	$btnAddReg = GUICtrlCreateButton("Add Reg.", 12, 53, 73, 29)
	$btnAdd = GUICtrlCreateButton("Add", 182, 53, 73, 29)
	$btnDup = GUICtrlCreateButton("x", -100, -100, 1, 1)
	$btnRot = GUICtrlCreateButton("x", -100, -100, 1, 1)

	Local $AccelKeys[5][2] = [["{ENTER}", $btnAdd], ["^{ENTER}", $btnAddQ], ["^r", $btnAddReg], ["^d", $btnDup], ["r", $btnRot]]
		GUISetAccelerators($AccelKeys)

	GUISetState(@SW_SHOW)
	WinSetOnTop("Auto Import", "", 1)
	GUICtrlSetState($input, $GUI_FOCUS)
EndFunc

Func CheckSKU()
	;If $sku = "" Then
	If StringLen($sku) < 4  Then
		MsgBox($MB_OK, "SKU Error", "SKU should be 4 digits")
		Return False
	Else
		Return True
	EndIf
EndFunc

Func AddSKU()
	$prodUP = 1
	$r = False
	$suff = ""

	FindFile()

	Local $i
	If ImportPDF() Then
		For $i = 1 to $q-$prodUP Step $prodUP
			Send("^d")
			Sleep(100)
		Next
	EndIf

; Old method of block above, doesn't work very well -- keep for now in case something breaks
;~    Local $i
;~    Local $fileFound
;~    For $i = 1 to $q Step $prodUP
;~ 	  If $i = 1 Then
;~ 		 $fileFound = ImportPDF()
;~ 	  Else
;~ 		 If $fileFound Then Send("^d")
;~ 	  EndIf
;~ 	  Sleep(100)
;~    Next

	WinActivate("Auto Import")
	GUICtrlSetState($input, $GUI_FOCUS)
	If $sku <> "reg" Then
		GUICtrlSetData($input, "")
	EndIf
EndFunc

Func FindFile()
	Switch $prod
		Case "M11"
			If $sku = "reg" Then
				$fl = "S:\XI-Online\!-Other Products\!ErgoSft-RegBars\!Mug-regbar.pdf"
			Else
				$prodUP = 1
				$suff = ""
				$r = True ;Rotation
				FindRange("M11-", "Mugs - M11\", "!PDF\")
			Endif
		Case "15M"
			If $sku = "reg" Then
				$fl = "S:\XI-Online\!-Other Products\!ErgoSft-RegBars\!Mug-regbar.pdf"
			Else
				$prodUP = 1
				$suff = ""
				$r = True ;Rotation
				FindRange("15M-", "Mugs - 15M\", "")
			EndIf
		Case "Coolie"
			If $sku = "reg" Then
				$fl = "S:\XI-Online\!-Other Products\!ErgoSft-RegBars\!Coolie-regbar.pdf"
			Else
				$prodUP = 4
				$suff = "-4"
				$r = False ;Rotation
				FindRange("C", "Coolies-Koozies\", "!PDF\")
			EndIf
		Case "Slim Coolie"
			If $sku = "reg" Then
				$fl = "S:\XI-Online\!-Other Products\!ErgoSft-RegBars\!Coolie-Slim-regbar.pdf"
			Else
				$prodUP = 4
				$suff = "-4"
				$r = False ;Rotation
				FindRange("SC", "Coolies-Koozies - Slim\", "!PDF\")
			EndIf
		Case "AWB"
			If $sku = "reg" Then
				$fl = "S:\XI-Online\!-Other Products\!ErgoSft-RegBars\AWB-regbar.pdf"
			Else
				$prodUP = 1
				$suff = ""
				$r = True ;Rotation
				FindRange("AWB-", "AWB - Water Bottles\", "!PDF\")
			EndIf
		Case "DMT"
			If $sku = "reg" Then
				$fl = "S:\XI-Online\!-Other Products\!ErgoSft-RegBars\DMT-Doormat-regbar.pdf"
			Else
				$prodUP = 1
				$suff = ""
				$r = True ;Rotation
				FindRange("DMT-", "DMT-Doormat\", "!PDF\")
			EndIf

		Case Else
			MsgBox($MB_OK, "Error", "Product not yet supported")
			$fl = "Skip"
	EndSwitch
EndFunc

Func FindRange($prfx, $prodFld, $pdfFld)
	If $sku < 100 Then
		$rngFld = $prfx & "0001-0099\"
	Else
		$rngFld = $prfx & StringLeft($sku, 2) & "00-" & StringLeft($sku, 2) & "99\"
	EndIf

	$fl = $sFld & $prodFld & $pdfFld & $rngFld & $prfx & $sku & $suff & ".pdf"
EndFunc

Func ImportPDF()
	If $fl <> "Skip" Then
		WinActivate("ErgoSoft")
		Send("^i")

		If WinWait("Import", "Import", 10) Then
			;Sleep(500)
			;WinActivate("Import")
			ControlSetText("Import", "Import", "[CLASS:Edit; INSTANCE:1]", $fl)
			Send("{ENTER}")

			Sleep(500)                            ;basically working
			If WinExists("Import") Then
				WinClose("Import")
				WinClose("Import", "Import")
				MsgBox($MB_OK, "Error", $fl & " not found")
				Return False
			Else
				WinWaitActive("ErgoSoft")
				Sleep(150)
				If $r Then Send("r")
				;If $r = True Then ControlSend("ErgoSoft", "", "[CLASS:AfxFrameOrView110; INSTANCE:2]", "r")
				Return True
			EndIf
		Else
			MsgBox($MB_OK, "Error", "Import window not found")
			Return False
		EndIf
	EndIf
EndFunc

#cs Corel Testing
Func ImportPDF()
	;MsgBox($MB_OK, "Testing", "Importing " & $fl)
	WinActivate("CorelDRAW")
	ControlSend("Corel", "", "[CLASS:AfxFrameOrView80u; INSTANCE:1]", "^i")
	WinWaitActive("Import", "")
	ControlSetText("Import", "", "[CLASS:Edit; INSTANCE:1]", $fl, 1)
	ControlSend("Import", "", "[CLASS:Button; INSTANCE:6]", "{ENTER}")
	WinWaitActive("Import PDF")
	ControlSend("Import PDF", "", "[CLASS:Button; INSTANCE:3]", "{ENTER}")
	WinWaitActive("Corel")
	ControlSend("Corel", "", "[CLASS:AfxFrameOrView80u; INSTANCE:1]", "{ENTER}")
	WinWaitActive("Corel")
	ControlSend("Corel", "", "[CLASS:AfxFrameOrView80u; INSTANCE:1]", "^g", 0)
	If $r = True Then ControlSend("Corel", "", "[CLASS:AfxFrameOrView80u; INSTANCE:1]", "+f", 0) ;Rotate
EndFunc
#ce


