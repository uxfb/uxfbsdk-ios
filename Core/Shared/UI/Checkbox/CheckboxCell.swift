//
//  UXFCheckboxCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class CheckboxCell: BaseCell, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(CheckCell.self,
                      forCellReuseIdentifier: String(describing: CheckCell.self))
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.allowsMultipleSelection = true
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
        options = field?.options ?? []
        tableView.backgroundColor = theme?.bgColor
        
        if field!.isError && field?.answers.count == 0 {
            isError = true
        } else {
            isError = false
        }
        
        tableView.reloadData()
        
        for answer in field?.answers ?? [] {
            if let index = options.lastIndex(where: { (option) -> Bool in
                option.id == answer
            }) {
                tableView.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    //MARK: - Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckCell", for: indexPath) as! CheckCell
        let theme = self.theme
        cell.configure(option: options[indexPath.row], theme: theme!, isError: isError)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wasError = isError
        isError = false
        checkAnswer(indexPath: indexPath)
        if wasError, let theme = theme {
            for case let cell as CheckCell in tableView.visibleCells {
                if let ip = tableView.indexPath(for: cell) {
                    cell.configure(option: options[ip.row], theme: theme, isError: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        checkAnswer(indexPath: indexPath)
        let selectedRows = tableView.indexPathsForSelectedRows ?? []
        if selectedRows.isEmpty, (field?.isError ?? false), let theme = theme {
            isError = true
            for case let cell as CheckCell in tableView.visibleCells {
                if let ip = tableView.indexPath(for: cell) {
                    cell.configure(option: options[ip.row], theme: theme, isError: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = self.bounds.width - 44 - 32
        let value = options[indexPath.row].value
        let font = theme!.fontP1
        let lines = CGFloat(value.linesCount(width: width, font: font))
//        let lines = CGFloat(value.linesCount(width: width, font: .mediumFont))
        return max(ceil(lines * font.lineHeight) + 24, 48)
    }
    
    //MARK:- CALL DELEGATE
    
    private func checkAnswer(indexPath: IndexPath) {
        if self.delegate != nil {
            let indexes = tableView.indexPathsForSelectedRows?.map({ (indexPath) -> Int in
                indexPath.row
            }) ?? []
            
            var answers: [String] = []
            for index in indexes {
                answers.append(options[index].id)
            }
            
            if (options[indexPath.row].exceptional ?? false) && answers.contains(options[indexPath.row].id) {
                answers = [options[indexPath.row].id]
                for selected in tableView.indexPathsForSelectedRows ?? [] where selected != indexPath {
                    tableView.deselectRow(at: selected, animated: true)
                }
            } else if !(options[indexPath.row].exceptional ?? false) {
                answers.removeAll { answer in
                    return options.filter { $0.exceptional ?? false }
                        .map { $0.id }
                        .contains(answer)
                }
                for selected in tableView.indexPathsForSelectedRows ?? [] where options[selected.row].exceptional ?? false {
                    tableView.deselectRow(at: selected, animated: true)
                }
            }
            
            self.delegate?.fieldChanged(self.field!, answer: answers, refresh: true)
        }
    }
}
