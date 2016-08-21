import Foundation
import CoreImage

class AbsoluteDifference: CIFilter
{
    var inputImage : CIImage?
    var discrete : CGFloat?
    
    var kernel = CIColorKernel(string:
        "kernel vec4 Difference(__sample image1,float discrete)" +
            "       {                                               " +
            "           float diff = abs(image1.r - discrete);         " +
            "           return vec4(vec3(diff),image1.a);        " +
        "       }                                               "
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            discrete = discrete,
            kernel = kernel
            else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage,discrete]
        return kernel.applyWithExtent(extent,arguments: arguments)
        
    }
    
}

class DifferenceAFilter : CIFilter
{
    var inputImage1 : CIImage?  //Initializes input
    var discrete : CGFloat?
    var kernel = CIColorKernel(string:  //The actual custom kernel code
        "kernel vec4 Difference(__sample image1,float discrete)" +
            "{" +
            "float diff = image1.r - discrete;" +
            "return vec4(vec3(diff),1.0);" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage1 = inputImage1,
            discrete = discrete,
            kernel = kernel
            else
        {
            return nil
        }
        
        let extent = inputImage1.extent
        let arguments = [inputImage1,discrete]
        return kernel.applyWithExtent(extent,arguments:arguments)
    }
}

class DifferenceBFilter : CIFilter
{
    var inputImage1 : CIImage?  //Initializes input
    var inputImage2 : CIImage?
    var kernel = CIColorKernel(string:  //The actual custom kernel code
        "kernel vec4 Difference(__sample image1,__sample image2)" +
            "{" +
            "float diff = image1.r - image2.r;" +
            "return vec4(vec3(diff),1.0);" +
        "}"
    )
    var extentFunction: (CGRect, CGRect) -> CGRect =
        { (a: CGRect, b: CGRect) in return CGRectZero }
    
    
    override var outputImage: CIImage!
    {
        guard let inputImage1 = inputImage1,
            inputImage2 = inputImage2,
            kernel = kernel
            else
        {
            return nil
        }
        let extent = inputImage1.extent
        let arguments = [inputImage1,inputImage2]
        return kernel.applyWithExtent(extent,arguments: arguments)
    }
    
}

class GrayScaleFilter: CIFilter
{
    //initialize inputs
    var inputImage: CIImage?
    
    //Write the Custome Color Kernel
    let GrayScaleKernel = CIColorKernel(string:
        "kernel vec4 grayFilter(__sample pixel)                        " +
            "{                                                              " +
            "    float gray = dot(pixel.rgb, vec3(0.2989,0.5870,0.1140)); " + //(0.2989,0.5870,0.1140), (0.3278,0.6557,0.0163)
            "    return vec4(vec3(gray),1.0);                           " +
        "}                                                              "
    )
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            GrayScaleKernel = GrayScaleKernel
            else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage]
        
        return GrayScaleKernel.applyWithExtent(extent,
                                               arguments: arguments)
    }
    
}

class GreyscaleRGBRatioFilter : CIFilter{
    
    var rgbImage : CIImage?
    var gsImage : CIImage?
    
    let ratioKernel = CIColorKernel(string:
        "kernel vec4 GrayscaleFilter(__sample rgbImage,__sample gsImage)" +
            "{" +
            "vec3 ratio = rgbImage.rgb / gsImage.rgb;" +
            " return vec4(ratio,1.0);" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let rgbImage = rgbImage,
            gsImage = gsImage,
            ratioKernel = ratioKernel
            else
        {
            return nil
        }
        
        let extent = rgbImage.extent
        
        let arguments = [rgbImage,gsImage]
        
        return ratioKernel.applyWithExtent(extent, arguments: arguments)
    }
    
}

class LLFRemapFilter: CIFilter
{
    var inputImage : CIImage?  //Initializes input
    var discrete : CGFloat?
    var sigma_r: CGFloat?
    var alpha: CGFloat?
    var beta: CGFloat?
    
