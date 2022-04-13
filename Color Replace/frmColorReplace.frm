VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmColorReplace 
   Caption         =   "Replace Colors"
   ClientHeight    =   5670
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   3375
   OleObjectBlob   =   "frmColorReplace.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmColorReplace"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub UserForm_Initialize()
    With findDrop
        .AddItem "Sublimation Black"
        .AddItem "DTG White"
        .AddItem "Black"
        .AddItem "White"
    End With
    With replaceDrop
        .AddItem "Sublimation Black"
        .AddItem "DTG White"
        .AddItem "Black"
        .AddItem "White"
    End With
    With presetBox
        .AddItem "White -> DTG White"
        .AddItem "Black -> Sublimation Black"
    End With
    
    findPreview.Picture = LoadPicture("S:\XI-Online\!-All Other Stuff\Ethan References\Macros\ColorReplace\nocolor2.jpg")
    replacePreview.Picture = LoadPicture("S:\XI-Online\!-All Other Stuff\Ethan References\Macros\ColorReplace\nocolor2.jpg")
    
    findProps.Caption = "No color selected"
    replaceProps.Caption = "No color selected"
End Sub
Private Sub findDrop_Change()
If findDrop.Value = "Unnamed Color" Then Exit Sub

If findDrop.Value = "Sublimation Black" Then
    findColor.ConvertToCMYK
    findColor.CMYKAssign 75, 67, 67, 90
    findProps.Caption = "C:75  M:67  Y:67  K:90"
    presetAssigns "find"
ElseIf findDrop.Value = "DTG White" Then
    findColor.ConvertToRGB
    findColor.RGBAssign 254, 254, 254
    findProps.Caption = "R:254  G:254  B:254"
    presetAssigns "find"
ElseIf findDrop.Value = "Black" Then
    findColor.ConvertToRGB
    findColor.RGBAssign 0, 0, 0
    findProps.Caption = "R:0  G:0  B:0"
    presetAssigns "find"
ElseIf findDrop.Value = "White" Then
    findColor.ConvertToRGB
    findColor.RGBAssign 255, 255, 255
    findProps.Caption = "R:255  G:255  B:255"
    presetAssigns "find"
End If
End Sub
Private Sub replaceDrop_Change()
If replaceDrop.Value = "Unnamed Color" Then Exit Sub

If replaceDrop.Value = "Sublimation Black" Then
    replaceColor.ConvertToCMYK
    replaceColor.CMYKAssign 75, 67, 67, 90
    replaceProps.Caption = "C:75  M:67  Y:67  K:90"
    presetAssigns "replace"
ElseIf replaceDrop.Value = "DTG White" Then
    replaceColor.ConvertToRGB
    replaceColor.RGBAssign 254, 254, 254
    replaceProps.Caption = "R:254  G:254  B:254"
    presetAssigns "replace"
ElseIf replaceDrop.Value = "Black" Then
    replaceColor.ConvertToRGB
    replaceColor.RGBAssign 0, 0, 0
    replaceProps.Caption = "R:0  G:0  B:0"
    presetAssigns "replace"
ElseIf replaceDrop.Value = "White" Then
    replaceColor.ConvertToRGB
    replaceColor.RGBAssign 255, 255, 255
    replaceProps.Caption = "R:255  G:255  B:255"
    presetAssigns "replace"
End If
End Sub
Sub presetAssigns(aType As String)
Dim myColor As New Color

If aType = "find" Then
    myColor.CopyAssign findColor
    myColor.ConvertToRGB
    findPreview.BackColor = RGB(myColor.RGBRed, myColor.RGBGreen, myColor.RGBBlue)
    findPreview.Picture = LoadPicture(vbNullString)
Else
    myColor.CopyAssign replaceColor
    myColor.ConvertToRGB
    replacePreview.BackColor = RGB(myColor.RGBRed, myColor.RGBGreen, myColor.RGBBlue)
    replacePreview.Picture = LoadPicture(vbNullString)
End If
End Sub


Private Sub findFill_Click()
    findColorSub "Fill"
End Sub
Private Sub findOutline_Click()
    findColorSub "Outline"
End Sub
Private Sub replaceFill_Click()
    replaceColorSub "Fill"
End Sub
Private Sub replaceOutline_Click()
    replaceColorSub "Outline"
End Sub
Private Sub findAssign_Click()
Dim myColor As New Color

