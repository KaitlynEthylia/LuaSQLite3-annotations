---@meta _

--- A callback context is available as a parameter inside the callback functions `db:create_aggregate()` and `db:create_function()`. It can be used to get further information about the state of a query.
---@class SQLiteContext
local SQLiteContext = {}

---@return integer # The number of calls to the aggregate step function.
function SQLiteContext:aggregate_count() end

---@return any # the user-definable data field for callback funtions.
function SQLiteContext:get_aggregate_data() end

---@param data any # Set the user-definable data field for callback funtions to `data`.
function SQLiteContext:set_aggregate_data(data) end

--- Sets the result of a callback function to `res`. The type of the result depends on the type of `res` and is either a number or a string or nil. All other values will raise an error message.
---@param res? number | string
function SQLiteContext:result(res) end

--- Sets the result of a callback function to nil.
function SQLiteContext:result_null() end

--- Sets the result of a callback function to the value `number`.
---@param number number
function SQLiteContext:result_number(number) end

--- Sets the result of a callback function to the value `number`.
---@param number number
function SQLiteContext:result_double(number) end

--- Sets the result of a callback function to the integer value in `number`.
---@param number integer
function SQLiteContext:result_int(number) end

--- Sets the result of a callback function to the string in `str`.
---@param str string
function SQLiteContext:result_text(str) end

--- Sets the result of a callback function to the binary string in `blob`.
---@param blob string
function SQLiteContext:result_blob(blob) end

--- Sets the result of a callback function to the error value in `err`.
---@param err SQLiteStatusCode
function SQLiteContext:result_error(err) end

---@return any # `data` parameter given in the call to install the callback function.
---@see SQLiteDatabase.create_aggregate
---@see SQLiteDatabase.create_function
function SQLiteContext:user_data() end
