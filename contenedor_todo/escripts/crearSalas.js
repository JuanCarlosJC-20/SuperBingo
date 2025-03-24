function generarIdSala() {
    let idSala = '';
    for (let i = 0; i < 8; i++) {
      idSala += Math.floor(Math.random() * 10); // Genera un número entre 0 y 9
    }

    // Asigna el ID generado al contenido del span dentro del label
    document.getElementById('roomId').textContent = idSala;
  }

  // Genera un ID de sala cuando se carga la página
  generarIdSala();


document.getElementById("roomForm").addEventListener("submit", function(event) {
    event.preventDefault(); // Evita que el formulario se envíe

    // Verifica si algún radio button está seleccionado
    const selectedRoomType = document.querySelector('input[name="roomType"]:checked');
    
    if (selectedRoomType) {
        // Si hay una opción seleccionada, muestra un mensaje con el tipo de sala
        document.getElementById("message").textContent = `Has seleccionado la sala ${selectedRoomType.value}.`;
    } else {
        // Si no hay opción seleccionada, muestra un mensaje de error
        document.getElementById("message").textContent = "Por favor, selecciona un tipo de sala.";
    }
});