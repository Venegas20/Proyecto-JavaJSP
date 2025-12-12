
<%@page import="Entidades.EUsuario"%>
<%
    EUsuario user = (EUsuario) session.getAttribute("usuario");
    if (user == null) {
        response.sendRedirect("../LOGIN/login.html");
    }

%>

<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SISOTEC LTE 4</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
        <link rel="stylesheet" href="../CSS/dashboard.css" />
    </head>

    <body>
        <%@ include file="includes/navbar.jsp"%>

        <%@ include file="includes/header.jsp"%>

        <!-- CONTENIDO PRINCIPAL -->
        <main class="main-content">

            <!-- **IFRAME DONDE SE CARGARÁ USUARIOS.HTML** -->
            <iframe id="contentFrame" src="" frameborder="0"
                    style="width: 100%; height: calc(100vh - 150px);"></iframe>

        </main>

        <!-- FOOTER -->
        <%@ include file="includes/footer.jsp"%>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            function actualizarFechaHora() {
                const ahora = new Date();

                // Formato de fecha
                const opcionesFecha = {
                    year: "numeric",
                    month: "2-digit",
                    day: "2-digit"
                };

                // Formato de hora
                const opcionesHora = {
                    hour: "2-digit",
                    minute: "2-digit",
                    second: "2-digit"
                };

                const fecha = ahora.toLocaleDateString("es-ES", opcionesFecha);
                const hora = ahora.toLocaleTimeString("es-ES", opcionesHora);

                document.getElementById("fechaHora").textContent = fecha + " " + hora;
            }

            // Actualiza cada segundo
            setInterval(actualizarFechaHora, 1000);

            // Ejecuta una vez al cargar
            actualizarFechaHora();


            /* ===============================
             FUNCIÓN PARA CARGAR PÁGINAS EN EL IFRAME
             ==================================*/
            function loadPage(url) {
                document.getElementById("contentFrame").src = url;
                document.querySelector(".page-title h1").textContent = "Gestión de Usuarios";
            }

            /* ABRIR/CERRAR SIDEBAR */
            document.getElementById('menuToggle').addEventListener('click', function () {
                const sidebar = document.querySelector('.sidebar');
                const topNav = document.querySelector('.top-nav');
                const mainContent = document.querySelector('.main-content');
                const footer = document.querySelector('.footer');

                sidebar.classList.toggle('active');

                if (sidebar.classList.contains('active')) {
                    topNav.style.left = '280px';
                    mainContent.style.marginLeft = '280px';
                    footer.style.marginLeft = '280px';
                } else {
                    topNav.style.left = '0';
                    mainContent.style.marginLeft = '0';
                    footer.style.marginLeft = '0';
                }
            });

            /* MENÚ DE USUARIO */
            const userMenuTrigger = document.getElementById('userMenuTrigger');
            const userMenuDropdown = document.getElementById('userMenuDropdown');

            userMenuTrigger.addEventListener('click', function (e) {
                e.stopPropagation();
                const open = userMenuDropdown.style.opacity === '1';
                userMenuDropdown.style.opacity = open ? '0' : '1';
                userMenuDropdown.style.visibility = open ? 'hidden' : 'visible';
                userMenuDropdown.style.transform = open ? 'translateY(-10px)' : 'translateY(0)';
            });

            document.addEventListener('click', () => {
                userMenuDropdown.style.opacity = '0';
                userMenuDropdown.style.visibility = 'hidden';
                userMenuDropdown.style.transform = 'translateY(-10px)';
            });

        </script>

    </body>

</html>
