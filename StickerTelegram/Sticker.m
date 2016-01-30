//
//  Sticker.m
//  Stickers Telegram
//
//  Created by Fede Cugliandolo on 5/12/15.
//  Copyright © 2015 YiyiSoft. All rights reserved.
//

#import "Sticker.h"
#import "UIimage+WebP.h"


@implementation Sticker

- (void) getWebPImage {
    __block NSString *webPPath;
    [UIImage imageToWebP:self.stickerImage quality:100 alpha:1.0
                  preset:WEBP_PRESET_ICON
             configBlock:nil
         completionBlock:^(NSData *result) {
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             webPPath = [paths[0] stringByAppendingPathComponent:@"image.webp"];
             if (![result writeToFile:webPPath atomically:YES]) {
                 NSLog(@"Failed to save file");
             }
         } failureBlock:^(NSError *error) {
             NSLog(@"%@", error.localizedDescription);
         }];
}

-(NSURL *)webpImageDataURL {
    if (_stickerImage) [self getWebPImage];
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

@end
