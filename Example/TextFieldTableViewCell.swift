//
//  TextFieldTableViewCell.swift
//  Example SegmentedControl
//
//  Created by Giorgos Tsiapaliokas on 16/12/15.
//  Copyright © 2015 Giorgos Tsiapaliokas. All rights reserved.
//

import UIKit
import SnapKit

class TextFieldTableViewCell: UITableViewCell {

    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Something"
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()
   
    private let label: UILabel = {
        let label = UILabel()
        label.text = "A Simple TextField"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.textField)
        
        self.label.snp_makeConstraints() { make in
            make.left.top.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
        
        self.textField.snp_makeConstraints() { make in
            make.top.equalTo(self.contentView).offset(10)
            make.bottom.right.equalTo(self.contentView).offset(-10)
        }
    }

}
