# Fast-LLF
Fast Local Laplacian Filters for iOS

An implementation of Fast Local Laplacian Filters (http://www.di.ens.fr/~aubry/llf.html) for iOS through Swift and custom Core Image filters.

Sample implementation:
http://imgur.com/gallery/4UeQV

Currently, it appars that the implementation is a tad on the slow side for live editing-- I'm wondering if there are parts in the implementation of the algorithm that can be used again to help with computation. 

It may help to do the following further paralellize the loop which forms each level of the output pyramid, and maybe force reuse of filters that are used multiple times on the image. However it's believed that the rendering portion of the image is taking up most of the time -- if there are ways to help with render speed, then there will be improvements.
