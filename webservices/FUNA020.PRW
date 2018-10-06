#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 ณFUNA020  บAutor ณEllen Santiago		 บ Data ณ  07/02/14    บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para processamento da integra็ใo de Fornecedor e  	  บฑฑ
ฑฑบ          ณClientes com o sistema SoulMV 			     			           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Customizado Fund. ABC                       				     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FUNA020(oXML)

Local aArea			:= GetArea()			  	// Armazen.a ultima area utilizada
Local aAreaSA2 		:= 	SA2->( GetArea() )// Armazena area SA2 
Local aRetFor		:= {}						// Array com o resultado do processamento
Local aVetor		:= {}						// Array da ExecAuto   
Local cCodigo		:= ""						// Codigo do Fornecedor 
Local cLoja			:= SuperGetMv("FS_LJFINT",,"")// Codigo da Loja   
Local cNome			:= ""						// Razao Social 
Local cNreduz		:= ""						// Nome Reduzido do Fornecedor 
Local cEnd			:= ""						// Endereco 
Local cEst			:= ""						// Estado 
Local cMun			:= ""						// Municipio    
Local cTipo			:= ""						// Tipo de Fornecedor 
Local cBairro		:= ""						// Bairro  
Local cCep			:= ""						// CEP
Local cInsEst 		:= ""						// Inscricao Estadual
Local cInsMuni		:= ""                // Inscricao Municipal
Local cFilInt		:= ""						// Filial para processamento da integracao
Local cFilBkp		:= ""						// Bkp da filial logada
Local cMsgRet		:= ""						// Mensagem de retorno do processamento
Local lOK			:= .T.					// Informa se o processamento esta correto
Local lExist		:= .F.					// Informa se o fornecedor existe		
Local nOpcInt		:= 0						// Informa a operacao realizada na integracao 
Local cError  		:= ""
Local cWarning		:= ""

Private lMsErroAuto	:= .F. 				// Variavel de controle da ExecAuto
Private _cDirLog	:= ""  					// Diretorio de log txt 
Private _aMsgErr	:= {}  					// Mensagens de erro para o arquivo de log

