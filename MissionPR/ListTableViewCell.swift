//
//  ListTableViewCell.swift
//  MissionPR
//
//  Created by Lane Faison on 12/24/19.
//  Copyright © 2019 Lane Faison. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell, ConfigurableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewModel: ListCellViewModel?
    
    func configure(viewModel: ListCellViewModel) {
        self.viewModel = viewModel
        
        if viewModel.title.isEmpty {
            textLabel?.text = "Null!"
        } else {
            textLabel?.text = viewModel.title
        }
    }
}
