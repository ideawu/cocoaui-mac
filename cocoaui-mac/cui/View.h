//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#ifndef View_hpp
#define View_hpp

#include <list>
#include "Layout.h"

namespace cui{
	class View
	{
	public:
		View();
		~View();
		
		void sizeToFit();

		Layout* layout();
		bool needsLayout() const;
		void needsLayout(bool needsLayout);
		
		View* parent() const;
		View* superview() const;
		void removeFromParent();
		void addSubview(View *view);
		void removeSubview(View *view);
		std::list<View *>* subviews();

	private:
		View(const View &d);
		View& operator =(const View &d);
		
		Layout _layout;
		bool _needsLayout;

		View *_parent;
		std::list<View *> *_subs;

		void addSubview(View *view, bool isFront);
	};
}; // end namespace

#endif /* View_hpp */
