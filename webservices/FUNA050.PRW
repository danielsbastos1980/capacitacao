#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �FUNA050  �Autor �Leandro Kenji de Moura� Data �  02/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para processamento da integra��o de Produtos 		  ���
���          �com o sistema SoulMV 										           ���
�������������������������������������������������������������������������͹��
���Uso       � Customizado Fund. ABC                       				     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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




//�����������������������������������������Ŀ
//�DIRETORIO DE ERROR-LOG TXT			  		  �
//�������������������������������������������
lReturn := EXISTDIR( _cDirLog )	
If !lReturn
	AAdd(_aMsgErr, { "Diret�rio de Erro TXT " + "(" + AllTrim(_cDirLog) + ") N�o encontra-se criado", "04", "" } )
EndIf


//�����������������������������������������Ŀ
//�Faz backup e tratamento na filial logada �
//�������������������������������������������
cFilBkp := cFilAnt
lOK := U_FUNXPFIL("SB1")

//������������������Ŀ
//�Valida XML enviado�
//��������������������                                                       
If lOK
	lOK := VldXML(oXML,@cCodProd,@cDesProd,@cUnit,@nOpcInt)
EndIf

//���������������������������������Ŀ
//�Verifica a existencia do produto �
//�����������������������������������
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

//���������������������������������Ŀ
//�Verifica a existencia da unidade �
//�����������������������������������
If lOK

	dbSelectArea("SAH")
	SAH->( dbSetOrder(1) )
	If !SAH->( dbSeek( FWXFilial("SAH") + cUnit ) )
		lOK := .F.
		//cMsgRet := "Unidade " + cUnit + " nao cadastrada"
		AAdd(_aMsgErr, { "Unidade " + cUnit + " nao cadastrada", "04", "" } )
	EndIf

EndIf

//���������������������������������Ŀ
//�Monta array e envia para ExecAuto�
//�����������������������������������
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

//������������������������Ŀ
//�Gera Log txt			   �
//��������������������������
If Len(_aMsgErr) > 0
   LOG050()
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
���Funcao	 �VldXML   �Autor �Leandro Kenji de Moura� Data �  02/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para validar a mensagem XML enviada para integracao  ���
���          �					 										      		     ���
�������������������������������������������������������������������������͹��
���Uso       � FUNA050 - Customizado Fund. ABC             				  	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldXML(oXML,cCodProd,cDesProd,cUnit,nOpcInt)

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

	cCodProd := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_CODIGOPRODUTO:TEXT )

ElseIf lRet
	lRet := .F.
//	cMsgRet := "Cod. do produto nao encontrado"	
	AAdd( _aMsgErr, { "Cod. do produto nao encontrado", "04", "" } )
EndIf

//�������������������������Ŀ
//�Verifica desc. do produto�
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_CADASTROPRODUTO,"_DESCPRODUTO") <> Nil ) .AND. !Empty(oXml:_Mensagem:_CADASTROPRODUTO:_DESCPRODUTO:TEXT ) 

	cDesProd := AllTrim( oXml:_Mensagem:_CADASTROPRODUTO:_DESCPRODUTO:TEXT )

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FUNDLOG   �Autor  �Ellen Santiago      � Data �  06/02/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � GERA ARQUIVO DE LOG COM ERROS DE PROCESSAMENTO             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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