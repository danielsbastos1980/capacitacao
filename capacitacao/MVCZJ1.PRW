#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'fwbrowse.ch'

#DEFINE MAX_WHILE 500

/*/{Protheus.doc} MVCZJ1
Controle dos processos jurídicos (MVC)
@author Daniel S. Bastos
@since 01/10/2018
@version 1.0
/*/
User Function MVCZJ1()
	Local oBrowse   := nil

	dbSelectArea("ZJ2")

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZJ1")
	oBrowse:SetMenuDef("MVCZJ1")
	oBrowse:SetDescription("Processos Juridicos")

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
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.MVCZJ1" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.MVCZJ1"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.MVCZJ1" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.MVCZJ1" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Email Pends"	ACTION "StaticCall(MVCZJ1,fEmail)" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Suas Pends"	ACTION "StaticCall(MVCZJ2,u_MVCZJ2)" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Solic Docs"	ACTION "StaticCall(MVCZJ1,fSolDocs)" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Carta Finceira" ACTION "StaticCall(MVCZJ1,fFinanc)" OPERATION 4 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function ModelDef()
	Local oModel    := nil
	Local oStruCab  := FWFormStruct(1,'ZJ1')
	Local oStruGrid := FWFormStruct(1,'ZJ2',{|cCpoZJ2| (AllTrim(cCpoZJ2) $ "|ZJ2_ITEM|ZJ2_DTATUA|ZJ2_DTFAT|ZJ2_HORAR|ZJ2_RESPON|ZJ2_NOMRES|ZJ2_OBS|ZJ2_PEND")})

	oModel := MPFormModel():New("MDLMVCZJ1",/*bPreVldFM*/,/*bPosFM*/,/*bCommit*/,/*bCancelFM*/)

	oModel:AddFields('ZJ1MASTER',/*cOwner*/,oStruCab,,/*bPosVldF*/,/*bCarga*/)
	oModel:AddGrid('ZJ2GRID','ZJ1MASTER',oStruGrid,/*bPreValidacao*/,/*bLinePost*/,/*bCarga*/,/*bPost*/)

	oModel:SetRelation("ZJ2GRID",{{"ZJ2_FILIAL",'ZJ1_FILIAL'},;
										{"ZJ2_PROCES","ZJ1_PROCES"},;
										{"ZJ2_UNIDAD","ZJ1_UNIDAD"},;
										{"ZJ2_UNIDES","ZJ1_UNIDES"},;
										{"ZJ2_COMARC","ZJ1_COMARC"},;
										{"ZJ2_COMDES","ZJ1_COMDES"},;
										{"ZJ2_VARA","ZJ1_VARA"},;
										{"ZJ2_VARDES","ZJ1_VARDES"},;
										{"ZJ2_CGC","ZJ1_CGC"},;
										{"ZJ2_NOMPAR","ZJ1_NOMPAR"},;
										{"ZJ2_TIPO","ZJ1_TIPO"},;
										{"ZJ2_STATUS","ZJ1_STATUS"},;
										{"ZJ2_VALOR","ZJ1_VALOR"},;
										{"ZJ2_CC","ZJ1_CC"},;
										{"ZJ2_CCDESC","ZJ1_CCDESC"},;
										{"ZJ2_OBJETO","ZJ1_OBJETO"}},ZJ2->(IndexKey(1)))
*/
	oModel:SetPrimaryKey({'ZJ2_FILIAL','ZJ2_RESPON','ZJ2_DTATUA'})
	oModel:GetModel("ZJ2GRID"):SetUniqueLine({'ZJ2_DTATUA','ZJ2_RESPON','ZJ2_OBS'})
	oModel:SetDescription("Atualizações")
	oModel:GetModel("ZJ2GRID"):SetDescription("Atualizações do processo")

Return oModel

/*/{Protheus.doc} ViewDef
View do modelo de dados
@author Daniel S. Bastos
@since 03/04/2018
@version 1.0
/*/
Static Function ViewDef()
	Local oView     := nil
	Local oModel    := FWLoadModel('MVCZJ1')
	Local oStruCab  := FWFormStruct(2,'ZJ1')
	Local oStruGrid := FWFormStruct(2,'ZJ2',{|cCpoZJ2| (AllTrim(cCpoZJ2) $ "|ZJ2_ITEM|ZJ2_DTATUA|ZJ2_DTFAT|ZJ2_HORAR|ZJ2_RESPON|ZJ2_NOMRES|ZJ2_OBS|ZJ2_PEND")})

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_CAB',oStruCab,'ZJ1MASTER')
	oView:AddGrid('VIEW_GRID',oStruGrid,'ZJ2GRID')

	oView:AddIncrementField("ZJ2GRID" , "ZJ2_ITEM" )

	oView:CreateHorizontalBox('SUPERIOR',40)
	oView:CreateHorizontalBox('INFERIOR',60)

	oView:SetOwnerView('VIEW_CAB','SUPERIOR')
	oView:SetOwnerView('VIEW_GRID','INFERIOR')

	oView:EnableTitleView('VIEW_GRID', "Histórico" )
	oView:SetCloseOnOk({||.T.})

