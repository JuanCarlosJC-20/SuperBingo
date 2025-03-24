// Array global para almacenar los números generados por la bola de bingo
let numerosGenerados = [];
let numbers = Array.from({ length: 75 }, (_, i) => i + 1);
let drawnNumbers = [];
const letters = ["B", "I", "N", "G", "O"];

// Función para generar números aleatorios en un rango sin repetición
function generarNumerosAleatorios(min, max, cantidad) {
    let numeros = [];
    while (numeros.length < cantidad) {
        let numero = Math.floor(Math.random() * (max - min + 1)) + min;
        if (!numeros.includes(numero)) {
            numeros.push(numero);
        }
    }
    return numeros;
}

// Función para generar el cartón de bingo
function generarCarton() {
    const bingoCard = document.getElementById('bingoCard');

    // Limpiar el cartón antes de generar uno nuevo
    bingoCard.innerHTML = `
        <div class="header">B</div>
        <div class="header">I</div>
        <div class="header">N</div>
        <div class="header">G</div>
        <div class="header">O</div>
    `;

    // Generar números para cada columna
    let numerosB = generarNumerosAleatorios(1, 15, 5);  // Columna B (1-15)
    let numerosI = generarNumerosAleatorios(16, 30, 5); // Columna I (16-30)
    let numerosN = generarNumerosAleatorios(31, 45, 5); // Columna N (31-45)
    let numerosG = generarNumerosAleatorios(46, 60, 5); // Columna G (46-60)
    let numerosO = generarNumerosAleatorios(61, 75, 5); // Columna O (61-75)

    // Función para manejar el clic en cada número del cartón
    function marcarNumero(event) {
        const numeroElement = event.target;
        const numero = parseInt(numeroElement.textContent);

        // Validar si el número fue generado por la bola
        if (numerosGenerados.includes(numero)) {
            const isMarked = numeroElement.classList.contains('marked');

            // Alternar el marcado
            if (!isMarked) {
                numeroElement.classList.add('marked');

                // Crear la imagen que cubrirá el número
                const img = document.createElement('img');
                img.src = '../Multimedia/img/marcador.png'; // Ajusta esta ruta según tu estructura de proyecto
                img.className = 'marked-image'; // Añadir la clase para el estilo

                // Ajustar posición de la imagen según el número
                const rect = numeroElement.getBoundingClientRect();
                img.style.top = `${rect.top + window.scrollY}px`; // Ajusta la posición vertical
                img.style.left = `${rect.left + window.scrollX}px`; // Ajusta la posición horizontal

                // Agregar la imagen al body
                document.body.appendChild(img);
            } else {
                // Si ya está marcado, quitar el marcado
                numeroElement.classList.remove('marked');
            }
        } else {
               showModal (`Este número.\naún no ha salido.`, true);
        }
    } 

    // Añadir los números a las columnas (B, I, N, G, O)
    const agregarNumerosColumna = (numeros) => {
        numeros.forEach(numero => {
            let div = document.createElement('div');
            div.className = 'number';
            div.textContent = numero;
            div.addEventListener('click', marcarNumero); // Añadir el listener de clic
            bingoCard.appendChild(div);
        });
    };

        // Añadir los números a las columnas (B, I, N, G, O)
        const agregarNumeros2Columna = (numeros2) => {
            numeros2.forEach(numero => {
                let div = document.createElement('div');
                div.className = 'number';
                div.textContent = numero;
                div.addEventListener('click', marcarNumero); // Añadir el listener de clic
                bingoCard.appendChild(div);
            });
        };

    agregarNumerosColumna(numerosB);
    agregarNumerosColumna(numerosI);
    agregarNumerosColumna(numerosN.map((numero, index) => index === 2 ? ' ' : numero)); // Espacio libre en la columna N
    agregarNumerosColumna(numerosG);
    agregarNumerosColumna(numerosO);
}

// Función para generar una bola de bingo sin repetición
function generateBingoNumber() {
    if (numbers.length === 0) {
        document.getElementById('message').textContent = "Todos los números han sido seleccionados.";
        return;
    }

    const randomIndex = Math.floor(Math.random() * numbers.length);
    const selectedNumber = numbers[randomIndex];

    // Remover el número seleccionado del array
    numbers.splice(randomIndex, 1);
    numerosGenerados.push(selectedNumber);

    // Hacer que la bola desaparezca temporalmente
    const bingoBall = document.getElementById('bingoBall');
    bingoBall.style.opacity = '0';

    // Esperar 1 segundo antes de mostrar el nuevo número y cambiar el color
    setTimeout(() => {
        document.getElementById('bingoNumber').textContent = selectedNumber;

        // Determinar la letra de bingo
        let bingoLetter = "";
        if (selectedNumber <= 15) bingoLetter = "B";
        else if (selectedNumber <= 30) bingoLetter = "I";
        else if (selectedNumber <= 45) bingoLetter = "N";
        else if (selectedNumber <= 60) bingoLetter = "G";
        else bingoLetter = "O";

        document.getElementById('bingoLetter').textContent = bingoLetter;

        // Cambiar el color de la bola
        changeBallColor();

        // Agregar el número al contenedor correspondiente
        agregarNumeroContenedor(bingoLetter, selectedNumber);

        // Dictar el número generado
        dictateNumber(bingoLetter, selectedNumber);

        // Volver a hacer visible la bola
        bingoBall.style.opacity = '1';
    }, 1000);
}

