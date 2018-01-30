//
//  TestWindow.m
//  Test
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "TestWindow.h"
#import "IView.h"

@interface TestWindow ()<NSWindowDelegate>

@end

@implementation TestWindow

- (id)init{
	self = [super initWithWindowNibName:@"TestWindow"];
	self.window.delegate = self;
	return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	IView *view = [[IView alloc] init];
	[view.style set:@"width: 100; height: 100; margin: 10 0 10 100; border: 3px solid #000; background: #666 url(alex.png);"];
	[self.window.contentView addSubview:view];
	
	[view bindEvent:IEventClick handler:^(IEventType event, IView *view) {
		log_debug(@"");
	}];
}

@end
