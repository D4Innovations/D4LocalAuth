//
//  WebHandlers.registerCompletion.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-04-26.
//
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionMySQL

protocol TryAgainCFG:BaseHandlerCFG {
    var tryAgainConfig:AuthConfig.BaseHandlerConfig {get}
}
extension LocalAuthWebHandlers {

	// registerCompletion
    public static func registerCompletion(data: [String:Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? TryAgainCFG else { return handlerCfgError() }
        return {
            request, response in
            let t = request.session?.data["csrf"] as? String ?? ""
            if let i = request.session?.userid, !i.isEmpty {
                response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                var context: [String : Any] = config.context
                
                if let v = request.param(name: "passvalidation"), !(v as String).isEmpty {
                    
                    let acc = Account(validation: v)
                    
                    if !acc.id.isEmpty {
                        if let p1 = request.param(name: "p1"), !(p1 as String).isEmpty,
                            let p2 = request.param(name: "p2"), !(p2 as String).isEmpty,
                            p1 == p2 {
                            acc.makePassword(p1)
                            acc.usertype = .standard
                            do {
                                try acc.save()
                                request.session?.userid = acc.id
                                response.render(template: config.templatePath, context: context)
                            } catch {
                                print("Account Save Error: \(error)")
                                context["error"] = true
                                context["errTitle"] = "Account Save Error"
                                context["errMsg"] = "Unable to save account"
                                response.render(template: config.templatePath, context: context)
                            }
                        } else {
                            context = config.tryAgainConfig.context
                            context["passvalidation"] = v
                            context["csrfToken"] = t
                            response.render(template: config.tryAgainConfig.templatePath, context: context)
                        }
                    } else {
                        print("Account Validation Error.")
                        context["error"] = true
                        context["errTitle"] = "Account Validation Error"
                        context["errMsg"] = "Validation Code not found."
                        response.render(template: config.templatePath, context: context)
                    }
                } else {
                    print("Account Validation Error.")
                    context["error"] = true
                    context["errTitle"] = "Account Validation Error."
                    context["errMsg"] = "Validation Code not provided."
                    response.render(template: config.templatePath, context: context)
                }
            }
        }
    }
}
