#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �FUNA102  �Autor �Ellen Santiago		  � Data �  12/02/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para processamento da integra��o de Condicoes de  	  ���
���          �Pagamento com o sistema SoulMV 							  		  ���
�������������������������������������������������������������������������͹��
���Uso       � Customizado Fund. ABC                       				     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FUNA360(oXML)
Local aArea			:= GetArea()			// Armazena ultima area utilizada
Local aAreaSE2		:= SE2->( GetArea() )// Armazena area SE2 
Local aRetCPag		:= {}						// Array com o resultado do processamento  
//Local aDados		:= {}						// Array da ExecAuto //aCtbAuto
Local aItens 		:= {}						// Array de Itens 
Local aItemAux 	:= {} 					// Array auxiliar para inser��o dos itens
Local aCab	  		:= {}						// Cabecalho 
Local cCodigo     := ""						// Codigo de Condicao de Pagamento
Local cTipo			:= SuperGetMv("FS_TPCINT",,"")	// Tipo da Condicao de Pagamento
Local cCondPg  	:= ""						// Condicao de Pagto. Qntde de Parcelas			
Local cDescri  	:= ""						// Descricao da Condicao de Pagto
Local cFilInt		:= ""						// Filial para processamento da integracao
Local cFilBkp		:= ""						// Bkp da filial logada
Local cMsgRet		:= ""						// Mensagem de retorno do processamento
Local lOK			:= .T.					// Informa se o processamento esta correto
Local lExistE4		:= .F.					// Informa se o fornecedor existe		
Local nOpcInt		:= 0						// Informa a operacao realizada na integracao 
Local cError  		:= ""
Local cWarning		:= ""

Private lMsErroAuto	:= .F. 				// Variavel de controle da ExecAuto
Private _cDirLog	:= ""  					// Diretorio de log txt 
Private _aMsgErr	:= {}  					// Mensagens de erro para o arquivo de log

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
lOK := U_FUNXPFIL("SE4")

//������������������Ŀ
//�Valida XML enviado�
//��������������������                                                       
If lOK
	lOK := VldXML(oXML,cCodigo,cTipo,cCondPg,cDescri,aItemAux,nOpcInt)
EndIf

//����������������������������������������������Ŀ
//�Verifica a existencia da condicao de pagamento�
//������������������������������������������������
If lOK

	dbSelectArea("SE4")
	SA2->( dbSetOrder(1) )
	lExistE4 :=  SA2->( dbSeek( FWXFilial("SE4") + cCondPg ) ) 
	
	If (nOpcInt == 3 ) .AND. lExistE4

		lOK := .F.
		AAdd(_aMsgErr, { "Condicao de Pagamento " + cCondPg + " duplicado", "360", "" } )
	
	ElseIf !(nOpcInt == 3 ) .AND. !lExistE4

		lOK := .F.
		AAdd(_aMsgErr, { "Condicao de Pagamento " + cCodFor + " nao encontrado", "360", "" } )

	EndIf

EndIf


//���������������������������������Ŀ
//�Monta array e envia para ExecAuto�
//�����������������������������������
If lOK
	ConOut("Inicio: "+Time())
	Begin Transaction
        

		//Populando Cabe�alho
	   aAdd(aCab, {"E4_CODIGO" , cCodigo, Nil})
		aAdd(aCab, {"E4_TIPO", cTipo, Nil} )
		aAdd(aCab, {"E4_COND", cCondPg, Nil} )
		aAdd(aCab, {"E4_DESCRI", cDescri, Nil} )
		
		//Populando Item auxiliar    
		aAdd(aItemAux, {"EC_ITEM", "01", Nil} )
		aAdd(aItemAux, {"EC_TIPO", "2", Nil} )
		aAdd(aItemAux, {"EC_COND", "3", Nil} )
		aAdd(aItemAux, {"EC_IPI", "N", Nil} )
		aAdd(aItemAux, {"EC_DDD", "D", Nil} )
		aAdd(aItemAux, {"EC_SOLID", "N", Nil} )
		aAdd(aItemAux, {"EC_RATEIO", 100.00, Nil} )
		aAdd(aItens, aItemAux)

		MSExecAuto({|x,y,z|mata360(x,y,z)},aCab,aItens,nOpcInt) 
				
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
		ConOut("Condicao de Pagamento " + cCodigo + " incluido com sucesso! ")	
	EndIf
	
	ConOut("Fim  : "+Time())
EndIf

//������������������������Ŀ
//�Gera Log txt			   �
//��������������������������
If Len(_aMsgErr) > 0
   LOG360()
EndIf

//������������������������Ŀ
//�Retorno do processamento�
//��������������������������
aAdd(aRetCPag,lOK)
aAdd(aRetCPag,cMsgRet)

//���������������������������Ŀ
//�Retorno para filial logada �
//�����������������������������
cFilAnt := cFilBkp