// Función para agregar el número al contenedor correspondiente
function agregarNumeroContenedor(letra, numero) {
    const contenedor = document.querySelector(`.${letra.toLowerCase()}`);
    const divNumero = document.createElement('div');
    divNumero.className = 'number';
    divNumero.textContent = numero;
    contenedor.prepend(divNumero); // Agregar el número al inicio del contenedor
}


// Función para cambiar el color de la bola de bingo
function changeBallColor() {
    const bingoBall = document.getElementById('bingoBall');
    const colors = ['#FF5733', '#33FF57', '#3357FF', '#F0FF33', '#FF33A1', '#33FFF7'];
    const randomColor = colors[Math.floor(Math.random() * colors.length)];
    bingoBall.style.backgroundColor = randomColor;
}

// Función para dictar el número generado
function dictateNumber(letter, number) {
    const speech = new SpeechSynthesisUtterance();
    speech.lang = "es-ES"; // Idioma español
    speech.text = `Letra ${letter}, número ${number}`;
    window.speechSynthesis.speak(speech);
}

// Ejecutar la función de generar número de bingo cada 3.5 segundos
setInterval(generateBingoNumber, 3500);

// Llamar a la función para generar el cartón al cargar la página
window.onload = generarCarton;

//funcion al momento de salir de partida
function confirmExit() {
    // Mostrar el modal de confirmación
    const modal = document.getElementById('confirmationModal');
    modal.style.display = 'block';
}

function closeModal() {
    // Cerrar el modal
    const modal = document.getElementById('confirmationModal');
    modal.style.display = 'none';
}

// Aceptar salir de la partida
function confirmExitAction() {
    // Cerrar el modal
    closeModal();

    // Redirigir al usuario a la página de inicio
    window.location.href = '../home.html'; // Ajusta la ruta según tu proyecto
}

// Función para comprobar si se ha hecho Bingo
function checkBingo() {
    // Obtener todas las celdas marcadas en el cartón
    let selectedCells = document.querySelectorAll('.number.marked');
    
    // Obtener los números marcados
    let selectedNumbers = Array.from(selectedCells).map(cell => parseInt(cell.textContent));
    
    // Verificar si todas las celdas están marcadas (excepto la casilla del espacio libre)
    let allSelected = selectedCells.length === 24; // 24 porque la casilla del centro es libre
    
    // Verificar si los números marcados coinciden con los números generados
    let missingNumbers = selectedNumbers.filter(num => !numerosGenerados.includes(num));
    
    if (allSelected && missingNumbers.length === 0) {
        
        // Mostrar mensaje de victoria
        showModal('¡Felicidades,\nhas ganado!', true);

        
    } else if (!allSelected) {
        // Mostrar mensaje de que faltan casillas por marcar
        showModal('No has marcado\ntodas las casillas.', false);
    } else {
        // Mostrar mensaje de que faltan algunos números
        showModal('Te hacen falta\nalgunos número(s).', false);
    }
}

// Función para mostrar el modal
function showModal(message, isWin) {
    const modal = document.getElementById('validationModal');
    const modalMessage = document.getElementById('modal-message');
    const claimRewardBtn = document.getElementById('claim-reward');
    
    modalMessage.textContent = message;
    modal.style.display = 'flex';

    if (isWin) {
        claimRewardBtn.style.display = 'inline-block'; // Mostrar el botón "Reclamar Recompensa" si se gana
    } else {
        claimRewardBtn.style.display = 'none'; // Ocultar el botón si no se gana
    }
}

// Función para cerrar el modal
function closeModal() {
    const modal = document.getElementById('validationModal');
    modal.style.display = 'none';
}

// Evento para el botón de verificar bingo
document.getElementById('checkBingoButton').addEventListener('click', checkBingo);

// Nombres de los bots y asignación de imágenes de perfil
const botNames = ['elzapato', 'elGranBron', 'pedoalimaña', 'juanitoNvaja', 'Botsito333'];
const botImages = [
    '../Multimedia/img/perfil1.png',  // Imagen de perfil para el primer bot
    '../Multimedia/img/perfil2.png',  // Imagen de perfil para el segundo bot
    '../Multimedia/img/perfil3.png',  // Imagen de perfil para el tercer bot
    '../Multimedia/img/perfil4.png',  // Imagen de perfil para el cuarto bot
    '../Multimedia/img/perfil5.png'   // Imagen de perfil para el quinto bot
];
const botCards = Array.from({ length: botNames.length }, () => new Set()); // Tarjetas de los bots

