#include "protheus.ch"
#include "parmtype.ch"
#include "totvs.ch"


/*/{Protheus.doc} jsonSA2
//Enviar os dados do fornecedor para o sistema externo.
@author daniel.bastos
@since 19/07/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
user function jsonSA2(cCodigo,cLoja)
Local cUrl 		:= GetMv("FU_JSURLFN")
Local cWebServ 	:= GetMv("FU_JSWSERV")
Local cMetodo	:= GetMv("FU_JSMFORN")
local cLogin	:= GetMv("FU_JSUSER")
local cSenha	:= GetMv("FU_JSSENHA")
local lMessage		:= .F.
Local nTimeOut := 120
Local aHeader := {}
Local cHeadRet := ""
Local sPostRet := ""
Local cChave := ""
Local cDDD := ""
Local cFone := ""
Local cEmail := ""
Local cSite := ""

local oIntJson := nil

aAdd(aHeader,"Accept:application/json" )
aadd(aHeader,"Content-Type: application/json")

/*RpcClearEnv()
RPCSetType(3)
RpcSetEnv("18","01")

cUrl 	:= superGetMv("FU_JSURLFN",,"http://hsist.no-ip.org:81/integracao_protheus/setFornec")
cWebServ:= superGetMv("FU_JSWSERV",,"Hsist")
cMetodo	:= superGetMv("FU_JSMFORN",,"setFornec")
cLogin	:= superGetMv("FU_JSUSER",,"fuabc")
cSenha	:= superGetMv("FU_JSSENHA",,"iierbs")
*/
dbSelectArea("SA2")
SA2->(dbSetOrder(1))
SA2->(msSeek(xFilial("SA2") + cCodigo + cLoja))

cChave := alltrim(SA2->(A2_FILIAL)) + "|"
cChave += alltrim(SA2->(A2_CGC)) + "|"
cChave += alltrim(SA2->(A2_NOME)) + "|"
cChave += alltrim(SA2->(A2_NREDUZ)) + "|"

cJson := '{'
cJson += '"auth":{"login":"' + cLogin + '","senha":"' + cSenha + '"},' + chr(13)
cJson += '    "data":['

cJson += '{'
cJson += '"for_cnpj":"' + SA2->A2_CGC + '",' + chr(13)
cJson += '"for_razao":"' + alltrim(SA2->A2_NOME) + '",' + chr(13)
cJson += '"for_nomfan":"' + alltrim(SA2->A2_NREDUZ) + '",' + chr(13)

//-------------------
//ver este tratamento
//-------------------
cJson += '"for_tiplog":"",' + chr(13)

cJson += '"for_nomlog":"' + alltrim(SA2->A2_END) + '",' + chr(13)
cJson += '"for_numero":"' + alltrim(SA2->A2_NR_END) + '",' + chr(13)
cJson += '"for_comple":"' + alltrim(SA2->A2_COMPLEM) + '",' + chr(13)
cJson += '"for_cep":"' + alltrim(SA2->A2_CEP) + '",' + chr(13)
cJson += '"for_bairro":"' + alltrim(SA2->A2_BAIRRO) + '",' + chr(13)
cJson += '"for_cidade":"' + alltrim(SA2->A2_MUN) + '",' + chr(13)
cJson += '"for_uf":"' + SA2->A2_EST + '",' + chr(13)

//----------------------------------
//Tratamento em fornecedor x contato
//----------------------------------
dbSelectArea("ZCT")
ZCT->(dbSetOrder(1))

if ZCT->(msSeek(xFilial("ZCT") + SA2->A2_COD + SA2->A2_LOJA))
	cDDD   := ZCT->ZCT_DDD
	cFone  := ZCT->ZCT_FONE
	cEmail := alltrim(ZCT->ZCT_EMAIL)
	cSite  := ""
endif

cJson += '"for_telddd":"' + cDDD  + '",' + chr(13)
cJson += '"for_telefo":"' + cFone + '",' + chr(13)
cJson += '"for_email":"' + cEmail + '",' + chr(13)
cJson += '"for_site":"' + cSite + '"' + chr(13)

cJson += '}'

cJson += ']'
cJson += '}'

cJson := EncodeUTF8(cJson)

sPostRet := HttpPost(cUrl,"",cJson,nTimeOut,aHeader,@cHeadRet)

if Valtype(sPostRet) == "C"
	oIntJson := integJson():New()
	oIntJson:atualizaJson(cWebServ, cMetodo, cChave, cJson, sPostRet, lMessage)
EndIf

return()