#include "protheus.ch"
#include "parmtype.ch"
#include "totvs.ch"

user function jsonSD3()
Local cUrl 		:= "http://localhost:8084/rest/index/MOVINTERNO"
Local nTimeOut := 120
Local aHeader := {}
Local cHeadRet := ""
Local sPostRet := ""
Local cAliasD3  := GetNextAlias()
local nLinha := 0
local nTotalReg := 0

aAdd(aHeader,"Accept:application/json")
aadd(aHeader,"Content-Type: application/json")
//aadd(aHeader,"tenantId: 99,01")

cQry := " SELECT D3_FILIAL, " + chr(13)
cQry += "   D3_TM, " + chr(13)
cQry += "   D3_CC, " + chr(13)
cQry += "   D3_EMISSAO, " + chr(13)
cQry += "   D3_COD, " + chr(13)
cQry += "   D3_QUANT, " + chr(13)
cQry += "   D3_LOTECTL, " + chr(13)
cQry += "   D3_LOCAL, " + chr(13)
cQry += "   D3_DOC "  + chr(13) + chr(13)

cQry += " FROM  "
cQry += RetSQLName("SD3") + " SD3  " + chr(13) + chr(13)

cQry += " WHERE D3_FILIAL   = '" + SD3->D3_FILIAL + "' " + chr(13)
cQry += " AND D3_DOC        = '" + SD3->D3_DOC + "' " + chr(13)
cQry += " AND D3_CC        	= '" + SD3->D3_CC + "' " + chr(13)
cQry += " AND D3_EMISSAO 	= '" + dTos(SD3->D3_EMISSAO) + "' " + chr(13)
cQry += " AND SD3.D_E_L_E_T_ <> '*' " + chr(13) + chr(13)

if select(cAliasD3) > 0
	(cAliasD3)->(dbCloseArea())
EndIf

cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,, cQry), cAliasD3, .T., .F.)

(cAliasD3)->(dbEval({||nTotalReg++}))
(cAliasD3)->(dbGotop())

if (cAliasD3)->(eof())
	msgAlert("Não há dados para a integração.")
	return
endif

cJson := '{'
cJson += '"auth":{"login":"fuabc","senha":"iierbs","empresa":"18","filial":"01"},' + chr(13)
cJson += '    "data":['

while (cAliasD3)->(!EOF())

	nLinha++

	if nLinha >= 2
		cJson += ','
	endif

	cJson += '{'
	cJson += '"mi_user":"' + alltrim(upper(cUserName)) + '",' + chr(13)
	cJson += '"mi_operacao":"I",' + chr(13)
	cJson += '"mi_idext":"' + alltrim((cAliasD3)->D3_DOC) + '",' + chr(13)

	cJson += '"mi_tm":"' + (cAliasD3)->D3_TM + '",' + chr(13)
	cJson += '"mi_cc":"' + (cAliasD3)->D3_CC + '",' + chr(13)
	cJson += '"mi_emissao":"' + (cAliasD3)->D3_EMISSAO + '",' + chr(13)

	cJson += '"mi_produto":"' + alltrim((cAliasD3)->D3_COD) + '",' + chr(13)

	cJson += '"mi_qtde":"' + alltrim(str((cAliasD3)->D3_QUANT)) + '",' + chr(13)
	cJson += '"mi_lote":"' + alltrim((cAliasD3)->D3_LOTECTL) + '",' + chr(13)
	cJson += '"mi_armazem":"' + (cAliasD3)->D3_LOCAL + '"' + chr(13)

	cJson += '}'

	(cAliasD3)->(dbSkip())
enddo

cJson += ']'
cJson += '}'

cJson := EncodeUTF8(cJson)

sPostRet := HttpPost(cUrl,"",cJson,nTimeOut,aHeader,@cHeadRet)

If Valtype(sPostRet) == "C"
	msgAlert("retorno Nil")

//	oIntJson := integJson():New()
//	oIntJson:atualizaJson(cWebServ, cMetodo, cChave, cJson, sPostRet)
else
	msgAlert("retorno C")

EndIf

return()