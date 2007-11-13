CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `url_part` varchar(255) default NULL,
  `parent` varchar(255) default NULL,
  `can_have_items` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8;

CREATE TABLE `components` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `descriptive_name` varchar(255) default NULL,
  `description` text,
  `version` varchar(255) default NULL,
  `homepage` varchar(255) default NULL,
  `tags` varchar(255) default NULL,
  `creator` varchar(255) default NULL,
  `owner` varchar(255) default NULL,
  `status` varchar(255) default NULL,
  `code` text,
  `internal_name` varchar(255) default NULL,
  `creation` int(11) NOT NULL default '0',
  `updated` int(11) NOT NULL default '0',
  `read_permissions` text,
  `write_permissions` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `data_groups` (
  `id` int(11) NOT NULL auto_increment,
  `groupingtype` varchar(255) default NULL,
  `creator` varchar(255) default NULL,
  `groupingid` varchar(255) default NULL,
  `owner` varchar(255) default NULL,
  `tags` text,
  `parent` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `read_permissions` text,
  `write_permissions` text,
  `remote_data` tinyint(1) NOT NULL default '0',
  `sourceid` varchar(255) default NULL,
  `include_sources` text,
  `updated` int(11) default NULL,
  `creation` int(11) default NULL,
  `category` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `data_items` (
  `id` int(11) NOT NULL auto_increment,
  `datatype` varchar(255) default NULL,
  `datacreator` varchar(255) default NULL,
  `dataid` varchar(255) default NULL,
  `grouping` varchar(255) default NULL,
  `owner` varchar(255) default NULL,
  `creator` varchar(255) default NULL,
  `creation` int(11) default NULL,
  `tags` text,
  `title` varchar(255) default NULL,
  `description` text,
  `stringdata` text,
  `integerdata` int(11) default NULL,
  `objectdata` text,
  `read_permissions` text,
  `write_permissions` text,
  `remote_data` tinyint(1) NOT NULL default '0',
  `sourceid` varchar(255) default NULL,
  `updated` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `data_sources` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `data_type` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `uri` text,
  `creation` int(11) NOT NULL default '0',
  `updated` int(11) NOT NULL default '0',
  `update_interval` int(11) NOT NULL default '0',
  `file_type` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `environments` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `short_name` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `creator` varchar(255) default NULL,
  `owner` varchar(255) default NULL,
  `creation` int(11) default NULL,
  `read_permissions` text,
  `write_permissions` text,
  `layout_type` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `group_members` (
  `id` int(11) NOT NULL auto_increment,
  `groupid` varchar(255) default NULL,
  `userid` varchar(255) default NULL,
  `level` varchar(255) default NULL,
  `isbanned` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `groups` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `displayname` varchar(255) default NULL,
  `creation` int(11) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `quotas` (
  `id` int(11) NOT NULL auto_increment,
  `storageid` varchar(255) default NULL,
  `objectid` varchar(255) default NULL,
  `max_file_size` varchar(255) default NULL,
  `max_total_size` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `sessions_session_id_index` (`session_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;

CREATE TABLE `storages` (
  `id` int(11) NOT NULL auto_increment,
  `objectid` varchar(255) default NULL,
  `objecttype` varchar(255) default NULL,
  `data` blob,
  `parent` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `creator` varchar(255) default NULL,
  `creatorapp` varchar(255) default NULL,
  `owner` varchar(255) default NULL,
  `tags` text,
  `description` text,
  `read_permissions` text,
  `write_permissions` text,
  `updated` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `subscription_payments` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `user_uuid` varchar(255) default NULL,
  `subscription_uuid` varchar(255) default NULL,
  `amount_paid` float default NULL,
  `date_paid` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `subscription_services` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `subscription_type` varchar(255) default NULL,
  `provider_uuid` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `creator` varchar(255) default NULL,
  `creation` int(11) default NULL,
  `updated` int(11) default NULL,
  `amount` float default NULL,
  `recurrence` int(11) default NULL,
  `recurrence_day` int(11) default NULL,
  `recurrence_notify` int(11) default NULL,
  `notify_template` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `user_uuid` varchar(255) default NULL,
  `sub_service_uuid` varchar(255) default NULL,
  `billing_data` varchar(255) default NULL,
  `creation` int(11) default NULL,
  `updated` int(11) default NULL,
  `status` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_sources` (
  `id` int(11) NOT NULL auto_increment,
  `sourceid` varchar(255) default NULL,
  `userid` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `username` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `secretquestion` varchar(255) default NULL,
  `secretanswer` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `displayname` varchar(255) default NULL,
  `creation` int(11) default NULL,
  `authcode` varchar(255) default NULL,
  `verified_email` tinyint(1) default NULL,
  `email` varchar(255) default NULL,
  `authcookie` varchar(255) default NULL,
  `authcookie_set_time` int(11) default NULL,
  `facebook_session_key` varchar(255) default NULL,
  `facebook_uid` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `widget_instances` (
  `id` int(11) NOT NULL auto_increment,
  `instanceid` varchar(255) default NULL,
  `widgetid` varchar(255) default NULL,
  `parent` varchar(255) default NULL,
  `configuration` text,
  `position` int(11) default NULL,
  `order` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `widgets` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) default NULL,
  `descriptive_name` varchar(255) default NULL,
  `description` text,
  `version` varchar(255) default NULL,
  `homepage` varchar(255) default NULL,
  `tags` varchar(255) default NULL,
  `creator` varchar(255) default NULL,
  `owner` varchar(255) default NULL,
  `status` varchar(255) default NULL,
  `required_components` text,
  `code` text,
  `configuration_fields` text,
  `internal_name` varchar(255) default NULL,
  `read_permissions` text,
  `write_permissions` text,
  `creation` int(11) NOT NULL default '0',
  `updated` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_info (version) VALUES (51)