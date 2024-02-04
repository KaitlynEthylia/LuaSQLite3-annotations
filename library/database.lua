---@meta _

---@alias SQLiteValue string | integer
---@class SQLiteDatabasePtr: lightuserdata
---@class SQLiteDatabase: userdata
local SQLiteDatabase = {}

--[[
Sets or removes a busy handler for a SQLiteDatabase. `fun` is either a Lua function that implements the busy handler or `nil` to remove a previously set handler. This function returns nothing.

The handler function is called with two parameters: `data` and the number of (re-)tries for a pending transaction. It should return `nil`, `false` or `0` if the transaction is to be aborted. All other values will result in another attempt to perform the transaction. (See the SQLite documentation for important hints about writing busy handlers.)
]]
---@param fun? fun(udata: any, retries: integer): boolean
---@param data? any
function SQLiteDatabase:busy_handler(fun, data) end

--[[
Sets a busy handler that waits for `t` milliseconds if a transaction cannot proceed. Calling this function will remove any busy handler set by `db:busy_handler()`; calling it with an argument less than or equal to 0 will turn off all busy handlers.
]]
---@param t integer
---@see SQLiteDatabase.busy_handler
function SQLiteDatabase:busy_timeout(t) end

--- Gets the number of database rows that were changed, inserted, or deleted by the most recent SQL statment. Only changes that are directly specified by INSERT, UPDATE, or DELETE statements are counted. Auxiliary changes caused by triggers are not counted. Use `db:total_changes()` to find the total number of changes.
---@return integer
---@see SQLiteDatabase.total_changes
function SQLiteDatabase:changes() end

--- Closes a database. All SQL statements prepared using `db:prepare()` should have been finalized before this function is called. The function returns `sqlite3.OK` on success or else a numerical error code.
---@return SQLiteStatusCode
---@see SQLiteDatabase.prepare
function SQLiteDatabase:close() end

--- Finalizes all statements that have not been explicitly finalized.
---@param temponly? boolean # Only finalize temporary and internal statements.
function SQLiteDatabase:close_vm(temponly) end

