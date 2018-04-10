//
//  WebHandlers.registerCompletion.swift
//  Perfect-OAuth2-Server
//
//  Created by Fatih Nayebi on 2017-08-08.
//
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionMySQL


extension LocalAuthWebHandlers {
    
    /// resetCompletion
    public static func resetPasswordCompletion(data: [String: Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? TryAgainCFG else { return handlerCfgError() }
        return {
            request, response in
            let t = request.session?.data["csrf"] as? String ?? ""
            if let i = request.session?.userid, !i.isEmpty { response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                var context: [String : Any] = config.context
                if let r = request.param(name: "passreset"), !(r as String).isEmpty {
                    let acct = Account(reset: r)
                    if !acct.id.isEmpty {
                        if let p1 = request.param(name: "p1"), !(p1 as String).isEmpty,
                            let p2 = request.param(name: "p2"), !(p2 as String).isEmpty,
                            p1 == p2 {
                            acct.makePassword(p1)
                            acct.usertype = .standard
                            do {
                                try acct.save()
                                request.session?.userid = acct.id
                                response.render(template: config.templatePath, context: context)
                            } catch {
                                print("Password Save Error: \(error)")
                                context["error"] = true
                                context["errTitle"] = "Password Save Error"
                                context["errMsg"] = "Unable to save account"
                                response.render(template: config.templatePath, context: context)
                            }
                        } else {
                            context = config.tryAgainConfig.context
                            //context["msg_body"] = "<p>Password Reset Error: The passwords must not be empty, and must match.</p>"
                            context["passreset"] = r
                            context["csrfToken"] = t
                            response.render(template: config.tryAgainConfig.templatePath, context: context)
                        }
                    } else {
                        print("Password Reset Error. Unable to find account.")
                        context["error"] = true
                        context["errTitle"] = "Password Reset Error."
                        context["errMsg"] = "Unable to find account."
                        response.render(template: config.templatePath, context: context)
                    }
                } else {
                    print("Password Reset Error. Code not found.")
                    context["error"] = true
                    context["errTitle"] = "Password Reset Error."
                    context["errMsg"] = "Code not found."
                    response.render(template: config.templatePath, context: context)
                }
            }
        }
    }
}