    var kernel = CIColorKernel(string:  //The actual custom kernel code
        "   kernel vec4 colorRemap(__sample inputIm,float discrete,float sigma_r,float alpha,float beta)" +
            "{" +
            "float NL = 0.01;" +
            "float P = inputIm.r;" +
            "float diff = P - discrete;" +
            /////////////////////////////////////////////////////////////////////
            "float d = abs(diff)/sigma_r;" +
            /////////////////////////////////////////////////////////////////////smooth step
            "float xmin = NL;" +
            "float xmax = 2.0*NL;" +
            "float x = d*sigma_r;" +
            "float y = clamp((x - xmin)/(xmax - xmin),0.0,1.0);" +
            "float tau = pow(y,2.0)*pow(y-2.0,2.0);" +
            "float fd = (alpha < 1.0) ? (tau*pow(d,alpha) + (1.0-tau)*d) : pow(d,alpha);" +
            ///////////////////////////////////////////////////////////////////rd
            "float rd = discrete + sign(diff)*sigma_r*(fd);" +
            /////////////////////////////////////////fe
            "float a = abs(diff) - sigma_r;" +
            "float fe = beta*a;" +
            ////////////////////////////////////////re
            "float re = discrete + sign(diff)*(fe + sigma_r);" +
            "float isedge = step(sigma_r,abs(diff));" +
            "float isnotedge = step(abs(diff),sigma_r);" +
            "float newPixel = isnotedge*rd + isedge*re;" +
            "return vec4(vec3(newPixel),1.0);" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            discrete = discrete,
            sigma_r = sigma_r,
            alpha = alpha,
            beta = beta,
            kernel = kernel
            else
        {
            return nil
        }
            let extent = inputImage.extent
            let arguments = [inputImage,discrete,sigma_r,alpha,beta]
            return kernel.applyWithExtent(extent,arguments: arguments)
            
        
        
    }
    
}

class Multiply2Filter : CIFilter{
    
    var inputImage1 : CIImage?
    var inputImage2 : CIImage?
    
    
    let multiplyKernel = CIColorKernel(string:
        "kernel vec4 mutliplyKernel(__sample inputIm1,__sample inputIm2)" +
            "{" +
            
            " return vec4(inputIm1.rgb * inputIm2.rgb,1.0);" +
        "}"
    )
    override var outputImage: CIImage!
    {
        guard let inputImage1  = inputImage1,
            inputImage2 = inputImage2,
            multiplyKernel = multiplyKernel
            else
        {
            return nil
        }
        
        let extent = inputImage1.extent
        
        let arguments = [inputImage1,inputImage2]
        
        return multiplyKernel.applyWithExtent(extent, arguments: arguments)
    }
    
}

class Multiply3Filter : CIFilter{
    
    var inputImage1 : CIImage?
    var inputImage2 : CIImage?
    var inputImage3 : CIImage?
    
    let multiplyKernel = CIColorKernel(string:
        "kernel vec4 multiplyKernel(__sample inputIm1,__sample inputIm2,__sample inputIm3)" +
            "{" +
            " return vec4(inputIm1.rgb *inputIm2.rgb *inputIm3.rgb,1.0);" +
        "}"
    )
    override var outputImage: CIImage!
    {
        guard let inputImage1  = inputImage1,
            inputImage2 = inputImage2,
            inputimage3 = inputImage3,
            multiplyKernel = multiplyKernel
            else
        {
            return nil
        }
        
        let extent = inputImage1.extent
        
        let arguments = [inputImage1,inputImage2,inputimage3]
        
        return multiplyKernel.applyWithExtent(extent, arguments: arguments)
    }
    
}

class OneMinusFilter : CIFilter
{
    var inputImage : CIImage?
    var discrete : CGFloat?
    
