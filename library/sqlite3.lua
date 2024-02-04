---@meta _

--[[
LuaSQLite 3 is a thin wrapper around the public domain SQLite3 database engine.

There are two modules, identical except that one links SQLite3 dynamically, the other statically.

The module lsqlite3 links SQLite3 dynamically. To use this module you need the SQLite3 library (DLL or .so). You can get it from http://www.sqlite.org/

The module lsqlite3complete links SQLite3 statically. The SQLite3 amalgamation source code is included in the LuaSQLite 3 distribution. This can simplify deployment, but might result in more than one copy of the SQLite library if other parts of the code also include it. See http://www.sqlite.org/howtocorrupt.html for an explanation on why it would be a bad idea.

Both modules support the creation and manipulation of SQLite3 databases. After a sqlite3 = require('lsqlite3') (or sqlite3 = require('lsqlite3complete')) the exported functions are called with prefix sqlite3. However, most sqlite3 functions are called via an object-oriented interface to either database or SQL statement objects; see below for details.

This documentation does not attempt to describe how SQLite3 itself works, it just describes the Lua binding and the available functions. For more information about the SQL features supported by SQLite3 and details about the syntax of SQL statements and queries, please see the SQLite3 documentation http://www.sqlite.org/. Using some of the advanced features (how to use callbacks, for instance) will require some familiarity with the SQLite3 API.
]]
---@class SQLite3
--- The database is opened in read-only mode. If the database does not already exist, an error is returned.
---@field OPEN_READONLY SQLiteOpenFlags
--- The database is opened for reading and writing if possible, or reading only if the file is write protected by the operating system. In either case the database must already exist, otherwise an error is returned. For historical reasons, if opening in read-write mode fails due to OS-level permissions, an attempt is made to open it in read-only mode.
---@field OPEN_READWRITE SQLiteOpenFlags
--- The database is opened for reading and writing, and is created if it does not already exist.
---@field OPEN_CREATE SQLiteOpenFlags
--- The filename can be interpreted as a URI if this flag is set.
---@field OPEN_URI SQLiteOpenFlags
--- The database will be opened as an in-memory database. The database is named by the "filename" argument for the purposes of cache-sharing, if shared cache mode is enabled, but the "filename" is otherwise ignored.
---@field OPEN_MEMORY SQLiteOpenFlags
--- The new database connection will use the "multi-thread" threading mode. This means that separate threads are allowed to use SQLite at the same time, as long as each thread is using a different database connection.
---@field OPEN_NOMUTEX SQLiteOpenFlags
--- The new database connection will use the "serialized" threading mode. This means the multiple threads can safely attempt to use the same database connection at the same time. (Mutexes will block any actual concurrency, but in this mode there is no harm in trying.)
---@field OEPN_FULLMUTEX SQLiteOpenFlags
--- The database is opened shared cache enabled. The use of shared cache mode is discouraged and hence shared cache capabilities may be omitted from many builds of SQLite. In such cases, this option is a no-op.
---@field OPEN_SHAREDCACHE SQLiteOpenFlags
--- The database is opened with shared cache disabled.
---@field OPEN_PRIVATECACHE SQLiteOpenFlags
--- The database connection comes up in "extended result code mode".
---@field OPEN_EXRESCODE SQLiteOpenFlags
--- The database filename is not allowed to contain a symbolic link.
---@field OPEN_NOFOLLOW SQLiteOpenFlags
--- The operation was successful and that there were no errors. Most other result codes indicate an error.
---@field OK SQLiteStatusCode
	--- A generic error code that is used when no other more specific error code is available
---@field ERROR SQLiteStatusCode
	--[[
Indicates an internal malfunction. In a working version of SQLite, an application should never see this result code. If application does encounter this result code, it shows that there is a bug in the database engine.

SQLite does not currently generate this result code. However, application-defined SQL functions or virtual tables, or VFSes, or other extensions might cause this result code to be returned.
	]]
---@field INTERNAL SQLiteStatusCode
	--- The requested access mode for a newly created database could not be provided
---@field PERM SQLiteStatusCode
	--[[
An operation was aborted prior to completion, usually be application request. See also: SQLITE_INTERRUPT.

If a ROLLBACK operation occurs on the same database connection as a pending read or write, then the pending read or write may fail with an ABORT or ABORT_ROLLBACK error.
	]]
