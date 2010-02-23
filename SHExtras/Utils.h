#import <Foundation/Foundation.h>

#define nsenumerate_getEnumerator( TYPE, OBJ )				\
	(TYPE)([OBJ isKindOfClass:[NSEnumerator class]]			\
	? OBJ													\
	: [OBJ performSelector:@selector(objectEnumerator)])

#define	nsenumerate( CONTAINER, ITERATOR_TYPE, ITERATOR_SYMBOL )			\
for( ITERATOR_TYPE															\
	 *enumerator = nsenumerate_getEnumerator(ITERATOR_TYPE*, CONTAINER),	\
	 *ITERATOR_SYMBOL = [((NSEnumerator*) enumerator) nextObject];			\
	 ITERATOR_SYMBOL != nil;												\
	 ITERATOR_SYMBOL = [((NSEnumerator*) enumerator) nextObject] )

#define	nsenumerat( CONTAINER, ITERATOR_SYMBOL )					\
for( id																\
	 enumerator = nsenumerate_getEnumerator(id, CONTAINER),			\
	 ITERATOR_SYMBOL = [((NSEnumerator*) enumerator) nextObject];	\
	 ITERATOR_SYMBOL != nil;										\
	 ITERATOR_SYMBOL = [((NSEnumerator*) enumerator) nextObject] )
	 
	 
/**/

#define  BBCLAMP(x,u,v) (x = x<u? u : (x>v ? v: x))