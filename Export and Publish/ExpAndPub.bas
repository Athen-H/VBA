Attribute VB_Name = "ExpAndPub"
'Option Private Module
Public bFixedExport As Boolean
Public bMugWarn As Boolean

Sub EPShow()
frmExpAndPub.Show vbModeless
End Sub
Function StartCheck() As Boolean
StartCheck = False

With frmExpAndPub
    If Documents.Count = 0 Then MsgBox "No open documents": Exit Function
    If .cbPublish = False And .cbExport = False Then MsgBox "Select a file type": Exit Function
    
    If .cbExport = True And .ExportPath = "" Then MsgBox "Choose Pic Location": Exit Function
    If .cbPublish = True And .PublishPath = "" Then MsgBox "Choose PDF Location": Exit Function
    If .cbUseFixed = True And .FixedPath = "" Then MsgBox "Choose Fixed Export Location": Exit Function
    
    If .cbExport = True And Dir(.ExportPath, vbDirectory) = "" Then MsgBox "Pic location does not exist": Exit Function
    If .cbPublish = True And Dir(.PublishPath, vbDirectory) = "" Then MsgBox "PDF location does not exist": Exit Function
    If .cbUseFixed = True And Dir(.FixedPath, vbDirectory) = "" Then MsgBox "Fixed Export location does not exist": Exit Function
        
        StartCheck = True
        .EPMultiPage.Value = 3
End With
End Function
Sub EPGo(allDocs As Boolean)
On Error GoTo ErrHndlr
Dim doc As Document, dCount As Integer, d As Integer

With frmExpAndPub
    If Right(.ExportPath, 1) <> "\" Then .ExportPath = .ExportPath & "\"
    If Right(.PublishPath, 1) <> "\" Then .PublishPath = .PublishPath & "\"
    If Right(.FixedPath, 1) <> "\" Then .FixedPath = .FixedPath & "\"
    If .cbUseFixed = True Then
        bFixedExport = True
    Else
        bFixedExport = False
    End If
    If allDocs = True Then
        dCount = Documents.Count
    Else
        dCount = 1
        Set doc = ActiveDocument
    End If
    
    For d = 1 To dCount
    .Repaint
    If allDocs Then Set doc = Documents(d)
        If .cbExport = True Then
            Export doc, optFind: .ProgBox.TopIndex = .ProgBox.ListCount - 1
        End If
        If .cbPublish = True Then
            Publish doc: .ProgBox.TopIndex = .ProgBox.ListCount - 1
        End If

Skip:
    Next d
    
    If .ProgBox.ListCount <> 0 Then
        .btnOpenPicFldr.Caption = "Open Pic Folder"
        If Len(Time) = 11 Then
            AddBoxItem "                       - Finished " & Left(Time, 8) & " -"
        Else
            AddBoxItem "                        - Finished " & Left(Time, 7) & " -"
        End If
    Else
        .EPMultiPage.Value = 0
    End If
End With

If bMugWarn Then
    shell "explorer.exe /root," & "S:\XI-Online\!-Other Products\Sublimation\Mugs - 15M", vbNormalFocus
    MsgBox "Remember to move 15M PDFs into correct 15M folder"
    bMugWarn = False
End If
Exit Sub

ErrHndlr:
If Left(Err.Description, 21) = "Method 'ExportBitmap'" Then
    Resume Next
ElseIf Left(Err.Description, 11) = "Layer 'SKU'" Then
    MsgBox "Layer 'SKU' not found in " & Documents(d).Title
    GoTo Skip
ElseIf Left(Err.Description, 12) = "File already" Then
    Resume Next
Else
    MsgBox Err.Description
End If
End Sub

Sub Export(exDoc As Document, exType As String)
Dim Dropdown As String, BaseName As String, path As String, cSuff As String
Set fso = New FileSystemObject

BaseName = fso.GetBaseName(exDoc)
Dropdown = frmExpAndPub.ExportDrop
ExportPath = frmExpAndPub.ExportPath
FixedPath = frmExpAndPub.FixedPath
cSuff = frmExpAndPub.PicSuffBox.Text: If cSuff <> "" And Left(cSuff, 1) <> "-" Then cSuff = "-" & cSuff

