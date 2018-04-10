//
//  WebHandlers.login.swift
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

    public static func login(data: [String:Any] = [:])  -> RequestHandler {
        guard let config = data["config"] as? BaseHandlerCFG else { return handlerCfgError() }
        return {
            request, response in
            if let i = request.session?.userid, !i.isEmpty { response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                var context: [String : Any] = config.context
                context["csrfToken"] = request.session?.data["csrf"] as? String ?? ""
                response.render(template: config.templatePath, context: context)
            }
        }
    }
    
	// POST request for login
    public static func loginPost(data: [String:Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? BaseHandlerCFG else { return handlerCfgError() }
        return {
            request, response in
            if let i = request.session?.userid, !i.isEmpty { response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                var context: [String : Any] = config.context
                context["csrfToken"] = request.session?.data["csrf"] as? String ?? ""
                
                if let e = request.param(name: "email"), !(e as String).isEmpty,
                    let p = request.param(name: "password"), !(p as String).isEmpty {
                    do {
                        let acc = try Account.login(e, p)
                        request.session?.userid = acc.id
                        response.redirect(path: config.redirectPath ?? "/auth/")
                        return
                    } catch {
                        print("Login Error:\(error)")
                        context["error"] = true
                        context["errTitle"] = "Login Error"
                        context["errMsg"] = "Username or password incorrect"
                        response.render(template: config.templatePath, context: context)
                    }
                } else {
                    print("Login Error: Username or password not supplied")
                    context["error"] = true
                    context["errTitle"] = "Login Error"
                    context["errMsg"] = "Username or password not supplied"
                    response.render(template: config.templatePath, context: context)
                }
            }
        }
	}

}
