//
//  Seeker.m
//  CurveSmoother
//
//  Created by Steven Hooley on 20/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "Seeker.h"
import java.awt.Color;
import java.awt.Graphics;

@implementation Seeker

static final Color seekLineColor = new Color(0.0F, 0.3F, 0.0F);
static final Color seekFillColor = new Color(0.5F, 1.0F, 0.5F);
static final Color fleeLineColor = new Color(0.3F, 0.0F, 0.0F);
static final Color fleeFillColor = new Color(1.0F, 0.5F, 0.5F);

- (id)init {
    self = [super init];
    if (self) {
        seek = YES;
        touch = NO;
        maxSpeed = 0.8F;
        maxForce = 0.06F;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)update() {

    [self steeringForSeekFlee:steering];
    [self applyGlobalForce:steering];
    
    touch |= target.approximateDistance(this.position) < 0.6D;
    
    [super update];
}

- (void)steeringForSeekFlee:(CGPoint)v {

    if(seek)
        steering.setDiff(target, position);
    else {
        steering.setDiff(position, target);
    }
    
    float goalLength = 1.1F * velocity.approximateLength();
    steering.setApproximateTruncate(goalLength);
    
    steering.setDiff(steering, velocity);
    steering.setApproximateTruncate(maxForce);
    v.set(steering);
}

//- (void)draw(Graphics g, float scale) {
//    int diameter = (int)(scale - 1.0F);
//    int radius = (int)(scale / 2.0F);
//    int top = (int)(scale * this.position.y - radius);
//    int left = (int)(scale * this.position.x - radius);
//    
//    g.setColor(this.seek ? seekFillColor : fleeFillColor);
//    g.fillOval(left, top, diameter, diameter);
//    g.setColor(this.seek ? seekLineColor : fleeLineColor);
//    g.drawOval(left, top, diameter, diameter);
//    
//    drawVector(steering, 30.0F, Color.blue, g, scale);
//    
//    drawVector(this.velocity, 4.0F, Color.magenta, g, scale);
//    
//    int tx = (int)(scale * this.target.x);
//    int ty = (int)(scale * this.target.y);
//    g.setColor(this.touch ? seekLineColor : Color.black);
//    g.drawOval(tx - radius, ty - radius, diameter, diameter);
//    g.drawLine(tx + diameter, ty, tx - diameter, ty);
//    g.drawLine(tx, ty + diameter, tx, ty - diameter);
//}

//- (void)drawVector(Vector3 v, float vscale, Color c, Graphics g, float dscale)
//{
//    drawSteer.setScale(vscale, v);
//    drawSteer.setSum(this.position, drawSteer);
//    g.setColor(c);
//    g.drawLine((int)(dscale * this.position.x), 
//               (int)(dscale * this.position.y), 
//               (int)(dscale * drawSteer.x), 
//               (int)(dscale * drawSteer.y));
//}

@end
