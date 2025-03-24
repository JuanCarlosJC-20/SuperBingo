<?php

header('Content-Type: text/html; charset=UTF-8');
require './db_connect.php';

$db = new Database();
$conn = $db->getConnection();

if ($conn === null) {
    die("<h2>Error de conexión con la base de datos.</h2>");
}

// Función para limpiar datos de entrada
function cleanInput($data) {
    return htmlspecialchars(strip_tags(trim($data)));
}

// Estilo CSS para los mensajes
$styles = <<<EOT
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificación de Cuenta - SuperBingo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background-color: #f0f2f5;
        }
        .container {
            background-color: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        h2 {
            color: #1a73e8;
            margin-bottom: 1rem;
        }
        .message {
            margin: 1rem 0;
            padding: 1rem;
            border-radius: 4px;
        }
        .success {
            background-color: #e6f4ea;
            color: #137333;
        }
        .error {
            background-color: #fce8e6;
            color: #c5221f;
        }
        .button {
            display: inline-block;
            padding: 10px 20px;
            margin-top: 1rem;
            background-color: #1a73e8;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .button:hover {
            background-color: #1557b0;
        }
    </style>
</head>
<body>
<div class="container">
EOT;

echo $styles;

if (isset($_GET['email']) && isset($_GET['token'])) {
    $email = cleanInput($_GET['email']);
    $token = cleanInput($_GET['token']);

    // Verificar usuario con el correo y token proporcionados
    $sql = "SELECT ID_Usuario FROM Registro_Usuario 
            WHERE Correo = ? AND TokenVerificacion = ? AND EstadoRegistro = 'pendiente'";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $email, $token);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        // Iniciar transacción
        $conn->begin_transaction();

        try {
            // Actualizar el estado de verificación del usuario
            $update_sql = "UPDATE Registro_Usuario 
                          SET EstadoRegistro = 'verificado', 
                              TokenVerificacion = NULL,
                              FechaVerificacion = CURRENT_TIMESTAMP 
                          WHERE Correo = ?";
            
            $update_stmt = $conn->prepare($update_sql);
            $update_stmt->bind_param("s", $email);
            
            if ($update_stmt->execute()) {
                $conn->commit();
                echo "<h2>¡Verificación Exitosa!</h2>";
                echo "<div class='message success'>
                        Tu cuenta ha sido verificada exitosamente. 
                        Ahora puedes iniciar sesión en SuperBingo.
                      </div>";
                echo "<a href='../index.html' class='button'>Ir a Iniciar Sesión</a>";
            } else {
                throw new Exception("Error al actualizar el estado de verificación.");
            }
            $update_stmt->close();
        } catch (Exception $e) {
            $conn->rollback();
            echo "<h2>Error en la Verificación</h2>";
            echo "<div class='message error'>
                    Ocurrió un error al verificar tu cuenta. 
                    Por favor, intenta nuevamente más tarde.
                  </div>";
        }
    } else {
        echo "<h2>Enlace Inválido</h2>";
        echo "<div class='message error'>
                El enlace de verificación es inválido o ya ha expirado.
                Si el problema persiste, por favor solicita un nuevo enlace de verificación.
              </div>";
    }
    $stmt->close();
} else {
    echo "<h2>Error en la Verificación</h2>";
    echo "<div class='message error'>
            Parámetros de verificación incompletos.
            Por favor, utiliza el enlace proporcionado en tu correo electrónico.
          </div>";
}

echo "</div></body></html>";

$conn->close();
?>