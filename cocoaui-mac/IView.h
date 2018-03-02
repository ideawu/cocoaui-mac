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
	IViewStateNone     = 0,
	IViewStateHover    = 1<<0,
	IViewStateDown     = 1<<1,
	IViewStateActive   = 1<<2,
}IViewState;

typedef enum{
	IEventUnhighlight  = 1<<0,
	IEventHighlight    = 1<<1,
	IEventClick        = 1<<2,
	IEventHover        = 1<<5,
	IEventUnhover      = 1<<6,
}IEventType;

typedef enum{
	IRefreshNone,
	IRefreshMaybe,
	IRefreshBegin,
}IRefreshState;

@class ITable;

@interface IView : NSView

@property (nonatomic, readonly) IStyle *style;
@property (nonatomic) NSColor *backgroundColor;
@property (nonatomic) IViewState state;

+ (IView *)viewWithUIView:(NSView *)view;
+ (IView *)viewWithUIView:(NSView *)view style:(NSString *)css;

+ (IView *)namedView:(NSString *)name;
+ (IView *)viewFromXml:(NSString *)xml;
+ (IView *)viewWithContentsOfFile:(NSString *)path;

// only available when init with xml or file
- (IView *)getViewById:(NSString *)vid;

/**
 * Add a view(instance of UIView or IView subclass) into subviews list,
 * apply style on the added view.
 */
- (void)addSubview:(NSView *)view style:(NSString *)css;

- (void)show;
- (void)hide;
- (void)toggle;

// alias of addEvent
- (void)bindEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler;
/**
 * event can be combined by | operator.
 */
- (void)addEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler;
/**
 * event can not be combined.
 */
- (void)fireEvent:(IEventType)event;

/**
 * 一般不需要调用本方法, 自定义控件重写本方法.
 */
- (void)layout;

@end

#endif
