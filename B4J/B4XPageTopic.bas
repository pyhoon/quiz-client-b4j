B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	#If B4i
	Dim hud As HUD
	#End If
	#If B4J
	Dim clx As clXToastMessage1
	Private fx As JFX	
	#End If	
	Private CLV As CustomListView
	Private LblTopic As Label
	Private LblShortDesc As Label
	Private LblResult As Label	
	#If B4J
	Private PnlTopic As Pane	
	#Else
	Private PnlTopic As Panel
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
	Root.LoadLayout("TopicPage")
	#If B4J
	' Handle B4J unable to draw gradient to xCustomListView
	CallSubDelayed3(Me, "SetScrollPaneBackgroundColor", CLV, xui.Color_Transparent)
	#End If
	#If B4A
	'B4XPages.SetTitle(Me, "Topic")
	B4XPages.AddMenuItem(Me, "Logout")	
	#End If
End Sub

#If B4J
Private Sub SetScrollPaneBackgroundColor(View As CustomListView, Color As Int)
	Dim SP As JavaObject = View.GetBase.GetView(0)
	Dim V As B4XView = SP
	V.Color = Color
	Dim V As B4XView = SP.RunMethod("lookup", Array(".viewport"))
	V.Color = Color
End Sub
#End If

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

Private Sub B4XPage_Appear
	LoadTopics
End Sub

Sub B4XPage_MenuClick (Tag As String)
	If Tag = "Logout" Then
		Logout		
	End If
	#If B4J
	If Tag = "Close" Then
		B4XPages.ClosePage(Me)
	End If	
	#End If
End Sub

#if B4J
'Delegate the native menu action to B4XPage_MenuClick.
Sub MenuBar1_Action
	Dim mi As MenuItem = Sender
	Dim t As String
	If mi.Tag = Null Then t = mi.Text.Replace("_", "") Else t = mi.Tag
	B4XPage_MenuClick(t)
End Sub
#End If

Sub CLV_ItemClick (Index As Int, Value As Object)
	Main.TopicID = Value		
	#If B4A or B4i
		B4XPages.ShowPage("Question")	
	#Else If B4J
		B4XPages.ShowPageAndRemovePreviousPages("Question")	
	#End If	
End Sub

Public Sub Logout
	'Log("Logout")
	Dim data As LoginData
	data.Initialize
	Wait For (data.DeleteLogin) Complete (Success As Boolean)
	'Log(data.DeleteLogin)
	'Log(Success)
	Main.UID = ""
	Main.PWD = ""
	#If B4A
		B4XPages.ClosePage(Me)
		StartActivity(Main)
	#Else
		#If B4i
		Main.NavControl.NavigationBarVisible = False
		#End If		
		B4XPages.ShowPageAndRemovePreviousPages("Login")
	#End If
End Sub

Sub LoadTopics
	Dim parser As JSONParser
	Dim Job As HttpJob
	Dim List1 As List
	Dim Map1 As Map
	Dim strError As String
	Dim strData As String
	Try
		'CommonUtility.LogMsg("[B4XPageTopic] LoadTopics")		
		#If B4J
		Private jo As JavaObject = Root
		jo.RunMethod("setCursor", Array(fx.Cursors.WAIT))
		#Else
		CommonUtility.ShowProgressDialog("Connecting to server...")
		#End If
		Job.Initialize("", Me)
		Dim param As Map = CreateMap("uid": Main.UID, "pwd": Main.PWD)
		Dim json As String
		Dim jgen As JSONGenerator
		jgen.Initialize(param)
		json = jgen.ToString
		Job.PostString(Main.strURL & "results/get", json)
		Wait For (Job) JobDone(Job As HttpJob)			
		#If B4J
		jo.RunMethod("setCursor", Array(fx.Cursors.DEFAULT))
		#Else
		CommonUtility.HideProgressDialog
		#End If		
		If Job.Success Then
			strData = Job.GetString
			parser.Initialize(strData)
			Dim Map1 As Map = parser.NextObject			
			If "success" <> Map1.Get("s") Then
				ShowToastMessage(Map1.Get("e"), False)				
				Return
			End If
			Dim List1 As List = Map1.Get("r")
			'Log(List1)
			CLV.Clear
			For i = 0 To List1.Size - 1
				Dim Map2 As Map = List1.Get(i)
				CLV.Add(CreateTopic(CLV.AsView.Width, Map2.Get("topic"), Map2.Get("shortdesc"), Map2.Get("score")), Map2.Get("id"))
			Next
		Else
			strError = Job.ErrorMessage
			Job.Release
			Log(strError)
			ShowConnectionError(strError)
		End If
	Catch
		Job.Release
		CommonUtility.LogErr("[B4XPageTopic] LoadTopics: " & LastException.Message)
		ShowToastMessage("Failed to download data", False)
	End Try
End Sub

#If B4J
Private Sub CreateTopic(Width As Int, Topic As String, ShortDesc As String, Result As String) As Pane
#Else
Private Sub CreateTopic(Width As Int, Topic As String, ShortDesc As String, Result As String) As Panel
#End If
	Dim p As B4XView = xui.CreatePanel("")
	Dim Height As Int = 100dip
	'If GetDeviceLayoutValues.ApproximateScreenSize < 4.5 Then Height = 350dip
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	#If B4J
	p.Color = xui.Color_Transparent
	#End If	
	p.LoadLayout("TopicItem")
	#If B4A
	LblTopic.TextSize = 20
	#End If	
	LblTopic.Text = Topic
	LblShortDesc.Text = ShortDesc
	LblResult.Text = Result
	Return p
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