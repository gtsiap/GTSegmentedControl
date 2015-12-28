// Copyright (c) 2015 Giorgos Tsiapaliokas <giorgos.tsiapaliokas@mykolab.com>
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
    public var items: [AnyObject] = [AnyObject]() {
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
            // TODO
            // We can't use UIAppearance.appearanceWhenContainedInInstancesOfClasses
            // because we need iOS 8.4 so lets do the theming manually
            applyTextColor()
        }
    }

    public override func tintColorDidChange() {
        for control in self.segmentedControls {
            control.tintColor = self.tintColor
        }
    }

    private func applyTextColor() {

        if let tintColor = self.textColor {
            for control in self.segmentedControls {
                control.setTitleTextAttributes([
                    NSForegroundColorAttributeName: tintColor,
                    NSFontAttributeName: UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
                ], forState: .Selected)
            }
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
    
    private func addSegment(
        segmentedControl: UISegmentedControl,
        item: AnyObject
        ) -> Bool {
            guard
                segmentedControl.numberOfSegments < self.itemsPerRow
                else { return false }
            
            let segmentIndex = segmentedControl.numberOfSegments
            segmentedControl.insertSegmentWithTitle(
                item as? String,
                atIndex: segmentIndex,
                animated: false
            )
            
            return true
    }
    
    private func addSegmentedControlsToView() {
        var previousControl: UISegmentedControl!
        
        for (index, control) in self.segmentedControls.enumerate() {
            
            // TODO
            // We can't use UIAppearance.appearanceWhenContainedInInstancesOfClasses
            // because we need iOS 8.4 so lets do the theming manually
            applyTextColor()

            addObserverForSegmentedControl(control)
            
            addSubview(control)
            
            if index == 0 {
                control.snp_makeConstraints() { make in
                    make.left.right.equalTo(self)
                    make.top.equalTo(self)
                }
                
            } else {
                control.snp_makeConstraints() { make in
                    make.left.right.equalTo(self)
                    make.top.equalTo(previousControl.snp_bottom)
                        .offset(self.spacing).priorityLow()
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
                let title = control.titleForSegmentAtIndex(index)
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
    public override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>)
    {
        
        if keyPath != "selectedSegmentIndex" &&
            context != &self.kvoContext
        {
            return
        }
        
        guard let segmentedControl = object as? UISegmentedControl else { return }
        
        if let
            value = segmentedControl
                .titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex)
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
    
    private func removeObserverForSegmentedControl(control: UISegmentedControl) {
        control.removeObserver(
            self,
            forKeyPath: "selectedSegmentIndex",
            context: &self.kvoContext
        )
    }
    
    private func addObserverForSegmentedControl(control: UISegmentedControl) {
        control.addObserver(
            self,
            forKeyPath: "selectedSegmentIndex",
            options: [.Old, .New],
            context: &self.kvoContext
        )
    }
    
    public override func intrinsicContentSize() -> CGSize {
        var height: CGFloat = 0
        
        for (index, control) in self.segmentedControls.enumerate() {
            if index != 0 {
                height += CGFloat(self.spacing)
            }
            
            height += control.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        }
        
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
    }
}
