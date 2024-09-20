document.addEventListener('DOMContentLoaded', () => {
    const loadingScreen = document.getElementById('loading-screen');
    const progress = document.querySelector('.progress');
    let width = 0;

    const interval = setInterval(() => {
        if (width >= 100) {
            clearInterval(interval);
            setTimeout(() => {
                loadingScreen.style.display = 'none';
            }, 500);
        } else {
            width++;
            progress.style.width = width + '%';
        }
    }, 20);
});

document.addEventListener('DOMContentLoaded', function () {
    const submitLink = document.getElementById('submit-link');
    const submitButton = document.getElementById('colores');
    const modal = document.querySelector('.modal');
    const closeModal = document.querySelector('.closeModal');
    const usernameInput = document.getElementById('username');
    const passwordInput = document.getElementById('password');
    const superBingoCp = document.querySelector('.superBingoCp'); // Referencia al elemento SuperBingo
    const content = document.querySelector('.content'); // Referencia al contenido principal

    // Manejador del enlace que contiene el botón "Iniciar"
    submitLink.addEventListener('click', function (event) {
        event.preventDefault(); // Prevenir la redirección predeterminada del enlace

        // Simulación de validación
        const username = usernameInput.value;
        const password = passwordInput.value;

        if (password === '' || username === '') {
            // Muestra el modal si la contraseña o usuario están vacíos
            modal.style.display = 'block';
            superBingoCp.classList.add('hide-superBingo'); // Oculta el SuperBingo
            
            // Estilo para el overlay traslúcido
            overlay.style.position = 'fixed';
            overlay.style.top = '0';
            overlay.style.left = '0';
            overlay.style.width = '100%';
            overlay.style.height = '100%';
            overlay.style.backgroundColor = 'rgba(0, 0, 0, 0.7)'; // Fondo negro traslúcido
            overlay.style.zIndex = '999'; // Debajo del modal pero encima del contenido
            overlay.style.display = 'none'; // Oculto por defecto
            
        } else {
            // Redirección manual después de la validación
            window.location.href = '/fronted/publico/HomeHtml/home.html';
        }
    });

    // Manejador para cerrar el modal
    closeModal.addEventListener('click', function (event) {
        event.preventDefault();
        modal.style.display = 'none';
        superBingoCp.classList.remove('hide-superBingo'); // Muestra el SuperBingo de nuevo
        content.style.opacity = '1'; // Restaura el fondo
    });
});