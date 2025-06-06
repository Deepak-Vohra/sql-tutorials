USE University;
GO

DECLARE @TableName NVARCHAR(255);
DECLARE @IndexName NVARCHAR(255);
DECLARE @SQL NVARCHAR(MAX);

DECLARE frag_cursor CURSOR FOR
SELECT 
    QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name),
    QUOTENAME(i.name)
FROM 
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ps
JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
JOIN sys.tables t ON i.object_id = t.object_id
WHERE 
    ps.avg_fragmentation_in_percent > 30
    AND i.type_desc IN ('CLUSTERED', 'NONCLUSTERED');

OPEN frag_cursor;
FETCH NEXT FROM frag_cursor INTO @TableName, @IndexName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER INDEX ' + @IndexName + ' ON ' + @TableName + ' REBUILD WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON);';
    PRINT 'Rebuilding index: ' + @IndexName + ' on table: ' + @TableName;
    EXEC sp_executesql @SQL;

    FETCH NEXT FROM frag_cursor INTO @TableName, @IndexName;
END;

CLOSE frag_cursor;
DEALLOCATE frag_cursor;
