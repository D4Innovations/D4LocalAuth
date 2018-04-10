//
//  Extensions.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//

import PerfectMustache
import PerfectHTTP

public struct MustacheHandler: MustachePageHandler {
	var context: [String: Any]
	public func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
		contxt.extendValues(with: context)
		do {
			contxt.webResponse.setHeader(.contentType, value: "text/html")
			try contxt.requestCompleted(withCollector: collector)
		} catch {
			let response = contxt.webResponse
			response.status = .internalServerError
			response.appendBody(string: "\(error)")
			response.completed()
		}
	}

	public init(context: [String: Any] = [String: Any]()) {
		self.context = context
	}
}


extension HTTPResponse {
	public func render(template: String, context: [String: Any] = [String: Any]()) {
		mustacheRequest(request: self.request, response: self, handler: MustacheHandler(context: context), templatePath: request.documentRoot + "/\(template).mustache")
	}
    
    public func renderContent(templateContent: String, context values: [String: Any] = [String: Any]()) {
        let context = MustacheEvaluationContext(templateContent: templateContent)
        let collector = MustacheEvaluationOutputCollector()
        context.extendValues(with: values)
        do {
            let d = try context.formulateResponse(withCollector: collector)
            self.setBody(string: d)
                .completed()
        } catch {
            self.setBody(string: "\(error)")
                .completed(status: .internalServerError)
        }
    }
    
	public func redirect(path: String) {
		self.status = .found
		self.addHeader(.location, value: path)
		self.completed()
	}

}

extension LocalAuthWebHandlers {
    public static func getStrFrom(templatePath:String,context:[String:Any]) -> String? {
        let context = MustacheEvaluationContext(templatePath: templatePath, map: context)
        let collector = MustacheEvaluationOutputCollector()
        do {
            return try context.formulateResponse(withCollector: collector)
        } catch {
            print(error)
            return  nil
        }
    }
}




