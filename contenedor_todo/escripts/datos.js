/**json de perfil de usuario */

function datousuario() {
    $.ajax({
        type: 'POST',
        url: 'Back_PHP/datosUsuario.php',
        dataType: 'json',
        success: function(data) {
            if (data.status == 'okey') {
                $('#nombreusuario').text(data.result.NombreUsuario);
                $('#monedas').text(data.result.Monedas);
                $('#id').text(data.result.ID_Usuario);
                $('#PartidasGanadas').text(data.result.PartidasGana);
            } else {
                alert("Usuario no encontrado o no ha iniciado sesión");
            }
        }
    });
}


$(document).ready(function() {
    datousuario();
});