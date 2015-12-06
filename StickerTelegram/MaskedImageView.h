#import <UIKit/UIKit.h>

@interface MaskedImageView : UIImageView

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *maskImage;

@end
