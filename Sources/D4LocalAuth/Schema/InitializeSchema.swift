//
//  InitializeSchema.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//
import PerfectLib
import StORM
import MySQLStORM
import PerfectSessionMySQL
import Foundation


extension AuthConfig {
    mutating func setup() {
        
        if let approveCfg = self.approverConfig {
            self.webRegisterPostConfig = approveCfg
        }
        self.webRegisterPostConfig.baseURL = self.baseURL
        self.webRegisterApproveConfig.baseURL = self.baseURL
        self.webResetPasswordPostConfig.baseURL = self.baseURL
        

        // StORM Connector Config
        MySQLConnector.host        = self.mySqlConfig.mysqlHost
        MySQLConnector.username    = self.mySqlConfig.mysqlUser
        MySQLConnector.password    = self.mySqlConfig.mysqlPwd
        MySQLConnector.database    = self.mySqlConfig.mysqlDBname
        MySQLConnector.port        = self.mySqlConfig.mysqlPort
        
        // Outbound email config
        SMTPConfig.mailserver         = self.smtpConfig.mailServer
        SMTPConfig.mailuser           = self.smtpConfig.mailUser
        SMTPConfig.mailpass           = self.smtpConfig.mailpass
        SMTPConfig.mailfromaddress    = self.smtpConfig.mailFromAddress
        SMTPConfig.mailfromname       = self.smtpConfig.mailFromName
        
        // session driver config
        MySQLSessionConnector.host = MySQLConnector.host
        MySQLSessionConnector.port = MySQLConnector.port
        MySQLSessionConnector.username = MySQLConnector.username
        MySQLSessionConnector.password = MySQLConnector.password
        MySQLSessionConnector.database = MySQLConnector.database
        MySQLSessionConnector.table = "sessions"

        //    StORMdebug = true
        MySQLConnector.quiet = true
        
        // Account
        Account.setup()
        
        MySQLConnector.quiet = false
    }
}


