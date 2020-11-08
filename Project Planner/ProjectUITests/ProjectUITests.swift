//
//  ProjectUITests.swift
//  ProjectUITests
//
//  Created by Mostak Khan on 01/05/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import XCTest

class ProjectUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
     
        continueAfterFailure = false
        
        XCUIApplication().launch()

            }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testExample() {
        
    }
    
}
