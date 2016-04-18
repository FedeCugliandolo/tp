//
//  Sticker.m
//  Stickers Telegram
//
//  Created by Fede Cugliandolo on 5/12/15.
//  Copyright © 2015 YiyiSoft. All rights reserved.
//

#import "Sticker.h"
#import "JPNG.h"
#import "UIimage+WebP.h"

@implementation Sticker

- (void) getWebPImage {
    __block NSString *webPPath;
    __weak Sticker *weakSelf = self;
    [UIImage imageToWebP:self.stickerImage quality:100 alpha:1.0
                  preset:WEBP_PRESET_ICON
             configBlock:nil
         completionBlock:^(NSData *result) {
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             webPPath = [paths[0] stringByAppendingPathComponent:@"image.webp"];
             if (![result writeToFile:webPPath atomically:YES]) {
                 NSLog(@"Failed to save file");
             } else {
                 [weakSelf save512PNG:result];
             }
         } failureBlock:^(NSError *error) {
             NSLog(@"%@", error.localizedDescription);
         }];
}

- (void) save512PNG:(NSData*)webPData {
    UIImage *imageFromWebPData = [UIImage imageWithWebPData:webPData];
    UIImage *scaledImage = [self scaleImage:imageFromWebPData proportionallyToSize:CGSizeMake(512, 512)];
    NSData *pngData = UIImagePNGRepresentation(scaledImage);
    UIImage *pngImage = [UIImage imageWithData:pngData];
    UIImage *pngImageAUX;
    float percent = 1.0;
    while (pngData.length / 1024 >= 350) {
        NSLog(@"init weight: %@", @(pngData.length / 1024));
        pngData = UIImageJPEGRepresentation(pngImage, percent);
        pngImageAUX = [UIImage imageWithData:pngData];
        pngData = UIImagePNGRepresentation(pngImageAUX);
        pngImageAUX = [UIImage imageWithData:pngData];
        percent -= .01;
        NSLog(@"final weight: %@", @(pngData.length / 1024));
    }
    if (pngImageAUX) {
        pngImage = pngImageAUX;
    }
    UIImageWriteToSavedPhotosAlbum(pngImage, nil, nil, nil);
}

-(NSURL *)webpImageDataURL {
    if (_stickerImage) {
        [self getWebPImage];
    }
    else NSLog(@"Error: No hay imagen para convertir");

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [documentsDirectory stringByAppendingPathComponent:@"image.webp"];
    
    return [NSURL fileURLWithPath:filename];
}

-(NSURL *)pngImageDataURL {
    NSData *imgData;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"image.png"];
    
    if (_stickerImage) {
         imgData = UIImagePNGRepresentation(self.stickerImage);
    }
    
    if ([imgData writeToFile:filePath atomically:YES])
        return [NSURL fileURLWithPath:filePath];
    else
        return nil;
}

#pragma mark - Scale Image
- (UIImage *)scaleImage:(UIImage *)originalImage toSize:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), originalImage.CGImage);
    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), originalImage.CGImage);
    }
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    
    return image;
}

- (CGSize)estimateNewSize:(CGSize)newSize forImage:(UIImage *)image
{
    if (image.size.width > image.size.height) {
        newSize = CGSizeMake(newSize.width, (image.size.height/image.size.width) * newSize.height);
    } else {
        newSize = CGSizeMake((image.size.width/image.size.height) * newSize.width, newSize.height);
    }
    
    return newSize;
}

- (UIImage *)scaleImage:(UIImage *)image proportionallyToSize:(CGSize)newSize
{
    return [self scaleImage:image toSize:[self estimateNewSize:newSize forImage:image]];
}

- (UIImage *)scaleImageWithData:(NSData *)imageData proportionallyToSize:(CGSize)newSize
{
    return [self scaleImage:[UIImage imageWithData:imageData] toSize:[self estimateNewSize:newSize forImage:[UIImage imageWithData:imageData]]];
}

@end
