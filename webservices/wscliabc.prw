#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://192.168.1.60:8080/ws1601/WSINTGMV.apw?WSDL
Gerado em        04/22/14 13:56:27
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _KVZRLDQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSINTGMV
------------------------------------------------------------------------------- */

WSCLIENT WSWSINTGMV

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD INTEGRMV

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cMSGXML                   AS string
	WSDATA   cINTEGRMVRESULT           AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSINTGMV
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.121227P-20131106] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSINTGMV
Return

WSMETHOD RESET WSCLIENT WSWSINTGMV
	::cMSGXML            := NIL 
	::cINTEGRMVRESULT    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSINTGMV
Local oClone := WSWSINTGMV():New()
	oClone:_URL          := ::_URL 
	oClone:cMSGXML       := ::cMSGXML
	oClone:cINTEGRMVRESULT := ::cINTEGRMVRESULT
Return oClone

// WSDL Method INTEGRMV of Service WSWSINTGMV

WSMETHOD INTEGRMV WSSEND cMSGXML WSRECEIVE cINTEGRMVRESULT WSCLIENT WSWSINTGMV
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INTEGRMV xmlns="http://192.168.1.60:8080/">'
cSoap += WSSoapValue("MSGXML", ::cMSGXML, cMSGXML , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</INTEGRMV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://192.168.1.60:8080/INTEGRMV",; 
	"DOCUMENT","http://192.168.1.60:8080/",,"1.031217",; 
	"http://192.168.1.60:8080/ws1601/WSINTGMV.apw")

::Init()
::cINTEGRMVRESULT    :=  WSAdvValue( oXmlRet,"_INTEGRMVRESPONSE:_INTEGRMVRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



