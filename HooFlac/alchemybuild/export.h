
#ifndef FLAC__EXPORT_H
#define FLAC__EXPORT_H

/** \file include/FLAC/export.h
 *
 *  \brief
 *  This module contains #defines and symbols for exporting function
 *  calls, and providing version information and compiled-in features.
 *
 *  See the \link flac_export export \endlink module.
 */

/** \defgroup flac_export FLAC/export.h: export symbols
 *  \ingroup flac
 *
 *  \brief
 *  This module contains #defines and symbols for exporting function
 *  calls, and providing version information and compiled-in features.
 *
 *  If you are compiling with MSVC and will link to the static library
 *  (libFLAC.lib) you should define FLAC__NO_DLL in your project to
 *  make sure the symbols are exported properly.
 *
 * \{
 */

#define FLAC_API

/** These #defines will mirror the libtool-based library version number, see
 * http://www.gnu.org/software/libtool/manual.html#Libtool-versioning
 */
#define FLAC_API_VERSION_CURRENT 10
#define FLAC_API_VERSION_REVISION 0 /**< see above */
#define FLAC_API_VERSION_AGE 2 /**< see above */

/** \c 1 if the library has been compiled with support for Ogg FLAC, else \c 0. */
extern FLAC_API int FLAC_API_SUPPORTS_OGG_FLAC;


#endif
