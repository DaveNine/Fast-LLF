//
//  ViewController.swift
//  Test
//
//  Created by David Sacco on 7/26/16.
//  Copyright © 2016 David Sacco. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    let imageView = OpenGLImageView()
    
    let OriginalImage = CIImage(image:UIImage(named: "symflower-down.jpeg")!)!
    
    
    
    let begin = NSDate()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialization
        let saver = CustomPhotoAlbum.sharedInstance
        let downscaled = resampleImage(OriginalImage, sizeX: OriginalImage.extent.width, sizeY: OriginalImage.extent.height) //might need to downscale to screen size?
        
        let grayInput = GrayScale(downscaled)
        let ratio = RGBRatio(downscaled, GrayImage: grayInput)
        
        //Algorithm
        let beginAlgo = NSDate()
        let outGray = FastLocalLaplacianFilter(grayInput, mapName: "LLF", MappingArgs: [0.3,0.25,1.0], numDiscrete: 20, numLevels:5)
        let endAlgo = NSDate()
        let intervalAlgo = endAlgo.timeIntervalSinceDate(beginAlgo)
        print("Algorithm took \(intervalAlgo) seconds to run.")
        
        let out = Multiply2(outGray, imageTwo: ratio)
        
        //Save the image
        let beginSave = NSDate()
        let cgimage = imageView.ciContext.createCGImage(out, fromRect: out.extent)
        let uiimage = UIImage(CGImage: cgimage)
        let jpegimage = UIImageJPEGRepresentation(uiimage, 1.0)
        let newimg = UIImage(data: jpegimage!)!

        saver.saveImage(newimg)
        
        let endSave = NSDate()
        let intervalSave = endSave.timeIntervalSinceDate(beginSave)
        print("Saving took \(intervalSave) seconds.")
        
        //Draw output
        view.addSubview(imageView)
        imageView.image = out //How to time it takes to render to screen? o_O
        
        
        
        
    }
    

    
    override func viewDidLayoutSubviews()
    {
        imageView.frame = view.bounds.insetBy(dx: 0, dy: 0)

    }
    
}

