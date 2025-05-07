SELECT *
FROM boms
WHERE product_code IN (
    SELECT product_code
    FROM boms
    GROUP BY product_code
    HAVING COUNT(*) = 1
);
