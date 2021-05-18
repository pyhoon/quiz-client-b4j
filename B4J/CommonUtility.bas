B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	#If B4i
	Dim hud As HUD
	#End If
	#If B4J
	Public Root As B4XView
	Public fx As JFX
	#End If	
End Sub

Sub ShowProgressDialog(Message As String)
	#If B4A
	ProgressDialogShow(Message)
	#Else If B4i
	hud.ProgressDialogShow(Message)
	#Else If B4J
	Log(Message)
	#End If
End Sub

Sub HideProgressDialog
	#If B4A
	ProgressDialogHide
	#Else If B4i
	hud.ProgressDialogHide
	#Else If B4J

	#End If
End Sub

Sub LogMsg(Message As String)
	#If B4A
	LogColor(Message, Colors.Blue)
	#Else
	Log(Message)
	#End If	
End Sub

Sub LogErr(Message As String)
	#If B4A
	LogColor(Message, Colors.Red)
	#Else
	Log(Message)
	#End If	
End Sub