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
        //let downscaled = resampleImage(OriginalImage, sizeX: OriginalImage.extent.width/2, sizeY: OriginalImage.extent.height/2)
        
        let grayInput = GrayScale(OriginalImage)
        let ratio = RGBRatio(OriginalImage, GrayImage: grayInput)
        
        //Algorithm
        let beginAlgo = NSDate()
        let outGray = FastLocalLaplacianFilter(grayInput, mapName: "LLF", MappingArgs: [0.3,0.25,1.0], numDiscrete: 20, numLevels:5)
        let endAlgo = NSDate()
        let intervalAlgo = endAlgo.timeIntervalSinceDate(beginAlgo)
        print("Algorithm took \(intervalAlgo) seconds.")
        
        let out = Multiply2(outGray, imageTwo: ratio)
        //Draw output
        view.addSubview(imageView)
        imageView.image = out

    }
    
    
    override func viewDidLayoutSubviews()
    {
        imageView.frame = view.bounds.insetBy(dx: 0, dy: 0)

    }
    
}

