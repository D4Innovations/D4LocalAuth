//
//  WebHandlers.resetPassword.swift
//  LocalAuthentication
//
//  Created by Fatih Nayebi on 2017-08-08.
//
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionMySQL

extension LocalAuthWebHandlers {
    
    // Reset Password GET - displays form
    public static func resetPassword(data: [String: Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? BaseHandlerCFG else { return handlerCfgError() }
        return {
            request, response in
            if let i = request.session?.userid, !i.isEmpty { response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                let t = request.session?.data["csrf"] as? String ?? ""
                var context: [String: Any] = config.context
                context["csrfToken"] = t
                response.render(template: config.templatePath, context: context)
            }
        }
    }
    
    
    // POST request for register form
    public static func resetPasswordPost(data: [String: Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? EmailRoutePostCfg,
            let baseURL = config.baseURL
            else { return handlerCfgError() }
        return {
            request, response in
            if let i = request.session?.userid, !i.isEmpty { response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                var context: [String: Any] = config.context
                var template = config.templatePath

                if let e = request.param(name: "email"), !(e as String).isEmpty {
                    do {
                        let acct = try Account.resetPassword(e)
                        let docroot = "\(request.documentRoot)/"
                        let resetURL = "\(baseURL)/auth/verifyPassReset/\(acct.passreset)"
                        let d = ["resetURL":resetURL] as [String:Any]
                        if let userMailConfig = config.mailConfig,
                            let h = getStrFrom(templatePath: docroot+userMailConfig.htmlTemplatePath, context: d),
                            let t = getStrFrom(templatePath: docroot+userMailConfig.txtTemplatePath, context: d)
                        {
                            Utility.sendMail(name: "", address: acct.email, subject: userMailConfig.subject, html: h, text: t)
                        } else {
                            if let errConfig = config.errorTemplateConfig {
                                template = errConfig.templatePath
                                context = errConfig.context
                            }
                            print("Config Error.")
                            context["error"] = true
                            context["errTitle"] = "Config Error."
                            context["errMsg"] = "Missing user MailConfig or Templates"
                        }
                        response.render(template: config.templatePath, context: context)
                    } catch {
                        if let errConfig = config.errorTemplateConfig {
                            template = errConfig.templatePath
                            context = errConfig.context
                        }
                        print(error)
                        context["error"] = true
                        context["errTitle"] = "Password Reset Error"
                        context["errMsg"] = "Email Address Not Found"
                    }
                } else {
                    if let errConfig = config.errorTemplateConfig {
                        template = errConfig.templatePath
                        context = errConfig.context
                    }
                    context["error"] = true
                    context["errTitle"] = "Password Reset Error"
                    context["errMsg"] = "Invalid or missing email address."
                }
                response.render(template: template, context: context)
            }
        }
    }
}
