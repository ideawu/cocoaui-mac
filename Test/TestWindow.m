//
//  TestWindow.m
//  Test
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "TestWindow.h"
#import "IKit.h"
#import <QuartzCore/QuartzCore.h>

@interface TestWindow ()<NSWindowDelegate>
@property IView *iview;
@end

@implementation TestWindow

- (id)init{
	self = [super initWithWindowNibName:@"TestWindow"];
	self.window.delegate = self;
	return self;
}

- (void)windowDidResize:(NSNotification *)notification{
	_iview.frame = [(NSView *)self.window.contentView bounds];
}

- (void)windowDidLoad {
	[super windowDidLoad];
	[self.window.contentView setWantsLayer:YES];

	_iview = [IView namedView:@"TestWindow"];
	[self.window.contentView addSubview:_iview];

	IImage *img = (IImage *)[_iview getViewById:@"abc"];
	[_iview bindEvent:IEventClick handler:^(IEventType event, IView *view) {
		log_debug(@"%@", img.src);
		img.src = @"images/toolbar-18/minus.png";
	}];

	[self windowDidResize:nil];
}

- (void)keyDown:(NSEvent *)event{
}

@end
