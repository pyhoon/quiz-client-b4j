B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Public CLV As CustomListView
	Private lblQuestion As Label
	Private BtnNext As Button
	Private BtnSubmit As Button	
	Dim QuestionList As List
	Dim AnswerList As List
	Dim Current As Int
	Dim Total As Int
	Dim Selected As Map
	'Public TopicID As Int
	Dim QuestionID As Int
	Dim AnswerID As Int
	#If B4i
	Private Button1 As Button
	Private Label1 As Label
	Dim hud As HUD
	#End If
	#If B4J
	Private Radio1 As RadioButton
	Private Label1 As Label
	Dim clx As clXToastMessage1
	Private fx As JFX
	#End If	
End Sub

'You can add more parameters here.
Public Sub Initialize
	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	#If B4J
	clx.Initialize(Root)
	#End If
	Root.LoadLayout("QuestionPage")
	#if B4J
	CallSubDelayed3(Me, "SetScrollPaneBackgroundColor", CLV, xui.Color_Transparent)
	#End If
	'B4XPages.AddMenuItem(Me, "Logout")
	BtnNext.Visible = False
	Selected.Initialize	
End Sub

Private Sub B4XPage_Appear
	CLV.Clear
	Selected.Clear
	'Log(Main.TopicID)
	If Main.TopicID > 0 Then
		LoadQuestions(Main.TopicID)
	Else
		Log("Invalid TopicID: " & Main.TopicID)
		'B4XPages.ClosePage(Me)
	End If
End Sub

Private Sub B4XPage_Disappear
	#If B4A
	'Log("B4XPageQuestion Disappear")
	#Else
	B4XPages.ShowPage("Topic")
	#End If
End Sub

#If B4j
Private Sub SetScrollPaneBackgroundColor(View As CustomListView, Color As Int)
	Dim SP As JavaObject = View.GetBase.GetView(0)
	Dim V As B4XView = SP
	V.Color = Color
	Dim V As B4XView = SP.RunMethod("lookup", Array(".viewport"))
	V.Color = Color
End Sub
#End If

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

Sub BtnSubmit_Click
	Selected.Put(QuestionID, AnswerID)
	'Log(Selected) 'ignore
	SubmitAnswer
End Sub

Sub BtnNext_Click
	' Store selected answers
	Selected.Put(QuestionID, AnswerID)
	If Current < Total - 1 Then
		Current = Current + 1
		ShowButtonsAndInfo
	End If
	GenerateAnswers
End Sub

Sub CLV_ItemClick (Index As Int, Value As Object)
'	If Index > 0 Then
'		Log(Value)
'	End If
End Sub

#If B4i
Sub Button1_Click
	Dim Index As Int = CLV.GetItemFromView(Sender)
	'Log("Selected=" & Index & " Value=" & CLV.GetValue(Index))
	For Each v As B4XView In CLV.AsView.GetAllViewsRecursive
		If v Is Button Then
			'Log("v.Tag=" & v.Tag & " | Sel.Tag=" & Sel.Tag & " | Sel=" & Sel)
			If v.Tag <> CLV.GetValue(Index) Then
				v.Text = Chr(0xE836)
			Else
				v.Text = Chr(0xE837)
			End If
		End If
	Next
	AnswerID = CLV.GetValue(Index)
End Sub
#Else
Sub Radio1_Click
	Dim Index As Int = CLV.GetItemFromView(Sender)
	Dim pnl As B4XView = CLV.GetPanel(Index) 	' ListItem
	Dim Sel As B4XView = pnl.GetView(1)		' Radio1 (clicked)
	'Log("Selected=" & Index & " Value=" & CLV.GetValue(Index))
	For Each v As B4XView In CLV.AsView.GetAllViewsRecursive
		'Log("v.Tag=" & v.Tag & " | Sel.Tag = " & Sel.Tag)
		If v Is RadioButton And v.Tag <> Sel.Tag Then
			v.Checked = False
		End If
	Next
	AnswerID = CLV.GetValue(Index)
