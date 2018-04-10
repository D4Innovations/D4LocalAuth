//
//  WebHandlers.registerVerify.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-04-26.
//
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionMySQL


    


extension LocalAuthWebHandlers {

	// Verify GET
    public static func registerApprove(data: [String:Any] = [:])  -> RequestHandler {
        guard let config = data["config"] as? EmailRoutePostCfg, let baseURL = config.baseURL
              else { return handlerCfgError() }
		return {
			request, response in
			//let t = request.session?.data["csrf"] as? String ?? ""
			//if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
			var context: [String : Any] = config.context

			if let v = request.urlVariables["passvalidation"], !(v as String).isEmpty {
				let acct = Account(validation: v)
				if !acct.id.isEmpty {
                    let docroot = "\(request.documentRoot)/"
                    let verifyURL = "\(baseURL)/auth/verifyAccount/\(acct.passvalidation)"
                    let d = ["verifyULR":verifyURL] as [String:Any]
                    if let userMailConfig = config.mailConfig,
                        let h = getStrFrom(templatePath: docroot+userMailConfig.htmlTemplatePath, context: d),
                        let t = getStrFrom(templatePath: docroot+userMailConfig.txtTemplatePath, context: d)
                    {
                        Utility.sendMail(name: acct.username, address: acct.email, subject: userMailConfig.subject, html: h, text: t)
                    } else {
                        print("Config Error.")
                        context["error"] = true
                        context["errTitle"] = "Config Error."
                        context["errMsg"] = "Missing user MailConfig or Templates"
                    }
                    response.render(template: config.templatePath, context: context)
				} else {
                    print("Account Validation Error.")
                    context["error"] = true
                    context["errTitle"] = "Account Validation Error."
                    context["errMsg"] = ""
                    response.render(template: config.templatePath, context: context)
				}
			} else {
                print("Account Validation Error.")
                context["error"] = true
                context["errTitle"] = "Account Validation Error."
                context["errMsg"] = "Code not found."
				response.render(template: config.templatePath, context: context)
			}
		}
	}
}
