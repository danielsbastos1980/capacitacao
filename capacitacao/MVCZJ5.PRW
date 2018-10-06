#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'fwbrowse.ch'

#DEFINE MAX_WHILE 500

/*/{Protheus.doc} MVCZJ5
Cadastro de Varas (MVC)
@author Daniel S. Bastos
@since 01/10/2018
@version 1.0
/*/
User Function MVCZJ5()
	Local oBrowse   := nil

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZJ5")
	oBrowse:SetMenuDef("MVCZJ5")
	oBrowse:SetDescription("Cadastro de Varas")

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
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.MVCZJ5" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.MVCZJ5"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.MVCZJ5" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.MVCZJ5" OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function ModelDef()
	Local oModel    := nil
	Local oStruct   := FWFormStruct(1,'ZJ5')
	Local bPosFM := { |oModel| fPosValidFM(oModel) }

	oModel := MPFormModel():New("MDLMVCZJ5",/*bPreVldFM*/,bPosFM,/*bCommit*/,/*bCancelFM*/)

	oModel:AddFields('ZJ5MASTER',/*cOwner*/,oStruct,,/*bPosVldF*/,/*bCarga*/)

	oModel:SetPrimaryKey({'ZJ5_FILIAL','ZJ5_COD'})

Return oModel

/*/{Protheus.doc} ViewDef
View do modelo de dados
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function ViewDef()
	Local oView   := nil
	Local oModel  := FWLoadModel('MVCZJ5')
	Local oStruct := FWFormStruct(2,'ZJ5')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_ZJ5',oStruct,'ZJ5MASTER')

Return oView


/*/{Protheus.doc} fPreValidFM
//TODO Descrição auto-gerada.
@author daniel.bastos
@since 02/10/2018
@version 6
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
static function fPosValidFM(oModel)
	local lRet := .T.
	local _cAlias := GetNextAlias()
	local cQry := ""

	//Tratamento de exclusão
	if oModel:nOperation == 5

		cQry := "  SELECT 'ZJ1' AS TABELA, " + chr(13)
		cQry += "     ZJ1_FILIAL AS FILIAL, " + chr(13)
		cQry += "     ZJ1_PROCES AS PROCESSO, " + chr(13)
		cQry += "     ZJ1_RESPON       AS RESPONSAVEL, " + chr(13)
		cQry += "     ZJ1_UNIDAD       AS UNIDADE, " + chr(13)
		cQry += "     ZJ1_COMARC       AS COMARCA, " + chr(13)
		cQry += "     ZJ1_VARA         AS VARA " + chr(13)
		cQry += "   FROM "
		cQry += retSqlName("ZJ1") +" ZJ1 " + chr(13)
		cQry += "   WHERE TRIM(ZJ1_VARA) = '" + alltrim(ZJ5->ZJ5_COD) + "' " + chr(13)
		cQry += "   AND ZJ1.D_E_L_E_T_    <> '*' " + chr(13)

		if select(_cAlias) > 0
			(_cAlias)->( dbCloseArea())
		endif

		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,, cQry), _cAlias, .T., .F.)

		(_cAlias)->(dbGoTop())

		if (_cAlias)->(!EOF())
			lRet := .F.
			Help(NIL, NIL, "HELP", NIL, "Registro está sendo utilizado em processos jurídicos.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Não poderá ser excluído!"})
		endif

		if select(_cAlias) > 0
			(_cAlias)->( dbCloseArea())
		endif
	endif

return(lRet)