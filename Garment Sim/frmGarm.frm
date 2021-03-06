VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmGarm 
   Caption         =   "Garment Simulation"
   ClientHeight    =   2475
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   5040
   OleObjectBlob   =   "frmGarm.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmGarm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub UserForm_Initialize()
Dim TempPath() As String
Cncl = False

cbAllDocs = True: cbAllDocsCZ = True
ProgTotal.Visible = False: ProgTotalCZ.Visible = False
ProgCounter.Visible = False: ProgCounterCZ.Visible = False
GarmCancel.Enabled = False: GarmCancelCZ.Enabled = False
Bar.Width = 0: BarCZ.Width = 0

If Right(GarmentPath, 9) = "not found" Or Right(GarmentPath, 6) = "custom" Then
    msgPath.Caption = "": msgPath2.Caption = GarmentPath
    msgPath2.ForeColor = &HFF&
    GarmStart.Enabled = False
    GarmOpen.Enabled = False
Else
    TempPath = Split(GarmentPath, "\")
    msgPath.Caption = Left(GarmentPath, Len(GarmentPath) - Len(TempPath(UBound(TempPath))))
    msgPath2.Caption = TempPath(UBound(TempPath))
End If

msgPathCZ.Caption = "S:\XI-Online\!LIVE-ACCESS\"
msgPath2CZ.Caption = "CZ-Customization"

If Right(GarmentPath, 6) = "custom" Then
    GarmMultiPage.Value = 1
Else
    GarmMultiPage.Value = 0
End If

frmGarmOpen = True
End Sub
Private Sub GarmMultiPage_Change()
    If GarmMultiPage.Value = 2 Then GarmentSim.ShowCZText
End Sub
Private Sub GarmOpen_Click()
shell "explorer.exe /root," & GarmentPath, vbNormalFocus
End Sub
Private Sub GarmOpenCZ_Click()
shell "explorer.exe /root," & GarmentPathCZ, vbNormalFocus
End Sub
Private Sub GarmChoose_Click()
Dim CFPath As String, TempPath() As String

CFPath = GarmChooseFolder("S:\XI-Online")
    If CFPath <> "" Then
        GarmentPath = CFPath
        TempPath = Split(GarmentPath, "\")
            msgPath.Caption = Left(GarmentPath, Len(GarmentPath) - Len(TempPath(UBound(TempPath) - 1)) - 1)
            msgPath2.Caption = TempPath(UBound(TempPath) - 1)
            msgPath2.ForeColor = &H0&
        GarmStart.Enabled = True
        GarmOpen.Enabled = True
    Else
        Exit Sub
    End If
      
End Sub
Private Sub GarmChooseCZ_Click()
Dim CFPath As String, TempPath() As String
  
CFPath = GarmChooseFolder("S:\XI-Online\CZ-Customization")
    If CFPath <> "" Then
        GarmentPathCZ = CFPath
        TempPath = Split(GarmentPathCZ, "\")
            msgPathCZ.Caption = Left(GarmentPathCZ, Len(GarmentPathCZ) - Len(TempPath(UBound(TempPath) - 1)) - 1)
            msgPath2CZ.Caption = TempPath(UBound(TempPath) - 1)
            msgPath2CZ.ForeColor = &H0&
        GarmStartCZ.Enabled = True
        GarmOpenCZ.Enabled = True
    Else
        Exit Sub
    End If
      
End Sub
Private Sub GarmCancel_Click()
If MsgBox("Cancel Simulation? You will need to close simulation templates manually.", vbYesNo, "Cancel?") = vbYes Then Cncl = True
End Sub
Private Sub GarmCancelCZ_Click()
If MsgBox("Cancel Simulation? You will need to close simulation templates manually.", vbYesNo, "Cancel?") = vbYes Then Cncl = True
End Sub
Private Sub btnRefreshCZ_Click()
    GarmentSim.ShowCZText
End Sub
Private Sub btnAddSelCZ_Click()
    If ActiveSelectionRange.Count = 0 Then
        MsgBox "No Selection"
    Else
        GarmentSim.AddSelCZ
    End If
End Sub
Private Sub GarmStart_Click()
Bar.Picture = LoadPicture("S:\XI-Online\!-All Other Stuff\Ethan References\Macros\GarmentSim\Bar.jpg")
Cncl = False

GarmMultiPage.pages(1).Enabled = False
GarmMultiPage.pages(2).Enabled = False
GarmStart.Enabled = False
GarmChoose.Enabled = False
GarmCancel.Enabled = True
cbAllDocs.Enabled = False

    GarmentSim.GarmentSim

GarmMultiPage.pages(1).Enabled = True
GarmMultiPage.pages(2).Enabled = True
GarmStart.Enabled = True
GarmChoose.Enabled = True
GarmCancel.Enabled = False
cbAllDocs.Enabled = True
End Sub
Private Sub GarmStartCZ_Click()
BarCZ.Picture = LoadPicture("S:\XI-Online\!-All Other Stuff\Ethan References\Macros\GarmentSim\Bar.jpg")
Cncl = False

GarmMultiPage.pages(0).Enabled = False
GarmMultiPage.pages(2).Enabled = False
GarmStartCZ.Enabled = False
GarmChooseCZ.Enabled = False
GarmCancelCZ.Enabled = True
cbAllDocsCZ.Enabled = False

    GarmentSim.GarmentSimCZ

GarmMultiPage.pages(0).Enabled = True
GarmMultiPage.pages(2).Enabled = True
GarmStartCZ.Enabled = True
GarmChooseCZ.Enabled = True
GarmCancelCZ.Enabled = False
cbAllDocsCZ.Enabled = True
End Sub


Private Sub UserForm_Terminate()
    frmGarmOpen = False
End Sub
