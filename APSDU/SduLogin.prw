#INCLUDE 'protheus.ch'
#INCLUDE 'Ap5Mail.ch'
/*/{Protheus.doc} User Function SduLogin
Enviar email de aviso que acessou o apsdu
@author Thalys Augusto
@since 15/07/2020
@version 1.0
@type function
/*/
User Function SduLogin()
             Local lRet := .T.
             local cMensagem            := ''
             Local cUser := ParamIXB
            
			 cMensagem	:=	"Usuário Protheus <b>" +Alltrim(cUser)+ "</b> efetuou login no APSDU através do usuário de rede <b> "
			 cMensagem	+=	+Alltrim(LogUserName()) + "</b> em " + DtoC( Date()) + " às " + Time() 
			 cMensagem	+=	" na máquina <b>"+Lower(ComputerName())+Upper(" (IP "+ GetClientIP()+" / PC: " +GetComputerName()+")</b>")

              //Informe aqui o seu e-mail
             cEmailPara          := 'SEUEMAIL@SEUEMAIL.COM.BR'
             SendMail(cEmailPara, 'Login no APSDU ', '<b> ' + cMensagem + '</b>')
Return .T.

/*/{Protheus.doc} Static Function SendMail
Função que realiza o envio do e-mail
@author Thalys Augusto
@since 15/07/2020
@version 1.0
@type function
/*/

Static Function SendMail(cPara , cSubject, cMsg)
                 Local oMail , oMessage , nErro
                Local lRet := .T.
                Local cSMTPServer := 'smtp.SEUEMAIL.COM.BR'
                Local cSMTPUser   := 'workflows@SEUEMAIL.COM.BR'
                Local cSMTPPass   := 'workflows'
                Local cMailFrom   := 'workflows@SEUEMAIL.COM.BR'
                Local nPort       := 587
                Local lUseAuth    := .T.
                Local cCopia := 'COPIA@SEUMAIL.COM.BR'
                MsgRun('Conectando com SMTP ',' ',{||oMail := TMailManager():New()})
                oMail:setUseSSL( .T. ) // Usa SSL na conexao, contas do GMAIL usam SSL.
				oMail:SetUseTLS( .T. ) // Usa TLS na conexao, contas de email de empresas exemplo contato@suaempresa.com.br
                MsgRun('Inicializando SMTP','',{|| oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort )})
                MsgRun('Setando Time-Out','',{||oMail:SetSmtpTimeOut( 30 )})
                MsgRun('Conectando com servidor...','',{||nErro := oMail:SmtpConnect()})
                MsgRun('Status de Retorno = '+str(nErro,6),'',{||})
                If lUseAuth
                   MsgRun('Autenticando Usuario ['+cSMTPUser+'] senha ********* ','',{||nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)})
                   MsgRun('Status de Retorno = '+str(nErro,6),'',{||})
                     If nErro <> 0
                          // Recupera erro ...
                          cMAilError := oMail:GetErrorString(nErro)
                          DEFAULT cMailError := '***UNKNOW***'
                          Conout('Erro de Autenticacao '+str(nErro,4)+' ('+cMAilError+')')
                          lRet := .F.
                     Endif
                Endif
                if nErro <> 0
                     // Recupera erro
                     cMAilError := oMail:GetErrorString(nErro)
                     DEFAULT cMailError := '***UNKNOW***'
                     conout(cMAilError)
                     Conout('Erro de Conexão SMTP '+str(nErro,4))
                     conout('Desconectando do SMTP')
                     oMail:SMTPDisconnect()
                     lRet := .F.
                Endif
                 If lRet
                     conout('Compondo mensagem em memória')
                     oMessage := TMailMessage():New()
                     oMessage:Clear()
                     oMessage:cFrom     := cMailFrom
                     oMessage:cTo     := cPara
                     If !Empty(cCopia)
                          oMessage:cCc     := cCopia
                     Endif
                     oMessage:cSubject     :=cSubject
                     oMessage:cBody          := cMsg
                    MsgRun('Enviando Mensagem para ['+cPara+'] ','',{||     nErro := oMessage:Send( oMail )})
                     if nErro <> 0
                          xError := oMail:GetErrorString(nErro)
                          Conout('Erro de Envio SMTP '+str(nErro,4)+' ('+xError+')')
                          lRet := .F.
                     Endif
                     conout('Desconectando do SMTP')
                     oMail:SMTPDisconnect()
                Endif


Return(lRet)
