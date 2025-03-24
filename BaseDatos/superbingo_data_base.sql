-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 22-03-2025 a las 15:19:46
-- Versión del servidor: 8.0.30
-- Versión de PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `superbingo_data_base`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CambiarContraseña` (IN `p_ID_Usuario` INT, IN `p_TokenRecuperacion` VARCHAR(255), IN `p_NuevaContraseña` VARCHAR(255))   BEGIN
    DECLARE v_Estado VARCHAR(20);
    
    SELECT Estado INTO v_Estado
    FROM Cambio_Contraseña
    WHERE ID_Usuario = p_ID_Usuario 
    AND TokenRecuperacion = p_TokenRecuperacion
    AND FechaHoraExpiracion > NOW()
    ORDER BY FechaHoraSolicitud DESC
    LIMIT 1;
    
    IF v_Estado = 'pendiente' THEN
        -- Actualizar la contraseña del usuario
        UPDATE Usuario 
        SET Contraseña = p_NuevaContraseña
        WHERE ID_Usuario = p_ID_Usuario;
        
        -- Marcar la solicitud como completada
        UPDATE Cambio_Contraseña
        SET Estado = 'completado'
        WHERE ID_Usuario = p_ID_Usuario 
        AND TokenRecuperacion = p_TokenRecuperacion;
        
        SELECT 'Contraseña actualizada exitosamente' as mensaje;
    ELSE
        SELECT 'Token inválido o expirado' as mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CerrarSesion` (IN `p_TokenSesion` VARCHAR(255))   BEGIN
    UPDATE Sesion
    SET 
        EstadoSesion = 'finalizada',
        FechaHoraFin = CURRENT_TIMESTAMP
    WHERE 
        TokenSesion = p_TokenSesion
        AND EstadoSesion = 'activa';
        
    SELECT 'Sesión cerrada correctamente' as mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `IniciarSesion` (IN `p_NombreUsuario` VARCHAR(50), IN `p_Contraseña` VARCHAR(255))   BEGIN
    DECLARE v_ID_Usuario INT;
    DECLARE v_TokenSesion VARCHAR(255);
    
    -- Verificar credenciales
    SELECT ID_Usuario INTO v_ID_Usuario
    FROM Usuario
    WHERE NombreUsuario = p_NombreUsuario 
    AND Contraseña = p_Contraseña;
    
    IF v_ID_Usuario IS NOT NULL THEN
        -- Generar token de sesión (esto es un ejemplo simple)
        SET v_TokenSesion = UUID();
        
        -- Crear nueva sesión
        INSERT INTO Sesion (
            ID_Usuario, 
            NombreUsuario, 
            Contraseña,
            TokenSesion, 
            DireccionIP
        )
        VALUES (
            v_ID_Usuario, 
            p_NombreUsuario, 
            p_Contraseña,
            v_TokenSesion, 
            CONNECTION_ID()
        );
        
        -- Retornar información de la sesión
        SELECT 
            'Sesión iniciada correctamente' as mensaje,
            v_TokenSesion as token,
            v_ID_Usuario as ID_Usuario;
    ELSE
        SELECT 'Credenciales inválidas' as mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SolicitarCambioContraseña` (IN `p_ID_Usuario` INT, IN `p_TokenRecuperacion` VARCHAR(255))   BEGIN
    INSERT INTO Cambio_Contraseña (ID_Usuario, TokenRecuperacion, FechaHoraExpiracion)
    VALUES (p_ID_Usuario, p_TokenRecuperacion, DATE_ADD(NOW(), INTERVAL 24 HOUR));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerificarSesion` (IN `p_TokenSesion` VARCHAR(255))   BEGIN
    DECLARE v_EstadoSesion VARCHAR(20);
    
    SELECT EstadoSesion INTO v_EstadoSesion
    FROM Sesion
    WHERE TokenSesion = p_TokenSesion
    AND FechaHoraFin IS NULL
    AND EstadoSesion = 'activa';
    
    IF v_EstadoSesion = 'activa' THEN
        UPDATE Sesion
        SET UltimaActividad = CURRENT_TIMESTAMP
        WHERE TokenSesion = p_TokenSesion;
        
        SELECT 'Sesión válida' as mensaje, true as esValida;
    ELSE
        SELECT 'Sesión inválida o expirada' as mensaje, false as esValida;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `avatar`
