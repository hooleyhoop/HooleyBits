
#ifndef FLAC__ASSERT_H
#define FLAC__ASSERT_H

/* we need this since some compilers (like MSVC) leave assert()s on release code (and we don't want to use their ASSERT) */

#define FLAC__ASSERT(x)
//#define FLAC__ASSERT_DECLARATION(x)

#endif