// Inicializar las tarjetas de los bots
function inicializarBots() {
    const botNamesContainer = document.getElementById('botNamesContainer');
    botNamesContainer.innerHTML = ''; // Limpiar el contenedor antes de llenarlo

    botCards.forEach((botCard, index) => {
        let numerosB = generarNumerosAleatorios(1, 15, 5);  // Columna B (1-15)
        let numerosI = generarNumerosAleatorios(16, 30, 5); // Columna I (16-30)
        let numerosN = generarNumerosAleatorios(31, 45, 5); // Columna N (31-45)
        let numerosG = generarNumerosAleatorios(46, 60, 5); // Columna G (46-60)
        let numerosO = generarNumerosAleatorios(61, 75, 5); // Columna O (61-75)

        // Agregar números a la tarjeta del bot
        botCard.add(...numerosB);
        botCard.add(...numerosI);
        botCard.add(...numerosN);
        botCard.add(...numerosG);
        botCard.add(...numerosO);
        
        // Agregar el espacio libre en la columna N
        botCard.delete(numerosN[2]); // Elimina un número para simular el espacio libre

        // Crear el contenedor de cada bot
        const botDiv = document.createElement('div');
        botDiv.classList.add('bot-profile'); // Añadir clase para el estilo

        // Crear la imagen de perfil
        const img = document.createElement('img');
        img.src = botImages[index]; // Asignar imagen correspondiente
        img.classList.add('profile-pic'); // Añadir clase para estilo de imagen

        // Crear el nombre del bot
        const botNameDiv = document.createElement('div');
        botNameDiv.textContent = botNames[index]; // Asignar nombre del bot
        botNameDiv.classList.add('bot-name'); // Añadir clase para el estilo del nombre

        // Agregar imagen y nombre al contenedor del bot
        botDiv.appendChild(img);
        botDiv.appendChild(botNameDiv);

        // Agregar el contenedor del bot al contenedor principal
        botNamesContainer.appendChild(botDiv);
    });
}

// Función para manejar el juego de los bots
function botsPlay(selectedNumber) {
    botCards.forEach((botCard, index) => {
        if (botCard.has(selectedNumber)) {
            botCard.delete(selectedNumber); // Elimina el número de la tarjeta del bot
            
            // Verificar si el bot ha ganado
            if (botCard.size === 0) {
                showModal (`El jugador\n ${botNames[index]} ha ganado.`, true);
                clearInterval(drawingInterval); // Detener el juego
            }
        }
    });
}

// Modificar la función generateBingoNumber para incluir bots
function generateBingoNumber() {
    if (numbers.length === 0) {
        document.getElementById('message').textContent = "Todos los números han sido seleccionados.";
        return;
    }

    const randomIndex = Math.floor(Math.random() * numbers.length);
    const selectedNumber = numbers[randomIndex];

    // Remover el número seleccionado del array
    numbers.splice(randomIndex, 1);
    numerosGenerados.push(selectedNumber);

    // Hacer que la bola desaparezca temporalmente
    const bingoBall = document.getElementById('bingoBall');
    bingoBall.style.opacity = '0';

    // Esperar 1 segundo antes de mostrar el nuevo número y cambiar el color
    setTimeout(() => {
        document.getElementById('bingoNumber').textContent = selectedNumber;

        // Determinar la letra de bingo
        let bingoLetter = "";
        if (selectedNumber <= 15) bingoLetter = "B";
        else if (selectedNumber <= 30) bingoLetter = "I";
        else if (selectedNumber <= 45) bingoLetter = "N";
        else if (selectedNumber <= 60) bingoLetter = "G";
        else bingoLetter = "O";

        document.getElementById('bingoLetter').textContent = bingoLetter;

        // Cambiar el color de la bola
        changeBallColor();

        // Agregar el número al contenedor correspondiente
        agregarNumeroContenedor(bingoLetter, selectedNumber);

        // Dictar el número generado
        dictateNumber(bingoLetter, selectedNumber);

        // Hacer que los bots jueguen
        botsPlay(selectedNumber);

        // Volver a hacer visible la bola
        bingoBall.style.opacity = '1';
    }, 1000);
}

// Llamar a la función para inicializar los bots al cargar la página
window.onload = () => {
    generarCarton();
    inicializarBots(); // Inicializar tarjetas de los bots
};

//mostrar los numeros saslidos en pantallas muy pequeñas 
function mostrarContainer() {
    const numeros = document.getElementById("nn");
    numeros.style.display = "flex";

    //cerrar automaticamente los numeros mostrados  
    setTimeout(() => {
        numeros.style.display = "none";
    }, 3000);
}
