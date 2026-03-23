//
//  AttributeManager.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 03.02.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

@objcMembers
class AttributeManager {
    static func checkAttributes(appId: String, requestManager: DataRequestManager, campaignId: Int, targeting: Targeting, attributes: [Attribute], completion: @escaping (Bool) -> Void) {
        let campaignAttributes = targeting.attributes ?? []
        
        if (attributes.count == 0 && campaignAttributes.count == 0) ||
            campaignAttributes.count == 0 {
            completion(true)
            return
        }
        
        if campaignAttributes.count > attributes.count {
            completion(false)
            return
        }
        
        var checkAttributes: [Attribute] = []
        for campaignAttribute in campaignAttributes {
          if let attribute = attributes.first(where: { att in
            att.attributeName == campaignAttribute.attributeName
          }) {
            switch campaignAttribute.rule {
              case "equal":
                    if let value = campaignAttribute.value {
                        if let number = value.getNumber(),
                           let appAttribute = attribute.attributeValue as? NSNumber {
                            
                            if appAttribute.compare(number) != .orderedSame {
                                completion(false)
                                return
                            }
                        } else if let string = value.getString() {
                            var appAttribute: String?
                            if let appValue = attribute.attributeValue as? String {
                                appAttribute = appValue
                            } else if let appValue = attribute.attributeValue as? Bool {
                                appAttribute = appValue.description
                            }
                           
                            if appAttribute != string {
                              completion(false)
                              return
                            }
                        }
                    } else {
                        completion(false)
                        return
                    }
                
              case "contain":
                if let string = campaignAttribute.value?.getString(),
                   let appAttribute = attribute.attributeValue as? String {
                  if !appAttribute.contains(string) {
                    completion(false)
                    return
                  }
                } else {
                  completion(false)
                  return
                }
                
              case "dateRange":
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                var minDate = dateFormatter.date(from: "1900-01-01")
                var maxDate = dateFormatter.date(from: "2099-01-01")
                
                let valueDate = attribute.attributeValue as? Date
                let minString = campaignAttribute.valueFrom?.getString()
                let maxString = campaignAttribute.valueTo?.getString()
                
                if (minString != nil || maxString != nil) && valueDate != nil {
                  minDate = dateFormatter.date(from: minString ?? "1900-01-01")!
                  maxDate = dateFormatter.date(from: maxString ?? "2099-01-01")!
                  
                  if (valueDate!.compare(maxDate!) == .orderedAscending || valueDate!.compare(maxDate!) == .orderedSame),
                     (valueDate!.compare(minDate!) == .orderedDescending ||
                      valueDate!.compare(minDate!) == .orderedSame) {
                    break
                  } else {
                    completion(false)
                    return
                  }
                } else {
                  completion(false)
                  return
                }
                
              case "numberRange":
                if let valueNumber = attribute.attributeValue as? NSNumber {
                  let minValue = campaignAttribute.valueFrom?.getNumber() ?? NSNumber(integerLiteral: .min)
                  let maxValue = campaignAttribute.valueTo?.getNumber()  ?? NSNumber(integerLiteral: .max)
                  
                  if (valueNumber.compare(maxValue) == .orderedAscending ||
                      valueNumber.compare(maxValue) == .orderedSame) &&
                      (valueNumber.compare(minValue) == .orderedDescending ||
                       valueNumber.compare(minValue) == .orderedSame) {
                    break
                  } else {
                    completion(false)
                    return
                  }
                } else {
                  completion(false)
                  return
                }
              case "list":
                checkAttributes.append(attribute)
                
              default:
                completion(false)
                return
            }
          } else {
            completion(false)
            return
          }
        }
        
        if checkAttributes.count > 0 {
            DispatchQueue.global(qos: .userInitiated).async {
                requestManager.sendAttributes(appId: appId,
                                              campaignId: campaignId,
                                              attributes: checkAttributes) { [weak requestManager] result in
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            }
        } else {
            completion(true)
        }
    }
}
