
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

        <!-- Barra lateral -->
        <nav class="sidebar">
            <div class="sidebar-header">
                <h2><i class="fas fa-tachometer-alt"></i> SISOTEC</h2>
                <p>Sistema de soporte técnico</p>
            </div>

            <div class="sidebar-menu">

                <h3>Panel de Tablas</h3>
                <ul>
                    <%          if (user != null && user.getPid() == 1) {
                    %>

                    <li class="active">
                        <a href="usuarios.jsp">
                            <i class="fas fa-user"></i> Gestión de usuarios
                        </a>
                    </li>
                    <li><a href="#"><i class="fas fa-desktop"></i> Gestión de Entidad</a></li>
                    <li><a href="#"><i class="fas fa-chart-line"></i> Gestión de Perfil</a></li>
                        <%}%>
                    <li><a href="#"><i class="fas fa-ticket"></i> Gestión de Tickets</a></li>
                </ul>

                <h3>MANTENIMIENTO</h3>
                <%
                    if (user != null && user.getPid() == 1) {

                %>
                <ul>
                    <li><a href="#"><i class="fas fa-window-restore"></i> Formularios</a></li>
                    <li><a href="#"><i class="fas fa-table"></i> Tablas</a></li>
                    <li><a href="#"><i class="fas fa-id-card"></i> Empleados</a></li>
                    <li><a href="#"><i class="fas fa-user-check"></i> Autorización</a></li>
                </ul>

                <h3>CONFIGURACIÓN</h3>
                <ul>
                    <li><a href="#"><i class="fas fa-cog"></i> Ajustes del sistema</a></li>
                    <li><a href="#"><i class="fas fa-users"></i> Usuarios</a></li>
                    <li><a href="#"><i class="fas fa-shield-alt"></i> Seguridad</a></li>
                </ul>
                <%}%>
            </div>
        </nav>

        <!-- NAV SUPERIOR -->
        <header class="top-nav">
            <div class="top-nav-content">

                <div class="top-nav-left">
                    <button class="menu-toggle" id="menuToggle">
                        <i class="fas fa-bars"></i>
                    </button>

                    <div class="page-title">
                        <h1><b>SISOTEC</b></h1>
                    </div>
                </div>

                <div class="top-navigation">
                    <ul class="nav-menu">
                        <li><a class="active" href="#">Reportes</a></li>
                        <li><a href="#">Mantenimiento</a></li>
                        <li><a href="#">Configuración</a></li>
                        <li><a href="#">Ayuda</a></li>
                    </ul>

                    <!-- Menú de usuario -->
                    <div class="user-menu-container">
                        <div class="user-menu-trigger" id="userMenuTrigger">
                            <div class="user-avatar" ><i class="fa-solid fa-users"></i></div>
                            <div class="user-info">

                                <div class="user-name">
                                    <% if (user != null) {%>
                                    <%= user.getUsuario()%>
                                    <% }%></div>
                                <div class="user-role" id="fechaHora"></div>
                            </div>
                            <i class="fas fa-chevron-down ms-2"></i>
                        </div>

                        <div class="user-menu-dropdown" id="userMenuDropdown">
                            <ul>
                                <li><a href="#" id="changeUserBtn"><i class="fas fa-exchange-alt"></i> Cambiar usuario</a></li>
                                <li><a href="../LOGIN/logout.jsp" id="logoutBtn"><i class="fas fa-sign-out-alt"></i> Cerrar sesión</a></li>
                            </ul>
                        </div>
                    </div>

                </div>
            </div>
        </header>

        <!-- CONTENIDO PRINCIPAL -->
        <main class="main-content">

            <!-- **IFRAME DONDE SE CARGARÁ USUARIOS.HTML** -->
            <iframe id="contentFrame" src="" frameborder="0"
                    style="width: 100%; height: calc(100vh - 150px);"></iframe>

        </main>

        <!-- FOOTER -->
        <footer class="footer">
            <div class="footer-content">
                <p>&copy; 2025 SISOTEC LTE V-0.0.01 - Sistema de Soporte Técnico. Todos los derechos reservados.</p>
            </div>
        </footer>

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
