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

var btn = document.getElementById("register-btn");

var btn = document.getElementById("colores");


    // Obtener elementos del DOM
    var modal = document.getElementById("registerModal");
    var btn = document.getElementById("colores"); // Cambiado a la ID correcta
    var span = document.getElementsByClassName("close")[0];

    // Mostrar la pantalla emergente al hacer clic en el botón de registrar
    btn.onclick = function() {
        modal.style.display = "block";
    }

    // Cerrar la pantalla emergente cuando se hace clic en el botón de cerrar (x)
    span.onclick = function() {
        modal.style.display = "none";
    }

    // Cerrar la pantalla emergente si se hace clic fuera de ella
    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }

