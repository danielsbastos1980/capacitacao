#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "XMLXFUN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWSFUN001 บAutor ณLeandro Kenji de Mouraบ Data ณ  26/12/13   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWebService responsavel por realizar a integracao com o      บฑฑ
ฑฑบ          ณsistema SoulMv.                                             บฑฑ                                                            	
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Customizado Fund. ABC                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
WSSERVICE WSIntgMV 	DESCRIPTION "WebService para integra็ใo SoulMV x Protheus"


WSDATA MsgXML	As String			// Mensagem XML recebida na integracao
WSDATA RetXML	As String			// Mensagem XML de retorno da integracao

WSMETHOD IntegrMV DESCRIPTION "Realiza integra็ใo com o Protheus"

ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo	 ณIntegrMV บAutor ณLeandro Kenji de Mouraบ Data ณ  26/12/13   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo utilizado para realizar a integra็ใo                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ WSIntGMV - Customizado Fund. ABC                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSMETHOD IntegrMV WSRECEIVE MsgXML WSSEND RetXML WSSERVICE WSIntgMV

Local aArea	   	:= GetArea()	  						// Armazena ultima area utilizada
Local aRetProc		:= {}										// Array com o resultado do processamento
Local cPathCab		:= SuperGetMv("FS_PTCBINT",,"")	// Informa o caminho para acessar o cabecalho da msg XML (_MENSAGEM:_CABECALHO)
Local cErro			:= ""			   						// Informa o erro ocorrido
Local cAviso		:= ""			 							// Informa o aviso ocorrido
Local cTpInt		:= ""										// Tipo do servico de integracao
Local lOk			:= .T.			  						// Informa se o processamento esta correto
Local cXML			:= ""

Static oXML			:= Nil									// Obj. contendo a mensagem XML - Utilizada como static devido a macro execucao

ConOut("","[WSIntGMV] - " + Time()  +  " - Chamada do metodo para integracao com o SoulMV.","") 


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o parser da mensagem XML enviadaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oXml := XmlParser(::MsgXML, "_", @cErro, @cAviso ) 

If oXml <> Nil

	If XmlChildEx(&("oXml" + cPathCab),"_SERVICO") <> Nil
	
		cTpInt := &("oXml" + cPathCab + ":_SERVICO:TEXT")
		
		//Retira espacos e deixa maiusculo
		cTpInt := Upper( AllTrim(cTpInt) )
		                                                          	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณChama rotinas de processamento de acordo com o tipo da integracaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cTpInt == "CENTRO_CUSTO"
		
			aRetProc := U_FUNA010(oXML)
					
		ElseIf cTpInt == "FORNECEDOR"  

			aRetProc := U_FUNA020(oXML)
		
		ElseIf cTpInt == "BEM"

			aRetProc := U_FUNA010(oXML)
			
		ElseIf cTpInt == "LOTE_CTB" 

			aRetProc := U_FUNA102(oXML)

		ElseIf cTpInt == "PRODUTO" 

			aRetProc := U_FUNA050(oXML)

		ElseIf cTpInt == "FORMA_PGTO"

			aRetProc := U_FUNA360(oXML)

		ElseIf cTpInt == "NOTA_ESTOQUE"

			aRetProc := U_FUNA140(oXML)

		ElseIf cTpInt == "CONTA_CORRENTE"

			aRetProc := U_FUNA070(oXML)

		ElseIf cTpInt == "CONTAS_RECEBER"

			aRetProc := U_FUNA090(oXML)

		ElseIf cTpInt == "CONTAS_PAGAR"

			aRetProc := U_FUNA100(oXML)

		ElseIf cTpInt == "MOVIM_BANC"

			aRetProc := U_FUNA110(oXML)
		
		Else
			lOK := .F.
			cErro := "Servico nao identificado."
		EndIf
	
	Else
		lOK := .F.
		cErro := "TAG servico nao encontrada."
	EndIf

Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetorna falha no parser do XMLณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lOK := .F.
	Conout("Objeto XML nao existe. Falha no parser")
EndIf
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTratamento no array de processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(aRetProc)
	Aadd(aRetProc,lOK)
	Aadd(aRetProc,cErro)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta XML de retorno da integracaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
::RetXML := ""
::RetXML := U_MtRetXML(aRetProc[1],aRetProc[2]) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDestroi obj. XMLณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
KillObj(@oXML)


RestArea(aArea)

ConOut("","[WSIntGMV] - " + Time()  +  " - Fim do WS para integracao com o SoulMV.","")


Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 ณMtRetXML บAutor ณLeandro Kenji de Mouraบ Data ณ  27/12/13   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para destroir o obj XML para nao alocar memoria 	  บฑฑ
ฑฑบ          ณdo server			   										  			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IntegrMV - Customizado Fund. ABC                       	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MtRetXML(lProcOk, cMsgErro)

Local cXMLRet	:= ""
Local cIntegr	:= ""

RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA ("99") FILIAL ("01")

If lProcOk
	cIntegr := "S"
Else
	cIntegr := "N"	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLayout XML de Retorno                     ณ
//ณ<mensagem> - Nod pai                      ณ
//ณ<integrado> - Informa se foi integrado S/Nณ
//ณ<log> - Informa a mensagem de erro 		   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cXMLRet := "<mensagem>"

cXMLRet += "<integrado>" + cIntegr + "</integrado>"  
cXMLRet += "<log>" + cMsgErro + "</log>"  

cXMLRet += "</mensagem>"


RESET ENVIRONMENT

Return cXMLRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 ณKillObj  บAutor ณLeandro Kenji de Mouraบ Data ณ  30/12/13   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para destroir o obj XML para nao alocar memoria 	  บฑฑ
ฑฑบ          ณdo server			   										  			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IntegrMV - Customizado Fund. ABC                       	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function KillObj(oXML, cPathFt)

Local aArea			:= GetArea()	// Armazena ultima area utilizada
Local cNodName		:= ""				// Nome do Nod para limpar
Local cKill			:= ""				// Caminho para limpeza no obj. XML
Local lRecurs		:= .F.			// Informa se a chamada foi recursiva
Local nFor			:= 0				// Contador do For
Local nChild		:= 0				// Quantidade de nos filhos		
Local oNodCld		:= Nil			// Obj. com o nod filho

Default cPathFt 	:= "" 			// Path do nod pai

RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA ("99") FILIAL ("01")


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a quantidade de nos filhosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cPathFt)
	nChild := XmlChildCount(oXML) 
Else
	lRecurs := .T.
	nChild := XmlChildCount( &( "oXML"+cPathFt ) )
EndIf

For nFor := 1 to nChild

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBusca o obj do nod filho  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lRecurs
		oNodCld	:= XmlGetChild( oXml,nFor)
	Else
		oNodCld	:= XmlGetChild( &("oXML" + cPathFt), nFor )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso nao seja ultimo nod chama a rotina recursivamente ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(oNodCld) == "O" .AND. XmlChildCount(oNodCld) > 0
		cNodName := ":_" + oNodCld:REALNAME
		cKill := cPathFt + cNodName
		
		KillObj(@oXml, cKill)
	
	ElseIf ValType(oNodCld) == "O"

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLimpa o nod filho ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cNodName := ":_" + oNodCld:REALNAME
		
		cKill := "oXml" + cPathFt + cNodName
		
		FreeObj(&cKill)
	
	EndIf
	
Next nFor   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa o obj. XML ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cKill := "oXml" + cPathFt
FreeObj(&cKill)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLibera fisicamente a memoria do serverณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lRecurs
	DelClassIntF()
EndIf

RestArea(aArea)


RESET ENVIRONMENT

Return