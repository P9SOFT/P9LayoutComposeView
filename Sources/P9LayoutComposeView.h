//
//  P9LayoutComposeView.h
//  
//
//  Created by Tae Hyun Na on 2016. 3. 4.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <UIKit/UIKit.h>
#import <P9ViewDragger/P9ViewDragger.h>

/*!
 Set this key to avoid translate action when tracking.
 */
#define     P9LayoutComposeViewComponentLockTrackingTranslateKey  @"P9LayoutComposeViewComponentLockTrackingTranslateKey"
/*!
 Set this key to avoid scale action when tracking.
 */
#define     P9LayoutComposeViewComponentLockTrackingScaleKey      @"P9LayoutComposeViewComponentLockTrackingScaleKey"
/*!
 Set this key to avoid rotate action when tracking.
 */
#define     P9LayoutComposeViewComponentLockTrackingRotateKey     @"P9LayoutComposeViewComponentLockTrackingRotateKey"
/*!
 Set this key to avoid all action when tracking.
 */
#define     P9LayoutComposeViewComponentFeezeingKey               @"P9LayoutComposeViewComponentFeezeingKey"

/*!
 P9LayoutComposeView
 
 P9LayoutcomposeView support that add, remove and edit layout its' subviews on runtime.
 */
@interface P9LayoutComposeView : UIView

/*!
 Return all added view objects
 @returns An array contains all added view objects.
 */
- (NSArray *)allComponents;

/*!
 Return view for key.
 @param key Given key string when adding object.
 @returns View for key.
 
 이 메소드는 동기처리됩니다.
 */
- (id)componentForKey:(NSString *)key;

/*!
 Return key value for given object.
 @param anObject An object to get key
 @returns Key value for given object.
 */
- (NSString *)keyForComponent:(id)anObject;

/*!
 Add view to subview of P9LayoutComposeView. if given view have already parent view then it'll fail.
 @param anObject Kind of UIView object to add.
 @param parameters Options for tracking.
 @returns Return key value for added object if succeed. If not, return nil.
 */
- (NSString *)addComponentObject:(id)anObject parameters:(NSDictionary *)parameters;

/*!
 Add view to subview of P9LayoutComposeView.
 This method will move similar with addComponentFromObject method but only different thing is make decoy view of given view and tracking it.
 @param anObject Kind of UIView or UIImage object to add.
 @param parameters Options for tracking.
 @returns Return key value for added object if succeed. If not, return nil.
 */
- (NSString *)addDecoyComponentFromObject:(id)anObject parameters:(NSDictionary *)parameters;

/*!
 Remove subview for given key.
 @param key Given key string when adding object.
 */
- (void)removeComponentForKey:(NSString *)key;

/*!
 Remove all subviews.
 */
- (void)removeAllComponents;

/*!
 Return layout order index of object for given key.
 @param key Given key string when adding object.
 @returns layout order index.
 */
- (NSInteger)layerOrderOfComponentForKey:(NSString *)key;

/*!
 Increase layout order index of object for given key.
 @param key Given key string when adding object.
 */
- (void)goUpLayerOrderOfComponentForKey:(NSString *)key;

/*!
 Make layout order index to last of object for given key.
 @param key Given key string when adding object.
 */
- (void)goTopLayerOrderOfComponentForKey:(NSString *)key;

/*!
 Decrease layout order index of object for given key.
 @param key Given key string when adding object.
 */
- (void)goDownLayerOrderOfComponentForKey:(NSString *)key;

/*!
 Make layout order index to first of object for given key.
 @param key Given key string when adding object.
 */
- (void)goBottomLayerOrderOfComponentForKey:(NSString *)key;

/*!
 Return transform structure of object for given key.
 @param key Given key string when adding object.
 @returns transform structure
 */
- (CATransform3D)transformOfComponentForKey:(NSString *)key;

/*!
 Return previous transform structure of object for given key.
 @param key Given key string when adding object.
 @returns transform structure
 */
- (CATransform3D)previousTransformOfComponentForKey:(NSString *)key;

/*!
 Update transform of object for given key to given transform.
 @param transform transform to update.
 @param key Given key string when adding object.
 */
- (void)setTransformOfComponent:(CATransform3D)transform forKey:(NSString *)key;

/*!
 Capture current view by given rate and return UIImage object.
 @param rate Capture rate.
 @returns UIImage object.
 */
- (UIImage *)captureStageForRate:(CGFloat)rate;

/*!
 The object that get feedback of P9LayoutComposeView act.
 */
@property (nonatomic, weak) id delegate;

@end

/*!
 P9LayoutComposeViewProtocol
 
 You can do additional action when event occured on component by implement this protocol.
 */
@protocol P9LayoutComposeViewProtocol

@optional

//- (void)p9LayoutComposeView:(P9LayoutComposeView *)layoutComposeView didDoubleTab:(id)anObject forKey:(NSString *)key;
//- (void)p9LayoutComposeView:(P9LayoutComposeView *)layoutComposeView didLongTab:(id)anObject forKey:(NSString *)key;
//- (void)p9LayoutComposeView:(P9LayoutComposeView *)layoutComposeView didForceTab:(id)anObject forKey:(NSString *)key;

/*!
 Called when before start tracking at once that added component to P9LayoutComposeView
 @param layoutComposeView Sender
 @param anObject Tracking target component
 @param key Given key string when adding object.
 */
- (void)p9LayoutComposeView:(P9LayoutComposeView *)layoutComposeView willStartTracking:(id)anObject forKey:(NSString *)key;

/*!
 Called when tracking every time that added component to P9LayoutComposeView
 @param layoutComposeView Sender
 @param anObject Tracking target component
 @param key Given key string when adding object.
 */
- (void)p9LayoutComposeView:(P9LayoutComposeView *)layoutComposeView didTracking:(id)anObject forKey:(NSString *)key;

/*!
 Called when ended tracking at once that added component to P9LayoutComposeView
 @param layoutComposeView Sender
 @param anObject Tracking target component
 @param key Given key string when adding object.
 */
- (void)p9LayoutComposeView:(P9LayoutComposeView *)layoutComposeView didEndTracking:(id)anObject forKey:(NSString *)key;

@end
