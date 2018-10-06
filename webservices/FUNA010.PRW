#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 ณFUNA010  บAutor ณEllen Santiago		  บ Data ณ  10/02/14   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para processamento da integra็ใo de Ativos 		     บฑฑ
ฑฑบ          ณImobilizados com o sistema SoulMV 						        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Customizado Fund. ABC                       				     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FUNA010(oXML)

Local aArea			:= GetArea()			  	// Armazena ultima area utilizada
//Local aAreaSN1	:= SN1->( GetArea() )		// Armazena area SN1 
Local aRetProc		:= {}						// Array com o resultado do processamento
Local aCabec	  	:= {}						// Cabecalho 
Local aItens 		:= {}						// Array de Itens
Local cPatrim		:= ""						// Classificacao
Local cBase			:= ""						// Codigo base do Bem
Local cAquisic		:= ""						// Data de Aquisicao
Local cQuantd		:= ""						// Quantidade do Bem
Local cDescri		:= ""						// Descricao Sintetica 
Local cChapa		:= ""						// Numero da Plaqueta 
Local cCalcpis		:= ""						// Abate depr. base calc PIS 
Local cDtClass		:= ""
Local cFilial		:= SuperGetMv("FS_FILINT",,"") 	 // Filail de Processamento
Local cTipo			:= SuperGetMv("FS_ATPINT",,"") 	 // Tipo de Ativo 
Local lOK			:= .T.						// Informa se o processamento esta correto
Local lExistN1		:= .F.						// Informa se o fornecedor existe		
Local nOpcInt		:= 0							// Informa a operacao realizada na integracao 
Local cError  		:= ""
Local cWarning		:= ""

Private lMsErroAuto	:= .F. 					// Variavel de controle da ExecAuto
Private _cDirLog	:= ""  						//Diretorio de log txt 
Private _aMsgErr	:= {}  						//Mensagens de erro para o arquivo de log