Return aRetCPag

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
Static Function VldXML(oXML,cCodigo,cTipo,cCondPg,cDescri,aItemAux,nOpcInt)

Local nI
Local lRet			:= .T.// Variavel de retorno
Local cOperXML		:= ""	// Informa a operacao da integracao 


//�������������������������������Ŀ
//�Verifica operacao da integracao�
//���������������������������������
If	XmlChildEx(oXml:_Mensagem:_LOTECONTABIL,"_OPERACAO") <> Nil

	cOperXML := UPPER( AllTrim( oXml:_Mensagem:_LOTECONTABIL:_OPERACAO:TEXT) )
	
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
 
//���������������������������Ŀ
//�Verifica Lote			  �
//�����������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_LOTECONTABIL,"_CODIGOLOTE") <> Nil ) .AND. ( !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_CODIGOLOTE:TEXT) )
	cLote := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_CODIGOLOTE:TEXT )
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Cod.Lote nao encontrado", "04", "" } )
EndIf


//�������������������������Ŀ
//�Numero do Documento      �
//���������������������������
/* NAO IDENTIFICADO NO XML
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_DESCFORNECEDOR") <> Nil ) .AND. !Empty(oXml:_Mensagem:_FORNECEDOR:_DESCFORNECEDOR:TEXT ) 
	cDoc 	:= AllTrim( oXml:_Mensagem:_FORNECEDOR:_DESCFORNECEDOR:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Numero do documento nao encontrado", "04", "" } )	
EndIf
*/

//�������������������������Ŀ
//�Lancamento Padrao        �
//���������������������������
/*  NAO IDENTIFICADO NO XML
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_NOMEFANTASIA") <> Nil ) .AND. !Empty(oXml:_Mensagem:_FORNECEDOR:_NOMEFANTASIA:TEXT ) 
	cPadrao := AllTrim( oXml:_Mensagem:_FORNECEDOR:_NOMEFANTASIA:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Lancamento Padrao nao encontrado", "04", "" } )	
EndIf
*/ 

//�������������������������Ŀ
//�Saldo Informado          �
//���������������������������
/*NAO IDENTIFICADO NO XML
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_CEP") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_CEP:TEXT) 
	nTotinf := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_CEP:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "Saldo nao encontrado", "04", "" } )	
Endif
*/

//�������������������������Ŀ
//�Numero da Linha          �   
//���������������������������
aAdd(aItens,{  {'CT2_LINHA', "001"	, NIL}} ) // Segundo documentacao considerar "001"


//�������������������������Ŀ       
//�Moeda Lancamento         �
//���������������������������
aAdd(aItens,{  {'CT2_MOEDLC', "R$"	, NIL}} ) // Segundo documentacao considerar "R$"


//�������������������������Ŀ
//�Tipo de Lancamento       �
//���������������������������
/* 
aAdd(aItens,{  {'CT2_DC', "VERIFICAR"	, NIL}} ) // NAO IDENTIFICADO NO XML
*/

//�������������������������Ŀ
//�Buscando os Lancamentos  � 
//���������������������������
For nI := 1 To Len(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO)
	//@cLinha,@cMoedlc,@cDc,@cDebito,@cCredito,@cValor,@cOrigem,@cHp,@cHist,@nOpcInt)
	
	//CONTA DEBITO
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
	
	//HISTORICO DO LANCAMENTO  ---> NAO IDENTIFICADO NO XML <---
	/*
	If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_LOTECONTABIL,"_LANCAMENTO") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_VALORLANCAMENTO:TEXT) 
   		cHist := AllTrim( oXml:_MENSAGEM:_LOTECONTABIL:_LISTALANCAMENTO:_LANCAMENTO[nI]:_VALORLANCAMENTO:TEXT ) 
   		aAdd(aItens,{  {'CT2_HIST', cHist	, NIL}} )
	ElseIf lRet
		lRet := .F.
		AAdd( _aMsgErr, { "Valor do Lancamento nao encontrada", "04", "" } )	
	EndIf
	*/
	
Next nI
    

Return lRet 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOG360    �Autor  �Ellen Santiago      � Data �  06/02/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � GERA ARQUIVO DE LOG COM ERROS DE PROCESSAMENTO             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function LOG360()
    
	Local nHdn		:= 0 
	Local nCount	:= 0
	Local cRegRet	:= ""
	Local cNomeArq	:= ""
	
	cNomeArq := "LOG_FORMADEPAGTO" + "_" +dTos(dDataBase) + StrTran(Time(),":","") 

	//CRIA LOG TXT NO DIRETORIO "TXT LOG"
	nHdn := FCREATE( _cDirLog + cNomeArq + ".txt" ,1)
	
	For nCount := 1 To Len(_aMsgErr)
		cRegRet := _aMsgErr[nCount][1]
		cRegRet += CRLF
		
		FWrite(nHdn,cRegRet,Len(cRegRet))
		
	Next nCount
	
	Fclose (nHdn)

	
Return .F.