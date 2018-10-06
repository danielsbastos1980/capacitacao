#INCLUDE "PROTHEUS.CH"

User function Consumir_cliente()

Local oObj   := WSMTCUSTOMER():New() 

//WsChgURL( @oObj, "MTCUSTOMER.APW" )

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cCUSTOMERID	:= "00000101"

If  !( oObj:GETCUSTOMER() )
	
	MsgAlert("Erro ao processar o WebService !")
	MostraErro()

Else

    oCliente := oObj:oWSGETCUSTOMERRESULT
    MsgAlert(oCliente:cNAME)

EndIf

return