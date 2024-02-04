---@meta _

--- A backup userdata is created using `backup = sqlite3.backup_init(...)`. It is then used to step the backup, or inquire about its progress.
---@class SQLiteBackup
local SQLiteBackup = {}

--[[
Returns the status of the backup after stepping `nPages`. It is called one or more times to transfer the data between the two databases.

`backup:step(nPages)` will copy up to nPages pages between the source and destination databases specified by backup userdata. If nPages is negative, all remaining source pages are copied.

If `backup:step(nPages)` successfully copies nPages pages and there are still more pages to be copied, then the function returns `sqlite3.OK`. If `backup:step(nPages)` successfully finishes copying all pages from source to destination, then it returns `sqlite3.DONE`. If an error occurs during the step, then an error code is returned. such as `sqlite3.READONLY`, `sqlite3.NOMEM`, `sqlite3.BUSY`, `sqlite3.LOCKED`, or an `sqlite3.IOERR_XXX` extended error code.
]]
---@param nPages integer # The number of pages to copy, or -1 for all remaining.
---@return SQLiteStatusCode
---@see SQLite3.READONLY
---@see SQLite3.NOMEM
---@see SQLite3.BUSY
---@see SQLite3.LOCKED
---@see SQLite3.IOERR
function SQLiteBackup:step(nPages) end

---@return integer # The number of pages still to be backed up at the conclusion of the most recent step.
---@see SQLiteBackup.step
function SQLiteBackup:remaining() end

---@return integer # The total number of pages in the source database at the conclusion of the most recent step.
---@see SQLiteBackup.step
function SQLiteBackup:pagecount() end

--[[
When `backup:step(nPages)` has returned `sqlite3.DONE`, or when the application wishes to abandon the backup operation, the application should destroy the backup by calling backup:finish(). This releases all resources associated with the backup. If backup:step(nPages) has not yet returned sqlite3.DONE, then any active write-transaction on the destination database is rolled back. After the call, the backup userdata corresponds to a completed backup, and should not be used.

The value returned by `backup:finish()` is `sqlite3.OK` if no errors occurred, regardless or whether or not the backup completed. If an out-of-memory condition or IO error occurred during any prior step on the same backup, then `backup:finish()` returns the corresponding error code.

A return of `sqlite3.BUSY` or `sqlite3.LOCKED` from `backup:step(nPages)` is not a permanent error and does not affect the return value of `backup:finish()`.
]]
---@return SQLiteStatusCode
---@see SQLiteBackup.step
---@see SQLite3.BUSY
---@see SQLite3.LOCKED
function SQLiteBackup:finish() end
