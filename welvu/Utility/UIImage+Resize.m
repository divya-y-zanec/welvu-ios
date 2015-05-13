//
//  UIImage+Resize.m
//
//  Created by Olivier Halligon on 12/08/09.
//  Copyright 2009 AliSoftware. All rights reserved.
//

#import "UIImage+Resize.h"
#import "welvuContants.h"

@implementation UIImage (ResizeCategory)

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

-(UIImage*)resizedImageToSize:(CGSize)dstSize
{
	CGImageRef imgRef = self.CGImage;
	// the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
	CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
	
	CGFloat scaleRatio = dstSize.width / srcSize.width;
	UIImageOrientation orient = self.imageOrientation;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	/////////////////////////////////////////////////////////////////////////////
	// The actual resize: draw the image on a new context, applying a transform matrix
	UIGraphicsBeginImageContextWithOptions(dstSize, NO, 0.0);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -srcSize.height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -srcSize.height);
	}
	
	CGContextConcatCTM(context, transform);
	
	// we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
	UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return resizedImage;
    
}



/////////////////////////////////////////////////////////////////////////////



-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale
{
	// get the image size (independant of imageOrientation)
	CGImageRef imgRef = self.CGImage;
	CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which depends on the imageOrientation)!
	
	// adjust boundingSize to make it independant on imageOrientation too for farther computations
	UIImageOrientation orient = self.imageOrientation;
	switch (orient) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
			break;
        default:
            // NOP
            break;
	}
    
	// Compute the target CGRect in order to keep aspect-ratio
	CGSize dstSize;
	
	if ( !scale && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height) ) {
		//NSLog(@"Image is smaller, and we asked not to scale it in this case (scaleIfSmaller:NO)");
		dstSize = srcSize; // no resize (we could directly return 'self' here, but we draw the image anyway to take image orientation into account)
	} else {
		CGFloat wRatio = boundingSize.width / srcSize.width;
		CGFloat hRatio = boundingSize.height / srcSize.height;
		
		if (wRatio < hRatio) {
			//NSLog(@"Width imposed, Height scaled ; ratio = %f",wRatio);
			dstSize = CGSizeMake(boundingSize.width, floorf(srcSize.height * wRatio));
		} else {
			//NSLog(@"Height imposed, Width scaled ; ratio = %f",hRatio);
			dstSize = CGSizeMake(floorf(srcSize.width * hRatio), boundingSize.height);
		}
	}
    
	return [self resizedImageToSize:dstSize];
}

- (UIImage*)imageWithBorderForUnselected:(NSInteger) borderWidth {
    CGSize size = self.size;
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [self drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.80, 0.80, 0.80, 1.0);
    CGContextStrokeRectWithWidth(context, rect, borderWidth);
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}

- (UIImage *)imageWithBorderForSelected:(NSInteger) borderWidth {
    CGSize size = self.size;
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [self drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.94, 0.67, 0.14, 1.0);
    CGContextStrokeRectWithWidth(context, rect, borderWidth);
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}

- (UIImage *) imageWithTickForSelected {
    
    UIImage *overlayImage = [UIImage imageNamed:@"tick.png"];
    CGSize targetSize = self.size;
    CGPoint topCorner = CGPointMake((targetSize.width - 32), 0);
    
    CGRect scaledRect = CGRectZero;
    
    CGFloat scaledX = targetSize.height * self.size.width / self.size.height;
    CGFloat offsetX = (scaledX - targetSize.width) / -2;
    
    scaledRect.origin = CGPointMake(offsetX, 0.0);
    scaledRect.size.width  = scaledX;
    scaledRect.size.height = targetSize.height;
    
    UIGraphicsBeginImageContext(targetSize);
    [self drawInRect:scaledRect];
    [overlayImage drawAtPoint:topCorner];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *) fuseImages:(CGSize)targetSize:(UIImage *) overlayImage {
    CGPoint topCorner = CGPointMake(0, 0);
    
    CGRect scaledRect = CGRectZero;
    
    CGFloat scaledX = targetSize.height * self.size.width / self.size.height;
    CGFloat offsetX = (scaledX - targetSize.width) / -2;
    
    scaledRect.origin = CGPointMake(offsetX, 0.0);
    scaledRect.size.width  = scaledX;
    scaledRect.size.height = targetSize.height;
    
    UIGraphicsBeginImageContext(targetSize);
    [self drawInRect:scaledRect];
    [overlayImage drawAtPoint:topCorner];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *) imageResizeToFit:(CGSize)targetSize {
    CGRect scaledRect = CGRectZero;
    
    CGFloat scaledX = targetSize.height * self.size.width / self.size.height;
    CGFloat offsetX = (scaledX - targetSize.width) / -2;
    
    scaledRect.origin = CGPointMake(offsetX, 0.0);
    scaledRect.size.width  = scaledX;
    scaledRect.size.height = targetSize.height;
    
    UIGraphicsBeginImageContext(targetSize);
    [self drawInRect:scaledRect];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

-(UIImage *)makeRoundCornerImage: (int) cornerWidth : (int) cornerHeight
{
	UIImage * newImage = nil;
    
	if( nil != self)
	{
		@autoreleasepool {
            int w = self.size.width;
            int h = self.size.height;
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
            
            CGContextBeginPath(context);
            CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
            addRoundedRectToPath(context, rect, cornerWidth, cornerHeight);
            CGContextClosePath(context);
            CGContextClip(context);
            
            CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
            
            CGImageRef imageMasked = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            CGColorSpaceRelease(colorSpace);
            
            newImage = [UIImage imageWithCGImage:imageMasked];
            CGImageRelease(imageMasked);
            
        }
	}
    
    return newImage;
}
@end
