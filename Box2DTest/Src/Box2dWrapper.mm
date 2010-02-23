//
//  Box2dWrapper.m
//  Box2DTest
//
//  Created by Steven Hooley on 4/20/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "Box2dWrapper.h"
#import "Box2D.h"


@implementation Box2dWrapper

- (void)init {
	self = [super init];

	b2AABB worldAABB;

	worldAABB.lowerBound.Set(-100.0f, -100.0f);
	worldAABB.upperBound.Set(100.0f, 100.0f);
	
	// Define the gravity vector.
	b2Vec2 gravity(0.0f, -10.0f);
	
	// Do we want to let bodies sleep?
	bool doSleep = true;
	
	// Construct a world object, which will hold and simulate the rigid bodies.
	b2World world(worldAABB, gravity, doSleep);

	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0.0f, -10.0f);
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world.CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2PolygonDef groundShapeDef;
	
	// The extents are the half-widths of the box.
	groundShapeDef.SetAsBox(50.0f, 10.0f);
	
	// Add the ground shape to the ground body.
	groundBody->CreateShape(&groundShapeDef);
	
	// Define the dynamic body. We set its position and call the body factory.
	b2BodyDef bodyDef;
	bodyDef.position.Set(0.0f, 4.0f);
	b2Body* body = world.CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonDef shapeDef;
	shapeDef.SetAsBox(1.0f, 1.0f);
	
	// Set the box density to be non-zero, so it will be dynamic.
	shapeDef.density = 1.0f;
	
	// Override the default friction.
	shapeDef.friction = 0.3f;
	
	// Add the shape to the body.
	body->CreateShape(&shapeDef);
	
	// Now tell the dynamic body to compute it's mass properties base
	// on its shape.
	body->SetMassFromShapes();
	
	// Prepare for simulation. Typically we use a time step of 1/60 of a
	// second (60Hz) and 10 iterations. This provides a high quality simulation
	// in most game scenarios.
	float32 timeStep = 1.0f / 60.0f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// This is our little game loop.
	for (int32 i = 0; i < 60; ++i)
	{
		// Instruct the world to perform a single step of simulation. It is
		// generally best to keep the time step and iterations fixed.
		world.Step(timeStep, velocityIterations, positionIterations);
		
		// Now print the position and angle of the body.
		b2Vec2 position = body->GetPosition();
		float32 angle = body->GetAngle();
		
		printf("%4.2f %4.2f %4.2f\n", position.x, position.y, angle);
	}
	
	// When the world destructor is called, all bodies and joints are freed. This can
	// create orphaned pointers, so be careful about your world management.
	
	
}

@end