If findColor.UserAssignEx = False Then Exit Sub

If findColor.Type = cdrColorRGB Then
    findProps.Caption = "R:" & findColor.RGBRed & "  G:" & findColor.RGBGreen & "  B:" & findColor.RGBBlue
ElseIf findColor.Type = cdrColorCMYK Then
    findProps.Caption = "C:" & findColor.CMYKCyan & "  M:" & findColor.CMYKMagenta & "  Y:" & findColor.CMYKYellow & "  K:" & findColor.CMYKBlack
ElseIf findColor.Type = cdrColorUserInk Or findColor.Type = cdrColorSpot Then
    findProps.Caption = "Tint: " & findColor.Tint & "%"
Else
    MsgBox colorType(findColor.Type) & " color model not supported. RGB, CMYK, or Spot only"
End If

myColor.CopyAssign findColor
myColor.ConvertToRGB
findPreview.Picture = LoadPicture(vbNullString)
findPreview.BackColor = RGB(myColor.RGBRed, myColor.RGBGreen, myColor.RGBBlue)

If findColor.Name <> "unnamed color" Then
    findDrop = findColor.Name
Else
    findDrop = "Unnamed Color"
End If
End Sub
Private Sub replaceAssign_Click()
Dim myColor As New Color

If replaceColor.UserAssignEx = False Then Exit Sub

If replaceColor.Type = cdrColorRGB Then
    replaceProps.Caption = "R:" & replaceColor.RGBRed & "  G:" & replaceColor.RGBGreen & "  B:" & replaceColor.RGBBlue
ElseIf replaceColor.Type = cdrColorCMYK Then
    replaceProps.Caption = "C:" & replaceColor.CMYKCyan & "  M:" & replaceColor.CMYKMagenta & "  Y:" & replaceColor.CMYKYellow & "  K:" & replaceColor.CMYKBlack
ElseIf replaceColor.Type = cdrColorUserInk Or replaceColor.Type = cdrColorSpot Then
    replaceProps.Caption = "Tint: " & replaceColor.Tint & "%"
Else
    MsgBox colorType(replaceColor.Type) & " color model not supported. RGB, CMYK, or Spot only"
End If

myColor.CopyAssign replaceColor
myColor.ConvertToRGB
replacePreview.Picture = LoadPicture(vbNullString)
replacePreview.BackColor = RGB(myColor.RGBRed, myColor.RGBGreen, myColor.RGBBlue)

If replaceColor.Name <> "unnamed color" Then
    replaceDrop = replaceColor.Name
Else
    replaceDrop = "Unnamed Color"
End If
End Sub
Private Sub btnGo_Click()
Dim s As Shape, sr As New ShapeRange, doc As Document
Set doc = ActiveDocument

If optSelRange = True And ActiveSelectionRange.Shapes.Count = 0 Then MsgBox "No Active Selection to apply changes to": Exit Sub
If cbFills = False And cbOutlines = False Then MsgBox "Select Fills and/or Outlines": Exit Sub
If MultiPage1.Value = 0 Then
    If findProps.Caption = "No color selected" Then MsgBox "Select color to find (old color)": Exit Sub
    If replaceProps.Caption = "No color selected" Then MsgBox "Select color to use for replace (new color)": Exit Sub
    If findColor.IsSame(replaceColor) Then MsgBox "Find and Replace are the same color": Exit Sub
End If

If frmColorReplace.optSelRange = True Then
    Set sr = ActiveSelectionRange.Shapes.FindShapes(recursive:=True)
ElseIf frmColorReplace.optDocRange = True Then
    For i = 1 To doc.pages.Count
        sr.AddRange doc.pages(i).FindShapes(recursive:=True)
    Next i
End If

If MultiPage1.Value = 1 Then
    'Presets
    If presetBox.ListIndex = 0 Then ReplaceWhite sr: Exit Sub
    If presetBox.ListIndex = 1 Then ReplaceBlack sr: Exit Sub
End If

If frmColorReplace.findDrop = "Black" And frmColorReplace.replaceDrop = "Sublimation Black" Then ReplaceBlack sr: Exit Sub
If frmColorReplace.findDrop = "White" And frmColorReplace.replaceDrop = "DTG White" Then ReplaceWhite sr: Exit Sub

    ColorFindReplace sr

End Sub


