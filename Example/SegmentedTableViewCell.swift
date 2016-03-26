// Copyright (c) 2015-2016 Giorgos Tsiapaliokas <giorgos.tsiapaliokas@mykolab.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import GTSegmentedControl

class SegmentedTableViewCell: UITableViewCell {

    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
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

        segmentedControl.tintColor = UIColor.redColor()
        segmentedControl.textColor = UIColor.blackColor()

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
            make.centerY.equalTo(self.label.snp_centerY).priorityLow()
            make.right.equalTo(self.contentView).offset(-10)
            make.left.equalTo(self.label.snp_right)
            make.height.lessThanOrEqualTo(self.contentView).offset(-10)
        }
    }
}