--- Returns a lightuserdata corresponding to the open db. Use with `sqlite3.open_ptr()` to pass a database connection between threads. (When using lsqlite3 in a multithreaded environment, each thread has a separate Lua environment; full userdata structures can't be passed from one thread to another, but this is possible with lightuserdata.)
---@return SQLiteDatabasePtr
---@see SQLite3.open_ptr
function SQLiteDatabase:get_ptr() end

--- Installs a commit_hook callback handler. `fun` is a Lua function that is invoked by SQLite3 whenever a transaction is commited. This callback receives one argument: the `data` argument used when the callback was installed. If `fun` returns `false` or `nil` the COMMIT is allowed to prodeed, otherwise the COMMIT is converted to a ROLLBACK.
---@param fun fun(data: any): boolean?
---@param data any
---@see SQLiteDatabase.rollback_hook
---@see SQLiteDatabase.update_hook
function SQLiteDatabase:commit_hook(fun, data) end

--[[
This function creates an aggregate callback function. Aggregates perform an operation over all rows in a query. `name` is a string with the name of the aggregate function as given in an SQL statement; `nargs` is the number of arguments this call will provide. `step` is the actual Lua function that gets called once for every row; it should accept a function context plus the same number of parameters as given in `nargs`. `final` is a function that is called once after all rows have been processed; it receives one argument, the function context. If provided, `data` can be any Lua value and would be returned by the `context:user_data()` method.

The function context can be used inside the two callback functions to communicate with SQLite3. Here is a simple example:

        db:exec[=[
          CREATE TABLE numbers(num1,num2);
          INSERT INTO numbers VALUES(1,11);
          INSERT INTO numbers VALUES(2,22);
          INSERT INTO numbers VALUES(3,33);
        ]=]

        local num_sum=0
        local function oneRow(context,num)  -- add one column in all rows
          num_sum=num_sum+num
        end
        local function afterLast(context)   -- return sum after last row has been processed
          context:result_number(num_sum)
          num_sum=0
        end

        db:create_aggregate("do_the_sums",1,oneRow,afterLast)
        for sum in db:urows('SELECT do_the_sums(num1) FROM numbers') do
			print("Sum of col 1:",sum)
		end
        for sum in db:urows('SELECT do_the_sums(num2) FROM numbers') do
			print("Sum of col 2:",sum)
		end
]]
---@param name string
---@param nargs integer
---@param step fun(ctx: SQLiteContext, ...: SQLiteValue)
---@param final fun(ctx: SQLiteContext)
---@param data? any
---@see SQLiteContext
function SQLiteDatabase:create_aggregate(name, nargs, step, final, data) end

--[[
Creates a collation callback. A collation callback is used to establish a collation order, mostly for string comparisons and sorting purposes. `name` is a string with the name of the collation to be created; `fun` is a function that accepts two string arguments, compares them and returns 0 if both strings are identical, -1 if the first argument is lower in the collation order than the second and 1 if the first argument is higher in the collation order than the second. A simple example:

        local function collate(s1,s2)
          s1=s1:lower()
          s2=s2:lower()
          if s1==s2 then return 0
          elseif s1<s2 then return -1
          else return 1 end
        end

        db:exec[=[
          CREATE TABLE test(id INTEGER PRIMARY KEY content COLLATE CINSENS);
          INSERT INTO test VALUES(NULL,'hello world');
          INSERT INTO test VALUES(NULL,'Buenos dias');
          INSERT INTO test VALUES(NULL,'HELLO WORLD');
        ]=]

		db:create_collation('CINSENS', collate)

        for row in db:nrows('SELECT * FROM test') do
			print(row.id,row.content)
		end
]]
---@param name string
---@param fun fun(first: string, second: string): -1 | 0 | 1
function SQLiteDatabase:create_collation(name, fun) end

--[[
creates a callback function. Callback function are called by SQLite3 once for every row in a query. `name` is a string with the name of the callback function as given in an SQL statement; `nargs` is the number of arguments this call will provide. `fun` is the actual Lua function that gets called once for every row; it should accept a function context (see Methods for callback contexts) plus the same number of parameters as given in `nargs`. If provided, `data` can be any Lua value and would be returned by the `context:user_data()` method. Here is an example:

        db:exec'CREATE TABLE test(col1,col2,col3)'
        db:exec'INSERT INTO test VALUES(1,2,4)'
        db:exec'INSERT INTO test VALUES(2,4,9)'
        db:exec'INSERT INTO test VALUES(3,6,16)'

		db:create_function('sum_cols',3,function(ctx,a,b,c)
          ctx:result_number(a+b+c)
        end))

		for col1,col2,col3,sum
		in db:urows('SELECT *,sum_cols(col1,col2,col3) FROM test') do
          print(col1,col2,col3,sum)
        end
]]
---@param name string
---@param nargs integer
---@param fun fun(ctx: SQLiteContext, ...)
---@param data any
function SQLiteDatabase:create_function(name, nargs, fun, data) end

--[[
When a name is provided, loads an SQLite extension library from the named file into this database connection. The optional entrypoint is the library initialization function name; if not supplied, SQLite tries various default entrypoint names. Returns true when successful, or false and an error string otherwise.

When called with no arguments, disables the `load_extension()` SQL function, which is enabled as a side effect of calling `db:load_extension` with a name.
]]
---@param name? string
---@param entrypoint? string
---@return boolean
---@return SQLiteStatusCode?
function SQLiteDatabase:load_extension(name, entrypoint) end

--- @return SQLiteStatusCode # The most recent error code
function SQLiteDatabase:errcode() end
--- @return SQLiteStatusCode # The most recent error code
function SQLiteDatabase:error_code() end

--- @return string # The most recent error message
function SQLiteDatabase:errmsg() end
--- @return string # The most recent error message
function SQLiteDatabase:error_message() end

--[[
Compiles and executes the SQL statement(s) given in string sql. The statements are simply executed one after the other and not stored. The function returns `sqlite3.OK` on success or else a numerical error code.

If one or more of the SQL statements are queries, then the callback function specified in `fun` is invoked once for each row of the query result (if `fun` is `nil`, no callback is invoked).

The callback receives four arguments: `data` (the third parameter of the `db:exec()` call), the number of columns in the row, a table with the column values and another table with the column names. The callback function should return `0`. If the callback returns a non-zero value then the query is aborted, all subsequent SQL statements are skipped and `db:exec()` returns `sqlite3.ABORT`. Here is a simple examle:

	sql=[=[
          CREATE TABLE numbers(num1,num2,str);
          INSERT INTO numbers VALUES(1,11,"ABC");
          INSERT INTO numbers VALUES(2,22,"DEF");
          INSERT INTO numbers VALUES(3,33,"UVW");
          INSERT INTO numbers VALUES(4,44,"XYZ");
          SELECT * FROM numbers;
        ]=]
	function showrow(udata,cols,values,names)
		assert(udata=='test_udata')
		print('exec:')
		for i=1,cols do print('',names[i],values[i]) end
		return 0
	end
	db:exec(sql,showrow,'test_udata')
]]
---@param sql string
---@param fun? fun(data: any, cols: integer, values: table<SQLiteValue>, names: table<string>)
---@param data? any
---@return SQLiteStatusCode
function SQLiteDatabase:exec(sql, fun, data) end
--[[
Compiles and executes the SQL statement(s) given in string sql. The statements are simply executed one after the other and not stored. The function returns `sqlite3.OK` on success or else a numerical error code.

If one or more of the SQL statements are queries, then the callback function specified in `fun` is invoked once for each row of the query result (if `fun` is `nil`, no callback is invoked).

The callback receives four arguments: `data` (the third parameter of the `db:exec()` call), the number of columns in the row, a table with the column values and another table with the column names. The callback function should return `0`. If the callback returns a non-zero value then the query is aborted, all subsequent SQL statements are skipped and `db:exec()` returns `sqlite3.ABORT`. Here is a simple examle:

	sql=[=[
          CREATE TABLE numbers(num1,num2,str);
          INSERT INTO numbers VALUES(1,11,"ABC");
          INSERT INTO numbers VALUES(2,22,"DEF");
          INSERT INTO numbers VALUES(3,33,"UVW");
          INSERT INTO numbers VALUES(4,44,"XYZ");
          SELECT * FROM numbers;
        ]=]
	function showrow(udata,cols,values,names)
		assert(udata=='test_udata')
		print('exec:')
		for i=1,cols do print('',names[i],values[i]) end
		return 0
	end
	db:execute(sql,showrow,'test_udata')
]]
---@param sql string
---@param fun? fun(data: any, cols: integer, values: table<SQLiteValue>, names: table<string>)
---@param data? any
---@return SQLiteStatusCode
function SQLiteDatabase:execute(sql, fun, data) end

--- Causes any pending database operation to abort and return at the next opportunity.
function SQLiteDatabase:interrupt() end

--- Gets the filename associated with database `name`. The name may be `"main"` for the main database file, or the name specified after the AS keyword in an ATTACH statement for an attached database. If there is no attached database name on the database connection db, then no value is returned; if database name is a temporary or in-memory database, then an empty string is returned.
---@param name string
---@return string
function SQLiteDatabase:db_filename(name) end

---@return boolean # Whether or not the database is open
function SQLiteDatabase:isopen() end

--[[
Gets the rowid of the most recent INSERT into the database. If no inserts have ever occurred, 0 is returned. (Each row in an SQLite table has a unique 64-bit signed integer key called the 'rowid'. This id is always available as an undeclared column named ROWID, OID, or _ROWID_. If the table has a column of type INTEGER PRIMARY KEY then that column is another alias for the rowid.)

If an INSERT occurs within a trigger, then the rowid of the inserted row is returned as long as the trigger is running. Once the trigger terminates, the value returned reverts to the last value inserted before the trigger fired.
]]
---@return integer
function SQLiteDatabase:last_insert_rowid() end

--- Creates an iterator that returns the successive rows selected by the SQL statement given in string sql. Each call to the iterator returns a table in which the named fields correspond to the columns in the database.
---@param sql string
---@return fun(): table<string, SQLiteValue>?
function SQLiteDatabase:nrows(sql) end

