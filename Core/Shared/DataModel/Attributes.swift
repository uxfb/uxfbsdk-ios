//
//  Attributes.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 11.03.2024.
//  Copyright © 2024 UXF. All rights reserved.
//

import Foundation

public enum AttributeDecodable: Decodable {
  
  case string(String)
  case int(Int)
  case double(Double)
  
  public init(from decoder: Decoder) throws {
    if let double = try? decoder.singleValueContainer().decode(Double.self) {
      self = .double(double)
      return
    }
    if let string = try? decoder.singleValueContainer().decode(String.self) {
      self = .string(string)
      return
    }
    if let int = try? decoder.singleValueContainer().decode(Int.self) {
      self = .int(int)
      return
    }
      
    throw Error.couldNotDecode
  }
  enum Error: Swift.Error {
    case couldNotDecode
  }
  
  public func getString() -> String? {
    switch self {
      case .string(let string):
        return string
        
      default:
        return nil
    }
  }
  
  public func getNumber() -> NSNumber? {
    switch self {
      case .double(let double):
        return double as NSNumber
      case .int(let num):
        return num as NSNumber
      case .string(let num):
        if let myNum = Double(num) {
            return myNum as NSNumber
        } else {
            return nil
        }
    }
  }
}

public struct CampaignAttribute: Decodable {
  public var attributeName: String
  public var value: AttributeDecodable?
  public var rule: String
  public var valueFrom: AttributeDecodable?
  public var valueTo: AttributeDecodable?
}

@objcMembers
public class Attribute {
    public var attributeName: String
    public var attributeValue: (any Codable)?
    
    init(attributeName: String, attributeValue: (any Codable)? = nil) {
        self.attributeName = attributeName
        self.attributeValue = attributeValue
    }
}

public struct CheckAttribute: Codable {
  public let checkAttributes: Bool
  public let attributes: [String: Bool]?
}

public class AttributesBuilder {
  private var attributes: [Attribute] = []
  
  public init() {
    attributes = []
  }
  
  public func addValue(_ name: String, value: String) -> AttributesBuilder {
    let attribute = Attribute(attributeName: name, attributeValue: value)
    append(attribute)
    return self
  }
  
  public func addValue(_ name: String, value: Int) -> AttributesBuilder {
    let attribute = Attribute(attributeName: name, attributeValue: value)
    append(attribute)
    return self
  }
  
  public func addValue(_ name: String, value: Double) -> AttributesBuilder {
    let attribute = Attribute(attributeName: name, attributeValue: value)
    append(attribute)
    return self
  }
  
  public func addValue(_ name: String, value: Date) -> AttributesBuilder {
    let attribute = Attribute(attributeName: name, attributeValue: value)
    append(attribute)
    return self
  }
  
  public func addValue(_ name: String, value: Bool) -> AttributesBuilder {
    let attribute = Attribute(attributeName: name, attributeValue: value)
    append(attribute)
    return self
  }
  
  public func remove(attributeName: String) -> AttributesBuilder {
    attributes.removeAll { attribute in
      attribute.attributeName == attributeName
    }
    return self
  }
  
  public func build() -> [Attribute] {
    return attributes
  }
  
  private func append(_ newAttribute: Attribute) {
    if let row = self.attributes.firstIndex(where: {$0.attributeName == newAttribute.attributeName}) {
      self.attributes[row].attributeValue = newAttribute.attributeValue
    } else {
      attributes.append(newAttribute)
    }
  }
}

extension Array<Attribute> {
  func convertToDict() -> [String: String] {
    var result: [String: String] = [:]
    for attribute in self {
      switch attribute.attributeValue {
        case let payload as String:
          result[attribute.attributeName] = payload
        
        case let payload as Int:
          result[attribute.attributeName] = "\(payload)"
        
        case let payload as Double:result[attribute.attributeName] = "\(payload)"
        
        case let payload as Bool:
          result[attribute.attributeName] = "\(payload)"
        
        case let payload as Date:
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
          result[attribute.attributeName] = dateFormatter.string(from: payload)
          
        default:
          break
      }
    }
    return result
  }
}
