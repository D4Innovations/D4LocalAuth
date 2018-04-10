import Foundation

import PerfectHTTP


public struct AuthConfig: Codable {
    var baseURL:String
    var mySqlConfig:MySQLConfig
    var smtpConfig:SmtpConfig
    
    // Addition of an Approver Route
    var approverConfig:EmailRoutePostConfig?
    
    // Routing Config
    var webIndexConfig:BaseHandlerConfig
    var webRegisterConfig:BaseHandlerConfig
    var webRegisterPostConfig:EmailRoutePostConfig

    var webRegisterApproveConfig:EmailRoutePostConfig
    var webRegisterVerifyConfig:BaseHandlerConfig
    var webRegisterCompleteConfig:TryAgainConfig
    var webLoginConfig:BaseHandlerConfig
    var webLoginPostConfig:BaseHandlerConfig
    var webResetPasswordConfig:BaseHandlerConfig
    var webResetPasswordPostConfig:EmailRoutePostConfig
    var webResetPasswordVerifyConfig:BaseHandlerConfig
    var webResetPasswordCompleteConfig:TryAgainConfig

    
    
    struct MySQLConfig:Codable {
        var mysqlUser:String
        var mysqlHost:String
        var mysqlPwd:String
        var mysqlDBname:String
        var mysqlPort:Int
    }
    
    struct SmtpConfig:Codable {
        var mailUser:String
        var mailServer:String
        var mailpass:String
        var mailFromAddress:String
        var mailFromName:String
    }
    
    struct BaseHandlerConfig:Codable, BaseHandlerCFG {
        var templatePath:String
        var context:[String:String]
        var redirectPath: String?
    }
    
    public struct MailConfig:Codable {
        let htmlTemplatePath:String
        let txtTemplatePath:String
        let subject:String
    }
    
    struct EmailRoutePostConfig:Codable, EmailRoutePostCfg {
        var baseURL:String?
        var approverName: String?
        var approverEmail: String?
        var mailConfig: AuthConfig.MailConfig?
        var templatePath: String
        var context: [String : String]
        
        var redirectPath: String?
        var errorTemplateConfig: AuthConfig.BaseHandlerConfig?
    }
    
    struct TryAgainConfig:Codable, TryAgainCFG {
        var tryAgainConfig: AuthConfig.BaseHandlerConfig
        var templatePath: String
        var context: [String : String]
        var redirectPath: String?
    }
    
    
    init?(configFile:String) {
        
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
