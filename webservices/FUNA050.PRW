#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 ณFUNA050  บAutor ณLeandro Kenji de Mouraบ Data ณ  02/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para processamento da integra็ใo de Produtos 		  บฑฑ
ฑฑบ          ณcom o sistema SoulMV 										           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Customizado Fund. ABC                       				     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FUNA050(oXML)

Local aArea			:= GetArea()			  		// Armazena ultima area utilizada
Local aAreaSB1		:= 	SB1->( GetArea() )	// Armazena area SB1 
Local aRetProc		:= {}								// Array com o resultado do processamento
Local aProdAuto	:= {}								// Array da ExecAuto
Local cCodProd		:= ""								// Codigo do produto
Local cDesProd		:= ""								// Descricao do produto
Local cUnit			:= ""								// Unidade do produto
Local cTpProd		:= SuperGetMv("FS_TPPINT",,"")// Tipo do produto
Local cLocPad		:= SuperGetMv("FS_LCPINT",,"")// Armazem do produto
Local cFilInt		:= ""								// Filial para processamento da integracao
Local cFilBkp		:= ""								// Bkp da filial logada
Local cMsgRet		:= ""								// Mensagem de retorno do processamento
Local lOK			:= .T.							// Informa se o processamento esta correto
Local lExistB1		:= .F.							// Informa se o produto existe		
Local nOpcInt		:= 0								// Informa a operacao realizada na integracao 
Local cError  		:= ""
Local cWarning		:= ""

Private lMsErroAuto	:= .F. 						// Variavel de controle da ExecAuto
Private _cDirLog	:= ""  							// Diretorio de log txt 
Private _aMsgErr	:= {}  							// Mensagens de erro para o arquivo de log

_cDirLog			:= AllTrim(SuperGetMv("FS_LOGSOUL", .F. ,"\xml\log\" , )) 	      




//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDIRETORIO DE ERROR-LOG TXT			  		  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lReturn := EXISTDIR( _cDirLog )	
If !lReturn
	AAdd(_aMsgErr, { "Diret๓rio de Erro TXT " + "(" + AllTrim(_cDirLog) + ") Nใo encontra-se criado", "04", "" } )
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz backup e tratamento na filial logada ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFilBkp := cFilAnt
lOK := U_FUNXPFIL("SB1")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida XML enviadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                                       
If lOK
	lOK := VldXML(oXML,@cCodProd,@cDesProd,@cUnit,@nOpcInt)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a existencia do produto ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK

	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	lExistB1 :=  SB1->( dbSeek( FWXFilial("SB1") + cCodProd  ) ) 
	
	If (nOpcInt == 3 ) .AND. lExistB1

		lOK := .F.
		AAdd(_aMsgErr, { "Produto " + cCodProd + " duplicado", "04", "" } )
	
	ElseIf !(nOpcInt == 3 ) .AND. !lExistB1

		lOK := .F.
		AAdd(_aMsgErr, { "Produto " + cCodProd + " nao encontrado", "04", "" } )

	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a existencia da unidade ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK

	dbSelectArea("SAH")
	SAH->( dbSetOrder(1) )
	If !SAH->( dbSeek( FWXFilial("SAH") + cUnit ) )
		lOK := .F.
		//cMsgRet := "Unidade " + cUnit + " nao cadastrada"
		AAdd(_aMsgErr, { "Unidade " + cUnit + " nao cadastrada", "04", "" } )
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta array e envia para ExecAutoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK
	Begin Transaction
		aProdAuto:= {	{"B1_COD"   ,cCodProd	    	,NIL},;                     
				 		{"B1_DESC"	,cDesProd	 		,NIL},;                     
						{"B1_TIPO"  ,cTpProd    		,Nil},;                   
						{"B1_UM"    ,cUnit      		,Nil},;                   
						{"B1_LOCPAD",cLocPad    		,Nil},;
						{"B1_UREV"  ,DTOS(dDataBase)	,Nil},;
						{"B1_DATREF",DTOS(dDataBase)	,Nil}}
				
		MSExecAuto({|x,y| Mata010(x,y)},aProdAuto,nOpcInt)
	End Transaction
	
	If lMsErroAuto
        DisarmTransaction()
        break
    EndIf   
    
	If lMsErroAuto
		lOK := .F.
		cMsgRet := MostraErro()
	EndIf
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera Log txt			   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(_aMsgErr) > 0
   LOG050()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorno do processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aRetProc,lOK)
aAdd(aRetProc,cMsgRet)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorno para filial logada ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFilAnt := cFilBkp

Return aRetProc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 ณVldXML   บAutor ณLeandro Kenji de Mouraบ Data ณ  02/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validar a mensagem XML enviada para integracao  บฑฑ
ฑฑบ          ณ					 										      		     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FUNA050 - Customizado Fund. ABC             				  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldXML(oXML,cCodProd,cDesProd,cUnit,nOpcInt)

Local lRet			:= .T.	// Variavel de retorno
Local cOperXML		:= ""		// Informa a operacao da integracao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica operacao da integracaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	XmlChildEx(oXml:_Mensagem:_CADASTROPRODUTO,"_OPERACAO") <> Nil

	cOperXML := UPPER( AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_OPERACAO:TEXT) )
	
	If cOperXML == "I"
    	nOpcInt := 3
 	ElseIf cOperXML == "A"
		nOpcInt := 4
	ElseIf cOperXML == "E"
		nOpcInt := 5
	Else
		lRet := .F.
		AAdd( _aMsgErr, { "Operacao nao identificada", "04", "" } )
	EndIf

