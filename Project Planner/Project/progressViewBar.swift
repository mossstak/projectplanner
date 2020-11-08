//
//  progressViewBar.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
/*
 reference: Some code is inspired from Apple Developer.
 https://developer.apple.com/documentation/uikit/uiview
 https://developer.apple.com/documentation/uikit/uiprogressview/1619844-progress
 https://developer.apple.com/documentation/uikit/uiprogressview/1619846-setprogress
 */


import UIKit

class progressViewBar: UIView {
    
    //initializes the progress view object.
    //Determines the shape of the progress bar outlayer in this case it is a shape of a rectangle
    //returns the value nil

    var progressViewBar: UIView? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //var progress: Float{get, set}
    var checkProgress: Float = 1 {
        didSet {
            setUpProgressBar(for: checkProgress)
        }
    }
    
    
    //func setProgress(Float, animated: Bool)
    private func setUpProgressBar(for value: Float) {

        if let view = progressViewBar {
            view.removeFromSuperview()
        }

        let width = value > 0.0 ? self.frame.width * CGFloat(value) : CGFloat(0)
        
        //determines the size of the progress bar inside layer
        let pgb = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 12.0))
        
        // color.backgroundColor = color Literal
        pgb.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        
        addSubview(pgb)

        progressViewBar = pgb
    }


}
