
<%@page import="Entidades.EUsuario"%>
<%
    EUsuario user2 = (EUsuario) session.getAttribute("usuario");


%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
                            <% if (user2 != null) {%>
                            <%= user2.getUsuario()%>
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
