#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �FUNA140  �Autor �Ellen Santiago		  � Data �  10/02/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para processamento da integra��o de Nota de Estoque  ���
���          �com o sistema SoulMV 							  			           ���
�������������������������������������������������������������������������͹��
���Uso       � Customizado Fund. ABC                       				     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FUNA140(oXML)

Local aArea			:= GetArea()			  	// Armazena ultima area utilizada
//Local aAreaCT2		:= CT2->( GetArea() )	// Armazena area CT2 
Local aRetProc		:= {}						// Array com o resultado do processamento
Local aCabec	  	:= {}						// Cabecalho 
Local aItens 		:= {}						// Array de Itens

Local cTipo       := ""					// Tipo da Nota (Nota/Consumidor/Ticket...)
Local cFormul		:= ""					// Formulario Proprio
Local cDoc			:= ""					// Numero do Documento
Local cSerie		:= ""					// Serie do Documento
Local cEmissao		:= ""					// Data de Emissao da NF
Local cFornece		:= ""					// Cdigo do Fornecedor 
Local cFilial		:= SuperGetMv("FS_FILINT",,"") 	 // Filail de Processamento
Local cLoja			:= SuperGetMv("FS_LJFINT",,"") 	 // Codigo Loja 
Local cNature		:= SuperGetMv("FS_NTNFINT",,"") // Determina Natureza da Operacao 
Local cTES			:= SuperGetMv("FS_TENFINT",,"") // Determina a TES 
Local cCond			:= ""					// Codigo da condicao de pagamento 
Local cEspecie		:= ""             // Tipo de Documento De/Para
Local cFilInt		:= ""					// Filial para processamento da integracao
Local cFilBkp		:= ""					// Bkp da filial logada
Local cMsgRet		:= ""					// Mensagem de retorno do processamento
Local lOK			:= .T.				// Informa se o processamento esta correto

Local lExistF1		:= .F.				// Informa se o fornecedor existe		
Local nOpcInt		:= 0					// Informa a operacao realizada na integracao 
Local cError  		:= ""
Local cWarning		:= ""

Private lMsErroAuto	:= .F. 			// Variavel de controle da ExecAuto

Private _cDirLog	:= ""  				//Diretorio de log txt 
Private _aMsgErr	:= {}  				//Mensagens de erro para o arquivo de log