_cDirLog			:= AllTrim(SuperGetMv("FS_LOGSOUL", .F. ,"\xml\log\" , )) 	      



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDIRETORIO DE ERROR-LOG TXT			        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lReturn := EXISTDIR( _cDirLog )	
If !lReturn
	AAdd(_aMsgErr, { "Diret๓rio de Erro TXT " + "(" + AllTrim(_cDirLog) + ") Nใo encontra-se criado", "04", "" } )
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz backup e tratamento na filial logada ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFilBkp := cFilAnt
lOK := U_FUNXPFIL("SN1")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida XML enviadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                                       
If lOK
	lOK := VldXML(oXML,@cGrupo,@cPatrim,@cBase,@cItem,@cAquisic,@cDescri,@cChapa,@cStatus,@cCalcpis,@cDtClass,@aItens,@nOpcInt) 
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a existencia do produto ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK

	dbSelectArea("SN1")
	SN1->( dbSetOrder(1) )
	lExistN1 :=  SN1->( dbSeek( FWXFilial("SN1") + cBase + cItem ) ) 
	
	If (nOpcInt == 3 ) .AND. lExistN1

		lOK := .F.
		AAdd(_aMsgErr, { "Ativo Imobilizado de cod. " + cBase + " duplicada", "010", "" } )
	
	ElseIf !(nOpcInt == 3 ) .AND. !lExistN1

		lOK := .F.
		AAdd(_aMsgErr, { "Ativo Imobilizado de cod. " + cBase + " nao encontrada", "010", "" } )

	EndIf

EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta array e envia para ExecAutoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOK
	ConOut("Inicio: "+Time())
	Begin Transaction
		
		aAdd(aCabec,    {     {"N1_FILIAL"   	,cFilial   	,NIL},;  
                              {"N1_PATRIM"      ,cPatrim    ,NIL},; 
                              {"N1_CBASE"      	,cBase     	,NIL},; 
                              {"N1_ITEM"       	,"0001"     ,NIL},; // Conforme doc do Cliente, considerar '0001' 
                              {"N1_AQUISIC"    	,cAquisic 	,NIL},; 
                              {"N1_QUANTD"      ,cQuantd   	,NIL},; 
                              {"N1_DESCRIC"    	,cDescri    ,NIL},; 
                              {"N1_CHAPA"      	,cChapa     ,NIL},; 
                              {"N1_STATUS"     	,"1"    	,NIL},; // Conforme doc do Cliente, considerar '1' 
                              {"N1_CALCPIS"     ,cCalcpis   ,NIL},; 
                              {"N1_DTCLASS"     ,cDtClass     ,NIL}} ) 
          
          // NAO IDENTIFICADO NO XML INFORMACOES DOS ITENS --> VERIFICAR COM O CLIENTE 
          aAdd(aItens, {      {"N3_FILIAL"      ,,NIL},; 
                              {"N3_CBASE"      	,,NIL},; 
                              {"N3_ITEM"      	,,NIL},; 
                              {"N3_TIPO"       	,,NIL},; 
                              {"N3_TIPREAV"    	,,NIL},; 
                              {"N3_HISTOR"      ,,NIL},; 
                              {"N3_TPSALDO"    	,,NIL},; 
                              {"N3_TPDEPR"      ,,NIL},; 
                              {"N3_CCONTAB"     ,,NIL},; 
                              {"N3_CUSTBEM"     ,,NIL},; 
                              {"N3_CDEPREC"     ,,NIL},; 
                              {"N3_CCUSTO"      ,,NIL},; 
                              {"N3_CCDEPR"      ,,NIL},; 
                              {"N3_CDESP"       ,,NIL},; 
                              {"N3_CCORREC"     ,,NIL},; 
                              {"N3_DINDEPR"     ,,NIL},; 
                              {"N3_VORIG1"      ,,NIL},; 
                              {"N3_TXDEPR1"     ,,NIL},; 
                              {"N3_VORIG3"      ,,NIL},; 
                              {"N3_TXDEPR3"     ,,NIL},; 
                              {"N3_VRCBAL1"     ,,NIL},; 
                              {"N3_VRDBAL1"     ,,NIL},; 
                              {"N3_VRDMES1"     ,,NIL},; 
                              {"N3_VRCACM1"     ,,NIL},; 
                              {"N3_VRDBAL3"     ,,NIL},; 
                              {"N3_VRDMES3"     ,,NIL},; 
                              {"N3_VRCACM3"     ,,NIL},; 
                              {"N3_VRDACM1"     ,,NIL},; 
                              {"N3_VRDACM3"     ,,NIL} }     ) 
          
		MSExecAuto({|X,Y,Z| ATFA010(X,Y,Z)} ,aCab ,aItens, 3) 
		
	End Transaction 

	If lMsErroAuto
        DisarmTransaction()
        break
    EndIf   
    
	If lMsErroAuto
   		ConOut("Erro na inclusao com ExecAuto")
		lOK := .F.
		cMsgRet := MostraErro()	
	Else
		ConOut("Ativo Imobilizado " + cBase + " incluido com sucesso! ")	
	EndIf
	
	ConOut("Fim  : "+Time())
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera Log txt			   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(_aMsgErr) > 0
   LOG010()
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
ฑฑบFuncao	 ณVldXML   บAutor ณEllen Santiago	     บ Data ณ  10/02/14   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validar a mensagem XML enviada para integracao  บฑฑ
ฑฑบ          ณ					 										                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FUNA020 - Customizado Fund. ABC             				     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldXML(oXML,cPatrim,cBase,cAquisic,cDescri,cChapa,cCalcpis,cDtClass,aItens,nOpcInt)


Local lRet		:= .T.	// Variavel de retorno
Local cOperXML	:= ""	// Informa a operacao da integracao 


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica operacao da integracaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	XmlChildEx(oXml:_Mensagem:_CADASTROBEM,"_OPERACAO") <> Nil

	cOperXML := UPPER( AllTrim( oXml:_Mensagem:_CADASTROBEM:_OPERACAO:TEXT) )
	
	If cOperXML == "I"
    	nOpcInt := 3
 	ElseIf cOperXML == "A"
		nOpcInt := 4
	ElseIf cOperXML == "E"
		nOpcInt := 5
	Else
		lRet := .F.
		AAdd( _aMsgErr, { "Operacao nao identificada", "140", "" } )
	EndIf

Else
	lRet := .F.
	AAdd( _aMsgErr, { "TAG operacao nao encontrada", "140", "" } )	
EndIf
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณClassificacao              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_CADASTROBEM,"_CODIGOCLASSIFICACAO") <> Nil ) .AND. ( !Empty(oXml:_MENSAGEM:_CADASTROBEM:_CODIGOCLASSIFICACAO:TEXT) )
	cPatrim := AllTrim( oXml:_MENSAGEM:_CADASTROBEM:_CODIGOCLASSIFICACAO:TEXT )
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Codigo de Classificacao nao encontrado", "010", "" } )
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCodigo Base do Bem       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_CADASTROBEM,"_CODIGOBEM") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_CADASTROBEM:_CODIGOBEM:TEXT) 
	cBase 	:= AllTrim(oXml:_MENSAGEM:_CADASTROBEM:_CODIGOBEM:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Codigo Base do Bem nao encontrado", "010", "" } )	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณData de Aquisicao        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_CADASTROBEM:_DADOSCOMPRA,"_DATACOMPRA") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_CADASTROBEM:_DADOSCOMPRA:_DATACOMPRA:TEXT) 
	cAquisic := AllTrim( oXml:_MENSAGEM:_CADASTROBEM:_DADOSCOMPRA:_DATACOMPRA:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Data de Aquisicao nao encontrada", "010", "" } )	
EndIf
 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescricao Sintetica      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_CADASTROBEM,"_DESCBEM") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_CADASTROBEM:_DESCBEM:TEXT) 
	cDescri := AllTrim(oXml:_MENSAGEM:_CADASTROBEM:_DESCBEM:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Descricao do Bem nao encontrada", "010", "" } )	
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNumero da Plaqueta       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_CADASTROBEM,"_DESCPLAQUETA") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_CADASTROBEM:_DESCPLAQUETA:TEXT) 
	cChapa := AllTrim(oXml:_MENSAGEM:_CADASTROBEM:_DESCPLAQUETA:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Numero da Plaqueta nao encontrado ", "010", "" } )	
Endif  


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbate depr. base calc PISณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_CADASTROBEM,"_CALCULOPIS") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_CADASTROBEM:_CALCULOPIS:TEXT) 
	cCalcpis := AllTrim(oXml:_MENSAGEM:_CADASTROBEM:_CALCULOPIS:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Abate depr. base calc PIS ", "010", "" } )	
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณData Tombamento       	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
/*   INFORMACAO DOCUMENTADA NA MIT POREM NAO IDENTIFICADA NO XML

If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_NOTAFISCAL,"_CODIGOTIPODOCUMENTODEPARA") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_NOTAFISCAL:_CODIGOTIPODOCUMENTODEPARA:TEXT) 
	cDtClass := AllTrim(oXml:_MENSAGEM:_NOTAFISCAL:_CODIGOTIPODOCUMENTODEPARA:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Tipo de Documento De/Para nao encontrado ", "140", "" } )	
Endif
*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBuscando os Produtos     ณ  
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//For nI := 1 To Len(oXml:_MENSAGEM:_NOTAFISCAL:_LISTAPRODUTO)
	  
	
	//ITEM 
	/*
	If lRet 
   		cItem := Len(oXml:_MENSAGEM:_NOTAFISCAL:_LISTAPRODUTO)
   		aAdd(aItens,{  {'D1_ITEM', cItem	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Nota sem item", "140", "" } )	
	EndIf 
	*/
	
	//
	/*
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_CODCONTABILDEBITO:TEXT) 
   		cDebito := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_CODCONTABILDEBITO:TEXT ) 
   		aAdd(aItens,{  {'CT2_DEBITO', cDebito	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Conta Debito nao encontrada", "04", "" } )	
	EndIf 
	*/
	//CONTA CREDITO 
	/*
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_CODREDUZIDOCREDITO:TEXT) 
   		cCredito := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_CODREDUZIDOCREDITO:TEXT ) 
   		aAdd(aItens,{  {'CT2_CREDIT', cCredito	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Conta Credito nao encontrada", "04", "" } )	
	EndIf
	*/
	//VALOR DO LANCAMENTO 
	/*
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_VALORLANCAMENTO:TEXT) 
   		cValor := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_VALORLANCAMENTO:TEXT ) 
   		aAdd(aItens,{  {'CT2_VALOR', cValor	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Valor do Lancamento nao encontrada", "04", "" } )	
	EndIf
	 */       
	//ORIGEM DO LANCAMENTO  ---> NAO IDENTIFICADO NO XML < ---
	/*
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_VALORLANCAMENTO:TEXT) 
   		cOrigem := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_VALORLANCAMENTO:TEXT ) 
   		aAdd(aItens,{  {'CT2_ORIGEM', cOrigem	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Origem do Lancamento nao encontrado", "04", "" } )	
	EndIf
	*/
	
	//HISTORICO PADRAO  
	/*
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[1]:_HISTORICOPADRAO:TEXT) 
   		cHp := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[1]:_HISTORICOPADRAO:TEXT) 
   		aAdd(aItens,{  {'CT2_HP', cHp	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Historico Padrao nao encontrada", "102", "" } )	
	EndIf
	 */
//Next nI
    

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOG010    บAutor  ณEllen Santiago      บ Data ณ  14/02/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GERA ARQUIVO DE LOG COM ERROS DE PROCESSAMENTO             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LOG010()
    
	Local nHdn		:= 0 
	Local nCount	:= 0
	Local cRegRet	:= ""
	Local cNomeArq	:= ""
	
	cNomeArq := "LOG_NOTA_ESTOQUE" + "_" +dTos(dDataBase) + StrTran(Time(),":","") 

	//CRIA LOG TXT NO DIRETORIO "TXT LOG"
	nHdn := FCREATE( _cDirLog + cNomeArq + ".txt" ,1)
	
	For nCount := 1 To Len(_aMsgErr)
		cRegRet := _aMsgErr[nCount][1]
		cRegRet += CRLF
		
		FWrite(nHdn,cRegRet,Len(cRegRet))
		
	Next nCount
	
	Fclose (nHdn)

	
Return .F.