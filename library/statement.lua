---@meta _

--- After creating a prepared statement with `db:prepare()` the returned statement object should be used for all further calls in connection with that statement.
---@class SQLiteStatment: userdata
local SQLiteStatment = {}

---@version >5.3
--- Binds `value` to statement parameter `n`. If `value` is a string, it is bound as text, otherwise if it is a number or an integer, then it is bound as either a double or an integer. If it is a boolean, it is bound as 0 or 1. If `value` is nil, any previous binding is removed. The function returns `sqlite3.OK` on success or else a numerical error code.
---@param n integer
---@param value? string | number | integer | boolean
---@return SQLiteStatusCode
function SQLiteStatment:bind(n, value) end

---@version <5.2, JIT
--- Binds `value` to statement parameter `n`. If `value` is a string, it is bound as text, otherwise if it is a number it is bound as a double. If it is a boolean, it is bound as 0 or 1. If `value` is nil, any previous binding is removed. The function returns `sqlite3.OK` on success or else a numerical error code.
---@param n integer
---@param value? string | number | boolean
---@return SQLiteStatusCode
---@see SQLiteStatusCode
function SQLiteStatment:bind(n, value) end

--- Binds string `blob` (which can be a binary string) as a blob to statement parameter `n`. The function returns `sqlite3.OK` on success or else a numerical error code.
---@param n integer
---@param blob string
---@return SQLiteStatusCode
---@see SQLiteStatusCode
function SQLiteStatment:bind_blob(n, blob) end

--- Binds the values in `nametable` to statement parameters. If the statement parameters are named (i.e., of the form ":AAA" or "$AAA") then this function looks for appropriately named fields in nametable; if the statement parameters are not named, it looks for numerical fields 1 to the number of statement parameters. The function returns `sqlite3.OK` on success or else a numerical error code.
---@param nametable table<string | integer, string | number | boolean>
---@return SQLiteStatusCode
---@see SQLiteStatusCode
function SQLiteStatment:bind_names(nametable) end

--[[
Gets the largest statement parameter index in prepared statement stmt. When the statement parameters are of the forms ":AAA" or "?", then they are assigned sequentially increasing numbers beginning with one, so the value returned is the number of parameters. However if the same statement parameter name is used multiple times, each occurrence is given the same number, so the value returned is the number of unique statement parameter names.

If statement parameters of the form "?NNN" are used (where NNN is an integer) then there might be gaps in the numbering and the value returned by this interface is the index of the statement parameter with the largest index value.
]]
---@return integer
function SQLiteStatment:bind_parameter_count() end

--- Gets the name of the `n`-th parameter in prepared statement stmt. Statement parameters of the form ":AAA" or "@AAA" or "$VVV" have a name which is the string ":AAA" or "@AAA" or "$VVV". In other words, the initial ":" or "$" or "@" is included as part of the name. Parameters of the form "?" or "?NNN" have no name. The first bound parameter has an index of 1. If the value `n` is out of range or if the `n`-th parameter is nameless, then nil is returned. The function returns `sqlite3.OK` on success or else a numerical error code.
---@return string?
---@return SQLiteStatusCode
---@see SQLiteStatusCode
function SQLiteStatment:bind_parameter_name(n) end

--- Binds the given values to statement parameters. The function returns `sqlite3.OK` on success or else a numerical error code.
---@param ... string | number | boolean
---@return SQLiteStatusCode
---@see SQLiteStatusCode
function SQLiteStatment:bind_values(...) end

--- Number of columns in the result set returned by the statement, or 0 if the statement does not return data (for example an UPDATE).
---@return integer
function SQLiteStatment:columns() end

--- Frees prepared statement stmt. If the statement was executed successfully, or not executed at all, then `sqlite3.OK` is returned. If execution of the statement failed then an error code is returned.
---@return SQLiteStatusCode
function SQLiteStatment:finalize() end

