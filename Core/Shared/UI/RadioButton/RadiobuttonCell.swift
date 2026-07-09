//
//  UXFRadiobuttonCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class RadiobuttonCell: BaseCell, UITableViewDelegate, UITableViewDataSource {
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(RadioCell.self,
                      forCellReuseIdentifier: String(describing: RadioCell.self))
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.allowsSelection = true
        view.separatorStyle = .none
        view.isScrollEnabled = false
        return view
    }()
    
    private var options: Array<Option> = []
    private var isError: Bool = false
    
    override func setupSubviews() {
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func updateUI() {
        guard let data = try? JSONSerialization.data(withJSONObject: field?.uiData["options"] as Any, options: .prettyPrinted) else {
            return
        }

        guard let opt = try? JSONDecoder().decode([Option].self,
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell", for: indexPath) as! RadioCell
        cell.configure(option: options[indexPath.row], theme: theme!, isError: isError)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wasError = isError
        isError = false
        if self.delegate != nil {
            let id = options[indexPath.row]
            self.delegate?.fieldChanged(self.field!, answer:[id.id], refresh: true)
        }
        if wasError, let theme = theme {
            for case let cell as RadioCell in tableView.visibleCells {
                if let ip = tableView.indexPath(for: cell) {
                    cell.configure(option: options[ip.row], theme: theme, isError: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = self.bounds.width - 48 - 32
        let value = options[indexPath.row].value
        let font = theme!.fontP1
        let lines = CGFloat(value.linesCount(width: width, font: font))
        return max(ceil(lines * font.lineHeight) + 24, 48)
    }
}

