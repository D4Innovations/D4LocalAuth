import Foundation

import PerfectHTTP


public struct AuthConfig: Codable {
    public var baseURL:String
    public var mySqlConfig:MySQLConfig
    public var smtpConfig:SmtpConfig
    
    // Addition of an Approver Route
    public var approverConfig:EmailRoutePostConfig?
    
    // Routing Config
    public var webIndexConfig:BaseHandlerConfig
    public var webRegisterConfig:BaseHandlerConfig
    public var webRegisterPostConfig:EmailRoutePostConfig

    public var webRegisterApproveConfig:EmailRoutePostConfig
    public var webRegisterVerifyConfig:BaseHandlerConfig
    public var webRegisterCompleteConfig:TryAgainConfig
    public var webLoginConfig:BaseHandlerConfig
    public var webLoginPostConfig:BaseHandlerConfig
    public var webResetPasswordConfig:BaseHandlerConfig
    public var webResetPasswordPostConfig:EmailRoutePostConfig
    public var webResetPasswordVerifyConfig:BaseHandlerConfig
    public var webResetPasswordCompleteConfig:TryAgainConfig

    
    
    public struct  MySQLConfig:Codable {
        public var mysqlUser:String
        public var mysqlHost:String
        public var mysqlPwd:String
        public var mysqlDBname:String
        public var mysqlPort:Int
    }
    
    public struct  SmtpConfig:Codable {
        public var mailUser:String
        public var mailServer:String
        public var mailpass:String
        public var mailFromAddress:String
        public var mailFromName:String
    }
    
    public struct  BaseHandlerConfig:Codable, BaseHandlerCFG {
        public var templatePath:String
        public var context:[String:String]
        public var redirectPath: String?
    }
    
    public struct MailConfig:Codable {
        public let htmlTemplatePath:String
        public let txtTemplatePath:String
        public let subject:String
    }
    
    public struct  EmailRoutePostConfig:Codable, EmailRoutePostCfg {
        public var baseURL:String?
        public var approverName: String?
        public var approverEmail: String?
        public var mailConfig: AuthConfig.MailConfig?
        public var templatePath: String
        public var context: [String : String]
        
        public var redirectPath: String?
        public var errorTemplateConfig: AuthConfig.BaseHandlerConfig?
    }
    
    public struct  TryAgainConfig:Codable, TryAgainCFG {
        public var tryAgainConfig: AuthConfig.BaseHandlerConfig
        public var templatePath: String
        public var context: [String : String]
        public var redirectPath: String?
    }
    
    
    public init?(configFile:String) {
        
        if (FileManager.default.fileExists(atPath: configFile)) {
            let fileURL = URL(fileURLWithPath:configFile)
            do {
                let archiveData = try Data(contentsOf: fileURL)
                if let newSelf:AuthConfig = JSONDecoder().decodeJSONWithErrors(data: archiveData) {
                    self = newSelf
                    //self.setup()
                } else {
                    print("No Data in File or Unable to Parse JSON")
                    return nil
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                return nil
            }
            
        } else {
            print ("Archive File doesn't Exist: \(configFile)")
            return nil
        }
    }
    
    
    
}
