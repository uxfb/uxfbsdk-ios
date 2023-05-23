//
//  UXFRadiobuttonCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class UXFRadiobuttonCell: UXFBaseCell, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView! {
        didSet {
            let bundle = Bundle(for: UXFeedback.self)
            tableView.register(UINib(nibName: "UXFRadioCell", bundle: bundle), forCellReuseIdentifier: "UXFRadioCell")
            tableView.delegate = self
            tableView.dataSource = self
            tableView.backgroundColor = .clear
            tableView.allowsSelection = true
        }
    }
    
    private var options: Array<UXFOption> = []
    
    private var isError: Bool = false
    
    override func updateUI() {
        guard let data = try? JSONSerialization.data(withJSONObject: field?.uiData["options"] as Any, options: .prettyPrinted) else {
            return
        }

        guard let opt = try? JSONDecoder().decode([UXFOption].self,
                                                      from: data) else {
            return
        }
        options = opt
        tableView.backgroundColor = theme?.bgColor
        
        if field!.isError && field?.answers.count == 0 {
            isError = true
        } else {
            isError = false
        }
        
        tableView.reloadData()
        
        let id = field?.answers.first ?? ""
        
        if let index = options.lastIndex(where: { (option) -> Bool in
            option.id == id
        }) {
            tableView.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    //MARK: - Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UXFRadioCell", for: indexPath) as! UXFRadioCell
        cell.configure(option: options[indexPath.row], theme: theme!, isError: isError)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isError = false
        if self.delegate != nil {
            let id = options[indexPath.row]
            self.delegate?.fieldChanged(self.field!, answer:[id.id], refresh: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = self.bounds.width - 48
        let value = options[indexPath.row].value
        let font = theme!.fontP1
        let lines = CGFloat(value.linesCount(width: width, font: font))
//        let lines = CGFloat(value.linesCount(width: width, font: .mediumFont))
        return max(ceil(lines * font.lineHeight) + 24, 48)
    }
}

