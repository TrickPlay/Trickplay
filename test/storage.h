#ifndef __TRICKPLAY_STORAGE__
#define __TRICKPLAY_STORAGE__

#include <string>

extern "C" {
	#include "tcutil.h"
	#include "tchdb.h"
}


namespace Storage
{
	typedef std::string String;
	
	class LocalHash
	{
		public:
			LocalHash();
			~LocalHash();

			String name;

			void connect();

			String get(String & key);
			void   put(String & key, String & value);
			void   del(String & key);

			// Remove all key/value pairs from the DB
			void nuke();

			// Transaction stuff
			void begin();
			void commit();
			void abort();

			// Flush to backing store			
			void flush();

			// Count number of key/value pairs in the DB
			uint64_t count();

		protected:
			TCHDB * db;
	};
	
	
	// Count the number of records in the database
	uint64_t count(LocalHash & db);
};

#endif // __TRICKPLAY_STORAGE__