If bFixedExport = True Then
    F = 2
Else
    F = 1
End If

If Dropdown = "First" Then
    exDoc.pages.First.Activate
ElseIf Dropdown = "Last" Then
    exDoc.pages.Last.Activate
End If

For i = 1 To F
If i = 2 Then ExportPath = FixedPath
If exType = "png" Then
    path = ExportPath & BaseName & cSuff & ".png"
    Set ExportFilter = exDoc.ExportBitmap(path, cdrPNG, cdrCurrentPage, cdrRGBColorImage, 0, 0, 300, 300, cdrNormalAntiAliasing, False, True, True, False, cdrCompressionNone)
        With ExportFilter
            .Interlaced = True
            .Transparency = 0 ' FilterPNGLib.pngNone
            .InvertMask = False '     ^^ This comment added by recording export as png??
            .Color = 0
            .Finish
        End With
    AddBoxItem BaseName & cSuff & ".png" & " Exported"
Else
    path = ExportPath & BaseName & cSuff & ".jpg"
    Set ExportFilter = exDoc.ExportBitmap(path, cdrJPEG, cdrCurrentPage, cdrRGBColorImage, 0, 0, 300, 300, cdrNormalAntiAliasing, False, False, True, False, cdrCompressionNone)
        With ExportFilter
            .Progressive = False
            .Optimized = False
            .SubFormat = 0
            .Compression = 10
            .Smoothing = 10
            .Finish
        End With
    AddBoxItem BaseName & cSuff & ".jpg" & " Exported"
End If
Next i

Set fso = Nothing
End Sub
Sub Publish(pubDoc As Document)
Dim Dropdown As String, BaseName As String, path As String, fldrpath As String, cSuff As String
Dim pubPath As String, pubSuff As String, pubRange As String, nmArr() As String
Set fso = New FileSystemObject

BaseName = fso.GetBaseName(pubDoc): path = frmExpAndPub.PublishPath
Dropdown = frmExpAndPub.PublishDrop: fldrpath = (frmExpAndPub.PublishPath & BaseName)
cSuff = frmExpAndPub.PDFSuffBox.Text: If cSuff <> "" And Left(cSuff, 1) <> "-" Then cSuff = "-" & cSuff

If Dropdown = "First" Then                              'Setting range as page 1, 1 export
    pubRange = 1
    iterations = 1
ElseIf Dropdown = "Last" Or Dropdown = "Coolies" Then   'Coolies is the same as last page export
    pubRange = pubDoc.pages.Count
    iterations = 1
ElseIf Dropdown = "Mugs" Then                           'Mug is page 1, but 2 exports
    pubRange = 1
    iterations = 2
ElseIf Dropdown = "VSB" Then                            'No need to set range for ESC stuff here, it's defined in the iterations
    iterations = 4
Else
    iterations = pubDoc.pages.Count                     'For all ESC apart from VSB, every page is exported
End If

