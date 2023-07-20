5 LET ERROR = ""
10 LET room = ROOMNAME ( )

20 LET count = ROOMCOUNT ( )
25 IF ( ERROR = "" AND count < 5 ) THEN GOTO 2100

30 LET name = ROOMGETNAME ( 0 )
40 IF ( ERROR = "" AND name != "room001" ) THEN GOTO 3000

45 REM room 999 doesnt exists
50 LET name = ROOMGETNAME ( 999 )
60 IF ( ERROR = "" AND name != "" ) THEN GOTO 4000 

1000 CLS
1010 LET idx = 0
1020 LETS name , desc = ROOMGET ( idx )
1040 PRINT 0 , idx , "#" + STR ( idx ) + " " + name + "-" + desc , 0 , 0
1050 IF ( idx >= count - 1 ) THEN GOTO 10020
1060 LET idx = idx + 1
1070 GOTO 1020

2100 REM ERROR room count
2120 LET ERROR = "ROOMCOUNT, count: " + STR ( count )
2140 GOTO 10000

3000 REM ERROR room name
3010 LET ERROR = "ROOMGETNAME: " + name
3020 GOTO 10000

4000 REM ERROR room name 999
4010 LET ERROR = "ROOMGETNAME 999"
4020 GOTO 10000

10000 CLS
10010 PRINT 0 , 0 , ERROR , 1

10020 SHOW
10030 PRINT 0 , 24 , "PRESS B to end", 1
10040 LET status = CONTROLACTIVE ( "JOYPAD_B" )
10050 IF ( status != 1 ) THEN GOTO 10030
10060 END