_cDirLog			:= AllTrim(SuperGetMv("FS_LOGSOUL", .F. ,"\xml\log\" , )) 	      



//�����������������������������������������Ŀ
//�DIRETORIO DE ERROR-LOG TXT			        �
//�������������������������������������������
lReturn := EXISTDIR( _cDirLog )	
If !lReturn
	AAdd(_aMsgErr, { "Diret�rio de Erro TXT " + "(" + AllTrim(_cDirLog) + ") N�o encontra-se criado", "04", "" } )
EndIf


//�����������������������������������������Ŀ
//�Faz backup e tratamento na filial logada �
//�������������������������������������������
cFilBkp := cFilAnt
lOK := U_FUNXPFIL("DFI")

//������������������Ŀ
//�Valida XML enviado�
//��������������������                                                       
If lOK
	lOK := VldXML(oXML,@cTipo,@cFormul,@cDoc,@cSerie,@cEmissao,@cFornece,@cCond,cEspecie,@aItens,@nOpcInt)
EndIf


//���������������������������������Ŀ
//�Verifica a existencia do produto �
//�����������������������������������
If lOK

	dbSelectArea("SF1")
	SA2->( dbSetOrder(2) )
	lExistF1 :=  SF1->( dbSeek( FWXFilial("SF1") + cFornece + cLoja + cDoc   ) ) 
	
	If (nOpcInt == 3 ) .AND. lExistF1

		lOK := .F.
		AAdd(_aMsgErr, { "Nota Fiscal Nro. " + cDoc + "Serie: " + cSerie +" duplicada", "140", "" } )
	
	ElseIf !(nOpcInt == 3 ) .AND. !lExistF1

		lOK := .F.
		AAdd(_aMsgErr, { "Nota Fiscal Nro. " + cDoc + "Serie: " + cSerie + " nao encontrada", "140", "" } )

	EndIf

EndIf


//���������������������������������Ŀ
//�Monta array e envia para ExecAuto�
//�����������������������������������
If lOK
	ConOut("Inicio: "+Time())
	Begin Transaction
		aCabec := 	{	{'F1_TIPO'	,cTipo		,NIL},;		
					{'F1_FORMUL'	,'N'		,NIL},;	 	
					{'F1_DOC'		,cDoc	    ,NIL},;		
					{'F1_SERIE'		,cSerie		,NIL},;		
					{'F1_EMISSAO'	,DTOC(cEmissao)	,NIL},;		
					{'F1_FORNECE'	,cFornece	,NIL},;		
					{'F1_LOJA'		,cLoja		,NIL},;		
					{'F1_COND'		,cCond		,NIL} }				
				
		aItens :=	{	{'D1_FILIAL'	,cFilial	,NIL},;	
				{'D1_ITEM'			,aItens[1]		,NIL},;	 					
				{'D1_COD'			,aItens[2]		,NIL},; 				
				{'D1_UM'				,aItens[3]		,NIL},;		    
				{'D1_QUANT'			,aItens[4]		,NIL},;						
				{'D1_VUNIT'			,aItens[5]		,NIL},;		
				{'D1_TOTAL'			,aItens[6]		,NIL},;	 
				{'D1_VALIPI'		,aItens[7]		,NIL},;					
				{'D1_TES'			,aItens[8]		,NIL},;		
				{'D1_LOCAL'			,aItens[9]		,NIL},;	 			
				{'D1_EMISSAO'		,aItens[10]		,NIL},;		
				{'D1_DTDIGIT'		,dDate			,NIL}	}      
						
	MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens,nOpcInt) 
		
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
		ConOut("Nota Fiscal Nro. " + cDoc + "Serie: " + cSerie + " incluido com sucesso! ")	
	EndIf
	
	ConOut("Fim  : "+Time())
EndIf

//������������������������Ŀ
//�Gera Log txt			   �
//��������������������������
If Len(_aMsgErr) > 0
   LOG140()
EndIf

//������������������������Ŀ
//�Retorno do processamento�
//��������������������������
aAdd(aRetProc,lOK)
aAdd(aRetProc,cMsgRet)

//���������������������������Ŀ
//�Retorno para filial logada �
//�����������������������������
cFilAnt := cFilBkp

Return aRetProc

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �VldXML   �Autor �Ellen Santiago	     � Data �  10/02/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para validar a mensagem XML enviada para integracao  ���
���          �					 										                 ���
�������������������������������������������������������������������������͹��
���Uso       � FUNA020 - Customizado Fund. ABC             				     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldXML(oXML,cTipo,cFormul,cDoc,cSerie,cEmissao,cFornece,cCond,cEspecie,aItens,nOpcInt)

Local nI
Local lRet			:= .T.// Variavel de retorno
Local cOperXML		:= ""	// Informa a operacao da integracao 


//�������������������������������Ŀ
//�Verifica operacao da integracao�
//���������������������������������
If	XmlChildEx(oXml:_Mensagem:_NOTAFISCAL,"_OPERACAO") <> Nil

	cOperXML := UPPER( AllTrim( oXml:_Mensagem:_NOTAFISCAL:_OPERACAO:TEXT) )
	
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
 
//���������������������������Ŀ
//�Tipo da Nota               �
//�����������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_NOTAFISCAL,"_TIPOENTRADA") <> Nil ) .AND. ( !Empty(oXml:_MENSAGEM:_NOTAFISCAL:_TIPOENTRADA:TEXT) )
	cTipo := AllTrim( oXml:_MENSAGEM:_NOTAFISCAL:_TIPOENTRADA:TEXT )
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Tipo de Entrada da Nota nao encontrado", "140", "" } )
EndIf


//�������������������������Ŀ
//�Numero do Documento      �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_NOTAFISCAL,"_NUMERODOCUMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_NOTAFISCAL:_NUMERODOCUMENTO:TEXT ) 
	cDoc 	:= AllTrim( oXml:_MENSAGEM:_NOTAFISCAL:_NUMERODOCUMENTO:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Numero do documento nao encontrado", "140", "" } )	
EndIf


//�������������������������Ŀ
//�Nro de Serie da Nota     �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_NOTAFISCAL,"_NUMEROSERIE") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_NOTAFISCAL:_NUMEROSERIE:TEXT) 
	cSerie := AllTrim( oXml:_MENSAGEM:_NOTAFISCAL:_NUMEROSERIE:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Numero de Serie da Nota nao encontrado", "140", "" } )	
EndIf
 

//�������������������������Ŀ
//�Data de Emissao          �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_NOTAFISCAL,"_DATAEMISSAO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_NOTAFISCAL:_DATAEMISSAO:TEXT) 
	cEmissao := AllTrim(oXml:_MENSAGEM:_NOTAFISCAL:_DATAEMISSAO:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Data de Emissao nao encontrado", "140", "" } )	
Endif


//�������������������������Ŀ
//�Codigo do Fornecedor     �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_NOTAFISCAL,"_CODIGOFORNECEDOR") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_NOTAFISCAL:_CODIGOFORNECEDOR:TEXT) 
	cFornece := AllTrim(oXml:_MENSAGEM:_NOTAFISCAL:_CODIGOFORNECEDOR:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Codigo do Fornecedor nao encontrado ", "140", "" } )	
Endif  


//�������������������������Ŀ
//�Condicao de Pagamento    �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_NOTAFISCAL,"_CODIGOCONDICAOPAGAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_NOTAFISCAL:_CODIGOCONDICAOPAGAMENTO:TEXT) 
	cCond := AllTrim(oXml:_MENSAGEM:_NOTAFISCAL:_CODIGOCONDICAOPAGAMENTO:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Condicao de Pagamento nao encontrado ", "140", "" } )	
Endif


//�������������������������Ŀ
//�Tipo de Documento De/Para�
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_NOTAFISCAL,"_CODIGOTIPODOCUMENTODEPARA") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_NOTAFISCAL:_CODIGOTIPODOCUMENTODEPARA:TEXT) 
	cEspecie := AllTrim(oXml:_MENSAGEM:_NOTAFISCAL:_CODIGOTIPODOCUMENTODEPARA:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Tipo de Documento De/Para nao encontrado ", "140", "" } )	
Endif


//�������������������������Ŀ
//�Buscando os Produtos     �  
//���������������������������
For nI := 1 To Len(oXml:_MENSAGEM:_NOTAFISCAL:_LISTAPRODUTO)
	  
	
	//ITEM
	If lRet 
   		cItem := Len(oXml:_MENSAGEM:_NOTAFISCAL:_LISTAPRODUTO)
   		aAdd(aItens,{  {'D1_ITEM', cItem	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Nota sem item", "140", "" } )	
	EndIf 
	
	
	//
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_CODCONTABILDEBITO:TEXT) 
   		cDebito := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_CODCONTABILDEBITO:TEXT ) 
   		aAdd(aItens,{  {'CT2_DEBITO', cDebito	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Conta Debito nao encontrada", "04", "" } )	
	EndIf 
	
	//CONTA CREDITO
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_CODREDUZIDOCREDITO:TEXT) 
   		cCredito := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_CODREDUZIDOCREDITO:TEXT ) 
   		aAdd(aItens,{  {'CT2_CREDIT', cCredito	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Conta Credito nao encontrada", "04", "" } )	
	EndIf
	
	//VALOR DO LANCAMENTO
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_VALORLANCAMENTO:TEXT) 
   		cValor := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_VALORLANCAMENTO:TEXT ) 
   		aAdd(aItens,{  {'CT2_VALOR', cValor	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Valor do Lancamento nao encontrada", "04", "" } )	
	EndIf
	        
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
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[1]:_HISTORICOPADRAO:TEXT) 
   		cHp := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[1]:_HISTORICOPADRAO:TEXT) 
   		aAdd(aItens,{  {'CT2_HP', cHp	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Historico Padrao nao encontrada", "102", "" } )	
	EndIf
	
Next nI
    

Return lRet 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOG140    �Autor  �Ellen Santiago      � Data �  06/02/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � GERA ARQUIVO DE LOG COM ERROS DE PROCESSAMENTO             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function LOG140()
    
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