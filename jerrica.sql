CREATE TABLE `jerr_PHPCoursework`.`CustomerPhone` (
    `cust_ID` SERIAL NOT NULL AUTO_INCREMENT,
    `last_name` VARCHAR(40) NULL,
    `first_name` VARCHAR(20) not NULL,
    `phone` CHAR(15) NULL,
    PRIMARY KEY (`cust_ID`)
) ENGINE = MyISAM;