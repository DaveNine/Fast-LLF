//
//  TestFilters.swift
//  FastLocalLaplacianFilter
//
//  Created by David Sacco on 8/12/16.
//  Copyright © 2016 David Sacco. All rights reserved.
//

import Foundation
import CoreImage


public class FirstThirdTermFilter: CIFilter
{
    var inputImage : CIImage?
    var discrete : CGFloat?
    var threshold : CGFloat?
    
    var kernel = CIColorKernel(string:
        "kernel vec4 Difference(__sample image1,float discrete, float threshold)" +
            "       {                                               " +
            "           float diff = abs(image1.r - discrete);         " +
            "           float FirstTerm = step(diff,threshold); " +
            "           float ThirdTerm = 1.0 - (diff / threshold); " +
            "           return vec4(vec3(FirstTerm*ThirdTerm),1.0);" +
            "}"

    )

    override public var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            discrete = discrete,
            threshold = threshold,
            kernel = kernel
            else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage,discrete,threshold]
        return kernel.applyWithExtent(extent,arguments: arguments)
        
    }
}

public func FirstThird(image: CIImage, discrete: CGFloat, threshold: CGFloat) -> CIImage
{
    let filter = FirstThirdTermFilter()
    filter.inputImage = image
    filter.discrete = discrete
    filter.threshold = threshold
    return filter.outputImage
}



