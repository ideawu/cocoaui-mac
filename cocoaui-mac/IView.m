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
#import "IMaskUIView.h"
#import "IStyleSheet.h"
#import "ICssRule.h"

@interface IView (){
	NSTrackingArea *_trackingArea;
	IEventType _mouseEvent;
	
	id _data;
	NSMutableArray *_subs;
	IFlowLayout *_layouter;
	
	//void (^_highlightHandler)(IEventType, IView *);
	//void (^_unhighlightHandler)(IEventType, IView *);
	//void (^_clickHandler)(IEventType, IView *);
	
	IMaskUIView *maskView;
	BOOL _needRenderOnUnhighlight;
}
@property (nonatomic) BOOL need_layout;
@property (nonatomic) UIView *backgroundView;
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

#if TARGET_OS_IPHONE
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
#endif

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
		NSString *copyright = @"Copyright(c)2015-2016 CocoaUI. All rights reserved.";
		// TODO: if(md5(copyright) != ""){exit();}
		log_info(@"%@ version: %s", copyright, VERSION);
		//NSString* appid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
		//log_debug(@"%@", appid);
	}
	self.backgroundColor = [UIColor clearColor];
	//self.userInteractionEnabled = NO;
	
	_style = [[IStyle alloc] init];
	_style.view = self;
	_style.tagName = @"view";
	
	static int id_incr = 0;
	self.seq = id_incr++;
	
	_need_layout = true;
	_layouter = [IFlowLayout layoutWithView:self];
}

- (BOOL)acceptsFirstResponder{
	return YES;
}

