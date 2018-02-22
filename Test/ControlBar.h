//
//  ControlBar.h
//  Tovi
//
//  Created by ideawu on 01/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IKit.h"

typedef enum{
	ControlBarEventFlipH,
	ControlBarEventFlipV,
	ControlBarEventRotateLeft,
	ControlBarEventRotateRight,
	ControlBarEventPlay,
	ControlBarEventPause,
	ControlBarEventPrev,
	ControlBarEventNext,
	ControlBarEventZoomOut,
	ControlBarEventZoomIn,
	ControlBarEventBestSize,
	ControlBarEventActualSize,
	ControlBarEventFillSize,
}ControlBarEvent;

@interface ControlBar : NSView

@property (readonly) IView *contentView;
@property (readonly) ILabel *textLabel;

- (void)bindHandler:(void (^)(ControlBarEvent event, IView *view))handler;

- (void)show;
- (void)hide;

- (void)setPlaying:(BOOL)isPlaying;

@end

