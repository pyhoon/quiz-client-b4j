B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
'#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals	
	#If B4i or B4J
	Private Root As B4XView
	Private B4XGifView1 As B4XGifView
	Public PageLogin As B4XPageLogin
	Public PageTopic As B4XPageTopic
	Public PageQuestion As B4XPageQuestion
	#End If
End Sub

Public Sub Initialize
	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	#If B4i or B4J
	Root = Root1
	Wait For (ShowSplashScreen) Complete (Unused As Boolean)
	PageLogin.Initialize
	B4XPages.AddPage("Login", PageLogin)
	PageTopic.Initialize
	B4XPages.AddPage("Topic", PageTopic)
	PageQuestion.Initialize
	B4XPages.AddPage("Question", PageQuestion)
	If Main.UID <> "" And Main.PWD <> "" Then
		#If B4i
		Main.NavControl.NavigationBarVisible = True
		#End If		
		B4XPages.ShowPageAndRemovePreviousPages("Topic")
	Else
		#If B4i
		Main.NavControl.NavigationBarVisible = False
		#End If		
		B4XPages.ShowPageAndRemovePreviousPages("Login")
	End If
	#End If
End Sub

Private Sub B4XPage_Appear
	#If B4i or B4J
	CheckLogin
	#End If
End Sub

#If B4i or B4J
Sub ShowSplashScreen As ResumableSub
	#If B4i
	Main.NavControl.NavigationBarVisible = False
	#End If	
	Root.LoadLayout("Splash")
	B4XPages.SetTitle(Me, "B4JQuiz")
	B4XGifView1.SetGif(File.DirAssets, "loading.gif")
	Sleep(3000)
	Root.RemoveAllViews
	Return True
End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.
Public Sub CheckLogin
	Dim data As LoginData
	data.Initialize
	Wait For (data.LoadLogin) Complete (MapUser As Map)	
	Log(MapUser) 'ignore	
	If MapUser.IsInitialized Then		
		If MapUser.ContainsKey("MapUser") Then
			Dim User As Map = MapUser.Get("MapUser")
			If User.IsInitialized Then
				If User.ContainsKey("UID") Then
					Main.UID = User.Get("UID")
				End If
				If User.ContainsKey("PWD") Then
					Main.PWD = User.Get("PWD")
				End If
				Log(Main.UID & "|" & Main.PWD)
			End If
		End If
	End If
End Sub
#End If