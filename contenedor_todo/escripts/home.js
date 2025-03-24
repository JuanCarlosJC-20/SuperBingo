// Función para mostrar/ocultar el menú de perfil
function toggleMenu() {
    var menu = document.getElementById("menu");
    menu.style.display = (menu.style.display === "none" || menu.style.display === "") ? "block" : "none";
}

/* js del botón de sonido de música de fondo */ 
const audio1 = document.getElementById('audio');
const soundButton = document.getElementById('soundButton');
const soundIcon = document.getElementById('soundIcon');
let isPlaying = false;

soundButton.addEventListener('click', () => {
    if (isPlaying) {
        audio1.pause();
        soundIcon.src; // Sonido apagado
    } else {
        audio1.play();
        soundIcon.src; // Sonido encendido
    }
    isPlaying = !isPlaying;
});

/* js del botón de sonido de juego */ 
var soun = new Audio();
soun.src = "../Multimedia/Sonidos/button-press.mp3"; /* efecto de sonido de botones */

/* js de la barra de configuración */ 
const volumeControl = document.getElementById('volume');
const volumeContainer = document.getElementById('volume-control');
const toggleButton = document.getElementById('toggle-volume');

// Configurar volumen inicial
audio1.volume = volumeControl.value;

// Actualizar el volumen cuando cambia la barra de rango
volumeControl.addEventListener('input', function() {
    audio1.volume = this.value;
});

// Mostrar/ocultar control de volumen
toggleButton.addEventListener('click', function() {
    volumeContainer.style.display = (volumeContainer.style.display === 'none' || volumeContainer.style.display === '') ? 'block' : 'none';
});

/* Funciones para el modal de recompensa diaria */
const recompensaDiaria = document.getElementById("recompensaDiaria");
const openRecompensa = document.getElementById("openRecompensa");
const closeRecompensa = document.getElementById("closeRecompensa");
const mensajeRecompensa = document.getElementById("mensajeRecompensa");

// Función para abrir la recompensa diaria y verificar en el servidor
openRecompensa.onclick = function() {
    fetch('./Back_PHP/recompensa_diaria.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === "success") {
            recompensaDiaria.style.display = "block";
            mensajeRecompensa.textContent = data.message; // Mensaje de éxito
            mensajeRecompensa.style.color = "#4CAF50"; // Verde para éxito
        } else {
            recompensaDiaria.style.display = "block";
            mensajeRecompensa.textContent = data.message; // Mensaje de error
            mensajeRecompensa.style.color = "#FF0000"; // Rojo para error
        }
    })
    .catch(error => console.error('Error:', error));
};

// Función para cerrar la recompensa diaria
closeRecompensa.onclick = function() {
    recompensaDiaria.style.display = "none";
    mensajeRecompensa.textContent = ""; // Limpiar mensaje al cerrar el modal
}

// Cerrar la recompensa diaria al hacer clic fuera del modal
window.onclick = function(event) {
    if (event.target === recompensaDiaria) {
        recompensaDiaria.style.display = "none";
        mensajeRecompensa.textContent = ""; // Limpiar mensaje
    }
}
