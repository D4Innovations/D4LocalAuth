//
//  WebHandlers.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//

import PerfectHTTP

extension AuthConfig {

    public func mainAuthenticationRoutes() -> Routes {

        var routes = Routes(baseUri: "/auth")

        // WEB
        // Registration Routes
        routes.add(method: .get, uri: "/", handler: LocalAuthWebHandlers.index(data:["config":webIndexConfig]))
        routes.add(method: .get, uri: "/register", handler: LocalAuthWebHandlers.register(data: ["config":webRegisterConfig]))
        routes.add(method: .post, uri: "register", handler: LocalAuthWebHandlers.registerPost(data: ["config":webRegisterPostConfig]))
        routes.add(method: .get, uri: "/approveAccount/{passvalidation}",
                   handler: LocalAuthWebHandlers.registerApprove(data: ["config":webRegisterApproveConfig]))
        routes.add(method: .get, uri: "/verifyAccount/{passvalidation}",
                   handler: LocalAuthWebHandlers.registerVerify(data: ["config" : webRegisterVerifyConfig]))
        routes.add(method: .post, uri: "/registrationCompletion", handler: LocalAuthWebHandlers.registerCompletion(data: ["config" : webRegisterCompleteConfig]))
        
        // Login
        routes.add(method: .get, uri: "/logout", handler: LocalAuthWebHandlers.logout())
        routes.add(method: .get, uri: "/login", handler: LocalAuthWebHandlers.login(data: ["config" : webLoginConfig]))
        routes.add(method: .post, uri: "/login", handler: LocalAuthWebHandlers.loginPost(data: ["config" : webLoginPostConfig]))
        
        routes.add(method: .get, uri: "/resetPassword", handler: LocalAuthWebHandlers.resetPassword(data: ["config" : webResetPasswordConfig]))
        routes.add(method: .post, uri: "/resetPassword",
                   handler: LocalAuthWebHandlers.resetPasswordPost(data: ["config" : webResetPasswordPostConfig]))
        routes.add(method: .get, uri: "/verifyPassReset/{passreset}",
                   handler: LocalAuthWebHandlers.resetPasswordVerify(data: ["config" : webResetPasswordVerifyConfig]))
        routes.add(method: .post, uri: "/resetPasswordComplete",
                   handler: LocalAuthWebHandlers.resetPasswordCompletion(data: ["config" : webResetPasswordCompleteConfig]))

        return routes
    }

}