---@param n integer
---@return string # The name of column `n` in the result set of the statement. (The left-most column is number 0.)
function SQLiteStatment:get_name(n) end

---@return table<string, string> # A table with the names and types of all columns in the current result set of the statement.
function SQLiteStatment:get_named_types() end

---@return table<string, SQLiteValue> # A table with names and values of all columns in the current result row of a query.
function SQLiteStatment:get_named_values() end

---@return string[] # A list of the names of all columns in the result set returned by the statement.
function SQLiteStatment:get_names() end

---@param n integer
---@return string # The type of column `n` in the result set of the statement. (The left-most column is number 0.)
function SQLiteStatment:get_type(n) end

---@return string[] # A list of the types of all columns in the result set returned by the statement.
function SQLiteStatment:get_types() end

---@return string[] # A list of the names of all columns in the result set returned by the statement.
function SQLiteStatment:get_unames() end

---@return string[] # A list of the types of all columns in the result set returned by the statement.
function SQLiteStatment:get_utypes() end

---@return SQLiteValue[] # A list of the values of all columns in the current result row of a query.
function SQLiteStatment:get_uvalues() end

---@param n integer
---@return SQLiteValue # The value of column `n` in the result set of the statement. (The left-most column is number 0.)
function SQLiteStatment:get_value(n) end

---@return SQLiteValue[] # A list of the values of all columns in the result set returned by the statement.
function SQLiteStatment:get_values() end

---@return boolean # Whether or not the statement hasn't been finalized.
function SQLiteStatment:isopen() end

--- Creates an iteragor over the names and values of the result set of the statement. Each iteration returns a table with the names and values for the current row. This is the prepared statement equivelent of `db:nrows()`.
---@return fun(): table<string, string | integer>?
---@see SQLiteDatabase.nrows
function SQLiteStatment:nrows() end

--- Resets the statment so that it is ready to be re-executed. Any statement variables that had values bound to them using the `stmt:bind*()` functions retain their values.
function SQLiteStatment:reset() end

--- Creates an iterator over the values of the result set of the statement. Each iteration returns an array with the values for the current row. This is the prepared statement equivalent of `db:rows()`.
---@return fun(): any[]
---@see SQLiteDatabase.rows
function SQLiteStatment:rows() end

--[[
Evaluates the (next iteration of the) prepared statement. It will return one of the following values:

- `sqlite3.BUSY`: the engine was unable to acquire the locks needed. If the statement is a COMMIT or occurs outside of an explicit transaction, then you can retry the statement. If the statement is not a COMMIT and occurs within a explicit transaction then you should rollback the transaction before continuing.

- `sqlite3.DONE`: the statement has finished executing successfully. `stmt:step()` should not be called again on this statement without first calling `stmt:reset()` to reset the virtual machine back to the initial state.

- `sqlite3.ROW`: this is returned each time a new row of data is ready for processing by the caller. The values may be accessed using the column access functions. `stmt:step()` can be called again to retrieve the next row of data.

- `sqlite3.ERROR`: a run-time error (such as a constraint violation) has occurred. `stmt:step()` should not be called again. More information may be found by calling `db:errmsg()`. A more specific error code can be obtained by calling `stmt:reset()`.

- `sqlite3.MISUSE`: the function was called inappropriately, perhaps because the statement has already been finalized or a previous call to `stmt:step()` has returned `sqlite3.ERROR` or `sqlite3.DONE`.
]]
---@return SQLiteStatusCode
---@see SQLiteStatusCode
function SQLiteStatment:step() end

--- Creates an iterator over the values of the result set of the statement. Each iteration returns the values for the current row. This is the prepared statement equivalent of db:urows().
---@return fun(): (string | number)?
---@see SQLiteDatabase.urows
function SQLiteStatment:urows() end

--- This function returns the rowid of the most recent INSERT into the database corresponding to this statement.
---@see SQLiteDatabase.last_insert_rowid
---@return integer
function SQLiteStatment:last_insert_rowid() end
