//
//  Functions.swift
//  Fast Local Laplacian Filters
//
//  Created by David Sacco on 8/12/16.
//  Copyright © 2016 David Sacco. All rights reserved.
//

import Foundation
import CoreImage

// GrayScale: Converts target CIImage to grayscale version.
// Inputs : inputImage: the image input, as a CIImage
// Outputs : CIImage
func GrayScale(inputImage: CIImage) -> CIImage
{
    let GrayscaleFilter = GrayScaleFilter()
    GrayscaleFilter.inputImage = inputImage
    return GrayscaleFilter.outputImage
}

// GaussianFilter: Performs a Gaussian Filter by a 5-tap method as descriped in Burte & Adelson's paper. Note the forced padding to prevent a black border affect from transparent pixels.
// Inputs : inputImage: The input to be blurred, as a CIImage
func GaussianFilter(inputImage: CIImage) -> CIImage
{
    let input = inputImage.imageByClampingToExtent().imageByCroppingToRect(CGRect(x: -5, y: -5, width: inputImage.extent.width+10, height: inputImage.extent.height+10))
    
    let kernelValues: [CGFloat] = [
        0.0025, 0.0125, 0.0200, 0.0125, 0.0025,
        0.0125, 0.0625, 0.1000, 0.0625, 0.0125,
        0.0200, 0.1000, 0.1600, 0.1000, 0.0200,
        0.0125, 0.0625, 0.1000, 0.0625, 0.0125,
        0.0025, 0.0125, 0.0200, 0.0125, 0.0025 ]
    
    let weightMatrix = CIVector(values: kernelValues,
                                count: kernelValues.count)
    
    let filter = CIFilter(name: "CIConvolution5X5",
                          withInputParameters: [
                            kCIInputImageKey: input,
                            kCIInputWeightsKey: weightMatrix])!
    
    let final = filter.outputImage!
    
    let rect = CGRect(x: 0, y: 0, width: inputImage.extent.size.width, height: inputImage.extent.size.height)
    
    return final.imageByCroppingToRect(rect)
    
}

// LLFRemap: Performs the color remapping as described in the first Local Laplacian Filter paper.
// Inputs : inputImage: the image to be remapped.
//          discrete: the sample gaussian coefficient, a value in [0,1].
//          sigma_r: parameter that controls what is and isn't an edge.
//          alpha: parameter that affects detail manipulation. 0<alpha<1 for enhancement, alpha>1 for diminishment.
//          beta: parameter that affects tone manipulation. beta > 1 for inverse tone mapping, beta < 1 for tone mapping.
// Outputs : CIImage
func LLFRemap(inputImage: CIImage, discrete: CGFloat, sigma_r: CGFloat, alpha: CGFloat, beta: CGFloat) -> CIImage
{
    let filter = LLFRemapFilter()
    filter.inputImage = inputImage
    filter.discrete = discrete
    filter.sigma_r = sigma_r
    filter.alpha = alpha
    filter.beta = beta
    
    return filter.outputImage
}

// resampleImage: Resamples the image to the target dimensions.
// Inputs : inputImage: the image to be resampled.
//          sizeX: the desired width of the sampled image.
//          sizeY: the desired height of the sampled image.
// Outputs : CIImage
func resampleImage(inputImage: CIImage, sizeX: CGFloat, sizeY: CGFloat) -> CIImage
{
    let inputWidth : CGFloat = inputImage.extent.size.width
    let inputHeight : CGFloat = inputImage.extent.size.height
    
    let scaleX = sizeX/inputWidth
    let scaleY = sizeY/inputHeight
    
    let resamplefilter = ResampleFilter()
    resamplefilter.inputImage = inputImage
    resamplefilter.inputScaleX = scaleX
    resamplefilter.inputScaleY = scaleY
    return resamplefilter.outputImage
}

// Sum: Takes the pixel by pixel sum of two images.
// Inputs : imageOne: the first Image to be summed.
//          imageTwo: the second Image to be summed.
// Outputs : CIImage
func Sum(imageOne:CIImage,imageTwo:CIImage) -> CIImage
{
    let generalFilter = SumOfImagesFilter()
    
    generalFilter.inputImage1 = imageOne
    generalFilter.inputImage2 = imageTwo
    
    return generalFilter.outputImage
    
}

// DifferenceA: Takes a sum of one image and a specific floating value, pixel by pixel. This is used for Greyscale images.
// Inputs : inputImage: the image to be added to.
//          discrete: A value, in [0,1], to be added pixel by pixel to the image.
// Outputs : CIImage
func DifferenceA(inputImage:CIImage,discrete:CGFloat) -> CIImage
{
    let generalFilter = DifferenceAFilter()
    generalFilter.inputImage1 = inputImage
    generalFilter.discrete = discrete
    return generalFilter.outputImage
    
}

