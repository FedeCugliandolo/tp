//
//  MaskedImageViewController.m
//  StickerTelegram
//
//  Created by Fede Cugliandolo on 15/7/15.
//  Copyright (c) 2015 YiyiSoft. All rights reserved.
//

#import "MaskedImageViewController.h"
#import "WBMaskedImageView.h"
#import "Sticker.h"

@interface MaskedImageViewController ()

@property (strong, nonatomic) IBOutlet WBMaskedImageView *imageView;
@property (nonatomic, strong) Sticker *sticker;

@end

@implementation MaskedImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.originalImage = self.originalImage;
    self.imageView.maskImage = self.maskedImage;
    [self trimImageView:self.imageView];
    self.sticker = [Sticker new];
    self.sticker.stickerImage = self.imageView.image;
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareAsSticker:(id)sender {
    self.dc = [UIDocumentInteractionController interactionControllerWithURL:self.sticker.webpImageDataURL];
    self.dc.delegate = self;
    [self.dc presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
}


- (IBAction)shareAsPNG:(id)sender {
    if (!self.imageView.image) return;
    else {
        self.dc = [UIDocumentInteractionController interactionControllerWithURL:self.sticker.pngImageDataURL];
        self.dc.delegate = self;
        [self.dc presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }
}

#pragma mark - Cropping Image
- (CGRect)cropRectForImage:(UIImage *)image {
    
    CGImageRef cgImage = image.CGImage;
    CGContextRef context = [self createARGBBitmapContextFromImage:cgImage];
    if (context == NULL) return CGRectZero;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(context, rect, cgImage);
    
    unsigned char *data = CGBitmapContextGetData(context);
    CGContextRelease(context);
    
    //Filter through data and look for non-transparent pixels.
    long lowX = width;
    long lowY = height;
    int highX = 0;
    int highY = 0;
    if (data != NULL) {
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                long pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */;
                if (data[pixelIndex] != 0) { //Alpha value is not zero; pixel is not transparent.
                    if (x < lowX) lowX = x;
                    if (x > highX) highX = x;
                    if (y < lowY) lowY = y;
                    if (y > highY) highY = y;
                }
            }
        }
        free(data);
    } else {
        return CGRectZero;
    }
    
    return CGRectMake(lowX, lowY, highX-lowX, highY-lowY);
}

- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage {
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    long bitmapByteCount;
    long bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) return NULL;
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     width,
                                     height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL) free (bitmapData);
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

- (void) trimImageView:(UIImageView*)imageView {
    CGRect newRect = [self cropRectForImage:imageView.image];
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageView.image.CGImage, newRect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    imageView.image = newImage;
}

@end
