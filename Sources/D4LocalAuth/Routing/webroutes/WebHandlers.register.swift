//
//  WebHandlers.register.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-04-26.
//
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionMySQL

protocol EmailRoutePostCfg:BaseHandlerCFG {
    var baseURL:String? {get}
    var approverName:String? {get}
    var approverEmail:String? {get}
    var mailConfig:AuthConfig.MailConfig? {get}
    var errorTemplateConfig:AuthConfig.BaseHandlerConfig? {get}
}

extension LocalAuthWebHandlers {

	// Register GET - displays form
    
    public static func register(data: [String:Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? BaseHandlerCFG else { return handlerCfgError() }
		return {
			request, response in
            if let i = request.session?.userid, !i.isEmpty {
                response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                let t = request.session?.data["csrf"] as? String ?? ""
                var context: [String : Any] = config.context
                context["csrfToken"] = t
                response.render(template: config.templatePath, context: context)
            }
		}
	}


	// POST request for register form
    public static func registerPost(data: [String:Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? EmailRoutePostCfg,
              let baseURL = config.baseURL
              else { return handlerCfgError() }
		return {
			request, response in
			if let i = request.session?.userid, !i.isEmpty {
                response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                var context: [String : Any] = config.context
                var template = config.templatePath

                var u = ""
                if let fname = request.param(name: "fname"), !fname.isEmpty {
                    u = fname
                }
                if let lname = request.param(name: "lname"), !lname.isEmpty {
                    u += (" " + lname)
                }
                if !u.isEmpty, let e = request.param(name: "email"), !(e as String).isEmpty {
                    let docroot = "\(request.documentRoot)/"
                    do {
                        let acct = try Account.register(u, e, .provisional)
                        var mailContext:[String:Any] = [:]
                        var sendToName = ""
                        var sendToEmail = ""
                        if let approverEmail = config.approverEmail, let approverName = config.approverName {
                            let verifyURL = "\(baseURL)/auth/approveAccount/\(acct.passvalidation)"
                            mailContext = ["verifyULR":verifyURL,"requester":u]
                            sendToName = approverName
                            sendToEmail = approverEmail
                        } else {
                            let verifyURL = "\(baseURL)/auth/verifyAccount/\(acct.passvalidation)"
                            mailContext = ["verifyULR":verifyURL]
                            sendToName = u
                            sendToEmail = e
                        }
                        if let mailConfig = config.mailConfig,
                            let h = getStrFrom(templatePath: docroot+mailConfig.htmlTemplatePath, context: mailContext),
                            let t = getStrFrom(templatePath: docroot+mailConfig.txtTemplatePath, context: mailContext)
                        {
                                Utility.sendMail(name: sendToName, address: sendToEmail, subject: mailConfig.subject, html: h, text: t)
                        } else {
                            if let errConfig = config.errorTemplateConfig {
                                template = errConfig.templatePath
                                context = errConfig.context
                            }
                            print("Config Error")
                            context["error"] = true
                            context["errTitle"] = "Config Error"
                            context["errMsg"] = "Missing approval MailConfig or Templates"
                        }
                    } catch {
                        if let errConfig = config.errorTemplateConfig {
                            template = errConfig.templatePath
                            context = errConfig.context
                        }
                        print(error)
                        context["error"] = true
                        context["errTitle"] = "Registration Error"
                        context["errMsg"] = "Email in use or invalid (\(error))"
                    }
                } else {
                    if let errConfig = config.errorTemplateConfig {
                        template = errConfig.templatePath
                        context = errConfig.context
                    }
                    print("Missing User Name and/or Email Address")
                    context["error"] = true
                    context["errTitle"] = "Missing User Name and/or Email Address"
                    //context["errMsg"] = ""
                }
                response.render(template: template, context: context)
            }
		}
	}
}