End Sub
#End If

'Sub SelectRadio
'	For Each v As B4XView In CLV.AsView.GetAllViewsRecursive
'		If v Is RadioButton Then
'			Dim A As Int
'			Dim B As Int
'			If v.Tag <> Null Then A = v.Tag
'			If Selected.Get(QuestionID) <> Null Then B = Selected.Get(QuestionID)
'			If A = B Then
'				v.Checked = True
'				Exit
'			End If
'		End If
'	Next
'End Sub

Sub SubmitAnswer
	Try
		Dim parser As JSONParser
		Dim Job As HttpJob
		Dim strError As String
		Dim strData As String
		'CommonUtility.LogMsg("[B4XPageQuestion] SubmitAnswer")
		CommonUtility.ShowProgressDialog("Connecting to server...")
		Job.Initialize("", Me)
		Dim param As Map = CreateMap("uid": Main.UID, "pwd": Main.PWD, "topic": Main.TopicID, "submitted": Selected)
		Dim json As String
		Dim jgen As JSONGenerator
		jgen.Initialize(param)
		json = jgen.ToString
		Log(json)
		Job.PostString(Main.strURL & "answers/put", json)
		Wait For (Job) JobDone(Job As HttpJob)
		CommonUtility.HideProgressDialog
		If Job.Success Then
			strData = Job.GetString
			parser.Initialize(strData)
			Dim Map1 As Map = parser.NextObject
			If "success" = Map1.Get("s") Then
				'ShowToastMessage(Map1.Get("s"), False)
				'B4XPages.ShowPageAndRemovePreviousPages("Topic")
				B4XPages.ClosePage(Me)
			Else
				ShowToastMessage(Map1.Get("e"), False)
				Return
			End If
		Else
			strError = Job.ErrorMessage
			Job.Release
			CommonUtility.LogErr(strError)
			ShowConnectionError(strError)
		End If
	Catch
		Job.Release
		CommonUtility.LogErr("[B4XPageQuestion] SubmitAnswer: " & LastException.Message)
		ShowToastMessage("Failed to upload data", False)
	End Try
End Sub

Sub LoadQuestions(Topic As Object)
	Dim parser As JSONParser
	Dim Job As HttpJob
	Dim strError As String
	Dim strData As String
	Try
		'Log("Topic=" & Topic)
		CommonUtility.LogMsg("[B4XPageQuestion] LoadQuestions")
		#If B4J
		Private jo As JavaObject = Root
		jo.RunMethod("setCursor", Array(fx.Cursors.WAIT))
		#Else
		CommonUtility.ShowProgressDialog("Connecting to server...")
		#End If
		Job.Initialize("", Me)
		Job.Download(Main.strURL & "questions/" & Topic)
		Wait For (Job) JobDone(Job As HttpJob)
		#If B4J
		jo.RunMethod("setCursor", Array(fx.Cursors.DEFAULT))
		#Else
		CommonUtility.HideProgressDialog
		#End If	
		If Job.Success Then
			strData = Job.GetString
			parser.Initialize(strData)
			Dim QuestionMap As Map = parser.NextObject
			If "success" <> QuestionMap.Get("s") Then
				ShowToastMessage(QuestionMap.Get("e"), False)
				Return
			End If
			Dim QuestionList As List = QuestionMap.Get("r")
			Current = 0
			Total = QuestionList.Size
			If Total > 0 Then
				ShowButtonsAndInfo
				GenerateAnswers
				AnswerID = 0
			Else
				lblQuestion.Text = "Question not available"
				BtnNext.Visible = False
				BtnSubmit.Visible = False
			End If
		Else
			strError = Job.ErrorMessage
			Job.Release
			Log(strError)
			ShowConnectionError(strError)
		End If
	Catch
		Job.Release
		CommonUtility.LogErr("[B4XPageQuestion] LoadQuestions: " & LastException.Message)
		ShowToastMessage("Failed to download data", False)
	End Try
