#include "storage.h"
#include "glib.h"

namespace Storage
{

	LocalHash::LocalHash()
	{
	}

	LocalHash::~LocalHash()
	{	
		tchdbdel(db);
	}

	void LocalHash::connect()
	{
		db = tchdbnew();
		if(!tchdbtune(db, 0, -1, -1, 0))
		{
			g_debug("Failed to tune DB: %s", tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}

		if(!tchdbsetcache(db, 32768))
		{
			g_debug("Failed to set cache for DB: %s", tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}

		if(!tchdbopen(db, name.c_str(), HDBOWRITER | HDBOREADER | HDBOCREAT))
		{
			g_debug("Failed to open DB file: %s", tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}
	}


	String LocalHash::get(String & key)
	{
		int val_len;
		void *value = tchdbget(db, (const void *)key.data(), key.length(), &val_len);
		if(NULL == value)
		{
			return String();
		} else {
			String result((const char *)value, (size_t)val_len);
			free(value);
			return result;
		}
	}

	void LocalHash::put(String & key, String & value)
	{
		if(!tchdbput(db, (const void*)key.data(), key.length(), (const void *)value.data(), value.length()))
		{
			g_debug("Failed to put (%s, %s): %s", key.c_str(), value.c_str(), tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}
	}

	void LocalHash::del(String & key)
	{
		if(!tchdbout(db, (const void *)key.data(), key.length()))
		{
			g_debug("Failed to delete (%s): %s", key.c_str(), tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}
	}
	
	// Clear all entries in the DB: remove all key/value pairs
	void LocalHash::nuke()
	{
		if(!tchdbvanish(db))
		{
			g_debug("Failed to nuke DB: %s", tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}
	}

	// Transaction stuff
	void LocalHash::begin()
	{
		if(!tchdbtranbegin(db))
		{
			g_debug("Failed to begin transaction: %s", tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}
	}

	void LocalHash::commit()
	{
		if(!tchdbtrancommit(db))
		{
			g_debug("Failed to commit transaction: %s", tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}
	}

	void LocalHash::abort()
	{
		if(!tchdbtranabort(db))
		{
			g_debug("Failed to abort transaction: %s", tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}
	}

	// Flush the database to backing store
	void LocalHash::flush()
	{
		if(!tchdbsync(db))
		{
			g_debug("Failed to flush DB: %s", tchdberrmsg(tchdbecode(db)));
			g_assert(false);
		}
	}

	// Count the number of records in the database
	uint64_t LocalHash::count()
	{
		return tchdbrnum(db);
	}
};