Else
	lRet := .F.
	AAdd( _aMsgErr, { "TAG operacao nao encontrada", "04", "" } )	
EndIf
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica cod. do produtoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_CADASTROPRODUTO,"_CODIGOPRODUTO") <> Nil ) .AND. ( !Empty(oXml:_Mensagem:_CADASTROPRODUTO:_CODIGOPRODUTO:TEXT) )

	cCodProd := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_CODIGOPRODUTO:TEXT )

ElseIf lRet
	lRet := .F.
//	cMsgRet := "Cod. do produto nao encontrado"	
	AAdd( _aMsgErr, { "Cod. do produto nao encontrado", "04", "" } )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica desc. do produtoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_CADASTROPRODUTO,"_DESCPRODUTO") <> Nil ) .AND. !Empty(oXml:_Mensagem:_CADASTROPRODUTO:_DESCPRODUTO:TEXT ) 

	cDesProd := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_DESCPRODUTO:TEXT )

ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Descr. do produto nao encontrado", "04", "" } )	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica unidade do produtoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(	oXml:_Mensagem:_CADASTROPRODUTO,"_LISTAUNIDADE") <> Nil )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento caso o obj. XML venha como arrayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(oXml:_Mensagem:_CADASTROPRODUTO:_LISTAUNIDADE:_UNIDADE) == "O"

    	cUnit := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_LISTAUNIDADE:_UNIDADE:_CODIGOUNIDADEPRODUTODEPARA:TEXT )

	ElseIf ValType(oXml:_Mensagem:_CADASTROPRODUTO:_LISTAUNIDADE:_UNIDADE) == "A"
    
    	cUnit := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_LISTAUNIDADE:_UNIDADE[1]:_CODIGOUNIDADEPRODUTODEPARA:TEXT )
	
	Else
		lRet := .F.
		AAdd( _aMsgErr, {"Cod. Unidade do Produto De/Para nao encontrada", "04", "" } )		
	EndIf

ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, {"Cod. Unidade do Produto De/Para nao encontrada", "04", "" } )		
EndIf 

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNDLOG   บAutor  ณEllen Santiago      บ Data ณ  06/02/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GERA ARQUIVO DE LOG COM ERROS DE PROCESSAMENTO             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LOG050()
    
	Local nHdn		:= 0 
	Local nCount	:= 0
	Local cRegRet	:= ""
	Local cNomeArq	:= ""
	
	cNomeArq := "LOG_PRODUTO" + "_" +dTos(dDataBase) + StrTran(Time(),":","") 

	//CRIA LOG TXT NO DIRETORIO "TXT LOG"
	nHdn := FCREATE( _cDirLog + cNomeArq + ".txt" ,1)
	
	For nCount := 1 To Len(_aMsgErr)
		cRegRet := _aMsgErr[nCount][1]
		cRegRet += CRLF
		
		FWrite(nHdn,cRegRet,Len(cRegRet))
		
	Next nCount
	
	Fclose (nHdn)

	
Return .F.