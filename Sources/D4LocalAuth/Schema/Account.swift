//
//  Account.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//

import StORM
import MySQLStORM
import PerfectSMTP

public class Account: MySQLStORM {
	public var id			  = ""
	public var username		  = ""
	public var password		  = ""
	public var email		  = ""
	public var usertype: AccountType = .provisional
	public var source		  = "local"	// local, facebook, etc
	public var remoteid		  = ""		// if oauth then the sourceid is stored here
	public var passvalidation = ""
    public var passreset      = ""
	public var detail	      = [String:Any]()

	public static func setup(_ str: String = "") {
		do {
			let obj = Account()
			try obj.setup(str)

			// Account migrations:
			// 1.3.1->1.4
			let _ = try? obj.sql("ALTER TABLE account ADD COLUMN `source` text AFTER `passvalidation`;", params: [])
			let _ = try? obj.sql("ALTER TABLE account ADD COLUMN `remoteid` text AFTER `source`;", params: [])
			let _ = try? obj.sql("ALTER TABLE account ADD COLUMN `passvalidation` text;", params: [])
			let _ = try? obj.sql("ALTER TABLE account ADD COLUMN `passreset` text;", params: [])

		} catch {
			// nothing
		}
	}


	override public func to(_ this: StORMRow) {
		id              = this.data["id"] as? String				?? ""
		username		= this.data["username"] as? String			?? ""
		password        = this.data["password"] as? String			?? ""
		email           = this.data["email"] as? String				?? ""
		usertype        = AccountType.from((this.data["usertype"] as? String)!)
		source          = this.data["source"] as? String			?? "local"
		remoteid        = this.data["remoteid"] as? String				?? ""
		passvalidation	= this.data["passvalidation"] as? String		?? ""
        passreset	    = this.data["passreset"] as? String		?? ""
		
        if let detailObj = this.data["detail"] {
			self.detail = fromJSONtoStringAny(detailObj as? String ?? "")
		}
	}

	public func rows() -> [Account] {
		var rows = [Account]()
		for i in 0..<self.results.rows.count {
			let row = Account()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	public override init() {
		super.init()
	}

	public init(
		_ i: String = "",
		_ u: String = "",
		_ p: String = "",
		_ e: String,
		_ ut: AccountType = .provisional,
		_ s: String = "local",
		_ rid: String = ""
		) {
		super.init()
		id = i
		username = u
		password = p
		email = e
		usertype = ut
		passvalidation = AccessToken.generate()
        passreset = AccessToken.generate()
		source = s
		remoteid = rid
	}
    
	public init(validation: String) {
		super.init()
		try? find(["passvalidation": validation])
	}
    
    public init(reset: String) {
        super.init()
        try? find(["passreset": reset])
    }

	public func makeID() {
		id = AccessToken.generate()
	}

	public func makePassword(_ p1: String) {
		if let digestBytes = p1.digest(.sha256),
			let hexBytes = digestBytes.encode(.hex),
			let hexBytesStr = String(validatingUTF8: hexBytes) {
			password = hexBytesStr
		}
	}

	public func isUnique() throws {
		// checks for email address already existing
		let this = Account()
		do {
			try this.find(["email":email])
			if this.results.cursorData.totalRecords > 0 {
				// print("failing unique test")
				throw OAuth2ServerError.invalidEmail
			}
		} catch {
			// print(error)
			throw OAuth2ServerError.invalidEmail
		}
	}

	// Register User
	public static func register(_ u: String, _ e: String, _ ut: AccountType = .provisional) throws -> Account {
		let acc = Account(AccessToken.generate(), u, "", e, ut)
		do {
			try acc.isUnique()
			// print("passed unique test")
			try acc.create()
		} catch {
			print(error)
			throw error
		}

		return acc
	}

    /// Reset Password
    /// - Parameter e: email address
    /// - Parameter baseURL: base url to create the reset pass url
    public static func resetPassword(_ e: String) throws -> Account {
        let acc = Account()
        do {
            try acc.find(["email": e])
            acc.passreset = AccessToken.generate()
            acc.email = e
            try acc.save()
        } catch {
            print(error)
            throw error
        }
                
        return acc
    }
    
	// Login User
	public static func login(_ e: String, _ p: String) throws -> Account {
		if let digestBytes = p.digest(.sha256),
			let hexBytes = digestBytes.encode(.hex),
			let hexBytesStr = String(validatingUTF8: hexBytes) {

			let acc = Account()
			let criteria = ["email":e,"password":hexBytesStr]
			do {
				try acc.find(criteria)
				if acc.usertype == .provisional {
					throw OAuth2ServerError.loginError
				}
				return acc
			} catch {
				print(error)
				throw OAuth2ServerError.loginError
			}
		} else {
			throw OAuth2ServerError.loginError
		}
	}

	public static func listUsers() -> [[String: Any]] {
		var users = [[String: Any]]()
		let t = Account()
		let cursor = StORMCursor(limit: 9999999,offset: 0)
		try? t.select(
			columns: [],
			whereclause: "true",
			params: [],
			orderby: ["username"],
			cursor: cursor
		)

		for row in t.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["username"] = row.username
			r["email"] = row.email
			r["usertype"] = row.usertype
			r["detail"] = row.detail
			r["source"] = row.source
			r["remoteid"] = row.remoteid
			users.append(r)
		}
		return users
	}
}

public enum AccountType {
	case provisional, standard, admin, inactive

	public static func from(_ str: String) -> AccountType {
		switch str {
		case "admin":
			return .admin
		case "standard":
			return .standard
		case "inactive":
			return .inactive
		default:
			return .provisional
		}
	}
}


