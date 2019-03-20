//
//  UXFPageElement.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 20.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

protocol UXFPageElementProtocol: Decodable{
    var _id: String {get set}
    var type: String {get set}
    var value: String {get set}
}
