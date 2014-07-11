# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: 192.168.0.240 (MySQL 5.0.95)
# Database: ddz
# Generation Time: 2014-07-11 08:51:28 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table accept_message_users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `accept_message_users`;

CREATE TABLE `accept_message_users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `mobile` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table active_admin_comments
# ------------------------------------------------------------

DROP TABLE IF EXISTS `active_admin_comments`;

CREATE TABLE `active_admin_comments` (
  `id` int(11) NOT NULL auto_increment,
  `namespace` varchar(255) collate utf8_unicode_ci default NULL,
  `body` text collate utf8_unicode_ci,
  `resource_id` varchar(255) collate utf8_unicode_ci NOT NULL,
  `resource_type` varchar(255) collate utf8_unicode_ci NOT NULL,
  `author_id` int(11) default NULL,
  `author_type` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_active_admin_comments_on_namespace` (`namespace`),
  KEY `index_active_admin_comments_on_author_type_and_author_id` (`author_type`,`author_id`),
  KEY `index_active_admin_comments_on_resource_type_and_resource_id` (`resource_type`,`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table activities
# ------------------------------------------------------------

DROP TABLE IF EXISTS `activities`;

CREATE TABLE `activities` (
  `id` int(11) NOT NULL auto_increment,
  `week_date` int(11) default NULL,
  `activity_name` varchar(255) collate utf8_unicode_ci default NULL,
  `activity_content` varchar(255) collate utf8_unicode_ci default NULL,
  `activity_object` varchar(255) collate utf8_unicode_ci default NULL,
  `activity_memo` varchar(255) collate utf8_unicode_ci default NULL,
  `activity_model` varchar(255) collate utf8_unicode_ci default NULL,
  `activity_parm` varchar(255) collate utf8_unicode_ci default NULL,
  `activity_type` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table admin_users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `admin_users`;

CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `encrypted_password` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `reset_password_token` varchar(255) collate utf8_unicode_ci default NULL,
  `reset_password_sent_at` datetime default NULL,
  `remember_created_at` datetime default NULL,
  `sign_in_count` int(11) NOT NULL default '0',
  `current_sign_in_at` datetime default NULL,
  `last_sign_in_at` datetime default NULL,
  `current_sign_in_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `last_sign_in_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_admin_users_on_email` (`email`),
  UNIQUE KEY `index_admin_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table apk_signature_public_keys
# ------------------------------------------------------------

DROP TABLE IF EXISTS `apk_signature_public_keys`;

CREATE TABLE `apk_signature_public_keys` (
  `id` int(11) NOT NULL auto_increment,
  `code` int(11) default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `public_key` text collate utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table apk_updates
# ------------------------------------------------------------

DROP TABLE IF EXISTS `apk_updates`;

CREATE TABLE `apk_updates` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `version` varchar(255) collate utf8_unicode_ci default NULL,
  `md5` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `url` varchar(255) collate utf8_unicode_ci default NULL,
  `update_flag` int(11) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table app_error_acceptors
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_error_acceptors`;

CREATE TABLE `app_error_acceptors` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table app_errors
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_errors`;

CREATE TABLE `app_errors` (
  `id` int(11) NOT NULL auto_increment,
  `raise_time` datetime default NULL,
  `appid` int(11) default NULL,
  `appname` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `net_type` varchar(255) default NULL,
  `model` varchar(255) default NULL,
  `manufactory` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `exception_info` varchar(255) default NULL,
  `app_bulid` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table ban_words
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ban_words`;

CREATE TABLE `ban_words` (
  `id` int(11) NOT NULL auto_increment,
  `word` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `zz_word` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table bankrupts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `bankrupts`;

CREATE TABLE `bankrupts` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `date` varchar(255) collate utf8_unicode_ci default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table blacklists
# ------------------------------------------------------------

DROP TABLE IF EXISTS `blacklists`;

CREATE TABLE `blacklists` (
  `id` int(11) NOT NULL auto_increment,
  `black_user` int(11) default NULL,
  `imsi` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table cities
# ------------------------------------------------------------

DROP TABLE IF EXISTS `cities`;

CREATE TABLE `cities` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table ddz_partners
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ddz_partners`;

CREATE TABLE `ddz_partners` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) collate utf8_unicode_ci default NULL,
  `product_id` varchar(255) collate utf8_unicode_ci default NULL,
  `enable` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sms_content` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table ddz_sheets
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ddz_sheets`;

CREATE TABLE `ddz_sheets` (
  `id` int(11) NOT NULL auto_increment,
  `date` varchar(255) collate utf8_unicode_ci default NULL,
  `game_id` varchar(255) collate utf8_unicode_ci default NULL,
  `day_max_online` int(11) default '0',
  `avg_hour_online` int(11) default NULL,
  `day_login_user` int(11) default NULL,
  `total_online_time` int(11) default NULL,
  `total_user` int(11) default NULL,
  `add_day_user` int(11) default NULL,
  `total_exp_user` int(11) default NULL,
  `day_exp_user` int(11) default NULL,
  `add_exp_user` int(11) default NULL,
  `total_day_money` float default NULL,
  `arpu` float default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `platform` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table delayed_jobs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `delayed_jobs`;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL auto_increment,
  `priority` int(11) default '0',
  `attempts` int(11) default '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime default NULL,
  `locked_at` datetime default NULL,
  `failed_at` datetime default NULL,
  `locked_by` varchar(255) default NULL,
  `queue` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table dialogue_count_201308
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dialogue_count_201308`;

CREATE TABLE `dialogue_count_201308` (
  `id` int(11) NOT NULL auto_increment,
  `dialogue_id` int(11) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table dialogue_count_201309
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dialogue_count_201309`;

CREATE TABLE `dialogue_count_201309` (
  `id` int(11) NOT NULL auto_increment,
  `dialogue_id` int(11) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table dialogue_count_201310
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dialogue_count_201310`;

CREATE TABLE `dialogue_count_201310` (
  `id` int(11) NOT NULL auto_increment,
  `dialogue_id` int(11) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table dialogue_count_201311
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dialogue_count_201311`;

CREATE TABLE `dialogue_count_201311` (
  `id` int(11) NOT NULL auto_increment,
  `dialogue_id` int(11) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table dialogue_count_201406
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dialogue_count_201406`;

CREATE TABLE `dialogue_count_201406` (
  `id` int(11) NOT NULL auto_increment,
  `dialogue_id` int(11) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table dialogue_counts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dialogue_counts`;

CREATE TABLE `dialogue_counts` (
  `id` int(11) NOT NULL auto_increment,
  `dialogue_id` int(11) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table dialogues
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dialogues`;

CREATE TABLE `dialogues` (
  `id` int(11) NOT NULL auto_increment,
  `content` varchar(255) collate utf8_unicode_ci default NULL,
  `vip_flag` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table every_hour_online_users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `every_hour_online_users`;

CREATE TABLE `every_hour_online_users` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table feedbacks
# ------------------------------------------------------------

DROP TABLE IF EXISTS `feedbacks`;

CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `brand` varchar(255) collate utf8_unicode_ci default NULL,
  `model` varchar(255) collate utf8_unicode_ci default NULL,
  `display` varchar(255) collate utf8_unicode_ci default NULL,
  `os_release` varchar(255) collate utf8_unicode_ci default NULL,
  `content` text collate utf8_unicode_ci,
  `manufactory` varchar(255) collate utf8_unicode_ci default NULL,
  `string` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table game_match_logs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_match_logs`;

CREATE TABLE `game_match_logs` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table game_product_items
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_product_items`;

CREATE TABLE `game_product_items` (
  `id` int(11) NOT NULL auto_increment,
  `game_id` int(11) default NULL,
  `item_name` varchar(255) collate utf8_unicode_ci default NULL,
  `item_note` varchar(255) collate utf8_unicode_ci default NULL,
  `cate_module` varchar(255) collate utf8_unicode_ci default NULL,
  `using_point` varchar(255) collate utf8_unicode_ci default NULL,
  `beans` int(11) default NULL,
  `item_feature` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `icon` varchar(255) collate utf8_unicode_ci default '0',
  `item_sort` int(11) default '0',
  `item_type` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table game_product_sell_counts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_product_sell_counts`;

CREATE TABLE `game_product_sell_counts` (
  `id` int(11) NOT NULL auto_increment,
  `game_product_id` int(11) default NULL,
  `sell_count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `cp_sell_count` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table game_products
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_products`;

CREATE TABLE `game_products` (
  `id` int(11) NOT NULL auto_increment,
  `game_id` int(11) default NULL,
  `product_name` varchar(255) collate utf8_unicode_ci default NULL,
  `product_type` int(11) default NULL,
  `price` varchar(255) collate utf8_unicode_ci default NULL,
  `sale_limit` int(11) default NULL,
  `note` varchar(255) collate utf8_unicode_ci default NULL,
  `state` int(11) default '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `icon` varchar(255) collate utf8_unicode_ci default '0',
  `product_sort` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table game_room_urls
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_room_urls`;

CREATE TABLE `game_room_urls` (
  `id` int(11) NOT NULL auto_increment,
  `domain_name` varchar(255) default NULL,
  `port` varchar(255) default NULL,
  `status` int(11) default NULL,
  `game_room_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table game_rooms
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_rooms`;

CREATE TABLE `game_rooms` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `ante` int(11) default NULL,
  `min_qualification` int(11) default NULL,
  `max_qualification` int(11) default NULL,
  `status` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `fake_online_count` int(11) default '0',
  `limit_online_count` int(11) default '0',
  `room_type` int(11) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table game_score_infos
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_score_infos`;

CREATE TABLE `game_score_infos` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `score` int(11) default '0',
  `win_count` int(11) default '0',
  `lost_count` int(11) default '0',
  `flee_count` int(11) default '0',
  `all_count` int(11) default '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table game_shop_cates
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_shop_cates`;

CREATE TABLE `game_shop_cates` (
  `id` int(11) NOT NULL auto_increment,
  `cate_id` int(11) default NULL,
  `cate_name` varchar(255) default NULL,
  `game_id` int(11) default NULL,
  `price` varchar(255) default NULL,
  `sale_count` varchar(255) default NULL,
  `cate_note` varchar(255) default NULL,
  `cate_valid` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `used_limit` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table game_teaches
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_teaches`;

CREATE TABLE `game_teaches` (
  `id` int(11) NOT NULL auto_increment,
  `content` varchar(255) collate utf8_unicode_ci default NULL,
  `moment` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table game_user_cates
# ------------------------------------------------------------

DROP TABLE IF EXISTS `game_user_cates`;

CREATE TABLE `game_user_cates` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `cate_id` int(11) default NULL,
  `game_id` int(11) default NULL,
  `cate_count` int(11) default '0',
  `used_flag` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gift_bag_id` int(11) default NULL,
  `treasure_box_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table get_mobile_charge_logs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `get_mobile_charge_logs`;

CREATE TABLE `get_mobile_charge_logs` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table get_salaries
# ------------------------------------------------------------

DROP TABLE IF EXISTS `get_salaries`;

CREATE TABLE `get_salaries` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `date` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table gift_bags
# ------------------------------------------------------------

DROP TABLE IF EXISTS `gift_bags`;

CREATE TABLE `gift_bags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `price` varchar(255) default NULL,
  `beans` int(11) default NULL,
  `sale_limit` int(11) default NULL,
  `sale_count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `note` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table gift_maps
# ------------------------------------------------------------

DROP TABLE IF EXISTS `gift_maps`;

CREATE TABLE `gift_maps` (
  `id` int(11) NOT NULL auto_increment,
  `gift_bag_id` int(11) default NULL,
  `game_shop_cate_id` int(11) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table kefu_pay_mobiles
# ------------------------------------------------------------

DROP TABLE IF EXISTS `kefu_pay_mobiles`;

CREATE TABLE `kefu_pay_mobiles` (
  `id` int(11) NOT NULL auto_increment,
  `mobile` varchar(255) collate utf8_unicode_ci default NULL,
  `pay_type` varchar(255) collate utf8_unicode_ci default NULL,
  `status` int(11) default NULL,
  `cause` text collate utf8_unicode_ci,
  `picture_path` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table levels
# ------------------------------------------------------------

DROP TABLE IF EXISTS `levels`;

CREATE TABLE `levels` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `min_score` int(11) default NULL,
  `max_score` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table login_logs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs`;

CREATE TABLE `login_logs` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201304
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201304`;

CREATE TABLE `login_logs_201304` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201305
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201305`;

CREATE TABLE `login_logs_201305` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201306
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201306`;

CREATE TABLE `login_logs_201306` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201307
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201307`;

CREATE TABLE `login_logs_201307` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201308
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201308`;

CREATE TABLE `login_logs_201308` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201309
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201309`;

CREATE TABLE `login_logs_201309` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201310
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201310`;

CREATE TABLE `login_logs_201310` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201311
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201311`;

CREATE TABLE `login_logs_201311` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201312
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201312`;

CREATE TABLE `login_logs_201312` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201401
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201401`;

CREATE TABLE `login_logs_201401` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201402
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201402`;

CREATE TABLE `login_logs_201402` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201403
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201403`;

CREATE TABLE `login_logs_201403` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201404
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201404`;

CREATE TABLE `login_logs_201404` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201405
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201405`;

CREATE TABLE `login_logs_201405` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201406
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201406`;

CREATE TABLE `login_logs_201406` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table login_logs_201407
# ------------------------------------------------------------

DROP TABLE IF EXISTS `login_logs_201407`;

CREATE TABLE `login_logs_201407` (
  `id` int(11) NOT NULL auto_increment,
  `appid` varchar(255) default NULL,
  `string` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `nick_name` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `city_id` varchar(255) default NULL,
  `integer` varchar(255) default NULL,
  `province_id` varchar(255) default NULL,
  `user_id` varchar(255) default NULL,
  `login_ip` varchar(255) default NULL,
  `login_time` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table match_descs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `match_descs`;

CREATE TABLE `match_descs` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table match_system_settings
# ------------------------------------------------------------

DROP TABLE IF EXISTS `match_system_settings`;

CREATE TABLE `match_system_settings` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table msisdn_regions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `msisdn_regions`;

CREATE TABLE `msisdn_regions` (
  `id` int(11) NOT NULL auto_increment,
  `province_id` int(11) default NULL,
  `city_id` int(11) default NULL,
  `operator` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_msisdn_regions_on_province_id` (`province_id`),
  KEY `index_msisdn_regions_on_city_id` (`city_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table partmers
# ------------------------------------------------------------

DROP TABLE IF EXISTS `partmers`;

CREATE TABLE `partmers` (
  `id` int(11) NOT NULL auto_increment,
  `appid` int(11) default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `link_man` varchar(255) collate utf8_unicode_ci default NULL,
  `telephone` varchar(255) collate utf8_unicode_ci default NULL,
  `address` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `email` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table partner_month_accounts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `partner_month_accounts`;

CREATE TABLE `partner_month_accounts` (
  `id` int(11) NOT NULL auto_increment,
  `appid` int(11) default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `date` varchar(255) collate utf8_unicode_ci default NULL,
  `account` float default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table partner_sheets
# ------------------------------------------------------------

DROP TABLE IF EXISTS `partner_sheets`;

CREATE TABLE `partner_sheets` (
  `id` int(11) NOT NULL auto_increment,
  `date` varchar(255) collate utf8_unicode_ci default NULL,
  `appid` int(11) default NULL,
  `add_count` int(11) default '0',
  `login_count` int(11) default '0',
  `consume_count` float default '0',
  `month` float default '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `total_users_count` int(11) default '0',
  `one_day_left_user` int(11) default '0',
  `three_day_left_user` int(11) default '0',
  `seven_day_left_user` int(11) default '0',
  `email` varchar(255) collate utf8_unicode_ci default NULL,
  `one_day_left_user_rate` int(11) default '0',
  `three_day_left_user_rate` int(11) default '0',
  `seven_day_left_user_rate` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table product_product_items
# ------------------------------------------------------------

DROP TABLE IF EXISTS `product_product_items`;

CREATE TABLE `product_product_items` (
  `id` int(11) NOT NULL auto_increment,
  `game_product_id` int(11) default NULL,
  `game_product_item_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `count` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table prop_consume_code_for_astepex
# ------------------------------------------------------------

DROP TABLE IF EXISTS `prop_consume_code_for_astepex`;

CREATE TABLE `prop_consume_code_for_astepex` (
  `id` int(11) NOT NULL auto_increment,
  `game_product_id` int(11) default NULL,
  `consume_code` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table prop_consume_code_for_astepexes
# ------------------------------------------------------------

DROP TABLE IF EXISTS `prop_consume_code_for_astepexes`;

CREATE TABLE `prop_consume_code_for_astepexes` (
  `id` int(11) NOT NULL auto_increment,
  `game_product_id` int(11) default NULL,
  `consume_code` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table prop_consume_code_for_asteps
# ------------------------------------------------------------

DROP TABLE IF EXISTS `prop_consume_code_for_asteps`;

CREATE TABLE `prop_consume_code_for_asteps` (
  `id` int(11) NOT NULL auto_increment,
  `consume_code` varchar(255) collate utf8_unicode_ci default NULL,
  `type` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `game_product_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table prop_consume_code_for_skies
# ------------------------------------------------------------

DROP TABLE IF EXISTS `prop_consume_code_for_skies`;

CREATE TABLE `prop_consume_code_for_skies` (
  `id` int(11) NOT NULL auto_increment,
  `consume_code` int(11) default NULL,
  `game_product_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table prop_consume_code_for_unicoms
# ------------------------------------------------------------

DROP TABLE IF EXISTS `prop_consume_code_for_unicoms`;

CREATE TABLE `prop_consume_code_for_unicoms` (
  `id` int(11) NOT NULL auto_increment,
  `consume_code` varchar(255) collate utf8_unicode_ci default NULL,
  `type` int(11) default NULL,
  `game_product_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table prop_consume_code_for_wiipays
# ------------------------------------------------------------

DROP TABLE IF EXISTS `prop_consume_code_for_wiipays`;

CREATE TABLE `prop_consume_code_for_wiipays` (
  `id` int(11) NOT NULL auto_increment,
  `game_product_id` int(11) default NULL,
  `consume_code` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table prop_consume_codes
# ------------------------------------------------------------

DROP TABLE IF EXISTS `prop_consume_codes`;

CREATE TABLE `prop_consume_codes` (
  `id` int(11) NOT NULL auto_increment,
  `game_product_id` int(11) default NULL,
  `consume_code` varchar(255) collate utf8_unicode_ci default NULL,
  `operator_type` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table provinces
# ------------------------------------------------------------

DROP TABLE IF EXISTS `provinces`;

CREATE TABLE `provinces` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table purchase_request_records
# ------------------------------------------------------------

DROP TABLE IF EXISTS `purchase_request_records`;

CREATE TABLE `purchase_request_records` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `user_product_id` int(11) default NULL,
  `game_product_id` int(11) default NULL,
  `product_count` int(11) default NULL,
  `request_seq` varchar(255) collate utf8_unicode_ci default NULL,
  `request_type` varchar(255) collate utf8_unicode_ci default NULL,
  `request_command` text collate utf8_unicode_ci,
  `request_time` datetime default NULL,
  `operator_type` varchar(255) collate utf8_unicode_ci default NULL,
  `state` int(11) default NULL,
  `reason` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `retry_times` int(11) default '0',
  `appid` int(11) default '0',
  `price` float default '0',
  `real_amount` float default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table purchase_transaction_records
# ------------------------------------------------------------

DROP TABLE IF EXISTS `purchase_transaction_records`;

CREATE TABLE `purchase_transaction_records` (
  `id` int(11) NOT NULL auto_increment,
  `request_id` varchar(255) collate utf8_unicode_ci default NULL,
  `operator_user_id` int(11) default NULL,
  `request_url` varchar(255) collate utf8_unicode_ci default NULL,
  `request_message` text collate utf8_unicode_ci,
  `response_message` varchar(255) collate utf8_unicode_ci default NULL,
  `request_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `request_time` datetime default NULL,
  `response_time` datetime default NULL,
  `elapsed_time` float default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table resource_updates
# ------------------------------------------------------------

DROP TABLE IF EXISTS `resource_updates`;

CREATE TABLE `resource_updates` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `version` varchar(255) collate utf8_unicode_ci default NULL,
  `md5` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `update_flag` int(11) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table schema_migrations
# ------------------------------------------------------------

DROP TABLE IF EXISTS `schema_migrations`;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table send_tiger_messages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `send_tiger_messages`;

CREATE TABLE `send_tiger_messages` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table share_weibos
# ------------------------------------------------------------

DROP TABLE IF EXISTS `share_weibos`;

CREATE TABLE `share_weibos` (
  `id` int(11) NOT NULL auto_increment,
  `url` varchar(255) collate utf8_unicode_ci default NULL,
  `appkey` varchar(255) collate utf8_unicode_ci default NULL,
  `title` varchar(255) collate utf8_unicode_ci default NULL,
  `ralate_uid` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `weibo_type` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table slot_machine_logs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `slot_machine_logs`;

CREATE TABLE `slot_machine_logs` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `content` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table spend_cate_logs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `spend_cate_logs`;

CREATE TABLE `spend_cate_logs` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `cate_id` int(11) default NULL,
  `cate_count` int(11) default NULL,
  `spend_count` varchar(255) default NULL,
  `add_date` datetime default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gift_bag_id` int(11) default NULL,
  `treasure_box_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table super_users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `super_users`;

CREATE TABLE `super_users` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `encrypted_password` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `reset_password_token` varchar(255) collate utf8_unicode_ci default NULL,
  `reset_password_sent_at` datetime default NULL,
  `remember_created_at` datetime default NULL,
  `sign_in_count` int(11) default '0',
  `current_sign_in_at` datetime default NULL,
  `last_sign_in_at` datetime default NULL,
  `current_sign_in_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `last_sign_in_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `superadmin` tinyint(1) NOT NULL default '0',
  `role` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_super_users_on_email` (`email`),
  UNIQUE KEY `index_super_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table system_messages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `system_messages`;

CREATE TABLE `system_messages` (
  `id` int(11) NOT NULL auto_increment,
  `content` varchar(255) collate utf8_unicode_ci default NULL,
  `message_type` int(11) default NULL,
  `failure_time` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table system_settings
# ------------------------------------------------------------

DROP TABLE IF EXISTS `system_settings`;

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL auto_increment,
  `setting_name` varchar(255) default NULL,
  `setting_value` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `enabled` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `flag` int(11) default '0',
  `payment` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table treasure_boxes
# ------------------------------------------------------------

DROP TABLE IF EXISTS `treasure_boxes`;

CREATE TABLE `treasure_boxes` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `beans` int(11) default NULL,
  `price` int(11) default NULL,
  `note` varchar(255) default NULL,
  `give_beans` int(11) default NULL,
  `sale_limit` int(11) default NULL,
  `sale_count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table ui_manages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ui_manages`;

CREATE TABLE `ui_manages` (
  `id` int(11) NOT NULL auto_increment,
  `content` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table update_packages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `update_packages`;

CREATE TABLE `update_packages` (
  `id` int(11) NOT NULL auto_increment,
  `version` varchar(255) collate utf8_unicode_ci default NULL,
  `url` varchar(255) collate utf8_unicode_ci default NULL,
  `md5` varchar(255) collate utf8_unicode_ci default NULL,
  `specifical_code` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `s_md5` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table use_cate_logs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `use_cate_logs`;

CREATE TABLE `use_cate_logs` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `cate_id` int(11) default NULL,
  `used_date` varchar(255) default NULL,
  `datetime` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table used_cates
# ------------------------------------------------------------

DROP TABLE IF EXISTS `used_cates`;

CREATE TABLE `used_cates` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `cate_id` int(11) default NULL,
  `cate_valid` int(11) default NULL,
  `cate_begin` datetime default NULL,
  `cate_last` datetime default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table user_game_teaches
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_game_teaches`;

CREATE TABLE `user_game_teaches` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `game_teach_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_ids
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_ids`;

CREATE TABLE `user_ids` (
  `id` int(11) NOT NULL auto_increment,
  `next_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table user_mobile_lists
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_mobile_lists`;

CREATE TABLE `user_mobile_lists` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_mobile_sources
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_mobile_sources`;

CREATE TABLE `user_mobile_sources` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `num` float default NULL,
  `source` text collate utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `mobile_type` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_product_item_counts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_product_item_counts`;

CREATE TABLE `user_product_item_counts` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `game_product_item_id` int(11) default NULL,
  `item_count` int(11) default '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_product_items
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_product_items`;

CREATE TABLE `user_product_items` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `game_id` int(11) default NULL,
  `item_name` varchar(255) collate utf8_unicode_ci default NULL,
  `item_note` varchar(255) collate utf8_unicode_ci default NULL,
  `cate_module` varchar(255) collate utf8_unicode_ci default NULL,
  `using_point` varchar(255) collate utf8_unicode_ci default NULL,
  `beans` int(11) default NULL,
  `item_feature` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `game_item_id` int(11) default NULL,
  `request_seq` varchar(255) collate utf8_unicode_ci default NULL,
  `state` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_products
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_products`;

CREATE TABLE `user_products` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `game_id` int(11) default NULL,
  `product_name` varchar(255) collate utf8_unicode_ci default NULL,
  `product_type` int(11) default NULL,
  `note` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `price` varchar(255) collate utf8_unicode_ci default NULL,
  `sale_limit` int(11) default NULL,
  `state` int(11) default NULL,
  `icon` int(11) default '0',
  `product_sort` int(11) default '0',
  `request_seq` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_profiles
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_profiles`;

CREATE TABLE `user_profiles` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `nick_name` varchar(255) default NULL,
  `gender` int(11) default '1',
  `email` varchar(255) default NULL,
  `appid` varchar(255) default NULL,
  `msisdn` varchar(255) default NULL,
  `memo` varchar(255) default NULL,
  `last_login_at` datetime default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `birthday` datetime default NULL,
  `version` varchar(255) default NULL,
  `avatar` int(11) default '0',
  `last_active_at` datetime default NULL,
  `online_time` int(11) default NULL,
  `consecutive` int(11) default '1',
  `day_total_game` int(11) default '0',
  `day_continue_win` int(11) default '0',
  `balance` int(11) default '0',
  `total_balance` int(11) default NULL,
  `first_buy` int(11) default '0',
  `used_credit` int(11) default '0',
  `payment` varchar(255) default NULL,
  `sign_up_get_charge` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table user_score_lists
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_score_lists`;

CREATE TABLE `user_score_lists` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `nick_name` varchar(255) collate utf8_unicode_ci default NULL,
  `score` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_sheets
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_sheets`;

CREATE TABLE `user_sheets` (
  `id` int(11) NOT NULL auto_increment,
  `date` varchar(255) collate utf8_unicode_ci default NULL,
  `online_time_count` int(11) default '0',
  `login_count` int(11) default '0',
  `paiju_time_count` int(11) default '0',
  `paiju_count` int(11) default '0',
  `paiju_break_count` int(11) default '0',
  `bank_broken_count` int(11) default '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_total_consume_lists
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_total_consume_lists`;

CREATE TABLE `user_total_consume_lists` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_used_props
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_used_props`;

CREATE TABLE `user_used_props` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `game_product_item_id` int(11) default NULL,
  `use_time` datetime default NULL,
  `state` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `game_id` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `nick_name` varchar(255) default NULL,
  `game_id` int(11) default NULL,
  `password_digest` varchar(255) default NULL,
  `password_salt` varchar(255) default NULL,
  `msisdn` varchar(255) default NULL,
  `imsi` varchar(255) default NULL,
  `mac` varchar(255) default NULL,
  `os_release` varchar(255) default NULL,
  `manufactory` varchar(255) default NULL,
  `brand` varchar(255) default NULL,
  `model` varchar(255) default NULL,
  `display` varchar(255) default NULL,
  `fingerprint` varchar(255) default NULL,
  `appid` int(11) default NULL,
  `version` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `login_token` varchar(255) default NULL,
  `imei` varchar(255) default NULL,
  `robot` int(11) default '0',
  `busy` int(11) default '0',
  `last_action_time` datetime default '2013-06-05 03:36:18',
  `game_level` varchar(255) default '短工',
  `vip_level` int(11) default NULL,
  `total_consume` float default NULL,
  `robot_type` int(11) default NULL,
  `prize` int(11) default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_users_on_user_id` (`user_id`),
  KEY `available_robot` (`robot`,`busy`,`last_action_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table vip_count_201308
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vip_count_201308`;

CREATE TABLE `vip_count_201308` (
  `id` int(11) NOT NULL auto_increment,
  `vip_level` varchar(255) collate utf8_unicode_ci default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table vip_count_201309
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vip_count_201309`;

CREATE TABLE `vip_count_201309` (
  `id` int(11) NOT NULL auto_increment,
  `vip_level` varchar(255) collate utf8_unicode_ci default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table vip_count_201310
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vip_count_201310`;

CREATE TABLE `vip_count_201310` (
  `id` int(11) NOT NULL auto_increment,
  `vip_level` varchar(255) collate utf8_unicode_ci default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table vip_count_201311
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vip_count_201311`;

CREATE TABLE `vip_count_201311` (
  `id` int(11) NOT NULL auto_increment,
  `vip_level` varchar(255) collate utf8_unicode_ci default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table vip_count_201406
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vip_count_201406`;

CREATE TABLE `vip_count_201406` (
  `id` int(11) NOT NULL auto_increment,
  `vip_level` varchar(255) collate utf8_unicode_ci default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table vip_counts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vip_counts`;

CREATE TABLE `vip_counts` (
  `id` int(11) NOT NULL auto_increment,
  `vip_level` varchar(255) collate utf8_unicode_ci default NULL,
  `count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table visit_room_counts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `visit_room_counts`;

CREATE TABLE `visit_room_counts` (
  `id` int(11) NOT NULL auto_increment,
  `game_room_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `count` int(11) default NULL,
  `date` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table visit_ui_counts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `visit_ui_counts`;

CREATE TABLE `visit_ui_counts` (
  `id` int(11) NOT NULL auto_increment,
  `ui_id` int(11) default NULL,
  `click_count` int(11) default NULL,
  `time_count` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
