//
//  P9LayoutComposeView.m
//  
//
//  Created by Tae Hyun Na on 2016. 3. 4.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "P9LayoutComposeView.h"

@interface P9LayoutComposeView ()
{
    NSMutableDictionary *_componentDict;
    NSMutableDictionary *_previousTransformOfComponentDict;
}

- (BOOL)prepareResources;
- (NSDictionary *)trackingParametersFrom:(NSDictionary *)dict;
- (void)addTracking:(id)anObject parameters:(NSDictionary *)parameters forKey:(NSString *)key;
- (void)removeTracking:(id)anObject;

@end

@implementation P9LayoutComposeView

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) != nil ) {
        if( [self prepareResources] == NO ) {
            return nil;
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if( (self = [super initWithCoder:aDecoder]) != nil ) {
        if( [self prepareResources] == NO ) {
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self removeAllComponents];
}

- (BOOL)prepareResources
{
    self.clipsToBounds = YES;
    if( (_componentDict = [NSMutableDictionary new]) == nil ) {
        return NO;
    }
    if( (_previousTransformOfComponentDict = [NSMutableDictionary new]) == nil ) {
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)trackingParametersFrom:(NSDictionary *)parameters
{
    if( [parameters count] == 0 ) {
        return nil;
    }
    NSMutableDictionary *trackingParams = [NSMutableDictionary new];
    if( trackingParams == nil ) {
        return nil;
    }
    if( [[parameters objectForKey:P9LayoutComposeViewComponentFeezeingKey] boolValue] == YES ) {
        [trackingParams setObject:@(1) forKey:P9ViewDraggerLockTranslateKey];
        [trackingParams setObject:@(1) forKey:P9ViewDraggerLockRotateKey];
        [trackingParams setObject:@(1) forKey:P9ViewDraggerLockScaleKey];
    }
    if( [[parameters objectForKey:P9LayoutComposeViewComponentLockTrackingTranslateKey] boolValue] == YES ) {
        [trackingParams setObject:@(1) forKey:P9ViewDraggerLockTranslateKey];
    }
    if( [[parameters objectForKey:P9LayoutComposeViewComponentLockTrackingRotateKey] boolValue] == YES ) {
        [trackingParams setObject:@(1) forKey:P9ViewDraggerLockRotateKey];
    }
    if( [[parameters objectForKey:P9LayoutComposeViewComponentLockTrackingScaleKey] boolValue] == YES ) {
        [trackingParams setObject:@(1) forKey:P9ViewDraggerLockScaleKey];
    }
    
    return [NSDictionary dictionaryWithDictionary:trackingParams];
}

- (void)addTracking:(id)anObject parameters:(NSDictionary *)parameters forKey:(NSString *)key
{
    [[P9ViewDragger defaultTracker] trackingView:anObject parameters:parameters ready:^(UIView *trackingView) {
        @synchronized(self) {
            [_previousTransformOfComponentDict setObject:[NSValue valueWithCATransform3D:trackingView.layer.transform] forKey:key];
        }
        if( [self.delegate respondsToSelector:@selector(p9LayoutComposeView:willStartTracking:forKey:)] == YES ) {
            [self.delegate p9LayoutComposeView:self willStartTracking:anObject forKey:key];
        }
    } trackingHandler:^(UIView *trackingView) {
        if( [self.delegate respondsToSelector:@selector(p9LayoutComposeView:didTracking:forKey:)] == YES ) {
            [self.delegate p9LayoutComposeView:self didTracking:anObject forKey:key];
        }
    } completion:^(UIView *trackingView) {
        if( [self.delegate respondsToSelector:@selector(p9LayoutComposeView:didEndTracking:forKey:)] == YES ) {
            [self.delegate p9LayoutComposeView:self didEndTracking:anObject forKey:key];
        }
    }];
}

- (void)removeTracking:(id)anObject
{
    [[P9ViewDragger defaultTracker] untrackingView:anObject];
}

- (NSArray *)allComponents
{
    NSArray *list = nil;
    @synchronized(self) {
        list = [_componentDict allValues];
    }
    
    return list;
}

- (id)componentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return nil;
    }
    
    id component = nil;
    @synchronized(self) {
        component = [_componentDict objectForKey:key];
    }
    
    return component;
}

- (NSString *)keyForComponent:(id)anObject
{
    if( anObject == nil ) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%p", anObject];;
}

- (NSString *)addComponentObject:(id)anObject parameters:(NSDictionary *)parameters
{
    if( [anObject isKindOfClass:[UIView class]] == NO ) {
        return nil;
    }
    if( [anObject superview] != nil ) {
        return nil;
    }
    NSDictionary *trackingParams = [self trackingParametersFrom:parameters];
    NSString *key = [self keyForComponent:anObject];
    [self addSubview:anObject];
    CGRect targetFrame = [anObject bounds];
    CGFloat rate = (targetFrame.size.width > targetFrame.size.height) ? (self.frame.size.width/2.0)/targetFrame.size.width : (self.frame.size.height/2.0)/targetFrame.size.height;
    CGRect frame;
    frame.size.width = targetFrame.size.width * rate;
    frame.size.height = targetFrame.size.height * rate;
    frame.origin.x = (self.frame.size.width/2.0)-(frame.size.width/2.0);
    frame.origin.y = (self.frame.size.height/2.0)-(frame.size.height/2.0);
    [anObject setFrame:frame];
    @synchronized(self) {
        [_componentDict setObject:anObject forKey:key];
    }
    [self addTracking:anObject parameters:trackingParams forKey:key];
    
    return key;
}

- (NSString *)addDecoyComponentFromObject:(id)anObject parameters:(NSDictionary *)parameters
{
    if( ([anObject isKindOfClass:[UIImage class]] == NO) && ([anObject isKindOfClass:[UIView class]] == NO) ) {
        return nil;
    }
    NSDictionary *trackingParams = [self trackingParametersFrom:parameters];
    NSString *key = [self keyForComponent:anObject];
    UIImage *image = nil;
    if( [anObject isKindOfClass:[UIImage class]] == YES ) {
        image = (UIImage *)anObject;
    } else if( [anObject isKindOfClass:[UIView class]] == YES ) {
        UIView *targetView = (UIView *)anObject;
        UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, false, [UIScreen mainScreen].scale);
        [targetView drawViewHierarchyInRect:targetView.bounds afterScreenUpdates:YES];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    if( image == nil ) {
        return nil;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if( imageView == nil ) {
        return nil;
    }
    [self addSubview:imageView];
    CGFloat rate = (image.size.width > image.size.height) ? (self.frame.size.width/2.0)/image.size.width : (self.frame.size.height/2.0)/image.size.height;
    CGRect frame;
    frame.size.width = image.size.width * rate;
    frame.size.height = image.size.height * rate;
    frame.origin.x = (self.frame.size.width/2.0)-(frame.size.width/2.0);
    frame.origin.y = (self.frame.size.height/2.0)-(frame.size.height/2.0);
    imageView.frame = frame;
    @synchronized(self) {
        [_componentDict setObject:imageView forKey:key];
    }
    [self addTracking:imageView parameters:trackingParams forKey:key];
    
    return key;
}

- (void)removeComponentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return;
    }
    
    @synchronized(self) {
        id anObject = [_componentDict objectForKey:key];
        if( anObject != nil ) {
            [anObject removeFromSuperview];
            [_componentDict removeObjectForKey:key];
            [_previousTransformOfComponentDict removeObjectForKey:key];
            [self removeTracking:anObject];
        }
    }
}