--

CREATE TABLE `avatar` (
  `ID_Avatar` int NOT NULL,
  `NombreAvatar` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `Costo` int DEFAULT '0',
  `Imagen` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `Categoria` enum('gratuito','premium') COLLATE utf8mb4_general_ci DEFAULT 'gratuito'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cambio_contraseña`
--

CREATE TABLE `cambio_contraseña` (
  `ID_Cambio` int NOT NULL,
  `ID_Usuario` int NOT NULL,
  `TokenRecuperacion` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `FechaHoraSolicitud` datetime DEFAULT CURRENT_TIMESTAMP,
  `FechaHoraExpiracion` datetime DEFAULT NULL,
  `Estado` enum('pendiente','completado','expirado') COLLATE utf8mb4_general_ci DEFAULT 'pendiente',
  `ContraseñaAnterior` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carton`
--

CREATE TABLE `carton` (
  `ID_Carton` int NOT NULL,
  `ID_Partida` int NOT NULL,
  `ID_Usuario` int NOT NULL,
  `Numeros` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `Diseño` int DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partida`
--

CREATE TABLE `partida` (
  `ID_Partida` int NOT NULL,
  `Estado` enum('en espera','en curso','finalizada') COLLATE utf8mb4_general_ci DEFAULT 'en espera',
  `FechaHoraInicio` datetime DEFAULT CURRENT_TIMESTAMP,
  `FechaHoraFin` datetime DEFAULT NULL,
  `ID_Creador` int NOT NULL,
  `TipoSala` enum('publico','privado') COLLATE utf8mb4_general_ci DEFAULT 'publico',
  `MaxJugadores` int DEFAULT NULL,
  `Ganador` int DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partida_usuario`
--

CREATE TABLE `partida_usuario` (
  `ID_Partida` int NOT NULL,
  `ID_Usuario` int NOT NULL,
  `PosicionFinal` int DEFAULT NULL,
  `MonedasGanadas` int DEFAULT '0',
  `FechaHoraIngreso` datetime DEFAULT CURRENT_TIMESTAMP,
  `FechaHoraSalida` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfil`
--

CREATE TABLE `perfil` (
  `ID_Perfil` int NOT NULL,
  `ID_Usuario` int NOT NULL,
  `NombreUsuario` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `ID_Avatar` int DEFAULT NULL,
  `TipoAvatar` enum('gratuito','comprado') COLLATE utf8mb4_general_ci DEFAULT 'gratuito',
  `MonedasGastadas` int DEFAULT '0',
  `FechaUltimaActualizacion` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro_usuario`
--

CREATE TABLE `registro_usuario` (
  `ID_Registro` int NOT NULL,
  `ID_Usuario` int DEFAULT NULL,
  `Correo` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `NombreUsuario` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `Contraseña_Hash` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `FechaHoraRegistro` datetime DEFAULT CURRENT_TIMESTAMP,
  `EstadoRegistro` enum('pendiente','completado','rechazado') COLLATE utf8mb4_general_ci DEFAULT 'pendiente',
  `TokenVerificacion` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sala`
--

CREATE TABLE `sala` (
  `ID_Sala` int NOT NULL,
  `ID_Partida` int NOT NULL,
  `Privacidad` enum('publico','privado') COLLATE utf8mb4_general_ci DEFAULT 'publico',
  `CodigoInvitacion` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `JugadoresEsperando` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sesion`
--

CREATE TABLE `sesion` (
  `ID_Sesion` int NOT NULL,
  `ID_Usuario` int NOT NULL,
  `NombreUsuario` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `Contraseña` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `FechaHoraInicio` datetime DEFAULT CURRENT_TIMESTAMP,
  `FechaHoraFin` datetime DEFAULT NULL,
  `DireccionIP` varchar(45) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `TokenSesion` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `EstadoSesion` enum('activa','finalizada','expirada') COLLATE utf8mb4_general_ci DEFAULT 'activa',
  `UltimaActividad` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transaccion_monedas`
--

CREATE TABLE `transaccion_monedas` (
  `ID_Transaccion` int NOT NULL,
  `ID_Usuario` int NOT NULL,
  `ID_Partida` int DEFAULT NULL,
  `Cantidad` int NOT NULL,
  `FechaHora` datetime DEFAULT CURRENT_TIMESTAMP,
  `Tipo` enum('premio','compra_avatar','otro') COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `ID_Usuario` int NOT NULL,
  `NombreUsuario` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `Correo` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Contraseña` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `Monedas` int DEFAULT '0',
  `PartidasGanadas` int DEFAULT '0',
  `FechaRegistro` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`ID_Usuario`, `NombreUsuario`, `Correo`, `Contraseña`, `Monedas`, `PartidasGanadas`, `FechaRegistro`) VALUES
(1, 'jose123', 'gahonaotoniel50@gmail.com', '$2y$10$LvQl931mszT2pswO5yyelOIm1lczj3k6/7U9H6/ep5xMCvumEWPyu', 0, 0, '2024-11-04 17:46:48'),
(2, 'AndresMC', 'andresmoreco2005@gmail.com', '$2y$10$omVx822PV2Of50udAMFS/uuqz4uRDwAs./zpWhg1SRzYMmr15JIeS', 0, 0, '2024-11-08 13:57:21'),
(3, 'JUANPERROSQUI', 'emjemplo@gmail.com', '$2y$10$dEQI0CKPaIWkiYsCodX0aO2YrGge5fI/cuV/P6g47dqATxKJzJbsG', 999, 1, '2024-11-12 10:09:18'),
(5, 'CAremonda2.5', 'emjemplo2@gmail.com', '$2y$10$6N.Vp8Z7g9E4g1PUN4KkM.ZoM18/8lCa.DClE015Pi9OvkjNTIFay', 0, 2, '2024-11-12 12:28:57'),
(6, 'camila', 'juancar@outlook.com', '$2y$10$LJxe4/gE14vbG48Ryt//d.PAjgLRj1lsxi.kSWPOdusycC.06gT82', 0, 0, '2024-11-12 19:26:13'),
(7, 'pepe', 'egemplo@gamil.com', '$2y$10$isRCUuacmlkpoCcwr0R9nejIINJQchTeZ6/2NB8cNEaDH2Oo3mtaC', 0, 0, '2024-11-14 17:54:15'),
(8, 'coma', 'liajurado1946@gmail.com', '$2y$10$GcRZGikZxRkTVNFDTTwQAOKPHJXk9qfE4.g778zv4h6xRUh6Kpd6K', 0, 0, '2025-03-22 16:13:11');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `avatar`
--
ALTER TABLE `avatar`
  ADD PRIMARY KEY (`ID_Avatar`);

--
-- Indices de la tabla `cambio_contraseña`
--
ALTER TABLE `cambio_contraseña`
  ADD PRIMARY KEY (`ID_Cambio`),
  ADD KEY `ID_Usuario` (`ID_Usuario`);

--
-- Indices de la tabla `carton`
--
ALTER TABLE `carton`
  ADD PRIMARY KEY (`ID_Carton`),
  ADD KEY `ID_Partida` (`ID_Partida`),
  ADD KEY `ID_Usuario` (`ID_Usuario`);

--
-- Indices de la tabla `partida`
--
ALTER TABLE `partida`
  ADD PRIMARY KEY (`ID_Partida`),
  ADD KEY `ID_Creador` (`ID_Creador`),
  ADD KEY `Ganador` (`Ganador`);

--
-- Indices de la tabla `partida_usuario`
--
ALTER TABLE `partida_usuario`
  ADD PRIMARY KEY (`ID_Partida`,`ID_Usuario`),
  ADD KEY `ID_Usuario` (`ID_Usuario`);

--
-- Indices de la tabla `perfil`
--
ALTER TABLE `perfil`
  ADD PRIMARY KEY (`ID_Perfil`),
  ADD UNIQUE KEY `ID_Usuario` (`ID_Usuario`),
  ADD KEY `ID_Avatar` (`ID_Avatar`);

--
-- Indices de la tabla `registro_usuario`
--
ALTER TABLE `registro_usuario`
  ADD PRIMARY KEY (`ID_Registro`),
  ADD KEY `ID_Usuario` (`ID_Usuario`);

--
-- Indices de la tabla `sala`
--
ALTER TABLE `sala`
  ADD PRIMARY KEY (`ID_Sala`),
  ADD UNIQUE KEY `ID_Partida` (`ID_Partida`);

--
-- Indices de la tabla `sesion`
--
ALTER TABLE `sesion`
  ADD PRIMARY KEY (`ID_Sesion`),
  ADD KEY `ID_Usuario` (`ID_Usuario`),
  ADD KEY `NombreUsuario` (`NombreUsuario`);

--
-- Indices de la tabla `transaccion_monedas`
--
ALTER TABLE `transaccion_monedas`
  ADD PRIMARY KEY (`ID_Transaccion`),
  ADD KEY `ID_Usuario` (`ID_Usuario`),
  ADD KEY `ID_Partida` (`ID_Partida`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`ID_Usuario`),
  ADD UNIQUE KEY `NombreUsuario` (`NombreUsuario`),
  ADD UNIQUE KEY `Correo` (`Correo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `avatar`
--
ALTER TABLE `avatar`
  MODIFY `ID_Avatar` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cambio_contraseña`
--
ALTER TABLE `cambio_contraseña`
  MODIFY `ID_Cambio` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `carton`
--
ALTER TABLE `carton`
  MODIFY `ID_Carton` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `partida`
--
ALTER TABLE `partida`
  MODIFY `ID_Partida` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `perfil`
--
ALTER TABLE `perfil`
  MODIFY `ID_Perfil` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `registro_usuario`
--
ALTER TABLE `registro_usuario`
  MODIFY `ID_Registro` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `sala`
--
ALTER TABLE `sala`
  MODIFY `ID_Sala` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `sesion`
--
ALTER TABLE `sesion`
  MODIFY `ID_Sesion` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `transaccion_monedas`
--
ALTER TABLE `transaccion_monedas`
  MODIFY `ID_Transaccion` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `ID_Usuario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cambio_contraseña`
--
ALTER TABLE `cambio_contraseña`
  ADD CONSTRAINT `cambio_contraseña_ibfk_1` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`);

--
-- Filtros para la tabla `carton`
--
ALTER TABLE `carton`
  ADD CONSTRAINT `carton_ibfk_1` FOREIGN KEY (`ID_Partida`) REFERENCES `partida` (`ID_Partida`),
  ADD CONSTRAINT `carton_ibfk_2` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`);

--
-- Filtros para la tabla `partida`
--
ALTER TABLE `partida`
  ADD CONSTRAINT `partida_ibfk_1` FOREIGN KEY (`ID_Creador`) REFERENCES `usuario` (`ID_Usuario`),
  ADD CONSTRAINT `partida_ibfk_2` FOREIGN KEY (`Ganador`) REFERENCES `usuario` (`ID_Usuario`);

--
-- Filtros para la tabla `partida_usuario`
--
ALTER TABLE `partida_usuario`
  ADD CONSTRAINT `partida_usuario_ibfk_1` FOREIGN KEY (`ID_Partida`) REFERENCES `partida` (`ID_Partida`),
  ADD CONSTRAINT `partida_usuario_ibfk_2` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`);

--
-- Filtros para la tabla `perfil`
--
ALTER TABLE `perfil`
  ADD CONSTRAINT `perfil_ibfk_1` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`),
  ADD CONSTRAINT `perfil_ibfk_2` FOREIGN KEY (`ID_Avatar`) REFERENCES `avatar` (`ID_Avatar`);

--
-- Filtros para la tabla `registro_usuario`
--
ALTER TABLE `registro_usuario`
  ADD CONSTRAINT `registro_usuario_ibfk_1` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`);

--
-- Filtros para la tabla `sala`
--
ALTER TABLE `sala`
  ADD CONSTRAINT `sala_ibfk_1` FOREIGN KEY (`ID_Partida`) REFERENCES `partida` (`ID_Partida`);

--
-- Filtros para la tabla `sesion`
--
ALTER TABLE `sesion`
  ADD CONSTRAINT `sesion_ibfk_1` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`),
  ADD CONSTRAINT `sesion_ibfk_2` FOREIGN KEY (`NombreUsuario`) REFERENCES `usuario` (`NombreUsuario`);

--
-- Filtros para la tabla `transaccion_monedas`
--
ALTER TABLE `transaccion_monedas`
  ADD CONSTRAINT `transaccion_monedas_ibfk_1` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`),
  ADD CONSTRAINT `transaccion_monedas_ibfk_2` FOREIGN KEY (`ID_Partida`) REFERENCES `partida` (`ID_Partida`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
