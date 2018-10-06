#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'fwbrowse.ch'

#DEFINE MAX_WHILE 500

/*/{Protheus.doc} MVCZJ3
Cadastro Advogados responsáveis (MVC)
@author Daniel S. Bastos
@since 01/10/2018
@version 1.0
/*/
User Function MVCZJ3()
	Local oBrowse   := nil

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZJ3")
	oBrowse:SetMenuDef("MVCZJ3")
	oBrowse:SetDescription("Cadastro Advogados responsáveis")

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
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.MVCZJ3" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.MVCZJ3"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.MVCZJ3" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.MVCZJ3" OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function ModelDef()
	Local oModel    := nil
	Local oStruct   := FWFormStruct(1,'ZJ3')
	Local bPosFM := { |oModel| fPosValidFM(oModel) }

	oModel := MPFormModel():New("MDLMVCZJ3",/*bPreVldFM*/,bPosFM,/*bCommit*/,/*bCancelFM*/)

	oModel:AddFields('ZJ3MASTER',/*cOwner*/,oStruct,,/*bPosVldF*/,/*bCarga*/)

	oModel:SetPrimaryKey({'ZJ3_FILIAL','ZJ3_COD'})

Return oModel

/*/{Protheus.doc} ViewDef
View do modelo de dados
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function ViewDef()
	Local oView   := nil
	Local oModel  := FWLoadModel('MVCZJ3')
	Local oStruct := FWFormStruct(2,'ZJ3')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_ZJ3',oStruct,'ZJ3MASTER')

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

		cQry := " SELECT TABELA, " + chr(13)
		cQry += "   FILIAL, " + chr(13)
		cQry += "   PROCESSO, " + chr(13)
		cQry += "   RESPONSAVEL, " + chr(13)
		cQry += "   COMARCA, " + chr(13)
		cQry += "   VARA " + chr(13)
		cQry += " FROM " + chr(13)
		cQry += "   (SELECT 'ZJ1' AS TABELA, " + chr(13)
		cQry += "     ZJ1_FILIAL AS FILIAL, " + chr(13)
		cQry += "     ZJ1_PROCES AS PROCESSO, " + chr(13)
		cQry += "     ZJ1_RESPON       AS RESPONSAVEL, " + chr(13)
		cQry += "     ZJ1_COMARC       AS COMARCA, " + chr(13)
		cQry += "     ZJ1_VARA         AS VARA " + chr(13)
		cQry += "   FROM "
		cQry += retSqlName("ZJ1") +" ZJ1 " + chr(13)
		cQry += "   WHERE TRIM(ZJ1_RESPON) = '" + alltrim(ZJ3->ZJ3_COD) + "' " + chr(13)
		cQry += "   AND ZJ1.D_E_L_E_T_    <> '*' " + chr(13)
		cQry += "   UNION ALL " + chr(13)
		cQry += "   SELECT 'ZJ2' AS TABELA, " + chr(13)
		cQry += "     ZJ2_FILIAL AS FILIAL, " + chr(13)
		cQry += "     ZJ1_PROCES AS PROCESSO, " + chr(13)
		cQry += "     ZJ2_RESPON      AS RESPONSAVEL, " + chr(13)
		cQry += "     ZJ1_COMARC      AS COMARCA, " + chr(13)
		cQry += "     ZJ1_VARA        AS VARA " + chr(13)
		cQry += "   FROM "
		cQry += retSqlName("ZJ2") +" J2 " + chr(13)
		cQry += "   INNER JOIN "
		cQry += retSqlName("ZJ1") +" J1 " + chr(13)
		cQry += "   ON ZJ2_FILIAL          = ZJ2_FILIAL " + chr(13)
		cQry += "   AND ZJ2_PROCES         = ZJ1_PROCES " + chr(13)
		cQry += "   AND J1.D_E_L_E_T_     <> '*' " + chr(13)
		cQry += "   WHERE TRIM(ZJ2_RESPON) = '" + alltrim(ZJ3->ZJ3_COD) + "' " + chr(13)
		cQry += "   AND J2.D_E_L_E_T_     <> '*') " + chr(13)

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