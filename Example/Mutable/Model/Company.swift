//
//  Company.swift
//  ModelGen
//
//  Generated by [ModelGen]: https://github.com/hebertialmeida/ModelGen
//  Copyright © 2018 ModelGen. All rights reserved.
//

import Unbox

/// Definition of a Company
public class Company: Equatable {

    // MARK: Instance Variables

    public var subdomain: String
    public var name: String
    public var logo: URL?
    public var id: Int

    // MARK: - Initializers

    public init(subdomain: String, name: String, logo: URL?, id: Int) {
        self.subdomain = subdomain
        self.name = name
        self.logo = logo
        self.id = id
    }

    public init(unboxer: Unboxer) throws {
        self.subdomain = try unboxer.unbox(key: "subdomain")
        self.name = try unboxer.unbox(key: "name")
        self.logo =  unboxer.unbox(key: "logo")
        self.id = try unboxer.unbox(key: "id")
    }
}

// MARK: - Equatable

public func == (lhs: Company, rhs: Company) -> Bool {
    guard lhs.subdomain == rhs.subdomain else { return false }
    guard lhs.name == rhs.name else { return false }
    guard lhs.logo == rhs.logo else { return false }
    guard lhs.id == rhs.id else { return false }
    return true
}