End Sub

#If B4J
Private Sub CreateAnswer(Width As Int, Content As String, Tag As String) As Pane
#Else
Private Sub CreateAnswer(Width As Int, Content As String, Tag As String) As Panel
#End If
	Dim p As B4XView = xui.CreatePanel("")
	
	#If B4A
	p.Color = xui.Color_Transparent
	#End If
	
	#If B4i
	Dim Height As Int = 80dip
	#End If
	#If B4J
	Dim Height As Int = 80dip
	#End If
	
	#If B4A
	Dim Radio1 As RadioButton
	Radio1.Initialize("Radio1")
	Radio1.Color = Colors.Transparent
	Radio1.TextColor = Colors.White
	Dim Label1 As Label
	Label1.Initialize("")
	Label1.TextSize = 20
		
	Label1.TextColor = Colors.White
	Label1.SingleLine = False
	p.AddView(Label1, 45dip, 5dip, Width - 40dip, Label1.Height)
	p.AddView(Radio1, 5dip, 5dip, 30dip, 30dip)	
	#End If
		
	'#If B4J
	'p.AddView(Label1, 45dip, 5dip, Width, Label1.Height)
	'#End If
		
	'#If B4J
	'Label1.TextColor = Main.fx.Colors.White
	'Label1.WrapText = True
	'Label1.PrefHeight = 30dip
	'Label1.PrefWidth = Width - 40dip
	'#End If
	
	#If B4A
	Dim su As StringUtils
	Label1.Text = Content
	Label1.Height = su.MeasureMultilineTextHeight(Label1, Label1.Text)
	'p.AddView(Label1, 45dip, 5dip, Width - 40dip, Label1.Height)
	p.Height = Label1.Height + 40dip
	Radio1.Tag = Tag
	#End If	
	
	#If B4J
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	p.LoadLayout("AnswerItem")
	Label1.Text = Content
	Radio1.Tag = Tag
	#End If
	
	#If B4i
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	p.LoadLayout("AnswerItem")
	Label1.Text = Content
	Button1.Tag = Tag	
	#End If
	
	Return p
End Sub

Sub ShowButtonsAndInfo
	lblQuestion.Text = "Question " & (Current + 1) & " of " & Total
	If Current = Total - 1 Then
		BtnNext.Visible = False
		BtnSubmit.Visible = True
	Else
		BtnNext.Visible = True
		BtnSubmit.Visible = False
	End If
End Sub

Sub GenerateAnswers
	Dim QuestionMap As Map = QuestionList.Get(Current) ' Current Question
	QuestionID = QuestionMap.Get("qid")
	CLV.Clear
	'CLV.Add(CreateQuestion(CLV.AsView.Width, QuestionMap.Get("question")), -1)
	CLV.AddTextItem(QuestionMap.Get("question") & CRLF & CRLF, -1)
	' List Answers
	Dim AnswerList As List = QuestionMap.Get("answers")
	For i = 0 To AnswerList.Size - 1
		Dim AnswerMap As Map = AnswerList.Get(i)
		CLV.Add(CreateAnswer(CLV.AsView.Width, AnswerMap.Get("answer"), AnswerMap.Get("aid")), AnswerMap.Get("aid"))		
	Next
End Sub

Sub ShowConnectionError(strError As String)
	If strError.Contains("Unable to resolve host") Then
		ShowToastMessage("Connection failed.", False)
	Else If strError.Contains("timeout") Then
		ShowToastMessage("Connection timeout.", False)
	Else
		ShowToastMessage("Error: " & strError, True)
	End If
End Sub

Sub ShowToastMessage(Message As String, LongDuration As Boolean)
	#If B4A
	ToastMessageShow(Message, LongDuration)
	#Else If B4i
	hud.ToastMessageShow(Message, LongDuration)
	#Else
	clx.Show(Message, LongDuration)
	#End If	
End Sub