//
//  UIImage+QRCode.m
//  CustomQRCode
//
//  Created by chengxun on 15/12/30.
//  Copyright © 2015年 chengxun. All rights reserved.
//

#import "UIImage+QRCode.h"
#import "UIImage+RoundRect.h"
@implementation UIImage (QRCode)
+ (UIImage*)imageOfQRCodeFromUrl:(NSString *)netWorkAddress codeSize:(CGFloat)codeSize{
    if(!netWorkAddress || (NSNull * )netWorkAddress == [NSNull null]){
        return nil;
    }
    codeSize = [self validateCodeSize:codeSize];
    CIImage * originImage = [self createQRFromAddress:netWorkAddress];
    //UIImage * result = [UIImage imageWithCIImage:originImage];
    UIImage * result = [self excludeFuzzuImageFromCIImage:originImage size:codeSize];
    return result;

}
+ (UIImage*)imageOfQRCodeFromUrl:(NSString *)netWorkAddress codeSize:(CGFloat)codeSize red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue{
    if(!netWorkAddress || (NSNull * )netWorkAddress == [NSNull null]){
        return nil;
    }
    NSUInteger rgb = (red << 16) + (green << 8) + blue;
    NSAssert((rgb & 0xffffff00) <= 0xd0d0d000, @"The color of QR code is two close to white color than it will diffculty to scan");
    codeSize = [self validateCodeSize:codeSize];
    CIImage * originImage = [self createQRFromAddress:netWorkAddress];
    UIImage * progressImage = [self excludeFuzzuImageFromCIImage:originImage size:codeSize];
    UIImage * effectiveImage = [self imageFillBlackColorAndTransparent: progressImage red: red green: green blue: blue];  
    return effectiveImage;
}

void ProviderReleaseData(void * info, const void * data, size_t size) {

    free((void *)data);

}

+ (UIImage*)imageFillBlackColorAndTransparent:(UIImage*)image red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth*4;
    uint32_t * rgbImageBuf = (uint32_t*)malloc(bytesPerRow*imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);

    CGContextDrawImage(context, (CGRect){(CGPointZero), (image.size)}, image.CGImage);

    //遍历像素

    int pixelNumber = imageHeight * imageWidth;

    [self fillWhiteToTransparentOnPixel: rgbImageBuf pixelNum: pixelNumber red: red green: green blue: blue];

    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow, ProviderReleaseData);

    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);

    UIImage * resultImage = [UIImage imageWithCGImage: imageRef];

    CGImageRelease(imageRef);

    CGColorSpaceRelease(colorSpace);

    CGContextRelease(context);

    return resultImage;
}
/**  颜色填充  */
+ (void)fillWhiteToTransparentOnPixel: (uint32_t *)rgbImageBuf pixelNum: (int)pixelNum red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue {

    uint32_t * pCurPtr = rgbImageBuf;

    for (int i = 0; i < pixelNum; i++, pCurPtr++) {

        if ((*pCurPtr & 0xffffff00) < 0xd0d0d000) {

            uint8_t * ptr = (uint8_t *)pCurPtr;

            ptr[3] = red;

            ptr[2] = green;

            ptr[1] = blue;

        } else {

            //将白色变成透明色

            uint8_t * ptr = (uint8_t *)pCurPtr;

            ptr[0] = 0;

        }

    }
    
}

+ (CGFloat)validateCodeSize:(CGFloat)codeSize{
    codeSize = MAX(160, codeSize);
    codeSize = MIN(CGRectGetWidth([UIScreen mainScreen].bounds)-80, codeSize);
    return codeSize;
}
/** 生成的模糊的二维码  */
+ (CIImage*)createQRFromAddress:(NSString*)networkAddress{
    NSData * stringData = [networkAddress dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    CIFilter * filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    return filter.outputImage;
}
/**  生成的清晰的二维码  */
+ (UIImage*)excludeFuzzuImageFromCIImage:(CIImage*)image size:(CGFloat)size{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);

    CIContext * context = [CIContext contextWithOptions: nil];

    CGImageRef bitmapImage = [context createCGImage: image fromRect: extent];

    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);

    CGContextScaleCTM(bitmapRef, scale, scale);

    CGContextDrawImage(bitmapRef, extent, bitmapImage);

    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);

    CGContextRelease(bitmapRef);

    CGImageRelease(bitmapImage);

    CGColorSpaceRelease(colorSpace);

    return [UIImage imageWithCGImage: scaledImage];
}
+ (UIImage *)imageInsertedImage: (UIImage *)originImage insertImage: (UIImage *)insertImage radius: (CGFloat)radius
{
    if (!insertImage) { return originImage; }
    insertImage = [UIImage imageOfRoundRectWithImage: insertImage size: insertImage.size radius: radius];
    UIImage * whiteBG = [UIImage imageNamed:@"ico_smallBand"];
    whiteBG = [UIImage imageOfRoundRectWithImage: whiteBG size: whiteBG.size radius: radius];

    //白色边缘宽度
    const CGFloat whiteSize = 2.f;
    CGSize brinkSize = CGSizeMake(originImage.size.width / 4, originImage.size.height / 4);
    CGFloat brinkX = (originImage.size.width - brinkSize.width) * 0.5;
    CGFloat brinkY = (originImage.size.height - brinkSize.height) * 0.5;

    CGSize imageSize = CGSizeMake(brinkSize.width - 2 * whiteSize, brinkSize.height - 2 * whiteSize);
    CGFloat imageX = brinkX + whiteSize;
    CGFloat imageY = brinkY + whiteSize;

    UIGraphicsBeginImageContext(originImage.size);
    [originImage drawInRect: (CGRect){ 0, 0, (originImage.size) }];
    [whiteBG drawInRect: (CGRect){ brinkX, brinkY, (brinkSize) }];
    [insertImage drawInRect: (CGRect){ imageX, imageY, (imageSize) }];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultImage;
}

@end
