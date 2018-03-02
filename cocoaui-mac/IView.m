/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IViewInternal.h"
#import "IFlowLayout.h"
#import "IStyleInternal.h"
#import "IStyleSheet.h"
#import "ICssRule.h"
#import "IViewLoader.h"

@interface IView (){
	NSTrackingArea *_trackingArea;
	IEventType _mouseEvent;
	
	NSMutableArray *_subs;
	IFlowLayout *_layouter;

	NSColor *_backgroundColor;
	
	BOOL _needRenderOnUnhighlight;
}
@property (nonatomic) BOOL need_layout;
@property (nonatomic) NSMutableArray *eventHandlers;
@property NSView *backgroundView;
@end

@implementation IView

+ (IView *)viewWithUIView:(UIView *)view{
	IView *ret = [[IView alloc] init];
	if(view.frame.size.height > 0){
		ret.style.size = view.frame.size;
	}
	[ret addUIView:view];
	return ret;
}

+ (IView *)viewWithUIView:(UIView *)view style:(NSString *)css{
	IView *ret = [self viewWithUIView:view];
	[ret.style set:css];
	return ret;
}

+ (IView *)namedView:(NSString *)name{
	NSString *path;
	NSRange range = [name rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound){
		NSString *ext = [[name substringFromIndex:range.location + 1] lowercaseString];
		name = [name substringToIndex:range.location];
		path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
	}else{
		path = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
	}
	return [IViewLoader viewWithContentsOfFile:path];
}

+ (IView *)viewFromXml:(NSString *)xml{
	return [IViewLoader viewFromXml:xml];
}

+ (IView *)viewWithContentsOfFile:(NSString *)path{
	return [IViewLoader viewWithContentsOfFile:path];
}


- (id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	[self construct];

	if(frame.size.width > 0){
		[_style set:[NSString stringWithFormat:@"width: %f", frame.size.width]];
	}
	if(frame.size.height > 0){
		[_style set:[NSString stringWithFormat:@"height: %f", frame.size.height]];
	}
	return self;
}

- (id)init{
	// 宽高不能同时为0, 否则 layoutSubviews 不会被调用, 就没有机会显示了
	self = [super initWithFrame:CGRectMake(0, 0, 1, 1)];
	[self construct];
	return self;
}

- (void)construct{
	static BOOL inited = NO;
	if(!inited){
		inited = YES;
		// TODO: if(md5(copyright) != ""){exit();}
		log_info(@"%s version: %s", COPYRIGHT, VERSION);
		//NSString* appid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
		//log_debug(@"%@", appid);
	}
	self.backgroundColor = [UIColor clearColor];
	//self.userInteractionEnabled = NO;

	self.wantsLayer = YES;

	_style = [[IStyle alloc] init];
	_style.view = self;
	_style.tagName = @"view";
	
	static int id_incr = 0;
	self.seq = id_incr++;
	
	_need_layout = true;
	_layouter = [IFlowLayout layoutWithView:self];
	
	_backgroundView = [[NSView alloc] init];
	_backgroundView.wantsLayer = YES;
	[super addSubview:_backgroundView];
}

