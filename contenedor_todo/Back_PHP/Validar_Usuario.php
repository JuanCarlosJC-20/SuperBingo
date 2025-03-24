<?php
// Incluir la conexión a la base de datos
include './db_connect.php';

// Crear una instancia de la clase Database
$db = new Database();
$conexion = $db->getConnection();

try {
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $nombre_usuario = $_POST['username'];
        $contraseña_usuario = $_POST['password'];

        // Consulta para verificar si el usuario existe en la base de datos
        $sql = "SELECT * FROM usuario WHERE NombreUsuario = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("s", $nombre_usuario);
        $stmt->execute();
        $resultado = $stmt->get_result();

        // Verificar si se encontró el usuario
        if ($resultado->num_rows > 0) {
            $usuario = $resultado->fetch_assoc();

            // Verificar si la contraseña ingresada coincide con la almacenada
            if (password_verify($contraseña_usuario, $usuario['Contraseña'])) {
                // Iniciar sesión del usuario
                session_start();
                $_SESSION['ID_Usuario'] = $usuario['ID_Usuario'];
                $_SESSION['NombreUsuario'] = $usuario['NombreUsuario'];

                // Redirigir al usuario a la página principal
                header("Location: ../home.html");
                exit();
            } else {
                // Contraseña incorrecta
                header("Location: ../login.html?error=Contraseña incorrecta");
                exit();
            }
        } else {
            // Usuario no registrado
            header("Location: ../login.html?error=Usuario no registrado");
            exit();
        }
    }
} finally {
    // Cerrar las conexiones
    if (isset($stmt)) {
        $stmt->close();
    }
    $db->closeConnection(); // Cerrar la conexión
}

?>
