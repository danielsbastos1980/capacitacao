#include "protheus.ch"
#include "parmtype.ch"
#include "totvs.ch"
#include "tbiconn.ch
#include "topconn.ch"

user function jsonSF1()
Local cUrl 		:= GetMv("FU_JSURLNF")
Local cWebServ 	:= GetMv("FU_JSWSERV")
Local cMetodo	:= GetMv("FU_JSMETNF")
local cLogin	:= GetMv("FU_JSUSER")
local cSenha	:= GetMv("FU_JSSENHA")
local lMessage	:= .T.
local cTES		:= superGetMv("FU_JSNFTES",,"001")
Local nTimeOut := 120
Local aHeader := {}
Local cHeadRet := ""
Local sPostRet := ""
Local cChave := ""
Local cAliasF1  := GetNextAlias()
local nTotalReg := 0
local nCusto := 0
local oIntJson := nil

aAdd(aHeader,"Accept:application/json" )
aadd(aHeader,"Content-Type: application/json")

//-----------------------------------
// Envia fornecedor para assistencial
//-----------------------------------
processa({||u_jsonSA2(SF1->F1_FORNECE,SF1->F1_LOJA)},"Processando integração fornecedor...")

cQry := " SELECT F1_FILIAL, " + chr(13)
cQry += "   F1_DOC, " + chr(13)
cQry += "   F1_SERIE, " + chr(13)
cQry += "   F1_FORNECE, " + chr(13)
cQry += "   F1_LOJA, " + chr(13)
cQry += "   F1_VALBRUT, " + chr(13)
cQry += "   F1_EMISSAO, " + chr(13)
cQry += "   F1_DTDIGIT, " + chr(13)
cQry += "   A2_CGC, " + chr(13)
cQry += "   D1_TES, " + chr(13)
cQry += "   D1_PEDIDO, " + chr(13)
cQry += "   D1_LOCAL, " + chr(13)
cQry += "   D1_COD, " + chr(13)
cQry += "   D1_QUANT, " + chr(13)
cQry += "   D1_UM, " + chr(13)
cQry += "   D1_LOTECTL, " + chr(13)
cQry += "   D1_DTVALID, " + chr(13)
cQry += "   D1_VUNIT, " + chr(13)
cQry += "   D1_CUSTO " + chr(13) + chr(13)

cQry += " FROM  "
cQry += RetSQLName("SF1") + " SF1  " + chr(13) + chr(13)

cQry += " INNER JOIN  "
cQry += RetSQLName("SD1") + " SD1  " + chr(13)
cQry += " ON D1_FILIAL        = F1_FILIAL " + chr(13)
cQry += " AND D1_DOC          = F1_DOC " + chr(13)
cQry += " AND D1_SERIE        = F1_SERIE " + chr(13)
cQry += " AND D1_FORNECE      = F1_FORNECE " + chr(13)
cQry += " AND D1_LOJA         = F1_LOJA " + chr(13)

if cTES == "001"
	cQry += " AND D1_TES          = '" + cTES + "'   " + chr(13)
endif

cQry += " AND SD1.D_E_L_E_T_ <> '*' " + chr(13) + chr(13)

cQry += " INNER JOIN  "
cQry += RetSQLName("SA2") + " SA2  " + chr(13)
cQry += " ON A2_FILIAL        = '" + xFilial("SA2") + "' " + chr(13)
cQry += " AND A2_COD          = F1_FORNECE " + chr(13)
cQry += " AND A2_LOJA         = F1_LOJA " + chr(13)
cQry += " AND SA2.D_E_L_E_T_ <> '*' " + chr(13) + chr(13)

cQry += " WHERE F1_FILIAL     = '" + xFilial("SF1") + "' " + chr(13)
cQry += " AND F1_DOC          = '" + SF1->F1_DOC + "' " + chr(13)
cQry += " AND F1_SERIE        = '" + SF1->F1_SERIE + "' " + chr(13)
cQry += " AND F1_FORNECE      = '" + SF1->F1_FORNECE + "' " + chr(13)
cQry += " AND F1_LOJA         = '" + SF1->F1_LOJA + "' " + chr(13)

