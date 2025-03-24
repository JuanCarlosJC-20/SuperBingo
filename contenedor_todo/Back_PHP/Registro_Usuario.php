<?php
header('Content-Type: application/json');
require './db_connect.php';
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require './php/PHPMailer/src/PHPMailer.php';
require './php/PHPMailer/src/SMTP.php';
require './php/PHPMailer/src/Exception.php';

$db = new Database();
$conn = $db->getConnection();

if ($conn === null) {
    echo json_encode(['status' => 'error', 'message' => 'No se pudo conectar a la base de datos.']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $nombreUsuario = $input['usuario'];
    $contraseña = $input['password'];
    $correo = $input['email'];

    if (empty($nombreUsuario) || empty($contraseña) || empty($correo)) {
        echo json_encode(['status' => 'error', 'message' => 'Todos los campos son requeridos.']);
        exit;
    }

    // Validar formato del correo electrónico
    if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(['status' => 'error', 'formato_message' => 'Formato de correo incorrecto.']);
        exit;
    }

    // Verificar si el usuario o el correo electrónico ya existen
    $sql_check = "SELECT NombreUsuario, Correo FROM Registro_Usuario WHERE NombreUsuario = ? OR Correo = ?";
    $stmt_check = $conn->prepare($sql_check);
    $stmt_check->bind_param('ss', $nombreUsuario, $correo);
    $stmt_check->execute();
    $stmt_check->store_result();

    if ($stmt_check->num_rows > 0) {
        echo json_encode(['status' => 'error', 'correoUsuariomessage' => 'El usuario o el correo ya existen.']);
        exit;
    }

    // Encriptar la contraseña
    $contraseña_hash = password_hash($contraseña, PASSWORD_DEFAULT);

    // Generar token de verificación
    $tokenVerificacion = bin2hex(random_bytes(32));

    // Iniciar una transacción
    $conn->begin_transaction();

    try {
        // Insertar en la tabla Usuario primero (ya que es referenciada por Registro_Usuario)
        $sql_usuario = "INSERT INTO Usuario (NombreUsuario, Correo, Contraseña) VALUES (?, ?, ?)";
        $stmt_usuario = $conn->prepare($sql_usuario);
        $stmt_usuario->bind_param('sss', $nombreUsuario, $correo, $contraseña_hash);
        
        if (!$stmt_usuario->execute()) {
            throw new Exception('Error al crear el usuario.');
        }
        
        $id_usuario = $conn->insert_id;

        // Insertar en la tabla Registro_Usuario
        $sql = "INSERT INTO Registro_Usuario (ID_Usuario, Correo, NombreUsuario, Contraseña_Hash, EstadoRegistro, TokenVerificacion) 
                VALUES (?, ?, ?, ?, 'pendiente', ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('issss', $id_usuario, $correo, $nombreUsuario, $contraseña_hash, $tokenVerificacion);

        if (!$stmt->execute()) {
            throw new Exception('Error en el registro de usuario.');
        }

        // Configurar PHPMailer
        $mail = new PHPMailer(true);
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'soporte.superbingo@gmail.com';
        $mail->Password = 'x x w c q t p a f j w a g d c p';
        $mail->SMTPSecure = 'tls';
        $mail->Port = 587;
        $mail->CharSet = 'UTF-8';

        // Configuración de destinatarios
        $mail->setFrom('soporte.superbingo@gmail.com', 'SuperBingo');
        $mail->addAddress($correo, $nombreUsuario);
        $mail->isHTML(true);
        $mail->Subject = "Verificación de cuenta";
        
        // El mismo contenido HTML que tenías antes, pero actualizado con los nuevos nombres de variables
        $mail->Body = '
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>¡Verifica tu cuenta en SuperBingo!</title>
    <style>
        /* Tus estilos CSS aquí... */
    </style>
</head>
<body>
    <div class="container">
        <h2>¡Verifica tu cuenta en SuperBingo!</h2>
        <div class="comic-bubble">¡Hola, ' . htmlspecialchars($nombreUsuario) . '! Gracias por unirte a SuperBingo.</div>
        <p>Para finalizar tu registro, haz clic en el siguiente enlace para verificar tu cuenta:</p>
        <a href="http://localhost/superbingo/contenedor_todo/back_php/validacion.php?email=' . urlencode($correo) . '&token=' . urlencode($tokenVerificacion) . '" class="button">Verificar cuenta</a>
        <p>O copia y pega esta URL en tu navegador:</p>
        <div class="comic-bubble">
            <a href="http://localhost/superbingo/contenedor_todo/back_php/validacion.php?email=' . urlencode($correo) . '&token=' . urlencode($tokenVerificacion) . '">
                http://localhost/superbingo/contenedor_todo/back_php/validacion.php
            </a>
        </div>
        <div class="footer">
            <p>Si no has solicitado esta verificación, ignora este correo.</p>
            <p>Equipo de SuperBingo</p>
        </div>
    </div>
</body>
</html>';
        $mail->AltBody = 'Haz clic en el siguiente enlace para verificar tu cuenta: http://localhost/superbingo/back_php/validacion.php?email=' . $correo . '&token=' . $tokenVerificacion;

        // Enviar el correo
        if (!$mail->send()) {
            throw new Exception('Error al enviar el correo de verificación: ' . $mail->ErrorInfo);
        }

        // Confirmar la transacción
        $conn->commit();
        echo json_encode(['status' => 'success', 'message' => 'Registro exitoso. Revisa tu correo para verificar tu cuenta.']);

    } catch (Exception $e) {
        // Revertir la transacción en caso de error
        $conn->rollback();
        echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
    }

    // Cerrar los statements
    if (isset($stmt)) $stmt->close();
    if (isset($stmt_usuario)) $stmt_usuario->close();
}

// Cerrar la conexión
$conn->close();
?>