<%@page import="Entidades.EUsuario"%>
<%
    EUsuario user1 = (EUsuario) session.getAttribute("usuario");

    // Obtener el nombre del archivo actual
    String servletPath = request.getServletPath();
    String nombreArchivo = servletPath.substring(servletPath.lastIndexOf("/") + 1);
    // Función para verificar si el archivo es activo


%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- Barra lateral -->
<nav class="sidebar">
    <div class="sidebar-header">
        <h2><i class="fas fa-tachometer-alt"></i> SISOTEC</h2>
        <p>Sistema de soporte técnico</p>
    </div>

    <div class="sidebar-menu">

        <h3>Panel de Tablas</h3>
        <ul>
            <li class="<%= nombreArchivo.equals("dashboard.jsp") ? "active" : ""%>">
                <a href="dashboard.jsp">
                    <i class="fas fa-user"></i> Dashboard 
                </a>
            </li>
            <% if (user1 != null && user1.getPid() == 1) {%>

            <li class="<%= nombreArchivo.equals("usuarios.jsp") ? "active" : ""%>">
                <a href="usuarios.jsp">
                    <i class="fas fa-user"></i> Gestión de usuarios
                </a>
            </li>
            <li class="<%= nombreArchivo.equals("entidades.jsp") ? "active" : ""%>">
                <a href="entidades.jsp"><i class="fas fa-desktop"></i> Gestión de Entidad</a>
            </li>
            <li class="<%= nombreArchivo.equals("perfiles.jsp") ? "active" : ""%>">
                <a href="perfiles.jsp"><i class="fas fa-chart-line"></i> Gestión de Perfil</a>
            </li>
            <% }%>
            <li class="<%= nombreArchivo.equals("tickets.jsp") ? "active" : ""%>">
                <a href="tickets.jsp"><i class="fas fa-ticket"></i> Gestión de Tickets</a>
            </li>
        </ul>

        <% if (user1
                    != null && user1.getPid()
                    == 1) {%>
        <h3>REPORTES</h3>
        <ul>
            <li class="<%= nombreArchivo.equals("reportes.jsp") ? "active" : ""%>">
                <a href="reportes.jsp"><i class="fas fa-window-restore"></i> Reportes</a>
            </li>
            <li class="<%=  ""%>">
                <a href="#"><i class="fas fa-table"></i> Tablas</a>
            </li>
            <li class="<%=  ""%>">
                <a href="#"><i class="fas fa-id-card"></i> Empleados</a>
            </li>
            <li class="<%=  ""%>">
                <a href="#"><i class="fas fa-user-check"></i> Autorización</a>
            </li>
        </ul>

        <h3>CONFIGURACIÓN</h3>
        <ul>
            <li class="<%=  ""%>">
                <a href="#"><i class="fas fa-cog"></i> Ajustes del sistema</a>
            </li>
            <li class="<%=  ""%>">
                <a href="#"><i class="fas fa-users"></i> Usuarios</a>
            </li>
            <li class="<%=  ""%>">
                <a href="#"><i class="fas fa-shield-alt"></i> Seguridad</a>
            </li>
        </ul>
        <% }%>
    </div>
</nav>