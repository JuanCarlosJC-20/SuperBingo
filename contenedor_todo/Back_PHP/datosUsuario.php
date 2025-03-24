<?php
session_start(); // Iniciar la sesión

// Verificar si el usuario ha iniciado sesión
if (!isset($_SESSION['ID_Usuario'])) {
    echo json_encode(array('status' => 'err', 'result' => 'Usuario no ha iniciado sesión'));
    exit;
}

// Obtener el ID del usuario desde la sesión
$id_usuario = $_SESSION['ID_Usuario'];

// Conectar a la base de datos
$host = "localhost";
$db_name = "superBingo_Data_Base";
$username = "root";
$password = "";

$db = new mysqli($host, $username, $password, $db_name);
if ($db->connect_error) {
    die('Problemas con la conexión: ' . $db->connect_error);
}


$query = $db->query("SELECT * FROM usuario WHERE ID_Usuario = '$id_usuario'");

if ($query->num_rows > 0) {
    $userData = $query->fetch_assoc();
    
    // Preparar los datos para enviarlos en formato JSON
    $data = array(
        'status' => 'okey',
        'result' => array(
            'ID_Usuario' => $userData['ID_Usuario'],
            'NombreUsuario' => $userData['NombreUsuario'],
            'Monedas' => $userData['Monedas'], 
            'PartidasGana' => $userData['PartidasGanadas'], 
           
        )
    );
} else {
    $data = array(
        'status' => 'err',
        'result' => 'Usuario no encontrado'
    );
}

// Devolver la respuesta en formato JSON
echo json_encode($data);
?>