Return oView


static Function fEmail()
	local cQry := ""
	local cUsuario := ""
	Local _cAlias  := GetNextAlias()
	local aEmail := {}

	cQry := " SELECT " + chr(13)
	cQry += "     ZJ1_FILIAL AS FILIAL,  " + chr(13)
	cQry += "      ZJ1_PROCES AS PROCESSO,  " + chr(13)
	cQry += "      ZJ2_RESPON AS RESPONSAVEL,  " + chr(13)
	cQry += "      ZJ2_ITEM AS ITEM,  " + chr(13)
	cQry += "      ZJ1_COMARC AS COMARCA,  " + chr(13)
	cQry += "      ZJ2_DTFAT  AS DTFATAL, " + chr(13)
	cQry += "      ZJ2_HORAR AS HORARIO,  " + chr(13)
	cQry += "      ZJ3_EMAIL AS EMAIL,  " + chr(13)
	cQry += "      ZJ2_OBS   AS OBS  " + chr(13)
	cQry += "    FROM "
	cQry += retSqlName("ZJ1") + " ZJ1  " + chr(13) + chr(13)

	cQry += "    INNER JOIN "
	cQry += retSqlName("ZJ2") + " ZJ2  " + chr(13)
	cQry += "    ON ZJ2_FILIAL = ZJ1_FILIAL " + chr(13)
	cQry += "    AND ZJ2_PROCES = ZJ1_PROCES " + chr(13)
	cQry += "    AND ZJ2_PEND <> '2' " + chr(13)
	cQry += "    AND ZJ2.D_E_L_E_T_ <> '*' " + chr(13) + chr(13)

	cQry += "    INNER JOIN "
	cQry += retSqlName("ZJ3") + " ZJ3  " + chr(13)
	cQry += "    ON ZJ3_FILIAL = '" + xFilial("ZJ3") + "'  " + chr(13)
	cQry += "    AND ZJ3_COD = ZJ2_RESPON " + chr(13)
	cQry += "    AND ZJ3.D_E_L_E_T_ <> '*' " + chr(13) + chr(13)

	cQry += "    WHERE ZJ1_FILIAL = '" + xFilial("ZJ1") + "' " + chr(13)
	cQry += "    AND ZJ1.D_E_L_E_T_ <> '*' " + chr(13)  + chr(13)

	cQry += " ORDER BY RESPONSAVEL, PROCESSO DESC, ITEM " + chr(13)

	if select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,, cQry), _cAlias, .T., .F.)

	(_cAlias)->(dbGotop())

	if (_cAlias)->(eof())
		msgAlert("Não há pendências para envio.")
		return
	endif

	//---------------------------
	// Montagem do corpo do email
	//---------------------------
	cUsuario := (_cAlias)->RESPONSAVEL

	while (_cAlias)->(!EOF())

		aAdd(aEmail,{(_cAlias)->EMAIL, (_cAlias)->PROCESSO, (_cAlias)->ITEM, dToc(sTod((_cAlias)->DTFATAL)), (_cAlias)->HORARIO, alltrim((_cAlias)->OBS)})

		(_cAlias)->(dbSkip())

		if (_cAlias)->(EOF()) .OR. cUsuario <> (_cAlias)->RESPONSAVEL
			envPend(aEmail)

			cUsuario := (_cAlias)->RESPONSAVEL
			aEmail := {}
		endif
	enddo

	msgAlert("Fim de processo!")

return

