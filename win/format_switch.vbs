#$language = "VBScript"
#$interface = "1.0"

' This automatically generated script may need to be
' edited in order to work correctly.

crt.sleep 1000
crt.Window.Show 0


g_delay=2000

' protect the command sync with user input
Sub Cmd(obj, str)
	Dim szOutput
	
	
	obj.Screen.Synchronous = True
	

	obj.Screen.Send str & vbCr
	crt.Sleep g_delay
	
	szOutput=obj.Screen.ReadString ("R:\> ", "Invalid", g_delay)
	
	
	Select Case obj.Screen.MatchIndex
	Case 0 'timeout
		obj.Screen.WaitForStrings "R:\> "
		

	Case 1
	
	Case else
		' to break the command
		obj.screen.sendkeys("" & vbCr)
		obj.Screen.WaitForStrings "R:\> "
	
		
		Call Cmd (obj, str)
	
	End Select
	
	
	obj.Screen.Synchronous = False

End Sub

Sub Cmd_980(obj, str)
	Dim szOutput
	
	
	obj.Screen.Synchronous = True
	

	obj.Screen.Send str & vbCr
	crt.Sleep g_delay
	
	szOutput=obj.Screen.ReadString ("scope>", "Password:", "Invalid", g_delay)
	
	
	Select Case obj.Screen.MatchIndex
	Case 0 'timeout
		obj.Screen.WaitForStrings "scope>"

	Case 1
	
	REM username
	Case 2
		obj.screen.sendkeys("qd" & vbCr)
		obj.Screen.WaitForStrings "scope>"

	Case else
		' to break the command
		obj.screen.sendkeys("" & vbCr)
		obj.Screen.WaitForStrings "scope>"
	
		Call Cmd_980 (obj, str)
	
	End Select
	
	
	obj.Screen.Synchronous = False

End Sub



Sub Main
	

	Dim logfile
	Dim source, port, device, mode
	
	logfile = "" & crt.Arguments(0)
	source = "" & crt.Arguments(1)
	port = "" & crt.Arguments(2)
	device = "" & crt.Arguments(3)
	mode = "" & crt.Arguments(4)
	
	Select Case device
	case "980"
	
		Set tab_com = crt.session.ConnectInTab("/TELNET " & port &"")
		
		tab_com.Activate
		
		tab_com.Session.LogFileName = logfile
		tab_com.Session.Log True
		
		REM username
		tab_com.Screen.WaitForStrings "login:"
		Call Cmd_980(tab_com, "qd")

		Select Case source
		case "HDMI"
			Call Cmd_980(tab_com, "out10:xvsi 4")
			Call Cmd_980(tab_com, "out10:xvsi?")
		End Select 
		
		Call Cmd_980(tab_com, "out10:fmtl " & mode)
		crt.sleep 1000
		Call Cmd_980(tab_com, "out10:imgl smptebar")
		crt.sleep 1000
		Call Cmd_980(tab_com, "out10:imgu")
		crt.sleep 1000
		Call Cmd_980(tab_com, "out10:imgu?")
		crt.sleep 1000
		Call Cmd_980(tab_com, "out10:fmtu")
		crt.sleep 1000
		Call Cmd_980(tab_com, "out10:fmtu?")
		crt.sleep 1000
		
		Call Cmd_980(tab_com, "")
		tab_com.Session.Log False
		tab_com.Session.Disconnect
		
		
	case Else 
	REM "780"
	REM "804"
		Set tab_com = crt.session.ConnectInTab("/SERIAL " & port & " /BAUD 115200 /DATA 8")
		
		tab_com.Activate
		
		tab_com.Session.LogFileName = logfile
		tab_com.Session.Log True
		
		Call Cmd(tab_com, "")
		
		Select Case source
		case "HDMI"
			Call Cmd(tab_com, "xvsi 4")
			Call Cmd(tab_com, "xvsi?")
		End Select 
		
		Call Cmd(tab_com, "fmtl " & mode )
		crt.sleep 1000
		Call Cmd(tab_com, "imgl smptebar")
		crt.sleep 1000
		Call Cmd(tab_com, "imgu")
		crt.sleep 1000
		Call Cmd(tab_com, "imgu?")
		crt.sleep 1000
		Call Cmd(tab_com, "fmtu")
		crt.sleep 1000
		Call Cmd(tab_com, "fmtu?")
		crt.sleep 1000
		
		Call Cmd(tab_com, "")
		tab_com.Session.Log False
		tab_com.Session.Disconnect
	End Select 
	
	
	
	
	crt.Quit
End Sub


