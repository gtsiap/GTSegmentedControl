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
import SnapKit

/**
    A multiline segmented control
 */
public class SegmentedControl: UIView {
    
    /**
        The items of the segmented control
     */
    public var items: [Any] = [Any]() {
        didSet {
            createSegmentedControls()
        }
    }
    
    /**
        Items per row
     */
    public var itemsPerRow = 3 {
        didSet {
            createSegmentedControls()
        }
    }
    
    /**
        Spacing between the rows
     */
    public var spacing: Double = 0 {
        didSet {
            createSegmentedControls()
        }
    }
    
    private var _value: String?
    
    /**
        The value for the current selected segment
     */
    public var value: String? {
        get {
            return self._value
        }
        
        set(newValue) {
            // we will start an expensive operation
            // so we must do it only if there is difference
            // in the UI.
            
            if self.value == newValue {
                return
            }
            
            self._value = newValue
            changeCurrentIndex()
        }
    }
    
    /**
        It is called when value changes
     */
    public var valueDidChange: ((String) -> ())?

    /**
        This color will be used as the color of the
        UISegmentedControl's text
     */
    public var textColor: UIColor? {
        didSet {
            let attributes = [
                NSForegroundColorAttributeName: tintColor,
                NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
            ]

            UISegmentedControl
                .appearance(whenContainedInInstancesOf: [type(of: self)])
                .setTitleTextAttributes(attributes, for: .selected)
        }
    }

    public override func tintColorDidChange() {
        for control in self.segmentedControls {
            control.tintColor = self.tintColor
        }
    }

    private var segmentedControls: [UISegmentedControl] = [UISegmentedControl]()
    
    private var kvoContext = UInt8()
    
    deinit {
        for control in self.segmentedControls {
            removeObserverForSegmentedControl(control)
        }
    }
    
    private func createSegmentedControls() {
        removeSegmentedControlsFromView()
        
        var currentSegmentedControl = UISegmentedControl()
        
        self.segmentedControls.append(currentSegmentedControl)
        for item in self.items {
            
            if !addSegment(currentSegmentedControl, item: item) {
                currentSegmentedControl = UISegmentedControl()
                
                self.segmentedControls.append(currentSegmentedControl)
                currentSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
                addSegment(currentSegmentedControl, item: item)
            }
        }
        
        addSegmentedControlsToView()
    }

    @discardableResult
    private func addSegment(
        _ segmentedControl: UISegmentedControl,
        item: Any
    ) -> Bool {
        guard
            segmentedControl.numberOfSegments < self.itemsPerRow
        else { return false }
            
        let segmentIndex = segmentedControl.numberOfSegments
        segmentedControl.insertSegment(
            withTitle: item as? String,
            at: segmentIndex,
            animated: false
        )
            
        return true
    }
    
    private func addSegmentedControlsToView() {
        var previousControl: UISegmentedControl!
        
        for (index, control) in self.segmentedControls.enumerated() {
            addObserverForSegmentedControl(control)
            
            addSubview(control)
            
            if index == 0 {
                control.snp.makeConstraints() { make in
                    make.left.right.equalTo(self)
                    make.top.equalTo(self)
                }
                
            } else {
                control.snp.makeConstraints() { make in
                    make.left.right.equalTo(self)
                    make.top.equalTo(previousControl.snp.bottom)
                        .offset(self.spacing).priority(UILayoutPriorityDefaultLow)
                }
            }
            
            previousControl = control
        }
    }
    
    private func removeSegmentedControlsFromView() {
        for segment in self.segmentedControls {
            segment.removeFromSuperview()
            removeObserverForSegmentedControl(segment)
        }
        
        self.segmentedControls.removeAll()
    }
    
    private func changeCurrentIndex() {
        guard let
            value = self.value
            else { return }
        
        for control in self.segmentedControls {
            for index in 0...control.numberOfSegments - 1 {
                let title = control.titleForSegment(at: index)
                guard value == title else { continue }
                
                // yes KVO sucks, but we don't have another
                // way to do this
                removeObserverForSegmentedControl(control)
                control.selectedSegmentIndex = index
                addObserverForSegmentedControl(control)
            } // end for index
        } // end for
    }

    // MARK: KVO
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?)
    {
        
        if keyPath != "selectedSegmentIndex" &&
            context != &self.kvoContext
        {
            return
        }
        
        guard let segmentedControl = object as? UISegmentedControl else { return }
        
        if let
            value = segmentedControl
                .titleForSegment(at: segmentedControl.selectedSegmentIndex)
        {
            self._value = value
            self.valueDidChange?(value)
        }
        
        for control in self.segmentedControls {
            guard control != segmentedControl else { continue }
            
            // If we don't remove the observer and call the selectedSegmentIndex
            // then the KVO will be triggered again. And then the selectedSegmentIndex
            // will call the KVO. In simple words we will trigger an infinite loop.
            // We can't use UIControlEvents.ValueChanged because
            // in iOS 9 if the keyboard is active the .ValueChanged target won't
            // be called.
            
            removeObserverForSegmentedControl(control)
            control.selectedSegmentIndex = -1
            addObserverForSegmentedControl(control)
        }
        
    }
    
    private func removeObserverForSegmentedControl(_ control: UISegmentedControl) {
        control.removeObserver(
            self,
            forKeyPath: "selectedSegmentIndex",
            context: &self.kvoContext
        )
    }
    
    private func addObserverForSegmentedControl(_ control: UISegmentedControl) {
        control.addObserver(
            self,
            forKeyPath: "selectedSegmentIndex",
            options: [.old, .new],
            context: &self.kvoContext
        )
    }
    
    open override var intrinsicContentSize : CGSize {
        var height: CGFloat = 0
        
        for (index, control) in self.segmentedControls.enumerated() {
            if index != 0 {
                height += CGFloat(self.spacing)
            }
            
            height += control.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        }
        
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
    }
}
