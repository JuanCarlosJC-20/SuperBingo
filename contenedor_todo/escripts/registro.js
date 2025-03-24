document.getElementById('registro-form').addEventListener('submit', function(event) {
    event.preventDefault();

    const email = document.getElementById('email').value;
    const usuario = document.getElementById('usuario').value;
    const password = document.getElementById('contrasena').value;
    const confirmarPassword = document.getElementById('confirmar-contrasena').value;

    const mensajeError = document.getElementById('mensaje-error');

    // Validar que los campos no estén vacíos
    if (email === '' || usuario === '' || password === '' || confirmarPassword === '') {
        mensajeError.textContent = 'Por favor, completa todos los campos.';
        return;
    }

    // Validar que las contraseñas coincidan
    if (password !== confirmarPassword) {
        mensajeError.textContent = 'Las contraseñas no coinciden.';
        return;
    }

    // Si las contraseñas coinciden, enviamos los datos
    const data = { usuario, email, password };
    fetch('../contenedor_todo/Back_PHP/Registro_Usuario.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`Error en la solicitud: ${response.statusText}`);
        }
        return response.text(); // Leer como texto
    })
    .then(text => {
        console.log("Respuesta del servidor:", text); // Mostrar el texto completo
        
        // Intentar convertir manualmente a JSON
        let data;
        try {
            data = JSON.parse(text);
        } catch (error) {
            console.error("Error al analizar JSON:", error);
            document.getElementById('mensaje-error').textContent = "Error al procesar la respuesta del servidor.";
            return;
        }
    
        // Manejar la respuesta basada en el JSON devuelto
        if (data.status === 'error') {
            document.getElementById('mensaje-error').textContent = data.message;
        } else {
            alert(data.message);
        }
    })
    .catch(error => {
        console.error('Error en la solicitud:', error);
    });
})    
