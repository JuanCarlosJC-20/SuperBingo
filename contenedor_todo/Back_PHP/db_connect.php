<?php
class Database {
    private $host = "localhost"; // Servidor de base de datos
    private $db_name = "superBingo_Data_Base"; // Nombre de la base de datos
    private $username = "root"; // Usuario de la base de datos (cámbialo según tu configuración)
    private $password = ""; // Contraseña del usuario
    private $port = "3306"; // Puerto de MySQL (por defecto 3306)
    private $conn; // Variable para almacenar la conexión

    // Método para obtener la conexión
    public function getConnection() {
        $this->conn = null;

        try {
            // Se crea la conexión utilizando mysqli
            $this->conn = new mysqli($this->host, $this->username, $this->password, $this->db_name, $this->port);

            // Verificamos si hubo un error en la conexión
            if ($this->conn->connect_error) {
                throw new Exception("Error de conexión: " . $this->conn->connect_error);
            }

            // Configurar el conjunto de caracteres
            $this->conn->set_charset("utf8");

            // Verificación de conexión
            if (!$this->conn->ping()) {
                throw new Exception("La conexión a la base de datos ha fallado.");
            }

        } catch (Exception $exception) {
            // En caso de error, se imprime el mensaje
            echo "Error de conexión: " . $exception->getMessage();
        }

        return $this->conn; // Retorna la conexión o null en caso de error
    }

    // Método para ejecutar una consulta SQL con parámetros
    public function ejecutarConsulta($sql, $params = []) {
        try {
            // Verificamos que la conexión esté establecida
            if ($this->conn === null) {
                throw new Exception("No se ha establecido la conexión a la base de datos.");
            }

            // Preparamos la consulta SQL
            $stmt = $this->conn->prepare($sql);
            if ($stmt === false) {
                throw new Exception("Error en la preparación de la consulta: " . $this->conn->error);
            }

            // Vinculamos los parámetros
            if (!empty($params)) {
                // Crear un arreglo para los tipos de datos de los parámetros
                $types = str_repeat('s', count($params)); // Suponiendo que todos son cadenas, ajusta según sea necesario
                $paramValues = array_values($params);
                $stmt->bind_param($types, ...$paramValues);

            }

            // Ejecutamos la consulta
            $stmt->execute();

            // Obtenemos los resultados
            $result = $stmt->get_result();

            // Retornamos los resultados como un arreglo asociativo
            return $result->fetch_all(MYSQLI_ASSOC);

        } catch (Exception $e) {
            echo "Error en la consulta: " . $e->getMessage();
            return [];
        }
    }

    // Método para cerrar la conexión
    public function closeConnection() {
        if ($this->conn) {
            $this->conn->close();
        }
    }
}
?>
