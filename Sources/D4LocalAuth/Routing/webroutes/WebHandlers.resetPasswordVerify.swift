//
//  WebHandlers.resetPasswordVerify.swift
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

	/// reset verification GET
    public static func resetPasswordVerify(data: [String: Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? BaseHandlerCFG else { return handlerCfgError() }
        return {
            request, response in
            let t = request.session?.data["csrf"] as? String ?? ""
            if let i = request.session?.userid, !i.isEmpty { response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                var context: [String : Any] = config.context
                if let r = request.urlVariables["passreset"], !(r as String).isEmpty {
                    let acct = Account(reset: r)
                    if !acct.id.isEmpty {
                        context["passreset"] = r
                        context["csrfToken"] = t
                        response.render(template: config.templatePath, context: context)
                    } else {
                        print("Password Reset Error")
                        context["error"] = true
                        context["errTitle"] = "Password Reset Error."
                        context["errMsg"] = ""
                        response.render(template: config.templatePath, context: context)
                    }
                } else {
                    print("Password Reset Error")
                    context["error"] = true
                    context["errTitle"] = "Password Reset Error."
                    context["errMsg"] = "Code not found."
                    response.render(template: config.templatePath, context: context)
                }
            }
        }
	}
}
