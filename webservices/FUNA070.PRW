#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �FUNA070  �Autor �Ellen Santiago		  � Data �  07/02/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para processamento da integra��o de Conta Corrente   ���
���          �com o sistema SoulMV 			     			                    ���
�������������������������������������������������������������������������͹��
���Uso       � Customizado Fund. ABC                       				     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FUNA070(oXML)

Local aArea			:= GetArea()			// Armazen.a ultima area utilizada
Local aAreaSA6 	:= SA6->( GetArea() )// Armazena area SA6 
Local cCodigo		:= ""						// Codigo do Banco
Local cAgencia		:= ""						// Agencia 
Local cNroCont		:= ""						// Numero da Conta
Local cBanco		:= ""                // Nome do Banco
Local cFilBkp		:= ""						// Bkp da filial logada
Local cMsgRet		:= ""						// Mensagem de retorno do processamento 
Local aRetProc		:= {}						// Array com o resultado do processamento						
Local lOK			:= .T.					// Informa se o processamento esta correto
Local lExist		:= .F.					// Informa se o fornecedor existe		
Local nOpcInt		:= 0						// Informa a operacao realizada na integracao 
Local cError  		:= ""
Local cWarning		:= ""

Private lMsErroAuto	:= .F. 				// Variavel de controle da ExecAuto
Private _cDirLog	:= ""  					// Diretorio de log txt 
Private _aMsgErr	:= {}  					// Mensagens de erro para o arquivo de log

