//
//  CALayer+Addition.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 16/1/20.
//  Copyright © 2016年 东方佳联. All rights reserved.
//

#import "UIView+Addition.h"
#import <objc/objc.h>

static const char *additionImageKey = "additionImage";
static const char *additionLayerKey = "additionLayer";

@interface UIView()

@property (nonatomic, strong) CALayer *additionLayer;

@end

@implementation UIView (Addition)

- (CALayer *)additionLayer
{
    return objc_getAssociatedObject(self, additionLayerKey);
}

- (void)setAdditionLayer:(CALayer *)additionLayer
{
    objc_setAssociatedObject(self, additionLayerKey, additionLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)additionImage
{
    return objc_getAssociatedObject(self, additionImageKey);
}

- (void)setAdditionImage:(UIImage *)additionImage
{
    if (nil == self.additionLayer) {
        CALayer *layer = [CALayer layer];
        layer.frame = self.bounds;
        [self.layer insertSublayer:layer atIndex:0];
        self.additionLayer = layer;
    }
    objc_setAssociatedObject(self, additionImageKey, additionImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.additionLayer.contents = (id)additionImage.CGImage;
}

- (CGFloat)additionScale
{
    return 0;
}

- (void)setAdditionScale:(CGFloat)additionScale
{
    self.additionLayer.transform = CATransform3DMakeScale(1 + additionScale, 1 + additionScale, 0);
}

@end
