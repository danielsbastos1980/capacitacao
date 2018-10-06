#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
// #########################################################################################
// Projeto: Específicos FUABC
// Modulo : Compras
// Fonte  : facoma13
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 23/10/15 | Daniel S. Bastos  | Desenvolvimento inicial
// ---------+-------------------+-----------------------------------------------------------
user function altZJ1()

private _cFOpen := "C:\arquivos\juridico\juridico.csv"

RpcClearEnv()
RPCSetType(3)
RpcSetEnv("01","01")

runProc()

return()


//------------------------------------------------------------------------------------------
// Processa importação
//------------------------------------------------------------------------------------------
static function runProc()
local n 		:= 1
local aItens	:= {}
local nLinha	:= 0

//Tratamento dos dados no arquivo
FT_FUSE(_cFOpen)
FT_FGOTOP()

While !FT_FEOF()
	nLinha++

	cLinha := strtran(Alltrim(FT_FREADLN()),'"',"")

 	cNord	:= substr(alltrim(cLinha),1,(At(";",alltrim(cLinha))-1))
	cLinha  := Substr(cLinha,(At(";",cLinha)+1),700)

	cParte	:= substr(alltrim(cLinha),1,(At(";",alltrim(cLinha))-1))
	cLinha  := Substr(cLinha,(At(";",cLinha)+1),700)

	cContra	:= substr(alltrim(cLinha),1,(At(";",alltrim(cLinha))-1))
	cLinha  := Substr(cLinha,(At(";",cLinha)+1),700)

	cProc	:= substr(alltrim(cLinha),1,(At(";",alltrim(cLinha))-1))
	cLinha  := Substr(cLinha,(At(";",cLinha)+1),700)

	cTipo	:= substr(alltrim(cLinha),1,(At(";",alltrim(cLinha))-1))
	cLinha  := Substr(cLinha,(At(";",cLinha)+1),700)

	cCom	:= substr(alltrim(cLinha),1,(At(";",alltrim(cLinha))-1))
	cLinha  := Substr(cLinha,(At(";",cLinha)+1),700)

	cVara	:= substr(alltrim(cLinha),1,(At(";",alltrim(cLinha))-1))
	cLinha  := Substr(cLinha,(At(";",cLinha)+1),700)

	cStatus	:= substr(alltrim(cLinha),1,(At(";",alltrim(cLinha))-1))
	cvalor  := Substr(cLinha,(At(";",cLinha)+1),700)

	if !empty(cNord) .AND. nLinha >= 2
		aAdd(aItens,{alltrim(cProc), ;
						alltrim(cNord), ;
						upper(alltrim(cParte)), ;
						upper(alltrim(cContra)), ;
						upper(alltrim(cCom)), ;
						upper(alltrim(cVara)), ;
						val(alltrim(cvalor)), ;
						upper(alltrim(cTipo)), ;
						upper(alltrim(cStatus))})
	endif

	FT_FSKIP()
enddo

FT_FUSE()

dbSelectArea("ZJ1")
ZJ1->(dbSetOrder(1))

for n := 1 to len(aItens)
	if !(msSeek(xFilial("ZJ1") + padr(aItens[n][01],tamsx3("ZJ1_PROCES")[1])))
		recLock("ZJ1",.T.)
			ZJ1->ZJ1_PROCES := aItens[n][01]
			ZJ1->ZJ1_NORD   := strZero(val(aItens[n][02]),4)
			ZJ1->ZJ1_NOMPAR := aItens[n][03]
			ZJ1->ZJ1_UNIDES := aItens[n][04]
			ZJ1->ZJ1_COMARC := aItens[n][05]
			ZJ1->ZJ1_VARA   := aItens[n][06]
			ZJ1->ZJ1_VALOR  := aItens[n][07]
			ZJ1->ZJ1_OBS    := aItens[n][08] + " | " + aItens[n][09]
			ZJ1->ZJ1_OBSMEM := aItens[n][08] + " | " + aItens[n][09]
		MsUnLock()
	endif
next

msgAlert("Fim processo.")

return