- (void)removeAllComponents
{
    @synchronized(self) {
        NSArray *allViews = [_componentDict allValues];
        if( [allViews count] > 0 ) {
            [_componentDict removeAllObjects];
            [_previousTransformOfComponentDict removeAllObjects];
            for( id anObject in allViews ) {
                [anObject removeFromSuperview];
                [self removeTracking:anObject];
            }
        }
    }
}

- (NSInteger)layerOrderOfComponentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return -1;
    }
    
    id anObject = nil;
    @synchronized(self) {
        anObject = [_componentDict objectForKey:key];
    }
    if( anObject == nil ) {
        return -1;
    }
    
    return (NSUInteger)[self.subviews indexOfObject:anObject];
}

- (void)goUpLayerOrderOfComponentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return;
    }
    
    id anObject = nil;
    @synchronized(self) {
        anObject = [_componentDict objectForKey:key];
    }
    if( anObject == nil ) {
        return;
    }
    NSUInteger currnetIndex = [self.subviews indexOfObject:anObject];
    if( currnetIndex == ([self.subviews count]-1) ) {
        return;
    }
    
    [self exchangeSubviewAtIndex:currnetIndex withSubviewAtIndex:currnetIndex+1];
}

- (void)goTopLayerOrderOfComponentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return;
    }
    
    id anObject = nil;
    @synchronized(self) {
        anObject = [_componentDict objectForKey:key];
    }
    if( anObject == nil ) {
        return;
    }
    NSUInteger currnetIndex = [self.subviews indexOfObject:anObject];
    NSUInteger count = [self.subviews count];
    if( currnetIndex == (count-1) ) {
        return;
    }
    
    [self exchangeSubviewAtIndex:currnetIndex withSubviewAtIndex:count-1];
}

- (void)goDownLayerOrderOfComponentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return;
    }
    
    id anObject = nil;
    @synchronized(self) {
        anObject = [_componentDict objectForKey:key];
    }
    if( anObject == nil ) {
        return;
    }
    NSUInteger currnetIndex = [self.subviews indexOfObject:anObject];
    if( currnetIndex == 0 ) {
        return;
    }
    
    [self exchangeSubviewAtIndex:currnetIndex withSubviewAtIndex:currnetIndex-1];
}

- (void)goBottomLayerOrderOfComponentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return;
    }
    
    id anObject = nil;
    @synchronized(self) {
        anObject = [_componentDict objectForKey:key];
    }
    if( anObject == nil ) {
        return;
    }
    NSUInteger currnetIndex = [self.subviews indexOfObject:anObject];
    if( currnetIndex == 0 ) {
        return;
    }
    
    [self exchangeSubviewAtIndex:currnetIndex withSubviewAtIndex:0];
}

- (CATransform3D)transformOfComponentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return CATransform3DIdentity;
    }
    
    id anObject = nil;
    @synchronized(self) {
        anObject = [_componentDict objectForKey:key];
    }
    
    return ((anObject != nil) ? [[anObject layer] transform] : CATransform3DIdentity);
}

- (CATransform3D)previousTransformOfComponentForKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return CATransform3DIdentity;
    }
    
    NSValue *transformValue = nil;
    @synchronized(self) {
        transformValue = [_previousTransformOfComponentDict objectForKey:key];
    }
    
    return ((transformValue != nil) ? [transformValue CATransform3DValue] : CATransform3DIdentity);
}

- (void)setTransformOfComponent:(CATransform3D)transform forKey:(NSString *)key
{
    if( [key length] == 0 ) {
        return;
    }
    
    id anObject = nil;
    @synchronized(self) {
        anObject = [_componentDict objectForKey:key];
    }
    if( anObject != nil ) {
        [[anObject layer] setTransform:transform];
    }
}

- (UIImage *)captureStageForRate:(CGFloat)rate
{
    if( rate <= 0.0 ) {
        return nil;
    }
    
    CGRect frame = self.bounds;
    frame.size.width *= rate;
    frame.size.height *= rate;
    
    UIImage *captureImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, false, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:frame afterScreenUpdates:YES];
    captureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return captureImage;
}

@end
