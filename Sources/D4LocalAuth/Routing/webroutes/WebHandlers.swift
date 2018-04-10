//
//  WebHandlers.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionMySQL

public protocol BaseHandlerCFG:RedirectPathCFG {
    var templatePath:String {get}
    var context:[String:String] {get}
}


public class LocalAuthWebHandlers {

    public static func handlerCfgError() -> RequestHandler {
        return { request, response in
            var errResp = "<!doctype html><html lang=\"en\"><head><title>{{title}}</title></head>"
            errResp += "<body><p>{{errMsg}}</p></body></html>"
            let context:[String : Any] = ["title":"Config Error","errMsg":"Handler Config Error:\(request.path)"]
            response.renderContent(templateContent: errResp, context: context)
        }
    }
    
    public static func index(data: [String:Any] = [:])  -> RequestHandler {
        guard let config = data["config"] as? BaseHandlerCFG else { return handlerCfgError() }
		return {
			request, response in
			var context: [String : Any] = config.context
			if let i = request.session?.userid, !i.isEmpty {
                let acct = Account()
                try? acct.get(i)
                context["username"] = acct.username
                context["authenticated"] = true
                context["title"] = context["title2"]
            }
			context["csrfToken"] = request.session?.data["csrf"] as? String ?? ""
			response.render(template: config.templatePath, context: context)
		}
	}
}
