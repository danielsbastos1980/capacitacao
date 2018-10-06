#include "apwebsrv.ch"
#include "protheus.ch"
#include "parmtype.ch"
#include "restful.ch"
#include "totvs.ch"
#include "xmlcsvcs.ch"

user function jsonSD1()
Local cUrl := "http://hsist.no-ip.org:81/integracao_protheus/setNF"
Local nTimeOut := 120
Local aHeader := {}
Local cHeadRet := ""
Local cFiltro := ""
Local sPostRet := ""
local oJson := nil

aAdd(aHeader, "Accept: application/json" )
aadd(aHeader,'Content-Type: application/json')

RpcClearEnv()
RPCSetType(3)
RpcSetEnv("01","01")

cFiltro := "D1_FILIAL == " + SD1->D1_FILIAL + " .AND. D1_DOC == " + SD1->D1_DOC  + " .AND. D1_SERIE == " + SD1->D1_SERIE  + " .AND. D1_FORNECE == " + SD1->D1_FORNECE  + " .AND. D1_LOJA == " + SD1->D1_LOJA"

dbSelectArea("SD1")
SD1->(dbSetOrder(1))
SD1->(dbGoTop())

cJson := '{'
cJson += '"auth":{"login":"fuabc","senha":"iierbs"},'
cJson += '    "data":['

nLinha := 0

while SD1->(!EOF())

	nLinha++

	if nLinha >= 2
		cJson += ','
	endif

	cJson += '{'
	cJson += '"for_cnpj":"' + SD1->A2_CGC + '",'
	cJson += '"for_razao":"' + alltrim(SD1->A2_NOME) + '",'
	cJson += '"for_nomfan":"' + alltrim(SD1->A2_NREDUZ) + '",'

	cJson += '"for_tiplog":"' + "xxx" + '",' //ver este tratamento

	cJson += '"for_nomlog":"' + alltrim(SD1->A2_END) + '",'
	cJson += '"for_numero":"' + alltrim(SD1->A2_NR_END) + '",'
	cJson += '"for_comple":"' + alltrim(SD1->A2_COMPLEM) + '",'
	cJson += '"for_cep":"' + alltrim(SD1->A2_CEP) + '",'
	cJson += '"for_bairro":"' + alltrim(SD1->A2_BAIRRO) + '",'
	cJson += '"for_cidade":"' + alltrim(SD1->A2_MUN) + '",'
	cJson += '"for_uf":"' + SD1->A2_EST + '",'

	//Tratar em fornecedor x contato
	cJson += '"for_telddd":"' + "xxx"  + '",'
	cJson += '"for_telefo":"' + "xxx" + '",'
	cJson += '"for_email":"' + "xxx" + '",'
	cJson += '"for_site":"' + "xxx" + '"'
	cJson += '}'

	SD1->(dbSkip())
enddo

cJson += ']'
cJson += '}'

//HttpPost( < cUrl >, [ cGetParms ], [ cPostParms ], [ nTimeOut ], [ aHeadStr ], [ @cHeaderGet ] )
sPostRet := HttpPost(cUrl,"",cJson,nTimeOut,aHeader,@cHeadRet)
if empty(sPostRet)
  msgAlert("Sem retorno")

else
	If FWJsonDeserialize(sPostRet,@oJson)
		MsgInfo(oJson:message + " - " + oJson:status)
	else
		MsgInfo("Não realizou o deSerialize!")
	EndIf
Endif

RpcClearEnv()

return