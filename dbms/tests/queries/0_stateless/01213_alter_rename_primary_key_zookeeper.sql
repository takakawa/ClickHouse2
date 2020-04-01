DROP TABLE IF EXISTS table_for_rename_pk;

CREATE TABLE table_for_rename_pk
(
  date Date,
  key1 UInt64,
  key2 UInt64,
  key3 UInt64,
  value1 String,
  value2 String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/table_for_rename_pk', '1')
PARTITION BY date
ORDER BY (key1, pow(key2, 2), key3);

INSERT INTO table_for_rename_pk SELECT toDate('2019-10-01') + number % 3, number, number, number, toString(number), toString(number) from numbers(9);

SELECT key1, value1 FROM table_for_rename_pk WHERE key1 = 1 AND key2 = 1 AND key3 = 1;

ALTER TABLE table_for_rename_pk RENAME COLUMN key1 TO renamed_key1; --{serverError 44}

ALTER TABLE table_for_rename_pk RENAME COLUMN key3 TO renamed_key3; --{serverError 44}

ALTER TABLE table_for_rename_pk RENAME COLUMN key2 TO renamed_key2; --{serverError 44}

DROP TABLE IF EXISTS table_for_rename_pk;

DROP TABLE IF EXISTS table_for_rename_with_primary_key;

CREATE TABLE table_for_rename_with_primary_key
(
  date Date,
  key1 UInt64,
  key2 UInt64,
  key3 UInt64,
  value1 String,
  value2 String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/table_for_rename_pk', '1')
PARTITION BY date
ORDER BY (key1, key2, key3)
PRIMARY KEY (key1, key2);

INSERT INTO table_for_rename_with_primary_key SELECT toDate('2019-10-01') + number % 3, number, number, number, toString(number), toString(number) from numbers(9);

ALTER TABLE table_for_rename_with_primary_key RENAME COLUMN key1 TO renamed_key1; --{serverError 44}

ALTER TABLE table_for_rename_with_primary_key RENAME COLUMN key2 TO renamed_key2; --{serverError 44}

ALTER TABLE table_for_rename_with_primary_key RENAME COLUMN key3 TO renamed_key3; --{serverError 44}


DROP TABLE IF EXISTS table_for_rename_with_primary_key;