- (void)updateTrackingAreas{
	if(!_trackingArea){
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
#if TARGET_OS_IPHONE
	if(_viewLoader){
		return [_viewLoader getViewById:vid];
	}
#endif
	return nil;
}

- (IStyleSheet *)inheritedStyleSheet{
	IView *v = self;
	while(v){
#if TARGET_OS_IPHONE
		if(v.viewLoader){
			return v.viewLoader.styleSheet;
		}
#endif
		v = v.parent;
	}
	// TODO: 返回一个默认的 IStyleSheet?
	return nil;
}

- (id)data{
	return _data;
}

- (void)setData:(id)data{
	_data = data;
}

- (void)setDataInternal:(id)data{
	_data = data;
}

- (void)addUIView:(UIView *)view{
	[self setNeedsLayout];
	_contentView = view;
	[super addSubview:view];
}

- (void)addSubview:(UIView *)view style:(NSString *)css{
	[self setNeedsLayout];
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
	[super addSubview:sub];

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
	return [NSString stringWithFormat:@"%*s%-2d.%@", self.level*2, "", self.seq, self.style.tagName];
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

- (void)updateMaskView{
	if(_style.borderDrawType == IStyleBorderDrawNone){
		if(maskView){
			[maskView removeFromSuperview];
			maskView = nil;
		}
	}else{
		if(!maskView){
			maskView = [[IMaskUIView alloc] init];
			[super addSubview:maskView];
		}
		CGRect frame = self.frame;
		frame.origin = CGPointZero;
		maskView.frame = frame;
		
		[self bringSubviewToFront:maskView];
		maskView.needsDisplay = YES;
	}
}

- (void)updateBackgroundView{
	// TODO: 优化, 不要频繁创建销毁 _backgroundView
	if(_backgroundView){
		[_backgroundView removeFromSuperview];
	}
	if(_style.backgroundImage){
		if(_style.backgroundRepeat){
			_backgroundView = [[UIView alloc] init];
			_backgroundView.backgroundColor = [UIColor colorWithPatternImage:_style.backgroundImage];
		}else{
			_backgroundView = (UIView *)[UIImageView imageViewWithImage:_style.backgroundImage];
		}
		[super addSubview:_backgroundView];
		[self sendSubviewToBack:_backgroundView];
		CGRect frame = self.frame;
		frame.origin = CGPointZero;
		_backgroundView.frame = frame;
	}
	
	self.layer.opacity = _style.opacity;
}

- (void)setNeedsLayout{
	//log_debug(@"%@ %s", self.name, __FUNCTION__);
	_need_layout = true;
	
	if(self.isPrimativeView){
		self.needsLayout = YES;
	}
	if(self.parent){
		[self.parent setNeedsLayout];
	}else{
		self.needsLayout = YES;
	}
}

- (void)drawRect:(CGRect)rect{
//	log_debug(@"%@ %s %@", self.name, __FUNCTION__, NSStringFromRect(rect));
	//[super drawRect:rect]; // no need

//	self.clipsToBounds = _style.overflowHidden;
	self.layer.backgroundColor = [_style.backgroundColor CGColor];
	if(_style.borderRadius > 0){
		self.layer.cornerRadius = _style.borderRadius;
	}
	if(maskView){
		maskView.needsDisplay = YES;
	}
	[self updateBackgroundView];
}

- (void)layout{
	[super layout];
//	log_debug(@"%@ layout begin %@, #%d", self.name, NSStringFromCGRect(_style.rect), self.level);
	[self layoutSubviews];
//	log_debug(@"%@ layout end %@, #%d", self.name, NSStringFromCGRect(_style.rect), self.level);
}

- (void)layoutSubviews{
	//log_debug(@"%@ %s", self.name, __func__);
	if(!_need_layout){
		return;
	}
	if(_style.resizeWidth){
		if(!self.isRootView && !self.isPrimativeView){
			//log_debug(@"return %@ %s parent: %@", self.name, __FUNCTION__, self.parent.name);
			return;
		}
	}
//	log_debug(@"%d %s begin %@", _seq, __FUNCTION__, NSStringFromCGRect(_style.rect));
	[_layouter layout];
//	log_debug(@"%d %s end %@", _seq, __FUNCTION__, NSStringFromCGRect(_style.rect));
	
	// 显示背景图, 必须要重新设置, 不然改变尺寸时背景不变动
	if(self.layer.contents){
		self.layer.contents = self.layer.contents;
	}
	
	[self updateFrame];
	_need_layout = false;
}

- (BOOL)isFlipped{
	return YES;
}

- (void)updateFrame{
//	log_debug(@"%@ %s %@=>%@", self.name, __FUNCTION__, NSStringFromRect(self.frame), NSStringFromRect(_style.rect));
	CGRect frame = _style.rect;
	if(!self.superview.isFlipped){
		frame.origin.y = self.superview.bounds.size.height - frame.origin.y - frame.size.height;
	}
//	log_debug(@"%@ %.2f %.2f", self, frame.size.width, frame.size.height);

	self.frame = frame;
	self.hidden = _style.hidden;
	
	[self updateMaskView];
	[self updateBackgroundView];
	self.needsDisplay = YES;
}


#pragma mark - Events

- (void)bindEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler{
	[self addEvent:event handler:handler];
}

- (void)addEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler{
	if(event & IEventHighlight){
		_highlightHandler = handler;
	}
	if(event & IEventUnhighlight){
		_unhighlightHandler = handler;
	}
	if(event & IEventClick){
		_clickHandler = handler;
	}
}

- (BOOL)fireEvent:(IEventType)event{
	_event = event;
	void (^handler)(IEventType, IView *);
	if(event == IEventHighlight){
		handler = _highlightHandler;

		_needRenderOnUnhighlight = NO;
		IStyleSheet *sheet = self.inheritedStyleSheet;
		if(sheet){
			for(ICssRule *rule in sheet.rules){
				if([rule containsPseudoClass] && [rule matchView:self]){
					_needRenderOnUnhighlight = YES;
					[self.style renderAllCss];
					break;
				}
			}
		}
	}
	if(event == IEventUnhighlight){
		handler = _unhighlightHandler;
		if(_needRenderOnUnhighlight){
			[self.style renderAllCss];
		}
	}
	if(event == IEventClick){
		handler = _clickHandler;
	}
	if(handler){
		handler(event, self);
		return YES;
	}
	return NO;
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
	[self fireEvent:IEventHighlight];
}

- (void)mouseUp:(NSEvent *)event{
	if(_event == IEventHighlight){
//		[self performSelector:@selector(fireUnhighlightEvent) withObject:nil afterDelay:0.15];
		[self fireEvent:IEventUnhighlight];
		[self fireEvent:IEventClick];
	}
}

- (void)mouseDragged:(NSEvent *)event{
	if(_event == IEventHighlight){
		[self fireEvent:IEventUnhighlight];
	}
	[self fireEvent:IEventDragged];
}

- (void)mouseMoved:(NSEvent *)event{
}

- (void)mouseEntered:(NSEvent *)event{
	[self fireEvent:IEventHover];
}

- (void)mouseExited:(NSEvent *)event{
	[self fireEvent:IEventUnhover];
}

@end

