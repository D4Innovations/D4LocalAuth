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
    public static func registerVerify(data: [String:Any] = [:]) -> RequestHandler {
        guard let config = data["config"] as? BaseHandlerCFG else { return handlerCfgError() }
		return {
			request, response in
			let t = request.session?.data["csrf"] as? String ?? ""
			if let i = request.session?.userid, !i.isEmpty {
                response.redirect(path: config.redirectPath ?? "/auth/")
            } else {
                var context: [String : Any] = config.context
                
                if let v = request.urlVariables["passvalidation"], !(v as String).isEmpty {
                    
                    let acct = Account(validation: v)
                    
                    if !acct.id.isEmpty {
                        context["passvalidation"] = v
                        context["csrfToken"] = t
                        response.render(template: config.templatePath, context: context)
                    } else {
                        print("Account Validation Error.")
                        context["error"] = true
                        context["errTitle"] = "Account Validation Error."
                        context["errMsg"] = "Code not found."
                        
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
