B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	#If B4i
	Dim hud As HUD
	Private xui As XUI 'ignore
	#End If
	#If B4J
	Private fx As JFX
	Private clx As clXToastMessage1
	#End If		
	Private txtUserName As B4XFloatTextField
	Private txtPassword As B4XFloatTextField
	Private BtnLogin As Button
	Private BtnRegister As Button
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	#If B4J
	clx.Initialize(Root)
	#End If
	Root.LoadLayout("LoginPage")	
End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.
Sub Register
	Dim parser As JSONParser
	Dim Job As HttpJob
	Dim List1 As List
	Dim Map1 As Map
	Dim strError As String
	Dim strData As String
	Try
		CommonUtility.LogMsg("[Main] Register")
		CommonUtility.ShowProgressDialog("Connecting to server...")
		Job.Initialize("", Me)
		Dim param As Map = CreateMap("uid": txtUserName.Text.Trim, "pwd": txtPassword.Text.Trim)
		Dim json As String
		Dim jgen As JSONGenerator
		jgen.Initialize(param)
		json = jgen.ToString
		Job.PostString(Main.strURL & "register", json)
		Wait For (Job) JobDone(Job As HttpJob)
		CommonUtility.HideProgressDialog
		If Job.Success Then
			strData = Job.GetString
			parser.Initialize(strData)
			Dim Map1 As Map = parser.NextObject
			If "success" <> Map1.Get("s") Then
				ShowToastMessage(Map1.Get("e"), False)
				Return
			End If
			Dim List1 As List = Map1.Get("r")
			Log(List1.Get(0))
			Dim Map2 As Map = List1.Get(0)
			Log(Map2) 'ignore
			If 1 = Map2.Get("register") Then
				ShowToastMessage("User successfully registered!", False)
			End If			
		Else
			strError = Job.ErrorMessage
			Job.Release
			CommonUtility.LogErr(strError)
			ShowConnectionError(strError)
		End If
	Catch
		Job.Release
		CommonUtility.LogErr("[Main] Register: " & LastException.Message)
		ShowToastMessage("Failed to download data", False)
	End Try
End Sub

Sub Login
	Dim parser As JSONParser
	Dim Job As HttpJob
	Dim List1 As List
	Dim Map1 As Map
	Dim strError As String
	Dim strData As String
	Try
		CommonUtility.LogMsg("[Main] Login")
		CommonUtility.ShowProgressDialog("Connecting to server...")
		Job.Initialize("", Me)
		Dim param As Map = CreateMap("uid": txtUserName.Text.Trim, "pwd": txtPassword.Text.Trim)
		Dim json As String
		Dim jgen As JSONGenerator
		jgen.Initialize(param)
		json = jgen.ToString
		Job.PostString(Main.strURL & "login", json)
		Wait For (Job) JobDone(Job As HttpJob)
		CommonUtility.HideProgressDialog
		If Job.Success Then
			strData = Job.GetString
			Log(strData)
			parser.Initialize(strData)
			Dim Map1 As Map = parser.NextObject
			If "success" <> Map1.Get("s") Then
				CommonUtility.LogMsg(Map1.Get("e"))
				If "Error-User-Denied" = Map1.Get("e") Then
					ShowToastMessage("Wrong User Name or Password", False)
				End If
				Return
			End If
			Dim List1 As List = Map1.Get("r")
			Log(List1.Get(0))
			Main.UID = txtUserName.Text.Trim
			Main.PWD = txtPassword.Text.Trim

			Dim MapUser As Map = CreateMap("MapUser": CreateMap("UID": Main.UID, "PWD": Main.PWD))
			Log(MapUser) 'ignore
			Dim data As LoginData
			data.Initialize
			Wait For (data.SaveLogin(MapUser)) Complete (Success As Boolean)
			Log(Success)
			#If B4i
			Main.NavControl.NavigationBarVisible = True
			#End If			
			B4XPages.ShowPageAndRemovePreviousPages("Topic")
		Else
			strError = Job.ErrorMessage
			Job.Release
			Log(strError)
			ShowConnectionError(strError)
		End If
	Catch
		Job.Release
		CommonUtility.LogErr("[Main] Login: " & LastException.Message)
		ShowToastMessage("Failed to download data", False)
	End Try
End Sub

Sub BtnRegister_Click
	If txtUserName.Text.Trim = "" Then
		ShowToastMessage("Please enter User Name", False)
		Return
	End If
	If txtPassword.Text.Trim = "" Then
		ShowToastMessage("Please enter Password", False)
		Return
	End If
	Register
End Sub

Sub BtnLogin_Click
	If txtUserName.Text.Trim = "" Then
		ShowToastMessage("Please enter User Name", False)
		'txtUserName.TextField.RequestFocus
		Return
	End If
	If txtPassword.Text.Trim = "" Then
		ShowToastMessage("Please enter Password", False)
		txtPassword.TextField.RequestFocus
		Return
	End If
	Login
End Sub

Sub txtUserName_TextChanged (Old As String, New As String)
	BtnLogin.Enabled = New.Length > 0
	BtnRegister.Enabled = New.Length > 0
End Sub

Sub txtUserName_EnterPressed
	txtPassword.RequestFocusAndShowKeyboard	
End Sub

Sub txtPassword_EnterPressed
	'If BtnLogin.Enabled Then BtnLogin_Click
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
	#End If
	#If B4i
	hud.ToastMessageShow(Message, LongDuration)
	#End If
	#If B4J
	clx.Show(Message, LongDuration)
	#End If
End Sub