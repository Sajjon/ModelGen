//
//  Schema.swift
//  ModelGen
//
//  Created by Heberti Almeida on 2017-05-15.
//  Copyright © 2017 ModelGen. All rights reserved.
//

import Foundation
import PathKit

// MARK: Schema Types

enum SchemaType: String {
  case object
  case array
  case string
  case integer
  case number
  case boolean
}

enum StringFormatType: String {
  case date // Date representation, as defined by RFC 3339, section 5.6.
  case uri  // A universal resource identifier (URI), according to RFC3986.
}

// MARK: Schema

public final class SchemaProperty {


  let isOptional: Bool
  let isMutable: Bool

  let name: String?
  let type: String?
  let jsonKey: String?
  let description: String?
  let format: String?
  let ref: String?

  let items: SchemaProperty?
  let additionalProperties: SchemaProperty?

  var hasCustomJsonKey: Bool {
    return jsonKey != nil
  }

  init(dictionary: [String: Any]) throws {
    self.name = standardName(dictionary["name"] as? String)
    self.type = dictionary["type"] as? String
    self.jsonKey = dictionary["jsonKey"] as? String
    self.isOptional = (dictionary["isOptional"] as? Bool) ?? false
    self.isMutable = (dictionary["isMutable"] as? Bool) ?? false
    self.description = dictionary["description"] as? String
    self.format = dictionary["format"] as? String
    self.ref = dictionary["$ref"] as? String

    if let items = dictionary["items"] as? [String: Any] {
      self.items = try SchemaProperty(dictionary: items)
    } else {
      self.items = nil
    }

    if let additionalProperties = dictionary["additionalProperties"] as? [String: Any] {
      self.additionalProperties = try SchemaProperty(dictionary: additionalProperties)
    } else {
      self.additionalProperties = nil
    }
  }

  func toJson() -> JSON {
    var dictionary: JSON = [:]
    dictionary["name"] = name
    dictionary["type"] = type
    dictionary["jsonKey"] = jsonKey
    dictionary["isOptional"] = isOptional
    dictionary["isMutable"] = isMutable
    dictionary["description"] = description
    dictionary["format"] = format
    dictionary["$ref"] = ref
    dictionary["items"] = items?.toJson()
    dictionary["additionalProperties"] = additionalProperties?.toJson()

    return dictionary
  }
}

private func standardName(_ name: String?) -> String? {
  guard let name = name else { return nil }
  let splitedName = name.components(separatedBy: ".")
  guard splitedName.count > 0, let last = splitedName.last else {
    return fixVariableName(name)
  }
  return fixVariableName(last)
}

struct Schema {
  static func matchTypeFor(_ property: SchemaProperty, language: Language) throws -> String {
    // Match reference
    if let ref = property.ref {
      return matchRefType(ref)
    }

    // Match type
    guard let type = property.type else {
      throw SchemaError.missingType
    }

    guard let schemaType = SchemaType(rawValue: type) else {
      throw SchemaError.invalidSchemaType(type: type)
    }

    return try matchTypeFor(schemaType, property: property, language: language)
  }

  static func matchRefType(_ ref: String) -> String {
    let absolute = NSString(string: jsonAbsolutePath.description).appendingPathComponent(ref)
    let path = Path(absolute)
    let parser = JsonParser()
    do {
      try parser.parseFile(at: path)
    } catch let error {
      printError(error.localizedDescription, showFile: true)
    }

    guard let type = parser.json["title"] as? String else {
      return ""
    }
    return type.uppercaseFirst()
  }

  private static func matchTypeFor(_ format: StringFormatType, language: Language) -> String {
    switch format {
    case .uri:
      return typeFor(language, baseType: .uri)
    case .date:
      return typeFor(language, baseType: .date)
    }
  }

  private static func matchTypeFor(_ schemaType: SchemaType, property: SchemaProperty, language: Language) throws -> String {
    switch schemaType {
    case .object:
      guard let items = property.additionalProperties else {
        throw SchemaError.missingAdditionalProperties
      }
      return String(format: typeFor(language, baseType: .dictionary), try matchTypeFor(items, language: language))
    case .array:
      guard let items = property.items else {
        throw SchemaError.missingItems
      }
      return String(format: typeFor(language, baseType: .array), try matchTypeFor(items, language: language))
    case .string:
      guard let format = property.format, let stringFormat = StringFormatType(rawValue: format) else {
        return typeFor(language, baseType: .string)
      }
      return matchTypeFor(stringFormat, language: language)
    case .integer:
      return typeFor(language, baseType: .integer)
    case .number:
      return typeFor(language, baseType: .float)
    case .boolean:
      return typeFor(language, baseType: .boolean)
    }
  }

  private static func typeFor(_ language: Language, baseType: BaseType) -> String {
    switch language {
    case .swift:
      return SwiftType.match(baseType: baseType).rawValue
    case .objc:
      return ObjcType.match(baseType: baseType).rawValue
    }
  }
}


extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    func mapValues<T>(transform: (Value) -> T?) -> [Key: T] {
        var dict = [Key: T]()
        for (key, value) in zip(keys, values.flatMap(transform)) {
            dict[key] = value
        }
        return dict
    }
}
