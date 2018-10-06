#include 'protheus.ch'
#include 'parmtype.ch'


user function FI290COLS()
Local nTipo 	:= PARAMIXB[1] //
Local aRet 		:= PARAMIXB[2]
Local nI 		:= PARAMIXB[3]
Local aColPE 	:= {}
Local nCount
local lNUMCTA	:= SuperGetMv("FU_NUMCTA",,.F.)

if lNUMCTA
	aColPE 	:= {"E2_XPROCES","E2_MESBASE","E2_ANOBASE","E2_NUMCTA","E2_HIST"}
else
	aColPE 	:= {"E2_XPROCES","E2_MESBASE","E2_ANOBASE","E2_HIST"}
endif


// Condição utilizado para retornar o restante do aHeader
if nTipo == 1
	dbSelectArea("SX3")
	dbSetOrder(2)
	For nCount := 1 to len(aColPE)
		msSeek(aColPE[nCount])
		aAdd(aRet,{ X3TITULO(aColPE[nCount]), ;
					aColPE[nCount], ;
					X3PICTURE(aColPE[nCount]), ;
					TamSx3(aColPE[nCount])[1],;
					0,;
					"",;
					"û",;
					Posicione("SX3",2,aColPE[nCount],'X3_TIPO'),;
					"SE2" } )
	next
else // Ponto que Incrementa os valores das colunas
	aAdd(aRet[nI],SE2->E2_XPROCES)
	aAdd(aRet[nI],SE2->E2_MESBASE)
	aAdd(aRet[nI],SE2->E2_ANOBASE)

	if lNUMCTA
		aAdd(aRet[nI],SE2->E2_NUMCTA)
	endif

	aAdd(aRet[nI],SE2->E2_HIST)

	aAdd(aRet[nI],.F.)
endif

Return(aRet)