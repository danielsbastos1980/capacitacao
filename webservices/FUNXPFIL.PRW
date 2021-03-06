#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao	 �FUNXPFIL �Autor �Leandro Kenji de Moura� Data �  02/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para tratamento na filial utilizada na integracao	  ���
���          �															  					  ���
�������������������������������������������������������������������������͹��
���Uso       � Customizado Fund. ABC                       				  	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FUNXPFIL(cAlias)

Local aArea			:= GetArea()			  			// Armazena ultima area utilizada
Local cFilInt 		:= SuperGetMv("FS_FILINT",,"")// Filial para processamento da integracao
Local lRet			:= .T.								// Variavel de retorno


//����������������������������������������������Ŀ
//�Verifica compartilhamento do alias informado  �
//������������������������������������������������
If ADMTabExc(cAlias)

	If Empty(cFilInt)
		lRet := .F.
		AAdd(_aMsgErr, { "Filial de processamento nao informada - parametro [ FS_FILINT ]", "04", "" } )

	ElseIf !(cFilAnt == cFilInt)
		
		//���������������������������������������Ŀ
		//�Simula a filial informada no parametro �
		//�����������������������������������������
		cFilAnt := cFilInt
	EndIf 

EndIf

RestArea(aArea)


Return lRet