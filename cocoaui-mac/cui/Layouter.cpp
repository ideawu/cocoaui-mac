//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#include "Layouter.h"

namespace cui{
	
	void Layouter::layoutView(View *view){
		float maxWidth = __FLT_MAX__;
		float maxHeight = __FLT_MAX__;
		layoutView(view, maxWidth, maxHeight);
	}
	
	void Layouter::layoutView(View *view, float maxWidth, float maxHeight){
		if(!view->needsLayout()){
			return;
		}
		
		view->layout()->outerBox(Rect(0, 0, maxWidth, maxHeight));
		layoutSubviews(view);
		resizeView(view);
		view->sizeToFit();
	}

	void Layouter::layoutSubviews(View *view){
		Rect inner = view->layout()->innerBox();
		_maxWidth = inner.width;
		_maxHeight = inner.height;
		_x = inner.x;
		_y = inner.y;
		_contentWidth = 0;
		_contentHeight = 0;
		
		std::list<View *> *subs = view->subviews();
		for(std::list<View *>::iterator it = subs->begin(); it != subs->end(); it++){
			View *sub = *it;
			layoutView(sub, _maxWidth, _maxHeight);
			placeView(sub);
		}
	}

	void Layouter::placeView(View *view){
		// TODO:
		
		Rect box = view->layout()->outerBox();
		_contentWidth = fmax(_contentWidth, box.x + box.width);
		_contentHeight = fmax(_contentHeight, box.y + box.height);
	}

	void Layouter::resizeView(View *view){
		Layout *layout = view->layout();
//		Edge border = layout->border();
//		Edge padding = layout->padding();
		
//		_contentWidth += border.left + border.right + padding.left + padding.right;
//		_contentHeight += border.top + border.bottom + padding.top + padding.bottom;
		
		if(layout->resizeWidth()){
			layout->innerWidth(_contentWidth);
//			if(_style.aspectRatio > 0){
//				_style.w = _style.h * _style.aspectRatio;
//			}
		}
		if(layout->resizeHeight()){
			layout->innerHeight(_contentHeight);
//			if(_style.aspectRatio > 0){
//				_style.h = _style.w / _style.aspectRatio;
//			}
		}
	}

}; // end namespace
