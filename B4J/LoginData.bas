B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Dim xui As XUI
	Dim KVS As KeyValueStore
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	xui.SetDataFolder("KVS")
	KVS.Initialize(xui.DefaultFolder, "kvs.dat")
End Sub

Sub SaveLogin(MapUser As Map) As ResumableSub
	Wait For (KVS.PutMapAsync(MapUser)) Complete (Success As Boolean)
	Return Success
End Sub

Sub LoadLogin As ResumableSub
	Wait For (KVS.GetMapAsync(Array("MapUser"))) Complete (MapUser As Map)
	Return MapUser
End Sub

Sub DeleteLogin As ResumableSub	
	KVS.Remove("MapUser")
	Sleep(0)
	Return True
End Sub