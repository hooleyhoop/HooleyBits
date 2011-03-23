//
//  2DVectorOps.c
//  CurveSmoother
//
//  Created by Steven Hooley on 21/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#include "2DVectorOps.h"



 CGPoint setUnitRandom() {
    do
    {
        this.x = (generator.nextFloat() * 2.0F - 1.0F);
        this.y = (generator.nextFloat() * 2.0F - 1.0F);
        this.z = (generator.nextFloat() * 2.0F - 1.0F);
    }
    while (magnitudeSquared() > 1.0F);
}