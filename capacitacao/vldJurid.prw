#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} vldJurid
//TODO Verifica se CPF possui processos na FUABC.
@author daniel.bastos
@since 01/10/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
user function vldJurid()
	local cMsg 		:= ""
	local cCpf 		:= strTran(alltrim(M->RA_CIC),"-","")
	local _cAlias	:= GetNextAlias()
	local lRet		:= .T.

	// Encerra processe se o CPF estiver em branco
	if empty(cCpf)
		return(lRet)
	endif

	// Levanta os processos deste CPF
	cQry := " SELECT  " + chr(13)
	cQry += " ZJ1_PROCES " + chr(13)
	cQry += " FROM " + RetSQLName("ZJ1") + " ZJ1 " + chr(13)
	cQry += " WHERE TRIM(ZJ1_CGC) = '" + cCpf + "' " + chr(13)
	cQry += " AND ZJ1.D_E_L_E_T_ <> '*'" + chr(13)

	if select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,, cQry), _cAlias, .T., .F.)

	while (_cAlias)->(!EOF())
		cMsg += "    - N.: " + (_cAlias)->ZJ1_PROCES + chr(13)

		(_cAlias)->(dbSkip())
	enddo

	if !(empty(cMsg))
		cMsg := "Constam o(s) processo(s) jurídico(s) abaixo para o CPF " + cCpf + ":"+ chr(13)  + chr(13) + cMsg
		msgAlert(cMsg)

		lRet := .F.
	endif

	if select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	EndIf

return(lRet)