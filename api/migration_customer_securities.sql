-- migration_customer_securities.sql — Sales Petik Profit
-- Mengganti tabel customer_securities skema lama (sekuritas, no_rdn)
-- ke skema lengkap (RDN, rekening pribadi, SID, dll).
--
-- CATATAN: Tabel lama belum berisi data penting, jadi aman di-DROP.
-- Jalankan: mysql -u sales_petikprofit_id -p sales_petikprofit_id < migration_customer_securities.sql
-- =============================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `customer_securities`;

CREATE TABLE `customer_securities` (
  `id`                    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `customer_id`           INT UNSIGNED NOT NULL,
  `sekuritas_name`        VARCHAR(100) NULL DEFAULT 'Maybank',
  `rdn_bank_name`         VARCHAR(100) NULL,
  `rdn_account_no`        VARCHAR(50)  NULL,
  `sec_client_id`         VARCHAR(50)  NULL,
  `sid`                   VARCHAR(50)  NULL,
  `personal_bank_name`    VARCHAR(100) NULL,
  `personal_account_no`   VARCHAR(50)  NULL,
  `personal_account_name` VARCHAR(150) NULL,
  `sort_order`            INT          NOT NULL DEFAULT 0,
  `created_at`            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_custsec_customer (`customer_id`),
  CONSTRAINT fk_custsec_customer FOREIGN KEY (`customer_id`)
    REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
