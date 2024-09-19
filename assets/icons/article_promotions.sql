-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : dim. 08 sep. 2024 à 22:15
-- Version du serveur : 10.4.28-MariaDB
-- Version de PHP : 8.1.17

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `daary`
--

--
-- Déchargement des données de la table `article_promotions`
--

INSERT INTO `article_promotions` (`id`, `article_id`, `start_date`, `end_date`, `amount`, `payed_by`, `status`, `payment_status`, `prospects_count`, `created_at`, `updated_at`) VALUES
(7, 30, '2024-09-05', '2024-10-05', 100.50, 'ADMIN', 'pending', 'payment-pending', 0, '2024-09-05 18:21:10', '2024-09-05 18:21:10'),
(8, 30, '2024-10-05', '2024-10-20', 200.75, 'SASS', 'active', 'payment-success', 50, '2024-09-05 18:21:10', '2024-09-05 18:21:10'),
(9, 33, '2024-10-20', '2024-11-04', 200.75, 'SASS', 'active', 'payment-success', 50, '2024-09-05 18:21:10', '2024-09-05 18:21:10'),
(10, 36, '2024-11-04', '2024-11-19', 200.75, 'SASS', 'active', 'payment-success', 50, '2024-09-05 18:21:10', '2024-09-05 18:21:10'),
(11, 40, '2024-11-19', '2024-12-04', 200.75, 'SASS', 'active', 'payment-success', 50, '2024-09-05 18:21:10', '2024-09-05 18:21:10'),
(12, 33, '2024-10-20', '2024-10-05', 150.00, 'ADMIN', 'expired', 'payment-failed', 30, '2024-09-05 18:21:10', '2024-09-05 18:21:10');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