For i = 1 To iterations
    If Dropdown = "Mugs" Then
        If i = 1 Then                                         'Mugs are exported as 2 PDFs, 1 for M11, 1 for 15M. Both have the same SKU just different prefixes
            nmArr = Split(BaseName, "-")
            BaseName = "M11-" & nmArr(1)                      'Just making an array where the first element is "M11" and the second is the SKU, e.g. "0991". Later we can just put the SKU element onto the prefix "15M-" for the 15M PDF
            bMugWarn = True                                   'Warning flag to prompt user to move 15M PDFs to correct folder, since M11 and 15M export to the same one - may be better to prompt for 15M folder when Mug dropdown is selected?
        ElseIf i = 2 Then
            pubDoc.pages(1).Layers("SKU").Printable = False   '15M PDF is the same as M11, just no SKU printed. Easiest way to do this is setting the layer the SKU is on to unprintable
            BaseName = "15M-" & nmArr(1)
            pubDoc.Dirty = False                              'Setting document to not dirty means you don't have to worry about saving version with unprintable SKU, and you don't have to click "no" on the save prompts when closing all
        End If
    ElseIf Dropdown = "JCN" Then                                                'ESC PDFs get their own folder for each SKU
        pubRange = i                                                            'Since every page is published, the publish range is defined as the page of the iteration. e.g. the 3rd publish iteration will be publishing the 3rd page
        If i = 1 Then
            If Dir(fldrpath, vbDirectory) <> "" Then fso.DeleteFolder fldrpath  'If the folder exists, delete it
            fso.CreateFolder fldrpath
            path = fldrpath & "\"                                               'JCN PDFs look like (e.g. SKU 2033) JCN-2033-1UP
            pubSuff = "-1UP"                                                                                       'JCN-2033-14UP
        Else                                                                                                       'JCN-2033-28UP
            pubSuff = "-" & pubDoc.pages(i).Name                                                                   'JCN-2033-56UP
        End If                                                                                                     'JCN-2033-112UP
    ElseIf Dropdown = "VSB" Then
        pubRange = i
        If i = 1 Then
            If Dir(fldrpath, vbDirectory) <> "" Then fso.DeleteFolder fldrpath
            fso.CreateFolder fldrpath
            path = fldrpath & "\"
            pubSuff = "-1UP"
        End If
        pubRange = i + 1
        pubSuff = "-" & pubDoc.pages(i + 1).Name                                'Page names/suffixes are a little weird for VSB, page 2 is actually 1-up, 3 is 2-up etc.
    ElseIf Dropdown = "LVSB" Then
        If i = 1 Then
            If Dir(fldrpath, vbDirectory) <> "" Then fso.DeleteFolder fldrpath
            fso.CreateFolder fldrpath
            path = fldrpath & "\"
        End If
        pubRange = i
        pubSuff = "-" & pubDoc.pages(i).Name                                    'Straightforward page names, page number is iteration number
    ElseIf Dropdown = "Coolies" Then
        pubSuff = "-4"                                                          'Just need to add "-4" suffix for coolie PDF
    End If
    
pubPath = (path & BaseName & pubSuff & cSuff & ".pdf")
    pubDoc.PDFSettings.PublishRange = pdfPageRange
    pubDoc.PDFSettings.PageRange = pubRange
    pubDoc.PublishToPDF pubPath
AddBoxItem BaseName & pubSuff & cSuff & ".pdf" & " Published"
Next i

Set fso = Nothing
End Sub


Sub AddBoxItem(Item As String)
    frmExpAndPub.ProgBox.AddItem Item
    frmExpAndPub.ProgBox.TopIndex = frmExpAndPub.ProgBox.ListCount - 1
    frmExpAndPub.Repaint
End Sub
Function EPChooseFolder(EPType As String) As String
Dim shell, folder

If EPType = "Export" Then
    EPPath = frmExpAndPub.ExportPath
ElseIf EPType = "Publish" Then
    EPPath = frmExpAndPub.PublishPath
ElseIf EPType = "CZ" Then
    EPPath = frmExpAndPub.ExportPathCZ
ElseIf EPType = "Fixed" Then
    EPPath = frmExpAndPub.FixedPath
End If

If Right(EPPath, 1) = "\" Then EPPath = Left(EPPath, Len(EPPath) - 1)