---@field ABORT SQLiteStatusCode
	--[[
The database file could not be written (or in some cases read) because of concurrent activity by some other database connection, usually a database connection in a separate process.

For example, if process A is in the middle of a large write transaction and at the same time process B attempts to start a new write transaction, process B will get back an SQLITE_BUSY result because SQLite only supports one writer at a time. Process B will need to wait for process A to finish its transaction before starting a new transaction. The sqlite3_busy_timeout() and sqlite3_busy_handler() interfaces and the busy_timeout pragma are available to process B to help it deal with SQLITE_BUSY errors.

An BUSY error can occur at any point in a transaction: when the transaction is first started, during any write or update operations, or when the transaction commits. To avoid encountering BUSY errors in the middle of a transaction, the application can use BEGIN IMMEDIATE instead of just BEGIN to start a transaction. The BEGIN IMMEDIATE command might itself return SQLITE_BUSY, but if it succeeds, then SQLite guarantees that no subsequent operations on the same database through the next COMMIT will return BUSY.

See also: [SQLITE_BUSY_RECOVERY](https://www.sqlite.org/rescode.html#busy_recovery) and [SQLITE_BUSY_SNAPSHOT](https://www.sqlite.org/rescode.html#busy_snapshot).

The BUSY result code differs from LOCKED in that BUSY indicates a conflict with a separate database connection, probably in a separate process, whereas LOCKED indicates a conflict within the same database connection (or sometimes a database connection with a shared cache).
	]]
---@field BUSY SQLiteStatusCode
	--[[
A write operation could not continue because of a conflict within the same database connection or a conflict with a different database connection that uses a shared cache.

For example, a DROP TABLE statement cannot be run while another thread is reading from that table on the same database connection because dropping the table would delete the table out from under the concurrent reader.

The LOCKED result code differs from BUSY in that LOCKED indicates a conflict on the same database connection (or on a connection with a shared cache) whereas BUSY indicates a conflict with a different database connection, probably in a different process.
	]]
---@field LOCKED SQLiteStatusCode
	--- Indicates that SQLite was unable to allocate all the memory it needed to complete the operation
---@field NOMEM SQLiteStatusCode
	--- An attempt was made to alter some data for which the current database connection does not have write permission.
---@field READONLY SQLiteStatusCode
	--- Indicates that an operation was interrupted by the sqlite3_interrupt() interface.
---@field INTERRUPT SQLiteStatusCode
	--[[
the operation could not finish because the operating system reported an I/O error.

A full disk drive will normally give a FULL error rather than an IOERR error.

There are many different extended result codes for I/O errors that identify the specific I/O operation that failed.
	]]
---@field IOERR SQLiteStatusCode
--- The database file has been corrupted. See the [How To Corrupt Your Database Files](https://www.sqlite.org/lockingv3.html#how_to_corrupt) for further discussion on how corruption can occur.
---@field CORRUPT SQLiteStatusCode
--[[
Exposed in three ways:

- NOTFOUND can be returned by the sqlite3_file_control() interface to indicate that the file control opcode passed as the third argument was not recognized by the underlying VFS.

- NOTFOUND can also be returned by the xSetSystemCall() method of an sqlite3_vfs object.

- NOTFOUND can be returned by sqlite3_vtab_rhs_value() to indicate that the right-hand operand of a constraint is not available to the xBestIndex method that made the call.

The SQLITE_NOTFOUND result code is also used internally by the SQLite implementation, but those internal uses are not exposed to the application.
]]
---@field NOTFOUND SQLiteStatusCode
	--[[
A write could not complete because the disk is full. Note that this error can occur when trying to write information into the main database file, or it can also occur when writing into temporary disk files.

Sometimes applications encounter this error even though there is an abundance of primary disk space because the error occurs when writing into temporary disk files on a system where temporary files are stored on a separate partition with much less space that the primary disk.
	]]
---@field FULL SQLiteStatusCode
	--- SQLite was unable to open a file. The file in question might be a primary database file or one of several temporary disk files.
---@field CANTOPEN SQLiteStatusCode
   --- Indicates a problem with the file locking protocol used by SQLite. The PROTOCOL error is currently only returned when using WAL mode and attempting to start a new transaction. There is a race condition that can occur when two separate database connections both try to start a transaction at the same time in WAL mode. The loser of the race backs off and tries again, after a brief delay. If the same connection loses the locking race dozens of times over a span of multiple seconds, it will eventually give up and return PROTOCOL. The PROTOCOL error should appear in practice very, very rarely, and only when there are many separate processes all competing intensely to write to the same database.
---@field PROTOCOL SQLiteStatusCode
	--- Not currently used by SQLite.
---@field EMPTY SQLiteStatusCode
	--- The database schema has changed.
---@field SCHEMEA SQLiteStatusCode
	--- A string or BLOB was too large. The default maximum length of a string or BLOB in SQLite is 1,000,000,000 bytes. This maximum length can be changed at compile-time using the SQLITE_MAX_LENGTH compile-time option, or at run-time using the sqlite3_limit(db,SQLITE_LIMIT_LENGTH,...) interface. The TOOBIG error results when SQLite encounters a string or BLOB that exceeds the compile-time or run-time limit.
---@field TOOBIG SQLiteStatusCode
	--- An SQL constraint violation occurred while trying to process an SQL statement.
---@field CONSTRAINT SQLiteStatusCode
	--[[
Datatype mismatch.

SQLite is normally very forgiving about mismatches between the type of a value and the declared type of the container in which that value is to be stored. For example, SQLite allows the application to store a large BLOB in a column with a declared type of BOOLEAN. But in a few cases, SQLite is strict about types. The MISMATCH error is returned in those few cases when the types do not match.

The rowid of a table must be an integer. Attempt to set the rowid to anything other than an integer (or a NULL which will be automatically converted into the next available integer rowid) results in an ISMATCH error.
	]]
---@field MISMATCH SQLiteStatusCode
	--[[
Returned if the application uses any SQLite interface in a way that is undefined or unsupported. For example, using a prepared statement after that prepared statement has been finalized might result in an MISUSE error.

SQLite tries to detect misuse and report the misuse using this result code. However, there is no guarantee that the detection of misuse will be successful. Misuse detection is probabilistic. Applications should never depend on an MISUSE return value.

If SQLite ever returns MISUSE from any interface, that means that the application is incorrectly coded and needs to be fixed. Do not ship an application that sometimes returns SQLITE_MISUSE from a standard SQLite interface because that application contains potentially serious bugs.
	]]
---@field MISUSE SQLiteStatusCode
	--- Can be returned on systems that do not support large files when the database grows to be larger than what the filesystem can handle. "NOLFS" stands for "NO Large File Support".
---@field NOLFS SQLiteStatusCode
	--- Not currently used by SQLite.
---@field FORMAT SQLiteStatusCode
	--- The parameter number argument is out of range.
---@field RANGE SQLiteStatusCode
	--- The file being opened does not appear to be an SQLite database file.
---@field NOTADB SQLiteStatusCode
	--- Another row of output is available.
---@field ROW SQLiteStatusCode
	--- The operation has completed.
---@field DONE SQLiteStatusCode
---@field CREATE_INDEX SQLiteAuthorizerActionCode
---@field CREATE_TABLE SQLiteAuthorizerActionCode
---@field CREATE_TEMP_INDEX SQLiteAuthorizerActionCode
---@field CREATE_TEMP_TABLE SQLiteAuthorizerActionCode
---@field CREATE_TEMP_TRIGGER SQLiteAuthorizerActionCode
---@field CREATE_TEMP_VIEW SQLiteAuthorizerActionCode
---@field CREATE_TRIGGER SQLiteAuthorizerActionCode
---@field CREATE_VIEW SQLiteAuthorizerActionCode
---@field DELETE SQLiteAuthorizerActionCode
---@field DROP_INDEX SQLiteAuthorizerActionCode
---@field DROP_TABLE SQLiteAuthorizerActionCode
---@field DROP_TEMP_INDEX SQLiteAuthorizerActionCode
---@field DROP_TEMP_TABLE SQLiteAuthorizerActionCode
---@field DROP_TEMP_TRIGGER SQLiteAuthorizerActionCode
---@field DROP_TEMP_VIEW SQLiteAuthorizerActionCode
---@field DROP_TRIGGER SQLiteAuthorizerActionCode
---@field DROP_VIEW SQLiteAuthorizerActionCode
---@field INSERT SQLiteAuthorizerActionCode
---@field PRAGMA SQLiteAuthorizerActionCode
---@field READ SQLiteAuthorizerActionCode
---@field SELECT SQLiteAuthorizerActionCode
---@field TRANSACTION SQLiteAuthorizerActionCode
---@field UPDATE SQLiteAuthorizerActionCode
---@field ATTACH SQLiteAuthorizerActionCode
---@field DETACH SQLiteAuthorizerActionCode
---@field ALTER_TABLE SQLiteAuthorizerActionCode
---@field REINDEX SQLiteAuthorizerActionCode
---@field ANALYZE SQLiteAuthorizerActionCode
---@field CREATE_VTABLE SQLiteAuthorizerActionCode
---@field DROP_VTABLE SQLiteAuthorizerActionCode
---@field FUNCTION SQLiteAuthorizerActionCode
---@field SAVEPOINT SQLiteAuthorizerActionCode
local sqlite3 = {
	OK = 0,
	ERROR = 1,
	INTERNAL = 2,
	PERM = 3,
	ABORT = 4,
	BUSY = 5,
	LOCKED = 6,
	NOMEM = 7,
	READONLY = 8,
	INTERRUPT = 9,
	IOERR = 10,
	CORRUPT = 11,
	NOTFOUND = 12,
	FULL = 13,
	CANTOPEN = 14,
	MISMATCH = 20,
	MISUSE = 21,
	NOLFS = 22,
	FORMAT = 24,
	RANGE = 25,
	NOTADB = 26,
	ROW = 100,
	DONE = 101;

	CREATE_INDEX = 1,
	CREATE_TABLE = 2,
	CREATE_TEMP_INDEX = 3,
	CREATE_TEMP_TABLE = 4,
	CREATE_TEMP_TRIGGER = 5,
	CREATE_TEMP_VIEW = 6,
	CREATE_TRIGGER = 7,
	CREATE_VIEW = 8,
	DELETE = 9,
	DROP_INDEX = 10,
	DROP_TABLE = 11,
	DROP_TEMP_INDEX = 12,
	DROP_TEMP_TABLE = 13,
	DROP_TEMP_TRIGGER = 14,
	DROP_TEMP_VIEW = 15,
	DROP_TRIGGER = 16,
	DROP_VIEW = 17,
	INSERT = 18,
	PRAGMA = 19,
	READ = 20,
	SELECT = 21,
	TRANSACTION = 22,
	UPDATE = 23,
	ATTACH = 24,
	DETACH = 25,
	ALTER_TABLE = 26,
	REINDEX = 27,
	ANALYZE = 28,
	CREATE_VTABLE = 29,
	DROP_VTABLE = 30,
	FUNCTION = 31,
	SAVEPOINT = 32;
}

---@class SQLiteOpenFlags
---@operator add(SQLiteOpenFlags): SQLiteOpenFlags

---@alias SQLiteStatusCode integer
---@alias SQLiteAuthorizerActionCode integer

---Checks the validity of a string as a SQL statement.
---@param sql string # The string to test the validity of.
---@return boolean # Whether or not the string `sql` comprises one or more complete SQL statements.
function sqlite3.complete(sql) end

--[[
Opens (or creates if it does not exist) a SQLite database with name filename and returns its handle as userdata (the returned object should be used for all further method calls in connection with this specific database). Example:

	myDB=sqlite3.open('MyDatabase.sqlite3')  -- open
	-- do some database calls...
	myDB:close()  -- close

	local db = sqlite3.open('foo.db', sqlite3.OPEN_READWRITE + sqlite3.OPEN_CREATE + sqlite3 OPEN_SHAREDCACHE)

The default value for `flags` is `sqlite3.OPEN_READWRITE + sqlite3.OPEN_CREATE`.
]]
---@param filename string # The name of the database file
---@param flags? SQLiteOpenFlags # Optional flags that can be passed to control the behaviour of this function. [See SQLite Docs](https://www.sqlite.org/c3ref/open.html)
---@return SQLiteDatabase?
---@return SQLiteStatusCode?
---@return string?
---@see SQLiteDatabase
function sqlite3.open(filename, flags) end

---Opens an SQLite database in memory and returns its handle as userdata. In case of an error, the function returns nil, an error code and an error message. (In-memory databases are volatile as they are never stored on disk.)
---@return SQLiteDatabase?
---@return SQLiteStatusCode?
---@return string?
---@see SQLiteDatabase
function sqlite3.open_memory() end

--- Opens the SQLite database corresponding to the light userdata db_ptr and returns its handle as userdata. Use `db:get_ptr()` to get a db_ptr for an open database.
---@param db_ptr SQLiteDatabasePtr
---@see SQLiteDatabase.get_ptr
function sqlite3.open_ptr(db_ptr) end

--[[
Starts an SQLite Online Backup from source_db to target_db and returns its handle as userdata. The source_db and target_db are open databases; they may be in-memory or file-based databases. The target_name and source_name are "main" for the main database, "temp" for the temporary database, or the name specified after the AS keyword in an ATTACH statement for an attached database.

The source and target databases must be different, or else the init call will fail with an error. A call to `sqlite3.backup_init()` will fail, returning `nil`, if there is already a read or read-write transaction open on the target database.

If an error occurs within sqlite3.backup_init, then `nil` is returned, and an error code and error message are stored in target_db. The error code and message for the failed call can be retrieved using the `db:errcode()`, or `db:errmsg()`.
]]
---@param target_db SQLiteDatabase
---@param target_name string
---@param source_db SQLiteDatabase
---@param source_name string
---@return SQLiteBackup?
---@see SQLiteBackup
function sqlite3.backup_init(target_db, target_name, source_db, source_name) end

--- Sets or queries the directory used by SQLite for temporary files. If string temp is a directory name or nil, the temporary directory is set accordingly and the old value is returned. If temp is missing, the function simply returns the current temporary directory.
---@param temp? string # The path to the directory to store temporary files in
---@return string # The current temporary directory
function sqlite3.temp_directory(temp) end

---@return string # A string with SQLite version information, in the form 'x.y[.z[.p]]'.
---@see SQLite3.lversion
function sqlite3.version() end

---@return string # A string with lsqlite3 library version information, in the form 'x.y[.z]'.
---@see SQLite3.version
function sqlite3.lversion() end

return sqlite3
