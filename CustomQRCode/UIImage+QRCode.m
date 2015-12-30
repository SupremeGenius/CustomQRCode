//
//  UIImage+QRCode.m
//  CustomQRCode
//
//  Created by chengxun on 15/12/30.
//  Copyright © 2015年 chengxun. All rights reserved.
//

#import "UIImage+QRCode.h"

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

@end
