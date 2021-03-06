#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �FUNA040  �Autor �Ellen Santiago	     � Data �  06/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para processamento da integra��o de Cliente		  	  ���
���          �com o sistema SoulMV 										  			  ���
�������������������������������������������������������������������������͹��
���Uso       � Customizado Fund. ABC                       				     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FUNA040(oXML)

Local aArea			:= GetArea()			  		// Armazena ultima area utilizada
Local aAreaSA1		:= 	SA1->( GetArea() )	// Armazena area SA1 
Local aRetCli		:= {}								// Array com o resultado do processamento
Local aCliAuto		:= {}								// Array da ExecAuto
Local cCodCli		:= ""								// Codigo do Cliente 
Local cFilial		:= SuperGetMv("FS_FILINT",,"") 	 // Filail de Processamento
Local cLoja			:= SuperGetMv("FS_LJFINT",,"") 	 // Codigo Loja 
Local cNome			:= ""								// Razao Social 
Local cNreduz		:= ""								// Nome Reduzido do Cliente 
Local cTipo			:= ""								// Tipo de Cliente    
Local cEnd			:= ""								// Endereco 
Local cMun			:= ""								// Municipio    
Local cEst			:= ""								// Estado    
Local cFilInt		:= ""								// Filial para processamento da integracao
Local cFilBkp		:= ""								// Bkp da filial logada
Local cMsgRet		:= ""								// Mensagem de retorno do processamento
Local lOK			:= .T.							// Informa se o processamento esta correto
Local lExistA1		:= .F.							// Informa se o produto existe		
Local nOpcInt		:= 0								// Informa a operacao realizada na integracao 
Local cError  		:= ""
Local cWarning		:= ""

Private lMsErroAuto	:= .F. 						// Variavel de controle da ExecAuto
Private _cDirLog	:= ""  							// Diretorio de log txt 
Private _aMsgErr	:= {}  							// Mensagens de erro para o arquivo de log