// DifferenceB: The difference between two images. Order here matters, but negative values are preserved in the algorithm.
// Inputs : imageOne: The image that is being subtracted from.
//          imageTwo: The image that is imageOne is being subtracted by.
// Outputs : CIImage
func DifferenceB(imageOne:CIImage,imageTwo:CIImage) -> CIImage
{
    let generalFilter = DifferenceBFilter()
    generalFilter.inputImage1 = imageOne
    generalFilter.inputImage2 = imageTwo
    return generalFilter.outputImage
    
}

// LevelDimensions: Saves the sizes of the images in the pyramid at all levels, for reference.
// Inputs : image: The image that the pyramid is being computed from.
//          levels: The number of levels in the pyramid
// Outputs : an Array of Arrays, each of which containing the width and height of each pyramid level.
func LevelDimensions(image: CIImage,levels:Int) -> [[CGFloat]]
{
    let inputWidth : CGFloat = image.extent.width
    let inputHeight : CGFloat = image.extent.height
    
    var levelSizes : [[CGFloat]] = [[inputWidth,inputHeight]]
    for j in 1...(levels-1)
    {
        let temp = [floor(inputWidth/pow(2.0,CGFloat(j))),floor(inputHeight/pow(2,CGFloat(j)))]
        levelSizes.append(temp)
    }
    return levelSizes
}

// GaussianLevel: Computes a given level in the Gaussian Pyramid.
// Inputs : image: The image that the pyramid is formed from.
//          level: The desired level to be computed.
// Outputs : CIImage
func GaussianLevel(image:CIImage, level:Int) -> CIImage
{
    if level == 1 {
        return image
    }
    else{
        var GauPyrLevel : CIImage = image
        let PyrLevel = LevelDimensions(image, levels: level)
        var I : CIImage
        var J : CIImage
        
        for j in 2 ... level
        {
            J = GaussianFilter(GauPyrLevel)
            I = resampleImage(J, sizeX: PyrLevel[j-1][0], sizeY: PyrLevel[j-1][1])
            GauPyrLevel = I
        }
        return GauPyrLevel
    }
}


// LaplacianLevel: Computes a given level in the Laplacian Pyramid.
// Inputs : image: The image that the pyramid is formed from.
//          level: The desired level to be computed.
// Outputs : CIImage
func LaplacianLevel(image:CIImage,level:Int) -> CIImage
{
    let PyrLevel = LevelDimensions(image, levels: level+1)
    var LapPyrLevel : CIImage?
    
    let GaussLevel = GaussianLevel(image, level: level)
    let GaussLevelD = GaussianLevel(image, level: level+1)
    let GaussLevelDU = resampleImage(GaussLevelD, sizeX: PyrLevel[level-1][0], sizeY: PyrLevel[level-1][1])
    
    LapPyrLevel = DifferenceB(GaussLevel, imageTwo: GaussLevelDU)
    
    return LapPyrLevel!
    
}

// AbsDifference: The absolute difference between an image and a value. This is used in the FLLF algorithm. The input image should be a gaussian level, and the discretisation value should be a sampled gaussian coefficient.
// Inputs : image1: The image to be subtacted from.
//          discretisation: The value to subtract the image from.
// Outputs : CIImage
func AbsDifference(image1: CIImage, discretisation: CGFloat) -> CIImage
{
    let absdiffFilter = AbsoluteDifference()
    absdiffFilter.inputImage = image1
    absdiffFilter.discrete = discretisation
    return absdiffFilter.outputImage
}

// Threshold: Applies a threshold filter with given threshold. Used in the FLLF algorithm.
// Inputs : image: The input image.
//          threshold: the threshold value.
// Outputs : CIImage
func Threshold(image: CIImage, threshold: CGFloat) -> CIImage
{
    let thresholdFilter = ThresholdFilter()
    thresholdFilter.inputImage = image
    thresholdFilter.threshold = threshold
    return thresholdFilter.outputImage
}

// OneMinusDivide: Applies 1 - (input)/value to the image. This is used in the FLLF algorithm
// Inputs : image: The input image.
//          value: the value to be divided by.
// Outputs : CIImage
func OneMinusDivide(image: CIImage, value: CGFloat) -> CIImage
{
    let OMFilter = OneMinusFilter()
    OMFilter.inputImage = image
    OMFilter.discrete = value
    return OMFilter.outputImage
}

// Multiply2: Multiplies two images together, pixelwise.
// Inputs : imageOne: The first image to be multiplied.
//          imageTwo: The second image to be multiplied.
// Outputs : CIImage
func Multiply2(imageOne: CIImage, imageTwo:CIImage) -> CIImage
{
    let multiplyFilter = Multiply2Filter()
    multiplyFilter.inputImage1 = imageOne
    multiplyFilter.inputImage2 = imageTwo
    return multiplyFilter.outputImage
}

