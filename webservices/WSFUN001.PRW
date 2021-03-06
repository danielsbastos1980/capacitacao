#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "XMLXFUN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WSFUN001 �Autor �Leandro Kenji de Moura� Data �  26/12/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �WebService responsavel por realizar a integracao com o      ���
���          �sistema SoulMv.                                             ���                                                            	
�������������������������������������������������������������������������͹��
���Uso       � Customizado Fund. ABC                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
WSSERVICE WSIntgMV 	DESCRIPTION "WebService para integra��o SoulMV x Protheus"


WSDATA MsgXML	As String			// Mensagem XML recebida na integracao
WSDATA RetXML	As String			// Mensagem XML de retorno da integracao

WSMETHOD IntegrMV DESCRIPTION "Realiza integra��o com o Protheus"

ENDWSSERVICE

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo	 �IntegrMV �Autor �Leandro Kenji de Moura� Data �  26/12/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo utilizado para realizar a integra��o                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � WSIntGMV - Customizado Fund. ABC                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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


//����������������������������������������Ŀ
//�Realiza o parser da mensagem XML enviada�
//������������������������������������������
oXml := XmlParser(::MsgXML, "_", @cErro, @cAviso ) 

If oXml <> Nil

	If XmlChildEx(&("oXml" + cPathCab),"_SERVICO") <> Nil
	
		cTpInt := &("oXml" + cPathCab + ":_SERVICO:TEXT")
		
		//Retira espacos e deixa maiusculo
		cTpInt := Upper( AllTrim(cTpInt) )
		                                                          	
		//�����������������������������������������������������������������Ŀ
		//�Chama rotinas de processamento de acordo com o tipo da integracao�
		//�������������������������������������������������������������������
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
	//������������������������������Ŀ
	//�Retorna falha no parser do XML�
	//��������������������������������
	lOK := .F.
	Conout("Objeto XML nao existe. Falha no parser")
EndIf
 
//������������������������������������Ŀ
//�Tratamento no array de processamento�
//��������������������������������������
If Empty(aRetProc)
	Aadd(aRetProc,lOK)
	Aadd(aRetProc,cErro)
EndIf

//����������������������������������Ŀ
//�Monta XML de retorno da integracao�
//������������������������������������
::RetXML := ""
::RetXML := U_MtRetXML(aRetProc[1],aRetProc[2]) 

//����������������Ŀ
//�Destroi obj. XML�
//������������������
KillObj(@oXML)


RestArea(aArea)

ConOut("","[WSIntGMV] - " + Time()  +  " - Fim do WS para integracao com o SoulMV.","")


Return .T. 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �MtRetXML �Autor �Leandro Kenji de Moura� Data �  27/12/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para destroir o obj XML para nao alocar memoria 	  ���
���          �do server			   										  			  ���
�������������������������������������������������������������������������͹��
���Uso       � IntegrMV - Customizado Fund. ABC                       	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//������������������������������������������Ŀ
//�Layout XML de Retorno                     �
//�<mensagem> - Nod pai                      �
//�<integrado> - Informa se foi integrado S/N�
//�<log> - Informa a mensagem de erro 		   �
//��������������������������������������������
cXMLRet := "<mensagem>"

cXMLRet += "<integrado>" + cIntegr + "</integrado>"  
cXMLRet += "<log>" + cMsgErro + "</log>"  

cXMLRet += "</mensagem>"


RESET ENVIRONMENT

Return cXMLRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �KillObj  �Autor �Leandro Kenji de Moura� Data �  30/12/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para destroir o obj XML para nao alocar memoria 	  ���
���          �do server			   										  			  ���
�������������������������������������������������������������������������͹��
���Uso       � IntegrMV - Customizado Fund. ABC                       	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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


//�����������������������������������Ŀ
//�Verifica a quantidade de nos filhos�
//�������������������������������������
If Empty(cPathFt)
	nChild := XmlChildCount(oXML) 
Else
	lRecurs := .T.
	nChild := XmlChildCount( &( "oXML"+cPathFt ) )
EndIf

For nFor := 1 to nChild

	//��������������������������Ŀ
	//�Busca o obj do nod filho  �
	//����������������������������
	If !lRecurs
		oNodCld	:= XmlGetChild( oXml,nFor)
	Else
		oNodCld	:= XmlGetChild( &("oXML" + cPathFt), nFor )
	EndIf
	
	//�������������������������������������������������������Ŀ
	//�Caso nao seja ultimo nod chama a rotina recursivamente �
	//���������������������������������������������������������
	If ValType(oNodCld) == "O" .AND. XmlChildCount(oNodCld) > 0
		cNodName := ":_" + oNodCld:REALNAME
		cKill := cPathFt + cNodName
		
		KillObj(@oXml, cKill)
	
	ElseIf ValType(oNodCld) == "O"

		//������������������Ŀ
		//�Limpa o nod filho �
		//��������������������
		cNodName := ":_" + oNodCld:REALNAME
		
		cKill := "oXml" + cPathFt + cNodName
		
		FreeObj(&cKill)
	
	EndIf
	
Next nFor   

//�����������������Ŀ
//�Limpa o obj. XML �
//�������������������
cKill := "oXml" + cPathFt
FreeObj(&cKill)

//��������������������������������������Ŀ
//�Libera fisicamente a memoria do server�
//����������������������������������������
If !lRecurs
	DelClassIntF()
EndIf

RestArea(aArea)


RESET ENVIRONMENT

Return