_cDirLog			:= AllTrim(SuperGetMv("FS_LOGSOUL", .F. ,"\xml\log\" , )) 	      



//�����������������������������������������Ŀ
//�DIRETORIO DE ERROR-LOG TXT			  	     �
//�������������������������������������������
lReturn := EXISTDIR( _cDirLog )	
If !lReturn
	AAdd(_aMsgErr, { "Diret�rio de Erro TXT " + "(" + AllTrim(_cDirLog) + ") N�o encontra-se criado", "04", "" } )
EndIf


//�����������������������������������������Ŀ
//�Faz backup e tratamento na filial logada �
//�������������������������������������������
cFilBkp := cFilAnt
lOK := U_FUNXPFIL("SA1")

//������������������Ŀ
//�Valida XML enviado�
//��������������������                                                       
If lOK
	lOK := VldXML(oXML,@cCodCli,@@cNome,@cNreduz,@cTipo,@cEnd,@cMun,@cEst,@nOpcInt)
EndIf

//���������������������������������Ŀ
//�Verifica a existencia do Cliente �
//�����������������������������������
If lOK

	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	lExistA1 :=  SA1->( dbSeek( FWXFilial("SA1") + cCodCli + cLoja  ) ) 
	
	If (nOpcInt == 3 ) .AND. lExistA1
		lOK := .F.
		AAdd(_aMsgErr, { "Cliente " + cCodCli + " duplicado", "04", "" } )	
	ElseIf !(nOpcInt == 3 ) .AND. !lExistA1
		lOK := .F.
		AAdd(_aMsgErr, { "Cliente " + cCodCli + " nao encontrado", "04", "" } )
	EndIf

EndIf

//���������������������������������Ŀ
//�Verifica a existencia da unidade �
//�����������������������������������
/*
If lOK

	dbSelectArea("SAH")
	SAH->( dbSetOrder(1) )
	If !SAH->( dbSeek( FWXFilial("SAH") + cNome ) )
		lOK := .F.
		//cMsgRet := "Unidade " + cNome + " nao cadastrada"
		AAdd(_aMsgErr, { "Unidade " + cNome + " nao cadastrada", "04", "" } )
	EndIf

EndIf
*/
//���������������������������������Ŀ
//�Monta array e envia para ExecAuto�                     
//�����������������������������������
If lOK
	Begin Transaction     
					
		aCliAuto:={ {"A1_COD"   ,cCodCli	,Nil},; // Codigo				 
				{"A1_LOJA"      ,cLoja     ,Nil},; // Loja				 
				{"A1_NOME"      ,cNome  	,Nil},; // Nome				 
				{"A1_NREDUZ"    ,cNreduz	,Nil},; // Nome reduz.				 
				{"A1_TIPO"      ,cTipo		,Nil},; // Tipo				 
				{"A1_END"       ,cEnd		,Nil},; // Endereco				 
				{"A1_MUN"       ,cMun		,Nil},; // Cidade				 
				{"A1_EST"       ,cEst	   ,Nil}}  // Estado
				
		MSExecAuto({|x,y| Mata030(x,y)},aCliAuto,nOpcInt)
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

//������������������������Ŀ
//�Gera Log txt			   �
//��������������������������
If Len(_aMsgErr) > 0
   LOG040()
EndIf

//������������������������Ŀ
//�Retorno do processamento�
//��������������������������
aAdd(aRetCli,lOK)
aAdd(aRetCli,cMsgRet)

//���������������������������Ŀ
//�Retorno para filial logada �
//�����������������������������
cFilAnt := cFilBkp

Return aRetCli

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �VldXML   �Autor �Ellen Santiago � Data �  07/02/14          ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para validar a mensagem XML enviada para integracao  ���
���          �					 										                 ���
�������������������������������������������������������������������������͹��
���Uso       � FUNA040 - Customizado Fund. ABC             				     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldXML(oXML,cCodCli,cNome,cNreduz,cTipo,cEnd,cMun,cEst,nOpcInt) 


Local lRet			:= .T.	// Variavel de retorno
Local cOperXML		:= ""		// Informa a operacao da integracao

//�������������������������������Ŀ
//�Verifica operacao da integracao�
//���������������������������������
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
 
//������������������������Ŀ
//�Verifica cod. do produto�
//��������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_CADASTROPRODUTO,"_CODIGOPRODUTO") <> Nil ) .AND. ( !Empty(oXml:_Mensagem:_CADASTROPRODUTO:_CODIGOPRODUTO:TEXT) )

	cCodCli := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_CODIGOPRODUTO:TEXT )

ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Cod. do produto nao encontrado", "04", "" } )
EndIf

//�������������������������Ŀ
//�Verifica desc. do produto�
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_CADASTROPRODUTO,"_DESCPRODUTO") <> Nil ) .AND. !Empty(oXml:_Mensagem:_CADASTROPRODUTO:_DESCPRODUTO:TEXT ) 

	cLoja := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_DESCPRODUTO:TEXT )

ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Descr. do produto nao encontrado", "04", "" } )	
EndIf

//���������������������������Ŀ
//�Verifica unidade do produto�
//�����������������������������
If lRet .AND. ( XmlChildEx(	oXml:_Mensagem:_CADASTROPRODUTO,"_LISTAUNIDADE") <> Nil )

	//�������������������������������������������Ŀ
	//�Tratamento caso o obj. XML venha como array�
	//���������������������������������������������
	If ValType(oXml:_Mensagem:_CADASTROPRODUTO:_LISTAUNIDADE:_UNIDADE) == "O"

    	cNome := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_LISTAUNIDADE:_UNIDADE:_CODIGOUNIDADEPRODUTODEPARA:TEXT )

	ElseIf ValType(oXml:_Mensagem:_CADASTROPRODUTO:_LISTAUNIDADE:_UNIDADE) == "A"
    
    	cNome := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_LISTAUNIDADE:_UNIDADE[1]:_CODIGOUNIDADEPRODUTODEPARA:TEXT )
	
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FUNDLOG   �Autor  �Ellen Santiago      � Data �  06/02/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � GERA ARQUIVO DE LOG COM ERROS DE PROCESSAMENTO             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function LOG040()
    
	Local nHdn		:= 0 
	Local nCount	:= 0
	Local cRegRet	:= ""
	Local cNomeArq	:= ""
	
	cNomeArq := "LOG_CLIENTE" + "_" +dTos(dDataBase) + StrTran(Time(),":","") 

	//CRIA LOG TXT NO DIRETORIO "TXT LOG"
	nHdn := FCREATE( _cDirLog + cNomeArq + ".txt" ,1)
	
	For nCount := 1 To Len(_aMsgErr)
		cRegRet := _aMsgErr[nCount][1]
		cRegRet += CRLF
		
		FWrite(nHdn,cRegRet,Len(cRegRet))
		
	Next nCount
	
	Fclose (nHdn)

	
Return .F.