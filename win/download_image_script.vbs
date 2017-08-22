#$language = "VBScript"
#$interface = "1.0"



' This automatically generated script may need to be
' edited in order to work correctly.

g_delay=2000

Sub Cmd(obj, str)
	Dim szOutput
	
	
	obj.Screen.Synchronous = True
	

	obj.Screen.Send str & vbCr
	crt.Sleep g_delay
	
	szOutput=obj.Screen.ReadString ("$ ", ": not found", g_delay)
	
	Select Case obj.Screen.MatchIndex
	Case 0 'timeout
		obj.Screen.WaitForStrings "$ "
	Case 1
	
	Case else
		' to break the command
		obj.screen.sendkeys("^c")
		obj.Screen.WaitForStrings "$ "
		
		Call Cmd (obj, str)
	
	End Select
	
	
	obj.Screen.Synchronous = False

End Sub

Sub Main
	Dim ssh2_ip, ssh2_name, ssh2_passwd
	Dim logfile
	Dim build_num, device_ip, flash_image, branch_id
	
	ssh2_ip		="10.86.9.167"
	ssh2_name	="qa"
	ssh2_passwd	="qa"
	
	logfile = "" & crt.Arguments(0)
	build_num="" & crt.Arguments(1)
	device_ip="" & crt.Arguments(2)
	flash_image="" & crt.Arguments(3)
	'"P111-OTA"
	branch_id="" & crt.Arguments(4)
	'"101"
	
	
	Set tab_ssh2 = crt.session.ConnectInTab("/SSH2 /PASSWORD " & ssh2_passwd & " " & ssh2_name & "@" & ssh2_ip &"")
	
	tab_ssh2.Activate
	
	'define the logging file
	tab_ssh2.Session.LogFileName = logfile
	tab_ssh2.Session.Log True 
	
	tab_ssh2.Screen.Synchronous = False
	
	crt.Sleep g_delay
	
	Call Cmd(tab_ssh2, "")
	
	' get start date
	Call Cmd(tab_ssh2, "date")
	
	' clear the image download folder
	Call Cmd(tab_ssh2, "rm ./" & flash_image & "/*" & build_num & "*")
	
	' set the environment
	Call Cmd(tab_ssh2, "export TV_IP=" & device_ip & "")
	
	' download the image
	Call Cmd(tab_ssh2, "" & flash_image & ".sh " & branch_id & " " & build_num & "")
	
	' get end date
	Call Cmd(tab_ssh2, "date")
	
	Call Cmd(tab_ssh2, "")
	
	tab_ssh2.Session.Log False
	
	tab_ssh2.Session.Disconnect
	
	
	crt.Quit
	
End Sub


