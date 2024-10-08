SELECT id, name
FROM Student
WHERE id IN (1110, 1101, 1617, 1107)
ORDER BY CASE
    WHEN id = 1110 THEN 1
    WHEN id = 1101 THEN 2
    WHEN id = 1617 THEN 3
    WHEN id = 1107 THEN 4
    ELSE 5
END;
