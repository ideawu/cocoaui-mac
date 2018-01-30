//
//  UIView.m
//  Mac
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "UIView.h"

@interface UIView(){
	NSColor *_backgroundColor;
	BOOL _clipsToBounds;
}
@end


@implementation UIView

- (void)setNeedsLayout{
	self.needsLayout = YES;
}

- (void)setNeedsDisplay{
	self.needsDisplay = YES;
}

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

- (BOOL)userInteractionEnabled{
	return NO;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled{
}

- (BOOL)clipsToBounds{
	return _clipsToBounds;
}

- (void)setClipsToBounds:(BOOL)clipsToBounds{
	_clipsToBounds = clipsToBounds;
}

- (BOOL)wantsDefaultClipping{
	// TODO:
	return YES;
}

@end