- (void)viewDidMoveToSuperview{
	if(self.isRootView){
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reshape)
													 name:NSViewFrameDidChangeNotification
												   object:self.superview];
	}
	if(!self.superview){
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

//- (void)viewWillStartLiveResize{
//	if(self.isRootView){
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(reshape)
//													 name:NSViewFrameDidChangeNotification
//												   object:self.superview];
//	}
//}
//
//- (void)viewDidEndLiveResize{
//	if(self.isRootView){
//		[[NSNotificationCenter defaultCenter] removeObserver:self];
//		[self reshape];
//	}
//}

- (BOOL)wantsLayer{
	return YES;
}

- (NSColor *)backgroundColor{
	return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor{
	_backgroundColor = backgroundColor;
	self.layer.backgroundColor = _backgroundColor.CGColor;
}

- (BOOL)acceptsFirstResponder{
	return YES;
}

- (void)updateTrackingAreas{
	if(_trackingArea){
		[self removeTrackingArea:_trackingArea];
	}
	NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
									 NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
	_trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
												 options:options
												   owner:self
												userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

- (IView *)getViewById:(NSString *)vid{
	if(_viewLoader){
		return [_viewLoader getViewById:vid];
	}
	return nil;
}

- (IStyleSheet *)inheritedStyleSheet{
	IView *v = self;
	while(v){
		if(v.viewLoader){
			return v.viewLoader.styleSheet;
		}
		v = v.parent;
	}
	// TODO: 返回一个默认的 IStyleSheet?
	return nil;
}

- (void)addUIView:(UIView *)view{
	[self setNeedsLayout:YES];
	_contentView = view;
	[super addSubview:view];
}

- (void)addSubview:(UIView *)view style:(NSString *)css{
	[self setNeedsLayout:YES];
	IView *sub;
	if([[view class] isSubclassOfClass:[IView class]]){
		sub = (IView *)view;
	}else{
		sub = [IView viewWithUIView:view];
	}
	if(!_subs){
		_subs = [[NSMutableArray alloc] init];
	}
	sub.parent = self;
	sub.level = self.level + 1;
	[_subs addObject:sub];
	
//	[_maskView removeFromSuperview];
	[super addSubview:sub];
//	[super addSubview:_maskView];

	if(css){
		[sub.style set:css];
	}
	if(self.inheritedStyleSheet){
		[sub.style renderAllCss];
	}
}

- (void)addSubview:(UIView *)view{
//	log_debug(@"%@", view);
	[self addSubview:view style:nil];
}

- (void)removeFromSuperview{
	self.needsLayout = YES;
	[super removeFromSuperview];
	[_parent.subs removeObject:self];
	_parent = nil;
}

- (void)sendSubviewToBack:(NSView *)subView{
	[subView removeFromSuperview];
	NSMutableArray *subs = [[NSMutableArray alloc] initWithCapacity:self.subviews.count];
	for(NSView *view in self.subviews){
		if(view != subView){
			[subs addObject:view];
		}
		[view removeFromSuperview];
	}
	
	[super addSubview:subView];
	for(NSView *view in subs){
		[super addSubview:view];
	}
	
	// 不能调用此方法，会反过来调用addSubview
	//[super addSubview:subView positioned:NSWindowBelow relativeTo:nil];
}

- (void)bringSubviewToFront:(NSView *)subView{
	[subView removeFromSuperview];
	[super addSubview:subView];
}

- (UIViewController *)viewController{
	UIResponder *responder = self;
	while (responder){
		if([responder isKindOfClass:[UIViewController class]]){
			return (UIViewController *)responder;
		}
		responder = [responder nextResponder];
	}
	return nil;
}

- (NSString *)name{
	return [NSString stringWithFormat:@"%*s%-2d-%@", self.level*2, "", self.seq, self.style.tagName];
}

- (void)show{
	[_style set:@"display: auto;"];
}

- (void)hide{
	[_style set:@"display: none;"];
}

- (void)toggle{
	if(_style.displayType == IStyleDisplayAuto){
		[self hide];
	}else{
		[self show];
	}
}

- (BOOL)isRootView{
	return ![self.superview isKindOfClass:[IView class]];
}

- (BOOL)isPrimativeView{
	return ((!_subs || _subs.count == 0) && _contentView);
}

- (void)reshape{
	if(self.isRootView){
		[self setNeedsLayout:YES];
	}
}

- (void)setNeedsLayout:(BOOL)needsLayout{
	if(needsLayout){
		_need_layout = true;
		
//		if(self.isPrimativeView){
//			super.needsLayout = YES;
//		}
		if(self.parent){
			[self.parent setNeedsLayout:YES];
		}else{
			super.needsLayout = YES;
		}
	}else{
		[super setNeedsLayout:NO];
	}
}

- (void)setNeedsDisplay:(BOOL)needsDisplay{
	if(needsDisplay && NSFoundationVersionNumber <= NSFoundationVersionNumber10_11_Max){
		if(self.parent){
			[self.parent setNeedsDisplay:YES];
		}
	}
	[super setNeedsDisplay:needsDisplay];
}

- (void)drawRect:(CGRect)rect{
	if(self.needsLayout){
		self.needsLayout = NO;
		[self layout];
	}

//	log_debug(@"%@ %s %@", self.name, __FUNCTION__, NSStringFromRect(rect));
	[super drawRect:rect];

//	self.clipsToBounds = _style.overflowHidden;
	
	self.layer.opacity = _style.opacity;
	if(self.layer.backgroundColor != [_style.backgroundColor CGColor]){
		self.layer.backgroundColor = [_style.backgroundColor CGColor];
	}
	self.layer.cornerRadius = _style.borderRadius;

	if(_style.backgroundImage){
		UIImage *img = _style.backgroundImage;
		if(_style.backgroundRepeat){
			_backgroundView.layer.geometryFlipped = NO;
			_backgroundView.layer.backgroundColor = [UIColor colorWithPatternImage:img].CGColor;
		}else{
			_backgroundView.layer.contents = img;
			// 在某些版本报错：Misuse of NSImage and CALayer. contentsGravity is topLeft. It should be one of resize, resizeAspect, or resizeAspectFill.
//			_backgroundView.layer.contentsGravity = kCAGravityTopLeft;
			float w = _backgroundView.frame.size.width/img.size.width;
			float h = _backgroundView.frame.size.height/img.size.height;
			_backgroundView.layer.contentsRect = CGRectMake(0, 0, w, h);
			_backgroundView.layer.geometryFlipped = NO;
			// 此函数没有antialias
//			[img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
		}
		_backgroundView.hidden = NO;
	}else{
		_backgroundView.hidden = YES;
	}
	
	[self drawBorder];
}

- (void)strokeBorder:(IStyleBorder *)border context:(CGContextRef)context{
	if(border.type == IStyleBorderDashed){
		CGFloat dashes[] = {border.width * 5, border.width * 5};
		CGContextSetLineDash(context, 0, dashes, 2);
	}
	CGContextSetLineWidth(context, border.width);
	[border.color set];
	CGContextStrokePath(context);
}

- (void)drawBorder{
	if(_style.borderDrawType == IStyleBorderDrawNone){
		return;
	}
	//log_debug(@"%s %@", __func__, NSStringFromCGRect(self.frame));
	CGFloat radius = _style.borderRadius;
	CGFloat x1, y1, x2, y2;
	CGRect rect = self.bounds;
	x1 = rect.origin.x;
	y1 = rect.origin.y;
	x2 = x1 + rect.size.width;
	y2 = y1 + rect.size.height;
	NSEdgeInsets borderEdge = _style.borderEdge;
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	// TODO: border 太大时有bug
	// top
	CGContextAddArc(context, radius, radius, radius-borderEdge.top/2, M_PI*5/4-20.0/180, M_PI*6/4, 0);
	CGContextAddLineToPoint(context, x2 - radius, y1+borderEdge.top/2);
	CGContextAddArc(context, x2 - radius, y1 + radius, radius-borderEdge.top/2, M_PI*6/4, M_PI*7/4, 0);
	[self strokeBorder:_style.borderTop context:context];
	
	// right
	CGContextAddArc(context, x2 - radius, y1 + radius, radius-borderEdge.right/2, M_PI*7/4-20.0/180, M_PI*8/4, 0);
	CGContextAddLineToPoint(context, x2-borderEdge.right/2, y2 - radius);
	CGContextAddArc(context, x2 - radius, y2 - radius, radius-borderEdge.right/2, M_PI*8/4, M_PI*9/4, 0);
	[self strokeBorder:_style.borderRight context:context];
	
	// bottom
	CGContextAddArc(context, x2 - radius, y2 - radius, radius-borderEdge.bottom/2, M_PI*9/4-20.0/180, M_PI*10/4, 0);
	CGContextAddLineToPoint(context, x1 + radius, y2-borderEdge.bottom/2);
	CGContextAddArc(context, x1 + radius, y2 - radius, radius-borderEdge.bottom/2, M_PI*10/4, M_PI*11/4, 0);
	[self strokeBorder:_style.borderBottom context:context];
	
	// left
	CGContextAddArc(context, x1 + radius, y2 - radius, radius-borderEdge.left/2, M_PI*11/4-20.0/180, M_PI*12/4, 0);
	CGContextAddLineToPoint(context, x1+borderEdge.left/2, y1 + radius);
	CGContextAddArc(context, x1 + radius, y1 + radius, radius-borderEdge.left/2, M_PI*12/4, M_PI*13/4, 0);
	[self strokeBorder:_style.borderLeft context:context];
}

- (void)layout{
	[super layout];
	if(self.isRootView){
	}
	
//	log_debug(@"%@ layout begin %@, #%d", self.name, NSStringFromCGRect(_style.rect), self.level);
	[self layoutSubviews];
//	log_debug(@"%@ layout end %@, #%d", self.name, NSStringFromCGRect(_style.rect), self.level);
}

- (void)layoutSubviews{
	//log_debug(@"%@ %s", self.name, __func__);
//	if(!_need_layout){
//		return;
//	}
//	if(_style.resizeWidth){
//		if(!self.isRootView && !self.isPrimativeView){
//			//log_debug(@"return %@ %s parent: %@", self.name, __FUNCTION__, self.parent.name);
//			return;
//		}
//	}
//	log_debug(@"%d %s begin %@", _seq, __FUNCTION__, NSStringFromCGRect(_style.rect));
	[_layouter layout];
//	log_debug(@"%d %s end %@", _seq, __FUNCTION__, NSStringFromCGRect(_style.rect));
	
	// 显示背景图, 必须要重新设置, 不然改变尺寸时背景不变动
//	if(self.layer.contents){
//		self.layer.contents = self.layer.contents;
//	}
	
	[self updateFrame];
	_need_layout = false;
}

- (BOOL)isFlipped{
	return YES;
}

- (void)updateFrame{
//	log_debug(@"%@ %s %@=>%@", self.name, __FUNCTION__, NSStringFromRect(self.frame), NSStringFromRect(_style.rect));
	if(self.isRootView){
		//
		self.frame = _style.rect;
	}else{
		self.frame = _style.rect;
	}
	
	self.hidden = _style.hidden;
	self.needsDisplay = YES;
	
	float x = _style.borderLeft.width;
	float y = _style.borderTop.width;
	float w = _style.width - _style.borderLeft.width - _style.borderRight.width;
	float h = _style.height - _style.borderTop.width - _style.borderBottom.width;
	_backgroundView.frame = CGRectMake(x, y, w, h);
	_backgroundView.needsDisplay = YES;
}


#pragma mark - Events

- (void)bindEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler{
	[self addEvent:event handler:handler];
}

- (void)addEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler{
	if(!_eventHandlers){
		_eventHandlers = [[NSMutableArray alloc] init];
	}
	[_eventHandlers addObject:@[@(event), handler]];
}

- (void)fireEvent:(IEventType)event{
//	NSString *name = nil;
//	switch (event) {
//		case IEventHighlight:
//			name = @"IEventHighlight";
//			break;
//		case IEventUnhighlight:
//			name = @"IEventUnhighlight";
//			break;
//		case IEventHover:
//			name = @"IEventHover";
//			break;
//		case IEventUnhover:
//			name = @"IEventUnhover";
//			break;
//		case IEventClick:
//			name = @"IEventClick";
//			break;
//	}
//	if(name){
////		if([self.name rangeOfString:@"a"].length != 0){
//			log_debug(@"%@ event: %@", self.name, name);
////		}
//	}
	
	BOOL shouldBubbleUp = YES;
	if(_eventHandlers){
		void (^handler)(IEventType, IView *);
		for(NSArray *arr in _eventHandlers){
			NSNumber *num = arr.firstObject;
			handler = arr.lastObject;
			if(event == num.intValue){
				shouldBubbleUp = NO;
				handler(event, self);
			}
		}
	}
	if(shouldBubbleUp && (event & IEventClick)){
		if([self.superview isKindOfClass:IView.class]){
			[(IView *)self.superview fireEvent:event];
		}
	}

	IStyleSheet *sheet = self.inheritedStyleSheet;
	if(sheet){
		if(_needRenderOnUnhighlight){
			[self.style renderAllCss];
			_needRenderOnUnhighlight = NO;
		}else{
			for(ICssRule *rule in sheet.rules){
				if([rule containsPseudoClass] && [rule matchView:self]){
					_needRenderOnUnhighlight = YES;
					[self.style renderAllCss];
					break;
				}
			}
		}
	}
}

- (void)fireHighlightEvent{
	[self fireEvent:IEventHighlight];
}

- (void)fireUnhighlightEvent{
	[self fireEvent:IEventUnhighlight];
}

- (void)fireClickEvent{
	[self fireEvent:IEventClick];
}


- (void)mouseDown:(NSEvent *)event{
//	if([self.name rangeOfString:@"span"].length != 0){
//		log_debug(@"%s %@", __func__, self);
//	}
	[self setState:IViewStateDown];
	if([self hasState:IViewStateHover]){
		[self delState:IViewStateHover];
		[self fireEvent:IEventUnhover];
	}
	[self setState:IViewStateActive];
	[self fireEvent:IEventHighlight];
	
	BOOL prevInside = YES;
	NSPoint point;
	while (1) {
		event = [[self window] nextEventMatchingMask:(kCGEventLeftMouseDragged | kCGEventLeftMouseUp)];
		point = [self convertPoint:[event locationInWindow] fromView:nil];

		BOOL inside = [self mouse:point inRect:self.bounds];
		if(prevInside && !inside){
			[self mouseExited:event];
		}else if(!prevInside && inside){
			[self mouseEntered:event];
		}
		prevInside = inside;
		
		if(event.type == kCGEventLeftMouseUp){
			if(!inside){
				[self delState:IViewStateDown];
			}
			[self mouseUp:event];
			if(inside){
				[self mouseEntered:event];
			}
			break;
		}else{
			[self mouseDragged:event];
		}
	}
}

- (void)mouseUp:(NSEvent *)event{
//	if([self.name rangeOfString:@"span"].length != 0){
//		log_debug(@"%s %@", __func__, self);
//	}
	if([self hasState:IViewStateDown]){
		[self delState:IViewStateActive];
		[self fireEvent:IEventUnhighlight];
		[self delState:IViewStateDown];
		[self fireEvent:IEventClick];
	}
}

- (void)mouseDragged:(NSEvent *)event{
}

- (void)mouseMoved:(NSEvent *)event{
	if(![self hasState:IViewStateHover]){
		[self setState:IViewStateHover];
		[self fireEvent:IEventHover];
	}
}

- (void)mouseEntered:(NSEvent *)event{
//	if([self.name rangeOfString:@"a"].length != 0){
//		log_debug(@"%s %@", __func__, self);
//	}
	if([self hasState:IViewStateDown]){
		if(![self hasState:IViewStateActive]){
			[self setState:IViewStateActive];
			[self fireEvent:IEventHighlight];
		}
	}else{
		if(![self hasState:IViewStateHover]){
			[self setState:IViewStateHover];
			[self fireEvent:IEventHover];
		}
	}
}

- (void)mouseExited:(NSEvent *)event{
//	if([self.name rangeOfString:@"span"].length != 0){
//		log_debug(@"%s %@", __func__, self);
//	}
	if([self hasState:IViewStateHover]){
		[self delState:IViewStateHover];
		[self fireEvent:IEventUnhover];
	}
	if([self hasState:IViewStateActive]){
		[self delState:IViewStateActive];
		[self fireEvent:IEventUnhighlight];
	}
}

- (void)setState:(IViewState)state{
	_state |= state;
}

- (void)delState:(IViewState)state{
	_state &= ~state;
}

- (BOOL)hasState:(IViewState)state{
	return _state & state;
}

@end