_cDirLog			:= AllTrim(SuperGetMv("FS_LOGSOUL", .F. ,"\xml\log\" , )) 	      


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDIRETORIO DE ERROR-LOG TXT				ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lReturn := EXISTDIR( _cDirLog )	
If !lReturn
	AAdd(_aMsgErr, { "Diret๓rio de Erro TXT " + "(" + AllTrim(_cDirLog) + ") Nใo encontra-se criado", "20", "" } )
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz backup e tratamento na filial logada ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFilBkp := cFilAnt
lOK := U_FUNXPFIL("SA2")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida XML enviadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                                       
If lOK
	lOK := VldXML(oXML,@cCodigo,@cLoja,@cNome,@cNreduz,@cEnd,@cEst,@cMun,@cTipo,@cBairro,@cCep,@cInsEst,@cInsMuni,@nOpcInt)
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Codigo da Loja             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK .And. Empty(cLoja)
	AAdd(_aMsgErr, { "Codigo da Loja nao informado no parametro [ FS_LJFINT ]  " + CRLF, "20", "" } )
	lOK := .F.
Endif



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a existencia do Fornecedor ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK

	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	lExist :=  SA2->( dbSeek( FWXFilial("SA2") + cCodigo + cLoja   ) ) 
	
	If (nOpcInt == 3 ) .AND. lExist

		lOK := .F.
		AAdd(_aMsgErr, { "Fornecedor " + cCodigo + " duplicado" + CRLF, "20", "" } )
	
	ElseIf !(nOpcInt == 3 ) .AND. !lExist

		lOK := .F.
		AAdd(_aMsgErr, { "Fornecedor " + cCodigo + " nao encontrado" + CRLF, "20", "" } )

	EndIf

EndIf  


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a existencia do Cliente    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK

	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	lExist :=  SA1->( dbSeek( FWXFilial("SA1") + cCodigo + cLoja   ) ) 
	
	If (nOpcInt == 3 ) .AND. lExist

		lOK := .F.
		AAdd(_aMsgErr, { "Cliente " + cCodigo + " duplicado" + CRLF, "20", "" } )
	
	ElseIf !(nOpcInt == 3 ) .AND. !lExist

		lOK := .F.
		AAdd(_aMsgErr, { "Fornecedor " + cCodigo + " nao encontrado" + CRLF, "20", "" } )

	EndIf

EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecAuto Fornecedor                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If lOK
	Begin Transaction
		aVetor:= {	{"A2_COD"   ,cCodigo ,NIL},;                     
				 		{"A2_LOJA"	,cLoja	 ,NIL},;                     
						{"A2_NOME"  ,cNome   ,Nil},;                   
						{"A2_NREDUZ",cNreduz ,Nil},;                   
						{"A2_END"	,cEnd    ,Nil},;
						{"A2_EST"  	,cEst	 ,Nil},;
						{"A2_MUN"  	,cMun	 ,Nil},;
						{"A2_TIPO"  ,cTipo	 ,Nil},;
						{"A2_BAIRRO",cBairro ,Nil},;
						{"A2_CEP"  	,cCep	 ,Nil},;
						{"A2_INSCR" ,cInsEst ,Nil},;
						{"A2_INSCRM",cInsMuni,Nil} }				
				
		MSExecAuto({|x,y| Mata020(x,y)},aVetor,nOpcInt)		
	End Transaction 

	If lMsErroAuto
		lOK := .F.
   		AAdd( _aMsgErr, { "Erro na inclusao com ExecAuto do Fornecedor" + CRLF, "20", ""  } )
		cMsgRet := MostraErro()
		AAdd( _aMsgErr, { cMsgRet, "20", "" } )	
        DisarmTransaction()
  	Else
		AAdd( _aMsgErr, {" --> Fornecedor " + cCodigo + " incluido com sucesso! <-- " + CRLF, "20", ""  } )	
    EndIf 
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecAuto Cliente                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK 
 	aVetor	:= {}
	Begin Transaction
						
		aVetor:={ 	{"A1_COD"	,cCodigo,Nil},; // Codigo				 
					{"A1_LOJA"  ,cLoja  ,Nil},; // Loja				 
					{"A1_NOME"  ,cNome  ,Nil},; // Nome				 
					{"A1_NREDUZ",cNreduz,Nil},; // Nome Fantasia				 
					{"A1_TIPO"  ,cTipo	,Nil},; // Tipo				 
					{"A1_END"   ,cEnd	,Nil},; // Endereco				 
					{"A1_MUN"   ,cMun	,Nil},; // Cidade				 
					{"A1_EST"   ,cEst	,Nil}}  // Estado 
						
												
		MSExecAuto({|x,y| Mata030(x,y)},aVetor,nOpcInt)		
	End Transaction 

	If lMsErroAuto
		lOK := .F.
   		AAdd( _aMsgErr, { "Erro na inclusao com ExecAuto do Cliente" + CRLF, "20", ""  } )
		cMsgRet := MostraErro()
		AAdd( _aMsgErr, { cMsgRet, "20", "" } )	
        DisarmTransaction()
  	Else
		AAdd( _aMsgErr, {" --> Cliente " + cCodigo + " incluido com sucesso! <-- " + CRLF, "20", ""  } )	
    EndIf 
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera Log txt			   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(_aMsgErr) > 0
   LOG020()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorno do processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aRetFor,lOK)
aAdd(aRetFor,cMsgRet)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorno para filial logada ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFilAnt := cFilBkp


Return aRetFor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 ณVldXML   บAutor ณEllen Santiago	     บ Data ณ  10/02/14   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validar a mensagem XML enviada para integracao  บฑฑ
ฑฑบ          ณ					 										  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FUNA020 - Customizado Fund. ABC             				     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldXML(oXML,cCodigo,cLoja,cNome,cNreduz,cEnd,cEst,cMun,cTipo,cBairro,cCep,cInsEst,cInsMuni,nOpcInt)

Local lRet			:= .T.	// Variavel de retorno
Local cOperXML		:= ""		// Informa a operacao da integracao 
Local cEndNro		:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica operacao da integracaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_OPERACAO") <> Nil

	cOperXML := UPPER( AllTrim( oXml:_Mensagem:_FORNECEDOR:_OPERACAO:TEXT) )
	
	If cOperXML == "I"
    	nOpcInt := 3
 	ElseIf cOperXML == "A"
		nOpcInt := 4
	ElseIf cOperXML == "E"
		nOpcInt := 5
	Else
		lRet := .F.
		AAdd( _aMsgErr, { "Operacao nao identificada" + CRLF, "20", "" } )
	EndIf

Else
	lRet := .F.
	AAdd( _aMsgErr, { "TAG operacao nao encontrada" + CRLF, "20", "" } )	
EndIf
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCod. do Fornecedor/Cliente ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_CODIGOFORNECEDOR") <> Nil ) .AND. ( !Empty(oXml:_Mensagem:_FORNECEDOR:_CODIGOFORNECEDOR:TEXT) )
	cCodigo := AllTrim( oXml:_Mensagem:_FORNECEDOR:_CODIGOFORNECEDOR:TEXT )
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Cod. do Fornecedor nao encontrado" + CRLF, "20", "" } )
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRazao Social             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_DESCFORNECEDOR") <> Nil ) .AND. !Empty(oXml:_Mensagem:_FORNECEDOR:_DESCFORNECEDOR:TEXT ) 
	cNome 	:= AllTrim( oXml:_Mensagem:_FORNECEDOR:_DESCFORNECEDOR:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Razao Social nao encontrado" + CRLF, "20", "" } )	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Nome Fantasia   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_NOMEFANTASIA") <> Nil ) .AND. !Empty(oXml:_Mensagem:_FORNECEDOR:_NOMEFANTASIA:TEXT ) 
	cNreduz := AllTrim( oXml:_Mensagem:_FORNECEDOR:_NOMEFANTASIA:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Nome Fantasia nao encontrado" + CRLF, "20", "" } )	
EndIf
 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Endereco        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_RUA") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_RUA:TEXT ) 
	cEnd := AllTrim( oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_RUA:TEXT )
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Endereco nao encontrado" + CRLF, "20", "" } )	
EndIf 

If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_NUMERO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_NUMERO:TEXT) 
	cEndNro := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_NUMERO:TEXT)
	cEnd	:= cEnd + "," + cEndNro