cQry += " AND SF1.D_E_L_E_T_ <> '*' " + chr(13)

if select(cAliasF1) > 0
	(cAliasF1)->(dbCloseArea())
EndIf

cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,, cQry), cAliasF1, .T., .F.)

(cAliasF1)->(dbEval({||nTotalReg++}))
(cAliasF1)->(DbEval({||nCusto += (cAliasF1)->(D1_CUSTO) }))
(cAliasF1)->(dbGotop())

if (cAliasF1)->(eof())
	msgAlert("Não há dados para a integração.")
	return
endif

procRegua(nTotalReg)

cChave := alltrim((cAliasF1)->(F1_FILIAL)) + "|"
cChave += alltrim((cAliasF1)->(F1_DOC)) + "|"
cChave += alltrim((cAliasF1)->(F1_SERIE)) + "|"
cChave += alltrim((cAliasF1)->(F1_FORNECE)) + "|"
cChave += alltrim((cAliasF1)->(F1_LOJA)) + "|"

cJson := '{'
cJson += '"auth":{"login":"' + cLogin + '","senha":"' + cSenha + '"},' + chr(13)
cJson += '    "data":['
cJson += '		{'
cJson += '		"nf_numero":"' + alltrim((cAliasF1)->(F1_DOC)) + '",' + chr(13)
cJson += '		"nf_serie":"' + alltrim((cAliasF1)->(F1_SERIE)) + '",' + chr(13)
cJson += '		"nf_cnpj":"' + (cAliasF1)->(A2_CGC) + '",' + chr(13)
cJson += '		"nf_datemi":"' + (cAliasF1)->(F1_EMISSAO) + '",' + chr(13)
cJson += '		"nf_datent":"' + (cAliasF1)->(F1_DTDIGIT) + '",' + chr(13)
cJson += '		"nf_tipent":"' + (cAliasF1)->(D1_TES) + '",' + chr(13)
cJson += '		"nf_pedido":"' + alltrim((cAliasF1)->(D1_PEDIDO)) + '",' + chr(13)
cJson += '		"nf_valtot":"' + alltrim(str(nCusto)) + '",' + chr(13)
cJson += '		"nf_armaze":"' + (cAliasF1)->(D1_LOCAL) +'",' + chr(13)
cJson += '		"nf_usuari":"' + upper(cUserName) + '",' + chr(13)
cJson += '		"nf_produt":['

nLinha := 0

while (cAliasF1)->(!EOF())

	nLinha++

	if nLinha >= 2
		cJson += ','
	endif

	cJson += '		{'
	cJson += '		"pro_codigo":"' + alltrim((cAliasF1)->(D1_COD)) + '",' + chr(13)
	cJson += '		"pro_quanti":"' + alltrim(str((cAliasF1)->(D1_QUANT))) + '",' + chr(13)
	cJson += '		"pro_unidad":"' + (cAliasF1)->(D1_UM) + '",' + chr(13)
	cJson += '		"pro_lote":"' + alltrim((cAliasF1)->(D1_LOTECTL)) + '",' + chr(13)
	cJson += '		"pro_valida":"' + alltrim((cAliasF1)->(D1_DTVALID)) + '",' + chr(13)
	cJson += '		"pro_valuni":"' + alltrim(str((cAliasF1)->(D1_VUNIT))) + '",' + chr(13)
	cJson += '		"pro_valtot":"' + alltrim(str((cAliasF1)->(D1_CUSTO))) + '"' + chr(13)
	cJson += '		}

	(cAliasF1)->(dbSkip())
enddo

cJson += '	]'
cJson += '	}'

cJson += ']'
cJson += '}'

cJson := EncodeUTF8(cJson)

if select(cAliasF1) > 0
	(cAliasF1)->(dbCloseArea())
EndIf

sPostRet := HttpPost(cUrl,"",cJson,nTimeOut,aHeader,@cHeadRet)

oIntJson := integJson():New()

If Valtype(sPostRet) == "C"
	oIntJson := integJson():New()
	oIntJson:atualizaJson(cWebServ, cMetodo, cChave, cJson, sPostRet, lMessage)
Else
	msgAlert("O sistema não identificou o retorno da integração!")
EndIf

return()