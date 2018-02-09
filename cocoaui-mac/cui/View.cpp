//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#include "View.h"

namespace cui{
	
	View::View(){
		_parent = NULL;
		_subs = NULL;
	}
	
	View::~View(){
		delete _subs;
	}

	Layout* View::layout(){
		return &_layout;
	}

	bool View::needsLayout() const{
		return _needsLayout;
	}

	void View::needsLayout(bool needsLayout){
		_needsLayout = needsLayout;
		if(_needsLayout && _parent){
			_parent->needsLayout(true);
		}
	}

	
	View* View::parent() const{
		return _parent;
	}

	View* View::superview() const{
		return _parent;
	}

	void View::removeFromParent(){
		if(_parent){
			_parent->removeSubview(this);
		}
	}
	
	void View::addSubview(View *view){
		addSubview(view, false);
	}
	
	void View::addSubview(View *view, bool isFront){
		if(!_subs){
			_subs = new std::list<View *>();
		}
		if(view->_parent){
			if(view->_parent == this){
				return;
			}else{
				view->removeFromParent();
			}
		}
		view->_parent = this;
		if(isFront){
			_subs->push_back(view);
		}else{
			_subs->push_front(view);
		}
	}
	
	void View::removeSubview(View *view){
		if(!_subs){
			return;
		}
		if(view->_parent == this){
			view->_parent = NULL;
			_subs->remove(view);
		}
	}

	std::list<View *>* View::subviews(){
		if(!_subs){
		}
		return _subs;
	}

}; // end namespace