// RGBRatio: Image to store the RGB Ratios of an image and it's corresponding grey image.
// Inputs : RGBImage: The input image with color.
//          GrayImage: The grayscale version of RGBImage.
// Outputs : CIImage
func RGBRatio(RGBImage: CIImage,GrayImage: CIImage) -> CIImage
{
    let RatioFilter = GreyscaleRGBRatioFilter()
    RatioFilter.rgbImage = RGBImage
    RatioFilter.gsImage = GrayImage
    
    return RatioFilter.outputImage
    
}

// linspace: Function that splits up the interval [0,1] into N pieces, including 0 and 1.
// Inputs : N: The number of 'splits' to take upon [0,1].
// Outputs : A array containing values where [0,1] has been split up. N=3 yeilds {0,.5,1}.
public func linspace(N: Int) -> [CGFloat]
{
    var discrete : [CGFloat] = []
    let M = N
    for j in 0 ... (M-1)
    {
        discrete.append(CGFloat(j)/(CGFloat(M)-1.0))
    }
    
    return discrete
}

// ImageRemap: This function hosts all of the remapping functions that FLLF.
// Inputs : image: the image to be remapped.
//          name: A string, specifying the remapping function to be used. Current options are "LLF" and "Gaussian"
//          discrete: sample value of gaussian coefficient.
//          arguments: These are the arguments for the remapping function:
//              "Gaussian": [sigma, factor]
//                  sigma: controls variance of neiboring pixels. suggest a value between 0.1 and 0.3.
//                  factor: controls how much is done. >0 for detail enhancement, <0 for detail reduction.
//              "LLF": [sigma_r, alpha, beta]
//                  sigma_r: decides what is and isn't an edge/detail.
//                  alpha: controls detail manipulation
//                  beta: controla tone manipulation
// Outputs : CIImage
func ImageRemap(image: CIImage,name: String, discrete: CGFloat, arguments: [CGFloat]) -> CIImage
{
    
    switch name {
    case "Gaussian":
        let sampleRemap = SampleRemapFilter()
        sampleRemap.inputImage = DifferenceA(image, discrete: discrete)
        sampleRemap.sigma = arguments[0]
        sampleRemap.fact = arguments[1]
        return sampleRemap.outputImage
        
    case "LLF":
        return LLFRemap(image, discrete: discrete, sigma_r: arguments[0], alpha: arguments[1], beta: arguments[2])
  
    default:
        print("Non-valid Remapping filter chosen")
        return image
    }
}

// BuildLaplacianLevel: Build a specified level in the output pyramid for FLLF.
// Inputs : image: The image to base the pyramid on.
//          mapName: the name of the remapping function to be used.
//          MappingArgs: the arguments for the specified mapName.
//          discrete: the sampled gaussian coefficient.
//          level: the level of the pyramid to be computed.
// Outputs : CIImage
func BuildLaplacianLevel(image: CIImage, mapName: String ,MappingArgs:[CGFloat], discrete:[CGFloat],level:Int)->CIImage
{
    let discretisation_step = discrete[1]-discrete[0]
    let inputGaussian = GaussianLevel(image, level: level)
    //var outputLaplacian = LaplacianLevel(image, level: level)
    var outputLaplacian = CIImage(color:CIColor(red: 0, green: 0, blue: 0)).imageByCroppingToRect(inputGaussian.extent)
    
    for k in discrete
    {
        let Iremap = ImageRemap(image, name: mapName, discrete: k, arguments: MappingArgs)
        let SecondTerm = LaplacianLevel(Iremap, level: level)
        
        let TermToAdd = Multiply2(FirstThird(inputGaussian, discrete: k, threshold: discretisation_step), imageTwo: SecondTerm)
        
        outputLaplacian = Sum(outputLaplacian,imageTwo: TermToAdd)
    }
    return outputLaplacian
}

// FastLocalLaplacianFilter: Performs a FLLF on the image.
// Inputs : inputImage: an input grayscale image to be filtered.
//          mapName: the name of the remapping function.
//          MappingArgs: the arguments for the corresponding mapName.
//          numDiscrete: Number of intesities to sample from, as gaussian coefficients, reccomend setting to >10.
//          numLevels: Number of levels in the pyramid. Reccomend setting 1 to 5 for performance, anything longer takes a while to render.
// Outputs : CIImage
public func FastLocalLaplacianFilter(inputImage: CIImage, mapName: String, MappingArgs: [CGFloat], numDiscrete: Int, numLevels: Int) -> CIImage
{
    let numLev = numLevels
    let numDisc = numDiscrete
    let discretization = linspace(numDisc)
    var output : CIImage = GaussianLevel(inputImage, level: numLev)
    
    for j in 1...(numLev-1)
    {
        let tempLap = BuildLaplacianLevel(inputImage, mapName:mapName, MappingArgs: MappingArgs, discrete: discretization, level: numLev-j)
        output = Sum(tempLap, imageTwo: resampleImage(output, sizeX: tempLap.extent.width, sizeY: tempLap.extent.height))
        
    }
    return output
}