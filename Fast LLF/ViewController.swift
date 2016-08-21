//
//  ViewController.swift
//  Test
//
//  Created by David Sacco on 7/26/16.
//  Copyright © 2016 David Sacco. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let imageView = OpenGLImageView()
    
    let OriginalImage = CIImage(image:UIImage(named: "flower")!)!
    
    
    
    let begin = NSDate()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialization
        //let downscaled = resampleImage(OriginalImage, sizeX: OriginalImage.extent.width/2, sizeY: OriginalImage.extent.height/2) //might need to downscale to screen size?
        
        let grayInput = GrayScale(OriginalImage)
        let ratio = RGBRatio(OriginalImage, GrayImage: grayInput)
        
        //Algorithm
        let beginAlgo = NSDate()
        let outGray = FastLocalLaplacianFilter(grayInput, mapName: "LLF", MappingArgs: [0.3,0.25,1.0], numDiscrete: 20, numLevels:5)
        let endAlgo = NSDate()
        let intervalAlgo = endAlgo.timeIntervalSinceDate(beginAlgo)
        print("Algorithm took \(intervalAlgo) seconds to run.")
        
        let out = Multiply2(outGray, imageTwo: ratio)
        //Draw output
        view.addSubview(imageView)
        imageView.image = out //How to time it takes to render to screen? o_O

    }
    
    
    override func viewDidLayoutSubviews()
    {
        imageView.frame = view.bounds.insetBy(dx: 0, dy: 0)

    }
    
}

