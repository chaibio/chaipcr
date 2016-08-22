
-- phpMyAdmin SQL Dump
-- version 2.11.11.3
-- http://www.phpmyadmin.net
--
-- Host: 68.178.143.41
-- Generation Time: Aug 18, 2016 at 06:26 PM
-- Server version: 5.5.43
-- PHP Version: 5.1.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `experiment1`
--

-- --------------------------------------------------------

--
-- Table structure for table `records`
--

CREATE TABLE IF NOT EXISTS `records` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ip',
  `timestmp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `c` varchar(200) NOT NULL,
  `deviceid` varchar(60) NOT NULL,
  `msg` varchar(240) NOT NULL,
  `timest` varchar(50) NOT NULL,
  `ip` varchar(150) NOT NULL DEFAULT 'N/A',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1490 ;
