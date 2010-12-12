SET names utf8;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';


-- -----------------------------------------------------
-- Table `regions`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `regions` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `assigned_budget` DECIMAL(10) NULL ,
  `is_central` TINYINT(1)  NULL DEFAULT false ,
  `phone` VARCHAR(45) NULL ,
  `city` VARCHAR(45) NULL ,
  `address` VARCHAR(45) NULL ,
  `zip` VARCHAR(45) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouses`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `warehouses` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `region_id` INT NOT NULL ,
  `is_central` TINYINT(1)  NULL DEFAULT false ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_warehouses_regions` (`region_id` ASC) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  CONSTRAINT `fk_warehouses_regions`
    FOREIGN KEY (`region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `roles`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `roles` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `full_name` VARCHAR(45) NULL ,
  `authorizable_id` INT NULL ,
  `authorizable_type` VARCHAR(45) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `users` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `login` VARCHAR(45) NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  `email` VARCHAR(45) NOT NULL ,
  `crypted_password` VARCHAR(45) NULL ,
  `salt` VARCHAR(45) NULL ,
  `remember_token` VARCHAR(45) NULL ,
  `remember_token_expires_at` DATETIME NULL ,
  `region_id` INT NULL ,
  `mobile` VARCHAR(45) NULL ,
  `phone` VARCHAR(45) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_users_regions1` (`region_id` ASC) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  UNIQUE INDEX `login_UNIQUE` (`login` ASC) ,
  CONSTRAINT `fk_users_regions1`
    FOREIGN KEY (`region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `roles_users`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `roles_users` (
  `user_id` INT NOT NULL AUTO_INCREMENT ,
  `role_id` INT NOT NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`user_id`, `role_id`) ,
  INDEX `fk_users_has_roles_roles1` (`role_id` ASC) ,
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) ,
  CONSTRAINT `fk_users_has_roles_users1`
    FOREIGN KEY (`user_id` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_has_roles_roles1`
    FOREIGN KEY (`role_id` )
    REFERENCES `roles` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `campaigns`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `campaigns` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `description` VARCHAR(45) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `catalogs`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `catalogs` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `campaign_id` INT NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  `order_startdate` DATETIME NOT NULL ,
  `order_enddate` DATETIME NOT NULL ,
  `memo` TEXT NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_catalogs_campaigns1` (`campaign_id` ASC) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  CONSTRAINT `fk_catalogs_campaigns1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `campaigns` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `materials`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `materials` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `cost` VARCHAR(45) NULL COMMENT 'production cost\n' ,
  `itemno` VARCHAR(45) NULL COMMENT '物料编号' ,
  `description` VARCHAR(45) NULL ,
  `spec` VARCHAR(45) NULL COMMENT '规格' ,
  `usage` VARCHAR(45) NULL COMMENT '物料使用方法' ,
  `image` VARCHAR(45) NULL COMMENT '图片' ,
  `memo` TEXT NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `catalogs_materials`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `catalogs_materials` (
  `catalog_id` INT NOT NULL AUTO_INCREMENT ,
  `material_id` INT NOT NULL ,
  `price` DECIMAL(10) NOT NULL COMMENT 'internal purchase price' ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`catalog_id`, `material_id`) ,
  INDEX `fk_catalogs_has_materials_materials1` (`material_id` ASC) ,
  UNIQUE INDEX `catalog_id_UNIQUE` (`catalog_id` ASC) ,
  CONSTRAINT `fk_catalogs_has_materials_catalogs1`
    FOREIGN KEY (`catalog_id` )
    REFERENCES `catalogs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_catalogs_has_materials_materials1`
    FOREIGN KEY (`material_id` )
    REFERENCES `materials` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `salesreps`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `salesreps` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `region_id` INT NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  `email` VARCHAR(45) NULL ,
  `mobile` VARCHAR(45) NULL ,
  `phone` VARCHAR(45) NULL ,
  `memo` TEXT NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_salesreps_regions1` (`region_id` ASC) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  CONSTRAINT `fk_salesreps_regions1`
    FOREIGN KEY (`region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `order_statuses`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `order_statuses` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `description` VARCHAR(45) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `orders`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `orders` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `campaign_id` INT NOT NULL ,
  `catalog_id` INT NOT NULL ,
  `region_id` INT NOT NULL ,
  `amount` DECIMAL(10) NOT NULL DEFAULT 0 COMMENT 'total amount of budget required' ,
  `order_status_id` INT NOT NULL ,
  `memo` TEXT NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_orders_campaigns1` (`campaign_id` ASC) ,
  INDEX `fk_orders_catalogs1` (`catalog_id` ASC) ,
  INDEX `fk_orders_regions1` (`region_id` ASC) ,
  INDEX `fk_orders_order_statuses1` (`order_status_id` ASC) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  CONSTRAINT `fk_orders_campaigns1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `campaigns` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_catalogs1`
    FOREIGN KEY (`catalog_id` )
    REFERENCES `catalogs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_regions1`
    FOREIGN KEY (`region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_order_statuses1`
    FOREIGN KEY (`order_status_id` )
    REFERENCES `order_statuses` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `order_line_item_raws`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `order_line_item_raws` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `order_id` INT NOT NULL ,
  `material_id` INT NOT NULL ,
  `region_id` INT NOT NULL ,
  `salesrep_id` INT NOT NULL ,
  `quantity` INT NOT NULL DEFAULT 0 ,
  `unit_price` DECIMAL(10) NOT NULL DEFAULT 0 ,
  `subtotal` DECIMAL(10) NOT NULL DEFAULT 0 ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  INDEX `fk_materials_has_orders_orders1` (`order_id` ASC) ,
  INDEX `fk_order_line_items_regions1` (`region_id` ASC) ,
  INDEX `fk_order_line_items_salesreps1` (`salesrep_id` ASC) ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  CONSTRAINT `fk_materials_has_orders_materials1`
    FOREIGN KEY (`material_id` )
    REFERENCES `materials` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_materials_has_orders_orders1`
    FOREIGN KEY (`order_id` )
    REFERENCES `orders` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_line_items_regions1`
    FOREIGN KEY (`region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_line_items_salesreps1`
    FOREIGN KEY (`salesrep_id` )
    REFERENCES `salesreps` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `order_line_item_adjusteds`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `order_line_item_adjusteds` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `order_id` INT NOT NULL ,
  `material_id` INT NOT NULL ,
  `region_id` INT NOT NULL ,
  `quantity_collected` INT NOT NULL COMMENT 'quanity_collected = (select sum(quantity) from order_line_items_raw group by material_id)\n\nrough sql' ,
  `quantity_adjust` INT NOT NULL DEFAULT 0 COMMENT 'manual adjustment' ,
  `quantity_total` INT NOT NULL DEFAULT 0 COMMENT 'quantity_total = quantity_collected + quantity_adjust' ,
  `unit_price` DECIMAL(10) NOT NULL DEFAULT 0 ,
  `subtotal` DECIMAL(10) NOT NULL DEFAULT 0 ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_orders_line_item_adjusted_orders1` (`order_id` ASC) ,
  INDEX `fk_orders_line_item_adjusted_materials1` (`material_id` ASC) ,
  INDEX `fk_orders_line_item_adjusted_regions1` (`region_id` ASC) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  CONSTRAINT `fk_orders_line_item_adjusted_orders1`
    FOREIGN KEY (`order_id` )
    REFERENCES `orders` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_line_item_adjusted_materials1`
    FOREIGN KEY (`material_id` )
    REFERENCES `materials` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_line_item_adjusted_regions1`
    FOREIGN KEY (`region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `productions`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `productions` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `campaign_id` INT NOT NULL ,
  `catalog_id` INT NOT NULL ,
  `locked` TINYINT(1)  NOT NULL DEFAULT false ,
  `memo` TEXT NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  INDEX `fk_production_sheets_campaigns1` (`campaign_id` ASC) ,
  INDEX `fk_production_sheets_catalogs1` (`catalog_id` ASC) ,
  CONSTRAINT `fk_production_sheets_campaigns1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `campaigns` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_production_sheets_catalogs1`
    FOREIGN KEY (`catalog_id` )
    REFERENCES `catalogs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `production_line_items`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `production_line_items` (
  `id` INT NOT NULL ,
  `production_id` INT NOT NULL ,
  `material_id` INT NOT NULL ,
  `quantity_collected` INT NOT NULL DEFAULT 0 ,
  `quantity_adjusted` INT NOT NULL DEFAULT 0 ,
  `quantity_total` INT NOT NULL DEFAULT 0 ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_production_line_items_materials1` (`material_id` ASC) ,
  INDEX `fk_production_line_items_production1` (`production_id` ASC) ,
  CONSTRAINT `fk_production_line_items_materials1`
    FOREIGN KEY (`material_id` )
    REFERENCES `materials` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_production_line_items_production1`
    FOREIGN KEY (`production_id` )
    REFERENCES `productions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventories`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `inventories` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `material_id` INT NOT NULL ,
  `quantity` INT NULL ,
  `region_id` INT NOT NULL COMMENT 'owner region' ,
  `warehouse_id` INT NOT NULL COMMENT 'physical location of the inventory' ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_inventories_materials1` (`material_id` ASC) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  INDEX `fk_inventories_regions1` (`region_id` ASC) ,
  INDEX `fk_inventories_warehouses1` (`warehouse_id` ASC) ,
  CONSTRAINT `fk_inventories_materials1`
    FOREIGN KEY (`material_id` )
    REFERENCES `materials` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventories_regions1`
    FOREIGN KEY (`region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventories_warehouses1`
    FOREIGN KEY (`warehouse_id` )
    REFERENCES `warehouses` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `transfer_types`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `transfer_types` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `description` VARCHAR(45) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `transfers`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `transfers` (
  `id` INT NOT NULL ,
  `from_region_id` INT NULL ,
  `to_region_id` INT NOT NULL ,
  `from_warehouse_id` INT NULL ,
  `to_warehouse_id` INT NOT NULL ,
  `amount` DECIMAL(10) NOT NULL DEFAULT 0 ,
  `transfer_type_id` INT NOT NULL ,
  `memo` TEXT NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_transfers_regions1` (`from_region_id` ASC) ,
  INDEX `fk_transfers_regions2` (`to_region_id` ASC) ,
  INDEX `fk_transfers_warehouses1` (`from_warehouse_id` ASC) ,
  INDEX `fk_transfers_warehouses2` (`to_warehouse_id` ASC) ,
  INDEX `fk_transfers_transfer_types1` (`transfer_type_id` ASC) ,
  CONSTRAINT `fk_transfers_regions1`
    FOREIGN KEY (`from_region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transfers_regions2`
    FOREIGN KEY (`to_region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transfers_warehouses1`
    FOREIGN KEY (`from_warehouse_id` )
    REFERENCES `warehouses` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transfers_warehouses2`
    FOREIGN KEY (`to_warehouse_id` )
    REFERENCES `warehouses` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transfers_transfer_types1`
    FOREIGN KEY (`transfer_type_id` )
    REFERENCES `transfer_types` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `transfer_line_items`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `transfer_line_items` (
  `id` INT NOT NULL ,
  `transfer_id` INT NOT NULL ,
  `region_id` INT NOT NULL ,
  `warehouse_id` INT NOT NULL ,
  `salesrep_id` INT NULL ,
  `material_id` INT NOT NULL ,
  `quantity` INT NOT NULL DEFAULT 0 ,
  `unit_price` DECIMAL(10) NOT NULL DEFAULT 10 ,
  `subtotal` DECIMAL(10) NOT NULL DEFAULT 0 ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_transfer_line_items_transfers1` (`transfer_id` ASC) ,
  INDEX `fk_transfer_line_items_regions1` (`region_id` ASC) ,
  INDEX `fk_transfer_line_items_warehouses1` (`warehouse_id` ASC) ,
  INDEX `fk_transfer_line_items_materials1` (`material_id` ASC) ,
  INDEX `fk_transfer_line_items_salesreps1` (`salesrep_id` ASC) ,
  CONSTRAINT `fk_transfer_line_items_transfers1`
    FOREIGN KEY (`transfer_id` )
    REFERENCES `transfers` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transfer_line_items_regions1`
    FOREIGN KEY (`region_id` )
    REFERENCES `regions` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transfer_line_items_warehouses1`
    FOREIGN KEY (`warehouse_id` )
    REFERENCES `warehouses` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transfer_line_items_materials1`
    FOREIGN KEY (`material_id` )
    REFERENCES `materials` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transfer_line_items_salesreps1`
    FOREIGN KEY (`salesrep_id` )
    REFERENCES `salesreps` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `regions`
-- -----------------------------------------------------
SET AUTOCOMMIT=0;
INSERT INTO regions (`id`, `name`, `assigned_budget`, `is_central`, `phone`, `city`, `address`, `zip`, `created_at`, `updated_at`) VALUES ('1', '总部', NULL, '1', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO regions (`id`, `name`, `assigned_budget`, `is_central`, `phone`, `city`, `address`, `zip`, `created_at`, `updated_at`) VALUES ('2', '北京大区', NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO regions (`id`, `name`, `assigned_budget`, `is_central`, `phone`, `city`, `address`, `zip`, `created_at`, `updated_at`) VALUES ('3', '上海大区', NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO regions (`id`, `name`, `assigned_budget`, `is_central`, `phone`, `city`, `address`, `zip`, `created_at`, `updated_at`) VALUES ('4', '广州大区', NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO regions (`id`, `name`, `assigned_budget`, `is_central`, `phone`, `city`, `address`, `zip`, `created_at`, `updated_at`) VALUES ('5', '市场部', NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `warehouses`
-- -----------------------------------------------------
SET AUTOCOMMIT=0;
INSERT INTO warehouses (`id`, `name`, `region_id`, `is_central`, `created_at`, `updated_at`) VALUES ('1', '中央仓库', '1', '1', NULL, NULL);
INSERT INTO warehouses (`id`, `name`, `region_id`, `is_central`, `created_at`, `updated_at`) VALUES ('2', '上海仓库', '2', '0', NULL, NULL);
INSERT INTO warehouses (`id`, `name`, `region_id`, `is_central`, `created_at`, `updated_at`) VALUES ('3', '北京仓库', '3', '0', NULL, NULL);
INSERT INTO warehouses (`id`, `name`, `region_id`, `is_central`, `created_at`, `updated_at`) VALUES ('4', '广州仓库', '4', '0', NULL, NULL);
INSERT INTO warehouses (`id`, `name`, `region_id`, `is_central`, `created_at`, `updated_at`) VALUES ('5', '市场部', '5', '0', NULL, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `roles`
-- -----------------------------------------------------
SET AUTOCOMMIT=0;
INSERT INTO roles (`id`, `name`, `full_name`, `authorizable_id`, `authorizable_type`, `created_at`, `updated_at`) VALUES ('1', 'ADMIN', 'Administrator', NULL, NULL, NULL, NULL);
INSERT INTO roles (`id`, `name`, `full_name`, `authorizable_id`, `authorizable_type`, `created_at`, `updated_at`) VALUES ('2', 'MM', 'Marketing Manager', NULL, NULL, NULL, NULL);
INSERT INTO roles (`id`, `name`, `full_name`, `authorizable_id`, `authorizable_type`, `created_at`, `updated_at`) VALUES ('3', 'PM', 'Project Manager', NULL, NULL, NULL, NULL);
INSERT INTO roles (`id`, `name`, `full_name`, `authorizable_id`, `authorizable_type`, `created_at`, `updated_at`) VALUES ('4', 'WA', 'Warehouse Admin', NULL, NULL, NULL, NULL);
INSERT INTO roles (`id`, `name`, `full_name`, `authorizable_id`, `authorizable_type`, `created_at`, `updated_at`) VALUES ('5', 'RM', 'Regional Manager', NULL, NULL, NULL, NULL);
INSERT INTO roles (`id`, `name`, `full_name`, `authorizable_id`, `authorizable_type`, `created_at`, `updated_at`) VALUES ('6', 'RC', 'Regional Coordinator', NULL, NULL, NULL, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `order_statuses`
-- -----------------------------------------------------
SET AUTOCOMMIT=0;
INSERT INTO order_statuses (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES ('1', '待审批', '等待区域经理审批', NULL, NULL);
INSERT INTO order_statuses (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES ('2', '已提交', '已提交总部，等待总部审核', NULL, NULL);
INSERT INTO order_statuses (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES ('3', '预定接受', '总部接受订单', NULL, NULL);
INSERT INTO order_statuses (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES ('4', '预定拒绝', '总部拒绝订单', NULL, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `transfer_types`
-- -----------------------------------------------------
SET AUTOCOMMIT=0;
INSERT INTO transfer_types (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES ('1', '总库入库', '总仓库入库', NULL, NULL);
INSERT INTO transfer_types (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES ('2', '物理库存转移', '所有权及仓储转移', NULL, NULL);
INSERT INTO transfer_types (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES ('3', '虚拟库存转移', '所有权变更但是仓储不变化', NULL, NULL);
INSERT INTO transfer_types (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES ('4', '物料申领', '物料申领，库存减少', NULL, NULL);

COMMIT;
