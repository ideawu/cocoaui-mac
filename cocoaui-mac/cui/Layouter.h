//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#ifndef Layouter_hpp
#define Layouter_hpp

#include <vector>
#include "types.h"

namespace cui{
	class View;
	
	class Layouter
	{
	public:
		Layouter();
		~Layouter();
		
		void layoutView(View *view);
		void layoutView(View *view, float maxWidth, float maxHeight);
		
	private:
		float _maxInnerWidth, _maxInnerHeight;
		float _xLeft, _xRight;
		float _y;
		float _contentWidth, _contentHeight;
		
		std::vector<Rect> *_leftRects;
		std::vector<Rect> *_rightRects;

		void resizeView(View *view);
		void layoutSubviews(View *view);
		
		void placeSubview(View *view);
		Rect findBoxForSubview(View *view);
		void putSubviewInBox(View *view, const Rect &inBox);
		
		void newLine();
		void newLine(bool isLeft);
		void popLeft();
		void popRight();
	};
}; // end namespace

#endif /* Layouter_hpp */
