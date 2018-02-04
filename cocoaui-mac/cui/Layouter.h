//  Created by ideawu on 04/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#ifndef Layouter_hpp
#define Layouter_hpp

#include "View.h"

namespace cui{
	class Layouter
	{
	public:
		void layoutView(View *view);
		void layoutView(View *view, float maxWidth, float maxHeight);
		
	private:
		float _maxWidth, _maxHeight;
		float _x, _y;
		float _contentWidth, _contentHeight;
		
		void resizeView(View *view);
		void layoutSubviews(View *view);
		void placeView(View *view);
	};
}; // end namespace

#endif /* Layouter_hpp */
