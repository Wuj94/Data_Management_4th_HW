
# Materialized Views
## deptByCategorySale

DROP TABLE deptByCategorySale;
CREATE TABLE deptByCategorySale
(
    dept_name        varchar(20) not null,
    category_sur_key int         not null,
    category_name    varchar(20) not null,
    sale_timestamp int not null
);

INSERT INTO deptByCategorySale
SELECT D.name, C.name, SUM(S.income), AVG(S.income), COUNT(S.income)
  FROM Department D inner join Category C on D.name = C.dept_name inner join
        SaleCategory SC on SC.category_sur_key = C.category_sur_key inner join
      Sale S on SC.sale_sur_key = S.sale_sur_key
    GROUP BY C.category_sur_key, C.name, D.name;

## On demand refresh stored procedure
DROP PROCEDURE refreshDeptByCategorySale;

DELIMITER $$

CREATE PROCEDURE refreshDeptByCategorySale (
    OUT rc INT
)
BEGIN

  TRUNCATE TABLE deptByCategorySale;

  INSERT INTO deptByCategorySale
  SELECT D.name, C.name, SUM(S.income), AVG(S.income), COUNT(S.income)
  FROM Department D inner join Category C on D.name = C.dept_name inner join
        SaleCategory SC on SC.category_sur_key = C.category_sur_key inner join
      Sale S on SC.sale_sur_key = S.sale_sur_key
    GROUP BY C.category_sur_key, C.name, D.name;

  SET rc = 0;
END;
$$

DELIMITER ;