load data infile 'customer.tbl' into table customer fields terminated by '|' lines terminated by '|\n';
load data infile 'supplier.tbl' into table supplier fields terminated by '|' lines terminated by '|\n';
load data infile 'part.tbl' into table part fields terminated by '|' lines terminated by '|\n';
load data infile 'date.tbl' into table dim_date fields terminated by '|' lines terminated by '|\n';
load data infile 'lineorder.tbl' into table lineorder fields terminated by '|' lines terminated by '|\n';