ElseIf lRet
	AAdd( _aMsgErr, { "Numero do endereco nao encontrado" + CRLF, "20", "" } )	
EndIf 	


If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_BAIRRO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_BAIRRO:TEXT) 
	cBairro := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_BAIRRO:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "Bairro nao encontrado" + CRLF, "20", "" } )	
Endif 

If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_CEP") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_CEP:TEXT) 
	cCep := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_CEP:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "CEP nao encontrado" + CRLF, "20", "" } )	
Endif



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Estado          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_UF") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_UF:TEXT) 
	cEst := AllTrim( oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_UF:TEXT )
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "UF nao encontrado" + CRLF, "20", "" } )	
EndIf   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Municipio       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_CIDADE") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_CIDADE:TEXT) 
	cMun := AllTrim( oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_CIDADE:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Municipio nao encontrado" + CRLF, "20", "" } )	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Tipo	        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR,"_TIPOCLIENTEFORNECEDOR") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_TIPOCLIENTEFORNECEDOR:TEXT) 	
	cTipo := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_TIPOCLIENTEFORNECEDOR:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Tipo de Fornecedor nao encontrado" + CRLF, "20", "" } )	
EndIf 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica CNPJ/CPF	    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR,"_CGCCPF") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_CGCCPF:TEXT) 	
	cCnpjCpf := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_CGCCPF:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "CNPJ/CPF nao encontrado" + CRLF, "20", "" } )	
EndIf  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Inscricao Estadual      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR,"_INSCRICAOESTADUAL") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_INSCRICAOESTADUAL:TEXT) 	
	cInsEst := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_INSCRICAOESTADUAL:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "Inscricao Estadual nao encontrado" + CRLF, "20", "" } )	
EndIf 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Inscricao Municipal	    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR,"_INSCRICAOMUNICIPAL") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_INSCRICAOMUNICIPAL:TEXT) 	
	cInsMuni := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_INSCRICAOMUNICIPAL:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "Inscricao Municipal nao encontrado" + CRLF, "20", "" } )		
EndIf 


Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOG020    บAutor  ณEllen Santiago      บ Data ณ  06/02/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GERA ARQUIVO DE LOG COM ERROS DE PROCESSAMENTO             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LOG020()
    
	Local nHdn		:= 0 
	Local nCount	:= 0
	Local cRegRet	:= ""
	Local cNomeArq	:= ""
	
	cNomeArq := "LOG_FORNECEDOR" + "_" +dTos(dDataBase) + StrTran(Time(),":","") 

	//CRIA LOG TXT NO DIRETORIO "TXT LOG"
	nHdn := FCREATE( _cDirLog + cNomeArq + ".txt" ,1)
	
	For nCount := 1 To Len(_aMsgErr)
		cRegRet := _aMsgErr[nCount][1]
		cRegRet += CRLF
		
		FWrite(nHdn,cRegRet,Len(cRegRet))
		
	Next nCount
	
	Fclose (nHdn)

	
Return .F.