--- Compiles the SQL statement in string sql into an internal representation and returns this as userdata. The returned object should be used for all further method calls in connection with this specific SQL statement.
---@param sql string
---@return SQLiteStatment
---@see SQLiteStatment
function SQLiteDatabase:prepare(sql) end

--[[
This function installs a callback function `fun` that is invoked periodically during long-running calls to `db:exec()` or `stmt:step()`. The progress callback is invoked once for every `n` internal operations. `data` is passed to the progress callback function each time it is invoked.

If a call to `db:exec()` or `stmt:step()` results in fewer than `n` operations being executed, then the progress callback is never invoked. Only a single progress callback function may be registered for each opened database and a call to this function will overwrite any previously set callback function. To remove the progress callback altogether, pass `nil` as the second argument.

If the progress callback returns a result other than 0, then the current query is immediately terminated, any database changes are rolled back and the containing `db:exec()` or `stmt:step()` call returns `sqlite3.INTERRUPT`. This feature can be used to cancel long-running queries.
]]
---@param n integer
---@param fun fun(data: any): 0?
---@param data any
---@see SQLiteDatabase.exec
---@see SQLiteStatment.step
---@see SQLite3.INTERRUPT
function SQLiteDatabase:progress_handler(n, fun, data) end

--- Installs a rollback_hook callback handler. `fun` is a Lua function that is invoked by SQLite3 whenever a transaction is rolled back. This callback receives one argument: the `data` argument used when the callback was installed.
---@param fun fun(data: any)
---@param data any
---@see SQLiteDatabase.commit_hook
---@see SQLiteDatabase.update_hook
function SQLiteDatabase:rollback_hook(fun, data) end

--[[
Creates an iterator that returns the successive rows selected by the SQL statement given in string `sql`. Each call to the iterator returns a table in which the numerical indices 1 to n correspond to the selected columns 1 to n in the database. Here is an example:

	for a in db:rows('SELECT * FROM table') do
		for _,v in ipairs(a) do print(v) end
	end
]]
---@param sql string
---@return fun(): any[]
function SQLiteDatabase:rows(sql) end


--- This function returns the number of database rows that have been modified by INSERT, UPDATE or DELETE statements since the database was opened. This includes UPDATE, INSERT and DELETE statements executed as part of trigger programs. All changes are counted as soon as the statement that produces them is completed by calling either `stmt:reset()` or `stmt:finalize()`.
---@return integer
---@see SQLiteStatment.reset
---@see SQLiteStatment.finalize
function SQLiteDatabase:total_changes() end

--- Installs a trace callback handler. `fun` is a Lua function that is called by SQLite3 just before the evaluation of an SQL statement. This callback receives two arguments: the first is the `data` argument used when the callback was installed; the second is a string with the SQL statement about to be executed.
---@param fun fun(data: any, sql: string)
---@param data any
function SQLiteDatabase:trace(fun, data) end

--- Installs a Data Change Notification Callback handler. `fun` is a Lua function that is invoked by SQLite3 whenever a row is updated, inserted or deleted. This callback receives five arguments: the first is the `data` argument used when the callback was installed; the second is an integer indicating the operation that caused the callback to be invoked (one of `sqlite3.UPDATE`, `sqlite3.INSERT`, or `sqlite3.DELETE`). The third and fourth arguments are the database and table name containing the affected row. The final callback parameter is the rowid of the row. In the case of an update, this is the rowid after the update takes place.
---@param fun fun(data: any, operation: SQLiteAuthorizerActionCode, dbname: string, tablename: string, rowid: integer)
---@param data any
---@see SQLiteDatabase.rollback_hook
---@see SQLiteDatabase.commit_hook
---@see SQLite3.INSERT
---@see SQLite3.UPDATE
---@see SQLite3.DELETE
function SQLiteDatabase:update_hook(fun, data) end

--[[Creates an iterator that returns the successive rows selected by the SQL statement given in string sql. Each call to the iterator returns the values that correspond to the columns in the currently selected row. Here is an example:

	for num1,num2 in db:urows('SELECT * FROM table') do
		print(num1,num2)
	end
]]
---@param sql string
---@return fun(): SQLiteValue?
function SQLiteDatabase:urows(sql) end

return SQLiteDatabase
