
<%@page import="Entidades.EUsuario"%>
<%
    EUsuario user1 = (EUsuario) session.getAttribute("usuario");

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
            <%          if (user1 != null && user1.getPid() == 1) {
            %>

            <li class="active">
                <a href="usuarios.jsp">
                    <i class="fas fa-user"></i> Gestión de usuarios
                </a>
            </li>
            <li><a href="entidades.jsp"><i class="fas fa-desktop"></i> Gestión de Entidad</a></li>
            <li><a href="#"><i class="fas fa-chart-line"></i> Gestión de Perfil</a></li>
                <%}%>
            <li><a href="tickets.jsp"><i class="fas fa-ticket"></i> Gestión de Tickets</a></li>
        </ul>

        <h3>MANTENIMIENTO</h3>
        <%
            if (user1 != null && user1.getPid() == 1) {

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