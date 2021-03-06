#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} filcpb1
//TODO Monta filtro de centro de custo do usu�rio logado (� necess�rio preencher o campo RA_APELIDO com o login) para a consulta padr�o "SB1" - .
@author daniel.bastos
@since 25/05/2012
@version 6
@return ${return}, ${return_description}

@type function
/*/
user function FILCPB1()
	local cFiltro := ""
	//-------------------------------------------------------------------------------------
	//Posiciona na tabela de funcion�rios para obter o centro de custo com base no apelido
	//-------------------------------------------------------------------------------------
	dbSelectArea("SRA")
	SRA->(dbSetOrder(10))
	SRA->(dbGoTop())
	if msSeek(alltrim(cUserName))
		cFiltro := '"' + alltrim(SRA->RA_CC) + '" $ B1_XCC'
	endif

return(cFiltro)