_cDirLog			:= AllTrim(SuperGetMv("FS_LOGSOUL", .F. ,"\xml\log\" , )) 	      





//�����������������������������������������Ŀ
//�DIRETORIO DE ERROR-LOG TXT				     �
//�������������������������������������������
lReturn := EXISTDIR( _cDirLog )	
If !lReturn
	AAdd(_aMsgErr, { "Diret�rio de Erro TXT " + "(" + AllTrim(_cDirLog) + ") N�o encontra-se criado", "20", "" } )
EndIf


//�����������������������������������������Ŀ
//�Faz backup e tratamento na filial logada �
//�������������������������������������������
cFilBkp := cFilAnt
lOK := U_FUNXPFIL("SA6")

//������������������Ŀ
//�Valida XML enviado�
//��������������������                                                       
If lOK
	lOK := VldXML(oXML,@cCodigo,@cAgencia,@cNroCont,@cBanco,@nOpcInt)
EndIf



//������������������������������������Ŀ
//�Verifica a existencia da Conta      �
//��������������������������������������

If lOK

	dbSelectArea("SA6")
	SA6->( dbSetOrder(1) )
	lExist :=  SA6->( dbSeek( FWXFilial("SA6") + cCodigo + cAgencia + cNroCont ) ) 
	
	If (nOpcInt == 3 ) .AND. lExist

		lOK := .F.
		AAdd(_aMsgErr, { "Conta/Agencia " + cNroCont + "/" + cAgencia + " duplicada" + CRLF, "20", "" } )
		
	Elseif (nOpcInt == 3 ) .AND. !lExist
	 
		RecLock("SA6",.T.)
			SA6->A6_COD		:= cCodigo 
			SA6->A6_AGENCIA	:= cAgencia 
			SA6->A6_NUMCON	:= cNroCont
			SA6->A6_NOME	:= cBanco
		SA6->(MsUnlock())

	ElseIf !(nOpcInt == 3 ) .AND. !lExist

		lOK := .F.
		AAdd(_aMsgErr, { "Conta/Agencia " + cNroCont + "/" + cAgencia + " nao encontrada" + CRLF, "20", "" } )

	EndIf

EndIf  


//������������������������Ŀ
//�Gera Log txt			   �
//��������������������������
If Len(_aMsgErr) > 0
   LOG020()
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


//RESET ENVIRONMENT

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
Static Function VldXML(oXML,cCodigo,cAgencia,cNroCont,cBanco,nOpcInt) 


Local lRet			:= .T.	// Variavel de retorno
Local cOperXML		:= ""	// Informa a operacao da integracao 

//�������������������������������Ŀ
//�Verifica operacao da integracao�
//���������������������������������
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
 
//���������������������������Ŀ
//�Cod. do Fornecedor/Cliente �
//�����������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_CODIGOFORNECEDOR") <> Nil ) .AND. ( !Empty(oXml:_Mensagem:_FORNECEDOR:_CODIGOFORNECEDOR:TEXT) )
	cCodigo := AllTrim( oXml:_Mensagem:_FORNECEDOR:_CODIGOFORNECEDOR:TEXT )
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Cod. do Fornecedor nao encontrado" + CRLF, "20", "" } )
EndIf


//�������������������������Ŀ
//�Razao Social             �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_DESCFORNECEDOR") <> Nil ) .AND. !Empty(oXml:_Mensagem:_FORNECEDOR:_DESCFORNECEDOR:TEXT ) 
	cNome 	:= AllTrim( oXml:_Mensagem:_FORNECEDOR:_DESCFORNECEDOR:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Razao Social nao encontrado" + CRLF, "20", "" } )	
EndIf


//�������������������������Ŀ
//�Verifica Nome Fantasia   �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_Mensagem:_FORNECEDOR,"_NOMEFANTASIA") <> Nil ) .AND. !Empty(oXml:_Mensagem:_FORNECEDOR:_NOMEFANTASIA:TEXT ) 
	cNreduz := AllTrim( oXml:_Mensagem:_FORNECEDOR:_NOMEFANTASIA:TEXT)	
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Nome Fantasia nao encontrado" + CRLF, "20", "" } )	
EndIf
 

//�������������������������Ŀ
//�Verifica Endereco        �
//���������������������������
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



//�������������������������Ŀ
//�Verifica Estado          �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_UF") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_UF:TEXT) 
	cEst := AllTrim( oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_UF:TEXT )
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "UF nao encontrado" + CRLF, "20", "" } )	
EndIf   

//�������������������������Ŀ
//�Verifica Municipio       �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO,"_CIDADE") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_CIDADE:TEXT) 
	cMun := AllTrim( oXml:_MENSAGEM:_FORNECEDOR:_ENDERECO:_CIDADE:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Municipio nao encontrado" + CRLF, "20", "" } )	
EndIf


//�������������������������Ŀ
//�Verifica Tipo	        �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR,"_TIPOCLIENTEFORNECEDOR") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_TIPOCLIENTEFORNECEDOR:TEXT) 	
	cTipo := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_TIPOCLIENTEFORNECEDOR:TEXT)
ElseIf lRet
	lRet := .F.
	AAdd( _aMsgErr, { "Tipo de Fornecedor nao encontrado" + CRLF, "20", "" } )	
EndIf 

//�������������������������Ŀ
//�Verifica CNPJ/CPF	    �
//���������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR,"_CGCCPF") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_CGCCPF:TEXT) 	
	cCnpjCpf := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_CGCCPF:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "CNPJ/CPF nao encontrado" + CRLF, "20", "" } )	
EndIf  

//���������������������������������Ŀ
//�Verifica Inscricao Estadual      �
//�����������������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR,"_INSCRICAOESTADUAL") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_INSCRICAOESTADUAL:TEXT) 	
	cInsEst := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_INSCRICAOESTADUAL:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "Inscricao Estadual nao encontrado" + CRLF, "20", "" } )	
EndIf 

//���������������������������������Ŀ
//�Verifica Inscricao Municipal	   �
//�����������������������������������
If lRet .AND. ( XmlChildEx(oXml:_MENSAGEM:_FORNECEDOR,"_INSCRICAOMUNICIPAL") <> Nil ) .AND. !Empty(oXml:_MENSAGEM:_FORNECEDOR:_INSCRICAOMUNICIPAL:TEXT) 	
	cInsMuni := AllTrim(oXml:_MENSAGEM:_FORNECEDOR:_INSCRICAOMUNICIPAL:TEXT)
ElseIf lRet
	AAdd( _aMsgErr, { "Inscricao Municipal nao encontrado" + CRLF, "20", "" } )		
EndIf 


Return lRet 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOG020    �Autor  �Ellen Santiago      � Data �  06/02/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � GERA ARQUIVO DE LOG COM ERROS DE PROCESSAMENTO             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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