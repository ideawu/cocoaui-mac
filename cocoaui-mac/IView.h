/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_IView_h
#define IKit_IView_h

#import "IStyle.h"

typedef enum{
	IEventUnhighlight  = 1<<0,
	IEventHighlight    = 1<<1,
	IEventClick        = 1<<2,
	IEventDragged      = 1<<3,
	IEventReturn       = 1<<4,
	IEventHover        = 1<<5,
	IEventUnhover      = 1<<6,
}IEventType;

typedef enum{
	IRefreshNone,
	IRefreshMaybe,
	IRefreshBegin,
}IRefreshState;

@class ITable;

@interface IView : UIView

@property (nonatomic, readonly) IStyle *style;

+ (IView *)viewWithUIView:(UIView *)view;
+ (IView *)viewWithUIView:(UIView *)view style:(NSString *)css;

#if TARGET_OS_IPHONE
+ (IView *)namedView:(NSString *)name;
+ (IView *)viewFromXml:(NSString *)xml;
+ (IView *)viewWithContentsOfFile:(NSString *)path;
#endif

- (id)data;
/**
 * Called when this IView is used as ITable row being shown.
 * Override this method when IView is used as ITable row(MUST call [super setData])
 */
- (void)setData:(id)data;

// only available when init with xml or file
- (IView *)getViewById:(NSString *)vid;

/**
 * Add a view(instance of UIView or IView subclass) into subviews list,
 * apply style on the added view.
 */
- (void)addSubview:(UIView *)view style:(NSString *)css;
/**
 * This method will traverse up the view hierarchy to find and return
 * the first UIViewController, if not any found, it will return nil.
 */
- (UIViewController *)viewController;


- (void)show;
- (void)hide;
- (void)toggle;

- (void)bindEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler;
/**
 * event can be combined by | operator.
 */
- (void)addEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler;
/**
 * event can not be combined.
 */
- (BOOL)fireEvent:(IEventType)event;

/**
 * 一般不需要调用本方法, 自定义控件重写本方法.
 */
- (void)layout;

@end

#endif