static function envPend(aEmail)
	local cFrom := ""
	local cTo := aEmail[01][01]
	local cCC := ""
	local cAssunto := "Pendencias Juridicas"
	local cMsg := ""

	//---------------------------
	// Montagem do corpo do email
	//---------------------------
	cMsg:= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> ' + chr(13)
	cMsg+= '<html xmlns="http://www.w3.org/1999/xhtml"> ' + chr(13)
	cMsg+= '<head> ' + chr(13)
	cMsg+= '<title>Protheus - '+alltrim(UPPER(SM0->M0_NOME))+' - ' + cAssunto + '</title> ' + chr(13)
	cMsg+= '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> ' + chr(13)
	cMsg+= '<style type="text/css"> ' + chr(13)
	cMsg+= 'body {font-family:Arial, Helvetica, sans-serif; font-size:12px;} ' + chr(13)

	cMsg+= 'table.tblGrid1 {background-color:#FFF; margin:0; border:solid 1px #ccc; border-collapse:collapse; width:650px; height:80px;} ' + chr(13)
	cMsg+= 'table.tblGrid1 th {background-color:#FFF; color:#000; font-weight:bold; font-size:14px; border:solid 1px #999; text-align:center; height:30px} ' + chr(13)
	cMsg+= 'table.tblGrid1 td {vertical-align:middle; border:solid 1px #999; text-align:center; height:20px} ' + chr(13)
	cMsg+= 'table.tblGrid1 td, table.tblGrid th {padding:3px;} ' + chr(13)

	cMsg+= 'table.tblGrid2 {background-color:#FFF; margin:0; border:solid 1px #ccc; border-collapse:collapse; width:650px;} ' + chr(13)
	cMsg+= 'table.tblGrid2 th {background-color:#b2d0df; color:#000; font-weight:bold; font-size:14px; border:solid 1px #999; text-align:center; height:30px} ' + chr(13)
	cMsg+= 'table.tblGrid2 td {vertical-align:middle; border:solid 1px #999; text-align:left; height:20px} ' + chr(13)
	cMsg+= 'table.tblGrid2 td, table.tblGrid th {padding:3px;} ' + chr(13)
	cMsg+= 'table.tblGrid2 tr:hover, table.tblGrid tr.cinza:hover {background-color:#FFC; cursor:default;} ' + chr(13)
	cMsg+= '</style> ' + chr(13)
	cMsg+= '</head> ' + chr(13)
	cMsg+= '<body> ' + chr(13)
	cMsg+= '<div> ' + chr(13)
	cMsg+= '<table class="tblGrid1"> ' + chr(13)
	cMsg+= '  <tr> ' + chr(13)
	cMsg+= '      <th><img src="http://fuabc.org.br/wp-content/uploads/2014/10/logo01.jpg" width="89" height="60" /></th> ' + chr(13)
	cMsg+= '      <th>' + cAssunto + '<br /> ' + chr(13)
	cMsg+= '      ' + alltrim(POSICIONE("SM0",1,CNUMEMP,"M0_NOME")) + " / "+ alltrim(POSICIONE("SM0",1,CNUMEMP,"M0_FILIAL")) + '</th> ' + chr(13)
	cMsg+= '      <th><img src="http://fuabc.org.br/wp-content/uploads/2014/10/logo01.jpg" width="89" height="60" /></th> ' + chr(13)
	cMsg+= '  </tr> ' + chr(13)
	cMsg+= '</table> ' + chr(13)

	cMsg+= '  <table class="tblGrid2"> ' + chr(13)
	cMsg+= '    <tr> ' + chr(13)
	cMsg+= '      <th>PENDÊNCIAS</th> ' + chr(13)
	cMsg+= '    </tr> ' + chr(13)
	cMsg+= '  </table> ' + chr(13)

	//-------------------------
	// Tratamento das mensagens
	//-------------------------
	cMsg+= ' <table class="tblGrid2"> ' + chr(13)
	cMsg+= '    <tr> ' + chr(13)
    cMsg+= '      <td><b>PROCESSO</b></td> ' + chr(13)
    cMsg+= '      <td><b>ITEM</b></td> ' + chr(13)
    cMsg+= '      <td><b>DT FATAL</b></td> ' + chr(13)
    cMsg+= '      <td><b>HORÁRIO</b></td> ' + chr(13)
    cMsg+= '      <td><b>ATIVIDADE</b></td> ' + chr(13)
    cMsg+= '    </tr> ' + chr(13)
	cMsg+= '    <br /> ' + chr(13)

	for nX := 1 to len(aEmail)
		cMsg+= '    <tr> ' + chr(13)
	    cMsg+= '      <td><b>' + aEmail[nX][02] + '</b></td> ' + chr(13)
	    cMsg+= '      <td>' + aEmail[nX][03] + '</td> ' + chr(13)
	    cMsg+= '      <td>' + aEmail[nX][04] + '</td> ' + chr(13)
	    cMsg+= '      <td>' + aEmail[nX][05] + '</td> ' + chr(13)
	    cMsg+= '      <td>' + aEmail[nX][06] + '</td> ' + chr(13)
	    cMsg+= '    </tr> ' + chr(13)
		cMsg+= '    <br /> ' + chr(13)
	next

	cMsg+= '  </table> ' + chr(13)
	cMsg+= '<br /> ' + chr(13)

	cMsg+= '  <table class="tblGrid2"> ' + chr(13)
	cMsg+= '    <tr> ' + chr(13)
	cMsg+= '      <td><b>FUABC - Mensagem automática, favor não responder este e-mail.</b></td> ' + chr(13)
	cMsg+= '    </tr> ' + chr(13)
	cMsg+= '  </table> ' + chr(13)
	cMsg+= '<br /> ' + chr(13)

	cMsg+= '</div> ' + chr(13)
	cMsg+= '</body> ' + chr(13)
	cMsg+= '</html> ' + chr(13)

	cMsg += ""

	u_envMail(cFrom,cTo,cCC,cAssunto,cMsg)

return


/*/{Protheus.doc} fSolDocs
//TODO Descrição auto-gerada.
@author Daniel
@since 06/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
static Function fSolDocs()
	msgAlert("Em desenvolvimento")
return


/*/{Protheus.doc} fFinanc
//TODO Descrição auto-gerada.
@author Daniel
@since 06/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
static Function fFinanc()
	msgAlert("Em desenvolvimento")
return

