//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#include "Layouter.h"

namespace cui{
	
	Layouter::Layouter(){
		_leftRects = NULL;
		_rightRects = NULL;
	}
	
	Layouter::~Layouter(){
		delete _leftRects;
		delete _rightRects;
	}

	void Layouter::layoutView(View *view){
		float maxWidth = 1000000;
		float maxHeight = 1000000;
		layoutView(view, maxWidth, maxHeight);
	}
	
	void Layouter::layoutView(View *view, float maxWidth, float maxHeight){
		if(!view->needsLayout()){
			return;
		}
		view->layout()->outerBox(Rect(0, 0, maxWidth, maxHeight));
		if(view->subviews()->size() > 0){
			layoutSubviews(view);
			resizeView(view);
		}
		view->sizeToFit();
	}

	void Layouter::resizeView(View *view){
		Layout *layout = view->layout();
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

	void Layouter::layoutSubviews(View *view){
		Layout *layout = view->layout();
		Edge border = layout->border();
		Edge padding = layout->padding();
		Point offset = Point(border.left + padding.left, border.top + padding.top);

		Rect inner = layout->innerBox();
		_maxWidth = inner.width;
		_maxHeight = inner.height;
		_xLeft = 0;
		_xRight = _maxWidth;
		_y = 0;
		_contentWidth = 0;
		_contentHeight = 0;
		
		std::list<View *> *subs = view->subviews();
		for(std::list<View *>::iterator it = subs->begin(); it != subs->end(); it++){
			View *sub = *it;
			layoutView(sub, _maxWidth, _maxHeight);
			placeView(sub);
			
			// content相对frame偏移
			Rect frame = sub->layout()->frame();
			frame.x += offset.x;
			frame.y += offset.y;
			sub->layout()->frame(frame);
		}
	}

	void Layouter::placeView(View *view){
		Layout *layout = view->layout();

		if(layout->displayNone()){
			return;
		}
		
		if(_leftRects == NULL){
			_leftRects = new std::vector<Rect>();
			_rightRects = new std::vector<Rect>();
		}
		
		// clear before positioning
		if(layout->clearLeft()){
			while(_leftRects->size() > 0){
				this->popLeft();
			}
		}
		if(layout->clearRight()){
			while(_rightRects->size() > 0){
				this->popRight();
			}
		}
		
		Rect inBox = this->findBoxForView(view);
		this->putViewInBox(view, inBox);
		
		// 计算节点占用的空间，和 float/clear 相关
		Rect space = view->layout()->outerBox();
		if(layout->floatCenter()){
			// 占用inBox全部宽度
			space.width = inBox.width;
		}
		if(layout->valignType() != ValignTop){
			// 占用inBox全部高度
			space.height = inBox.height;
		}
		if(layout->clearLeft()){
			space.x = 0;
		}
		if(layout->clearRight()){
			space.width = _maxWidth - space.x;
		}
		
		if(layout->floatLeft()){
			_leftRects->push_back(space);
		}else{
			_rightRects->push_back(space);
		}
		
		_contentWidth = fmax(_contentWidth, space.x2());
		_contentHeight = fmax(_contentHeight, space.y2());
	}

	Rect Layouter::findBoxForView(View *view){
		float width = view->layout()->outerBox().width;
		while(1){
			float w = _xRight - _xLeft;
			float h = fmax(_maxHeight, _y) - _y;
			Rect box = Rect(_xLeft, _y, w, h);
			
			if(box.width >= width){
				return box;
			}else{
				if(_leftRects->size() > 0 || _rightRects->size() > 0){
					this->newLine();
				}else{
					// 超出范围
					return box;
				}
			}
		}
	}

	void Layouter::newLine(){
		float y1 = _y;
		if(_leftRects->size() > 0){
			Rect rect = _leftRects->back();
			y1 = rect.y2();
		}
		float y2 = _y;
		if(_rightRects->size() > 0){
			Rect rect = _rightRects->back();
			y2 = rect.y2();
		}
		
		// 看哪边高，将低的那一边弹出
		if(y1 <= y2){
			if(_leftRects->size() > 0){
				this->popLeft();
			}else if(_rightRects->size() > 0){
				this->popRight();
			}
		}else{
			if(_rightRects->size() > 0){
				this->popRight();
			}else if(_leftRects->size() > 0){
				this->popLeft();
			}
		}
	}

	void Layouter::popLeft(){
		Rect box = _leftRects->back();
		_leftRects->pop_back();
		_xLeft = box.x;
		_y = fmax(_y, box.y2());
		// 清除低于_y的盒子
		while(_leftRects->size() > 0){
			Rect box = _leftRects->back();
			if(_y >= box.y2()){
				_leftRects->pop_back();
				_xLeft = box.x;
			}else{
				break;
			}
		}
	}
	
	void Layouter::popRight(){
		Rect box = _rightRects->back();
		_rightRects->pop_back();
		_xRight = box.x + box.width;
		_y = fmax(_y, box.y2());
		// 清除低于_y的盒子
		while(_rightRects->size() > 0){
			Rect box = _rightRects->back();
			if(_y >= box.y2()){
				_rightRects->pop_back();
				_xRight = box.x + box.width;
			}else{
				break;
			}
		}
	}

	void Layouter::putViewInBox(View *view, const Rect &inBox){
		Layout *layout = view->layout();
		Rect box = layout->outerBox();
		
		if(layout->floatLeft()){
			box.x = inBox.x;
		}else if(layout->floatRight()){
			box.x = inBox.x2() - box.width;
		}else{
			box.x = (inBox.width - box.width)/2 + inBox.x;
		}

		if(layout->valignType() == ValignTop){
			box.y = inBox.y;
		}else if(layout->valignType() == ValignBottom){
			box.y = inBox.y2() - box.height;
		}else if(layout->valignType() == ValignMiddle){
			box.y = (inBox.height - box.height)/2 + inBox.y;
		}

		layout->outerBox(box);
	}
	
}; // end namespace
