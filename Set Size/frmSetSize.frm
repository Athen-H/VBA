VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmSetSize 
   Caption         =   "Set Size"
   ClientHeight    =   2295
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   2895
   OleObjectBlob   =   "frmSetSize.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmSetSize"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdGet_Click()
    txtWidth = ActiveSelectionRange.SizeWidth
    txtHeight = ActiveSelectionRange.SizeHeight
End Sub
Private Sub cmdOK_Click()
Dim s As Shape, c As Double, a As Double, b As Double
Dim cw As Double, ch As Double
Dim w As Double, h As Double
ActiveDocument.ReferencePoint = cdrCenter

If (frmSetSize.txtWidth = "" Or frmSetSize.txtWidth = 0) And (frmSetSize.txtHeight = "" Or frmSetSize.txtHeight = 0) Then
      MsgBox "Enter dimensions"
      Exit Sub
End If
If frmSetSize.txtWidth < 0 Or frmSetSize.txtHeight < 0 Then
      MsgBox "Dimensions cannot be negative"
      Exit Sub
End If


If frmSetSize.txtWidth = "" Or frmSetSize.txtWidth = 0 Then
    cw = 1000
Else
    cw = frmSetSize.txtWidth
End If
If frmSetSize.txtHeight = "" Or frmSetSize.txtHeight = 0 Then
    ch = 1000
Else
    ch = frmSetSize.txtHeight
End If

ActiveDocument.BeginCommandGroup "Set Size"
For Each s In ActiveSelectionRange
    w = s.SizeWidth
    h = s.SizeHeight
    
    If frmSetSize.cbEllipse = False Then
        If cw / ch < w / h Then
           c = cw / w
           s.SizeHeight = h * c
           s.SizeWidth = cw
        Else
           c = ch / h
           s.SizeWidth = w * c
           s.SizeHeight = ch
        End If
    Else
        a = cw / 2: b = ch / 2
        c = (2 * a * b) / Sqr((a ^ 2 * h ^ 2) + (b ^ 2 * w ^ 2))
        s.SizeWidth = c * w: s.SizeHeight = c * h
    End If
    
Next s
ActiveDocument.EndCommandGroup
End Sub
Private Sub txtWidth_Change()
WidthMath.ForeColor = &H0&
txtWidth.ForeColor = &H0&

On Error GoTo Hndlr
If InStr(1, txtWidth, "/") Or InStr(1, txtWidth, "*") Or InStr(1, txtWidth, "+") Or InStr(1, txtWidth, "-") Or InStr(1, txtWidth, "^") Then
    WidthMath.Visible = True
    WidthMath.Text = Application.Evaluate(txtWidth)
Else
    WidthMath.Visible = False
End If
Exit Sub

Hndlr:
    WidthMath.ForeColor = &HFF&
    If Left(Err.Description, 9) = "Error par" Then WidthMath.Text = "Unable to Parse"
    If Left(Err.Description, 3) = "Div" Then WidthMath.Text = "Divide by 0"
    
End Sub
Private Sub txtHeight_Change()
HeightMath.ForeColor = &H0&
txtHeight.ForeColor = &H0&

On Error GoTo Hndlr
If InStr(1, txtHeight, "/") Or InStr(1, txtHeight, "*") Or InStr(1, txtHeight, "+") Or InStr(1, txtHeight, "-") Or InStr(1, txtHeight, "^") Then
    HeightMath.Visible = True
    HeightMath.Text = Application.Evaluate(txtHeight)
Else
    HeightMath.Visible = False
End If
Exit Sub

Hndlr:
    HeightMath.ForeColor = &HFF&
    If Left(Err.Description, 9) = "Error par" Then HeightMath.Text = "Unable to Parse"
    If Left(Err.Description, 3) = "Div" Then HeightMath.Text = "Divide by 0"
    
End Sub
Private Sub txtWidth_Exit(ByVal Cancel As MSForms.ReturnBoolean)
On Error GoTo Err
    WidthMath.Visible = False
    txtWidth.ForeColor = &H0&
    txtWidth = Application.Evaluate(txtWidth)
    Exit Sub
Err:
    txtWidth.ForeColor = &HFF&
End Sub
Private Sub txtHeight_Exit(ByVal Cancel As MSForms.ReturnBoolean)
On Error GoTo Err
    HeightMath.Visible = False
    txtHeight.ForeColor = &H0&
    txtHeight = Application.Evaluate(txtHeight)
    Exit Sub
Err:
    txtHeight.ForeColor = &HFF&
End Sub
