#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'fwbrowse.ch'

#DEFINE MAX_WHILE 500

/*/{Protheus.doc} MVCZJ2
Cadastro de Pendências jurídicas (MVC)
@author Daniel S. Bastos
@since 01/10/2018
@version 1.0
/*/
User Function MVCZJ2()
	Local oBrowse   := nil
	local cFiltro := ""
	//filtra/libera acesso ao browse de acordo com perfil de usuário
	StaticCall(MVCZJ2,fFiltro,@cFiltro)

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZJ2")
	oBrowse:SetMenuDef("MVCZJ2")
	oBrowse:SetFilterDefault(cFiltro)
	oBrowse:SetDescription("Cadastro de Pendências jurídicas")
	oBrowse:AddLegend("ZJ2_PEND=='1'"	, "GREEN" , "Pendência em aberto")
	oBrowse:AddLegend("ZJ2_PEND<>'1'"	, "BLUE"  , "Pendência encerrada")


	oBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
Definição de Menus da rotina
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "PesqBrw" 		OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.MVCZJ2" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.MVCZJ2" OPERATION 4 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function ModelDef()
	Local oModel    := nil
	Local oStruct   := FWFormStruct(1,'ZJ2')
	Local bPosFM := { |oModel| fPosValidFM(oModel) }

	oModel := MPFormModel():New("MDLMVCZJ2",/*bPreVldFM*/,/*bPosFM*/,/*bCommit*/,/*bCancelFM*/)

	oModel:AddFields('ZJ2MASTER',/*cOwner*/,oStruct,,/*bPosVldF*/,/*bCarga*/)

	oModel:SetPrimaryKey({'ZJ2_FILIAL','ZJ2_COD'})

Return oModel

/*/{Protheus.doc} ViewDef
View do modelo de dados
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function ViewDef()
	Local oView   := nil
	Local oModel  := FWLoadModel('MVCZJ2')
	Local oStruct := FWFormStruct(2,'ZJ2')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_ZJ2',oStruct,'ZJ2MASTER')

Return oView


/*/{Protheus.doc} fFiltro
//TODO Descrição auto-gerada.
@author daniel.bastos
@since 05/10/2018
@version 6
@return ${return}, ${return_description}
@param cFiltro, characters, descricao
@type function
/*/
static function fFiltro(cFiltro)
	local cQry := ""
	Local _cAlias  := GetNextAlias()

	cQry := " SELECT " + chr(13)
	cQry += "     ZJ3_LOGIN,    " + chr(13)
	cQry += "      ZJ3_COD  " + chr(13)
	cQry += "    FROM "
	cQry += retSqlName("ZJ3") + " ZJ3  " + chr(13) + chr(13)

	cQry += "    WHERE ZJ3_FILIAL = '" + xFilial("ZJ1") + "' " + chr(13)
	cQry += "    AND TRIM(ZJ3_LOGIN) = '" + alltrim(cUserName) + "' " + chr(13)  + chr(13)
	cQry += "    AND ZJ3.D_E_L_E_T_ <> '*' " + chr(13)  + chr(13)

	if select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,, cQry), _cAlias, .T., .F.)

	(_cAlias)->(dbGotop())

	if (_cAlias)->(!eof())
		cFiltro := "'" + alltrim((_cAlias)->ZJ3_COD) + "' == alltrim(ZJ2_RESPON)"
	endif

	if select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	EndIf

return