Set fso = New FileSystemObject
Set shell = CreateObject("Shell.Application")
Set folder = shell.BrowseForFolder(0, "Select Location", &H4000 + &H10, EPPath & "\")

    If Not folder Is Nothing Then
          EPChooseFolder = folder.self.path & "\"
    Else
        EPChooseFolder = ""
    End If
    
Set folder = Nothing
Set shell = Nothing
End Function
Function ProdFldr() As String
Dim CrFldr As Object, BaseName As String
Set fso = New FileSystemObject

If ActiveDocument.Properties("Folder", 1) <> "" Then
    If Dir(ActiveDocument.Properties("Folder", 1), vbDirectory) <> "" Then ProdFldr = ActiveDocument.Properties("Folder", 1): Exit Function
End If
BaseName = fso.GetBaseName(ActiveDocument)

'Unsaved File
If Left(BaseName, 7) = "Graphic" Or ActiveDocument.FullFileName = "" Then ProdFldr = "N/A": Exit Function
'Mugs
If Left(BaseName, 3) = "M11" Then ProdFldr = "S:\XI-Online\!-Other Products\Sublimation\Mugs - M11": Exit Function
'AWF
If Left(BaseName, 2) = "F-" Or _
   Left(BaseName, 3) = "AWF4" Then ProdFldr = "S:\XI-Online\!-Other Products\Laser\AWF - Frames": Exit Function
'Coolies
If (Left(BaseName, 2) = "SC" And IsNumeric(Mid(BaseName, 3, 1))) Then ProdFldr = "S:\XI-Online\!-Other Products\Sublimation\Coolies-Koozies - Slim": Exit Function
If (Left(BaseName, 1) = "C" And IsNumeric(Mid(BaseName, 2, 1))) Then ProdFldr = "S:\XI-Online\!-Other Products\Sublimation\Coolies-Koozies": Exit Function

For i = 1 To 5
If i = 1 Then Search1 = "S:\XI-Online\!-Other Products\Sublimation\": Search2 = Left(BaseName, 3) & "*?*": GoTo Find
If i = 2 Then Search1 = "S:\XI-Online\!-Other Products\Laser\": Search2 = Left(BaseName, 3) & "*?*": GoTo Find
If i = 3 Then Search1 = "S:\XI-Online\!-Other Products\ESC": Search2 = Left(BaseName, 3) & "*?*": GoTo Find
If i = 4 Then Search1 = "S:\XI-Online\!-Other Products\!!!Headquarters - DTG product Folders": Search2 = Left(BaseName, 3) & "*?*": GoTo Find
If i = 5 Then Search1 = "S:\XI-Online\!-Other Products\": Search2 = Left(BaseName, 3) & "*?*": GoTo Find

Find:
ProdFldr = CorelScriptTools.FindFirstFolder(Search1 & Search2, 16 Or 128)
If ProdFldr <> "" Then
    Set CrFldr = fso.GetFolder(Search1 & ProdFldr)
    ProdFldr = Search1 & fso.GetFileName(CrFldr)
    Exit Function
End If
Next i

ProdFldr = "Not Found"
End Function
Function optFind() As String
If frmExpAndPub.optJPEG = True Then
    optFind = "jpg"
Else
    optFind = "png"
End If
End Function


Sub EPGoCZ(allDocs As Boolean)
On Error GoTo ErrHndlr
Dim s As Shape, sr As ShapeRange, br As New ShapeRange, doc As Document, czlayer As Layer
Dim dCount As Integer, d As Integer, suff As String

With frmExpAndPub
    If Right(.ExportPathCZ, 1) <> "\" Then .ExportPathCZ = .ExportPathCZ & "\"
    If Right(.FixedPath, 1) <> "\" Then .FixedPath = .FixedPath & "\"
    If .cbUseFixed = True Then
        bFixedExport = True
    Else
        bFixedExport = False
    End If
    If allDocs = True Then
        dCount = Documents.Count
    Else
        dCount = 1
        Set doc = ActiveDocument
    End If
    
    For d = 1 To dCount
    .Repaint
    If allDocs Then Set doc = Documents(d)
    
        For p = 1 To doc.pages.Count
            For ly = 1 To doc.pages(p).Layers.Count
                If doc.pages(p).Layers(ly).Name = "Custom Text" Then Set czlayer = doc.pages(p).Layers(ly): Exit For
            Next ly
        Next p
        
        If Not czlayer Is Nothing Then
            Set sr = czlayer.FindShapes(Type:=cdrTextShape, recursive:=False)
            
            If sr.Count = 0 Then
                MsgBox "No Custom Text objects found in " & doc.Title
                GoTo Skip
            End If
        Else
            MsgBox "No Custom Text layer found in " & doc.Title
            GoTo Skip
        End If
        
        sr.Copy
        If .cbSample = True Then
        'Sample - Export pics like normal
            suff = "-sample"
            ExportCZ doc, optFindCZ, suff: .ProgBox.TopIndex = .ProgBox.ListCount - 1
        End If
        
        If .cbText = True Then
        'Text - Change text.story to "text"
            For Each s In sr
                s.Text.Story = "TEXT"
            Next s
            
            suff = "-text"
            ExportCZ doc, optFindCZ, suff: .ProgBox.TopIndex = .ProgBox.ListCount - 1
        End If
        
        If .cbCoords = True Then
        'Coord - Create bound boxes
            For Each s In sr
                br.Add CreatePSBound(s, doc, czlayer)
            Next s
            
            suff = "-coords"
            ExportCZ doc, optFindCZ, suff: .ProgBox.TopIndex = .ProgBox.ListCount - 1
            br.Delete
        End If
        
        If .cbBlank = True Then
        'Blank - Make text invisible
            For Each s In sr
                s.Fill.ApplyNoFill
                s.Outline.SetNoOutline
            Next s
            
            suff = "-blank"
            ExportCZ doc, optFindCZ, suff: .ProgBox.TopIndex = .ProgBox.ListCount - 1
            'czLayer.Printable = True
        End If
        sr.Delete
        czlayer.Paste
        doc.Dirty = False

Skip:
    Next d
    
    If .ProgBox.ListCount <> 0 Then
        .btnOpenPicFldr.Caption = "Open Pic Folder [Custom]"
        .btnOpenPubFldr.Enabled = False
        If Len(Time) = 11 Then
            AddBoxItem "                       - Finished " & Left(Time, 8) & " -"
        Else
            AddBoxItem "                        - Finished " & Left(Time, 7) & " -"
        End If
    Else
        .EPMultiPage.Value = 1
    End If
End With

Exit Sub

ErrHndlr:
If Left(Err.Description, 21) = "Method 'ExportBitmap'" Then
    Resume Next
ElseIf Left(Err.Description, 11) = "Layer 'SKU'" Then
    MsgBox "Layer 'SKU' not found in " & Documents(d).Title
    GoTo Skip
ElseIf Left(Err.Description, 12) = "File already" Then
    Resume Next
Else
    MsgBox Err.Description
End If
End Sub
Sub ExportCZ(exDoc As Document, exType As String, czSuff As String)
Dim Dropdown As String, BaseName As String, path As String, cSuff As String
Set fso = New FileSystemObject

BaseName = fso.GetBaseName(exDoc)
Dropdown = frmExpAndPub.ExportDropCZ
ExportPath = frmExpAndPub.ExportPathCZ
FixedPath = frmExpAndPub.FixedPath
cSuff = frmExpAndPub.PicSuffBoxCZ.Text: If cSuff <> "" And Left(cSuff, 1) <> "-" Then cSuff = "-" & cSuff

If bFixedExport = True Then
    F = 2
Else
    F = 1
End If

If Dropdown = "First" Then
    exDoc.pages.First.Activate
ElseIf Dropdown = "Last" Then
    exDoc.pages.Last.Activate
End If

For i = 1 To F
If i = 2 Then ExportPath = FixedPath
If exType = "png" Then
    path = ExportPath & BaseName & czSuff & cSuff & ".png"
    Set ExportFilter = exDoc.ExportBitmap(path, cdrPNG, cdrCurrentPage, cdrRGBColorImage, 0, 0, 300, 300, cdrNormalAntiAliasing, False, True, True, False, cdrCompressionNone)
        With ExportFilter
            .Interlaced = True
            .Transparency = 0 ' FilterPNGLib.pngNone
            .InvertMask = False '     ^^ This comment added by recording export as png??
            .Color = 0
            .Finish
        End With
    AddBoxItem BaseName & czSuff & cSuff & ".png" & " Exported"
Else
    path = ExportPath & BaseName & czSuff & cSuff & ".jpg"
    Set ExportFilter = exDoc.ExportBitmap(path, cdrJPEG, cdrCurrentPage, cdrRGBColorImage, 0, 0, 300, 300, cdrNormalAntiAliasing, False, False, True, False, cdrCompressionNone)
        With ExportFilter
            .Progressive = False
            .Optimized = False
            .SubFormat = 0
            .Compression = 10
            .Smoothing = 10
            .Finish
        End With
    AddBoxItem BaseName & czSuff & cSuff & ".jpg" & " Exported"
End If
Next i

Set fso = Nothing
End Sub
Function CreatePSBound(cs As Shape, cdoc As Document, cl As Layer) As Shape
Dim s As Shape, nr As New ShapeRange, ogTxt As String, txtBool As Boolean
Dim x#, y#, w#, h#

Dim cy As New Color, mg As New Color
cy.RGBAssign 0, 255, 255
mg.RGBAssign 255, 0, 255

ActiveDocument.BeginCommandGroup
    If cs.Type = cdrTextShape Then
        ogTxt = cs.Text.Story
        cs.Text.Story = "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
        txtBool = True
    End If
    
    cs.GetBoundingBox x, y, w, h
    Set s = cl.CreateRectangle2(x, y, w, h)
        s.Fill.UniformColor.CopyAssign mg
        s.Outline.SetNoOutline
        nr.Add s
    w = w / 2
    h = h / 2
    Set s = cl.CreateRectangle2(x, y, w, h)
        s.Fill.UniformColor.CopyAssign cy
        s.Outline.SetNoOutline
        nr.Add s
    Set s = cl.CreateRectangle2(x + w, y + h, w, h)
        s.Fill.UniformColor.CopyAssign cy
        s.Outline.SetNoOutline
        nr.Add s
        
    'ActiveDocument.ClearSelection
    'cl.Activate
    nr.AddToSelection
    Set CreatePSBound = nr.Group
        CreatePSBound.Name = "PS Coords Box"
        's.AddToSelection
    
    If txtBool = True Then
        cs.Text.Story = ogTxt
    End If
ActiveDocument.EndCommandGroup
End Function
Sub AddSelCZ()
Dim s As Shape, sr As ShapeRange, czlayer As Layer

Set sr = ActiveSelectionRange.Shapes.FindShapes(Type:=cdrTextShape, recursive:=False)
If sr.Count = 0 Then
    MsgBox "No text in selection": Exit Sub
End If

For i = 1 To ActivePage.Layers.Count
    If ActivePage.Layers(i).Name = "Custom Text" Then Set czlayer = ActivePage.Layers(i): Exit For
Next i

ActiveDocument.BeginCommandGroup
    If czlayer Is Nothing Then
        'MsgBox "Custom Text layer not found. Creating."
        Set czlayer = ActivePage.CreateLayer("Custom Text")
    End If
    
    For i = 1 To sr.Count
        sr.Shapes(i).MoveToLayer czlayer
    Next i
    
    ShowCZText
ActiveDocument.EndCommandGroup
End Sub
Sub ShowCZText()
Dim s As Shape, sr As ShapeRange, czlayer As Layer

With frmExpAndPub
    .CZBox.Clear

    For i = 1 To ActivePage.Layers.Count
        If ActivePage.Layers(i).Name = "Custom Text" Then Set czlayer = ActivePage.Layers(i): Exit For
    Next i
    
    If Not czlayer Is Nothing Then
        Set sr = czlayer.FindShapes(Type:=cdrTextShape, recursive:=False)
        
        If sr.Count > 0 Then
            For Each s In sr
                .CZBox.AddItem s.Text.Story
            Next s
        End If
    End If
End With
End Sub
Function StartCheckCZ() As Boolean
StartCheckCZ = False

With frmExpAndPub
    If Documents.Count = 0 Then MsgBox "No open documents": Exit Function
    
    If .cbSample = False And .cbText = False And .cbBlank = False And .cbCoords = False Then MsgBox "Select custom pic type(s) to export": Exit Function
    
    If .ExportPathCZ = "" Then MsgBox "Choose Custom Pic Location": Exit Function
    If .cbUseFixed = True And .FixedPath = "" Then MsgBox "Choose Fixed Export Location": Exit Function
    
    If Dir(.ExportPathCZ, vbDirectory) = "" Then MsgBox "Pic location does not exist": Exit Function
    If .cbUseFixed = True And Dir(.FixedPath, vbDirectory) = "" Then MsgBox "Fixed Export location does not exist": Exit Function
        
        StartCheckCZ = True
        .EPMultiPage.Value = 3
End With
End Function
Function optFindCZ() As String
If frmExpAndPub.optJPEGCZ = True Then
    optFindCZ = "jpg"
Else
    optFindCZ = "png"
End If
End Function


















