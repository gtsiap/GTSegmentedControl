//
//  SegmentedTableViewCell.swift
//  Example SegmentedControl
//
//  Created by Giorgos Tsiapaliokas on 16/12/15.
//  Copyright © 2015 Giorgos Tsiapaliokas. All rights reserved.
//

import UIKit
import GTSegmentedControl

class SegmentedTableViewCell: UITableViewCell {

    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Choose"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let segmentedControl: SegmentedControl = {
        let segmentedControl = SegmentedControl()
        segmentedControl.items = [
            "one", "two", "three",
            "four", "five", "six",
            "seven", "eight", "nine"
        ]
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.itemsPerRow = 3
        segmentedControl.spacing = 10
        
        return segmentedControl
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.segmentedControl)
        
        self.label.snp_makeConstraints() { make in
            make.left.top.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
        
        self.segmentedControl.snp_makeConstraints() { make in
            make.top.equalTo(self.contentView).offset(10)
            make.bottom.right.equalTo(self.contentView).offset(-10)
            make.left.equalTo(self.label.snp_right)
        }
    }

}