    var OneMinusKernel = CIColorKernel(string:
        "kernel vec4 OneMinusKernel(__sample inputIm,float discrete)" +
            "{" +
            "float outP = 1.0 - (inputIm.r / discrete);" +
            "return vec4(vec3(outP),1.0);" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            discrete = discrete,
            OneMinusKernel = OneMinusKernel
            else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage,discrete]
        return OneMinusKernel.applyWithExtent(extent,arguments: arguments)
        
    }
    
}

class ResampleFilter: CIFilter
{
    var inputImage : CIImage?
    var inputScaleX: CGFloat = 1
    var inputScaleY: CGFloat = 1
    let warpKernel = CIWarpKernel(string:
        "kernel vec2 resample(float inputScaleX, float inputScaleY)" +
            "   {                                                      " +
            "       float y = (destCoord().y / inputScaleY);           " +
            "       float x = (destCoord().x / inputScaleX);           " +
            "       return vec2(x,y);                                  " +
        "   }                                                      "
    )
    
    override var outputImage: CIImage!
    {
        if let inputImage = inputImage,
            kernel = warpKernel
        {
            let arguments = [inputScaleX, inputScaleY]
            
            let extent = CGRect(origin: inputImage.extent.origin,
                                size: CGSize(width: inputImage.extent.width*inputScaleX,
                                    height: inputImage.extent.height*inputScaleY))
            
            return kernel.applyWithExtent(extent,
                                          roiCallback:
                {
                    (index,rect) in
                    let sampleX = rect.origin.x/self.inputScaleX
                    let sampleY = rect.origin.y/self.inputScaleY
                    let sampleWidth = rect.width/self.inputScaleX
                    let sampleHeight = rect.height/self.inputScaleY
                    
                    let sampleRect = CGRect(x: sampleX, y: sampleY, width: sampleWidth, height: sampleHeight)
                    
                    return sampleRect
                },
                                          inputImage : inputImage,
                                          arguments : arguments)
            
        }
        return nil
    }
}

class SampleRemapFilter : CIFilter
{
    var inputImage : CIImage?
    var sigma : CGFloat = 0.02
    var fact : CGFloat = 5.0
    
    var remapKernel = CIColorKernel(string:
        "kernel vec4 remapKernel(__sample inputIm,float S,float F)" +
            "{" +
            "   float A = inputIm.r;" +
            "   float B = F*A*exp(-(A*A)/(2.0*S*S));" +
            "   return vec4(vec3(B),1.0);" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            remapKernel = remapKernel
            else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage,sigma,fact]
        return remapKernel.applyWithExtent(extent,arguments: arguments)
    }
    
}

class SumOfImagesFilter: CIFilter
{
    var inputImage1 : CIImage?  //Initializes input
    var inputImage2 : CIImage?
    var kernel = CIColorKernel(string:  //The actual custom kernel code
        "kernel vec4 Sum(__sample image1,__sample image2)" +
            "       {                                        " +
            "return vec4(vec3(image1.r + image2.r),1.0);" +
        "}"
    )

    
    
    override var outputImage: CIImage!
    {
        guard let inputImage1 = inputImage1,
            inputImage2 = inputImage2,
            kernel = kernel
            else
        {
            return nil
        }
        
        let extent = inputImage1.extent
        let arguments = [inputImage1,inputImage2]
        return kernel.applyWithExtent(extent,arguments: arguments)
    }
    
}

class ThresholdFilter : CIFilter{
    
    var inputImage : CIImage?
    var threshold : CGFloat = 0.75
    
    let thresholdKernel = CIColorKernel(string:
        "kernel vec4 thresholdFilter(__sample pixel, float threshold)" +
            "{" +
            " return vec4(step(pixel.r,threshold),step(pixel.g,threshold),step(pixel.b,threshold),1.0);" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            thresholdKernel=thresholdKernel
            else
        {
            return nil
        }
        
        let extent = inputImage.extent
        
        let arguments = [inputImage,threshold]
        
        return thresholdKernel.applyWithExtent(extent, arguments: arguments)
    }
    
}
