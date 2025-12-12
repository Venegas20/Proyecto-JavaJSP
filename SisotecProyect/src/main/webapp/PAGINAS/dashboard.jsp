<%@page import="Entidades.EUsuario"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../DBCONEXION/conexionDB.jsp"%>

<%
    EUsuario user = (EUsuario) session.getAttribute("usuario");
    if (user == null) {
        response.sendRedirect("../LOGIN/login.html");
        return;
    }

    // Verificar si es administrador
    boolean isAdmin = false;
    try {
        String queryAdmin = "SELECT Perfil_idPerfil FROM usuarios WHERE idUsuarios = ?";
        PreparedStatement psAdmin = cn.prepareStatement(queryAdmin);
        psAdmin.setInt(1, user.getId());
        ResultSet rsAdmin = psAdmin.executeQuery();

        if (rsAdmin.next()) {
            isAdmin = (rsAdmin.getInt("Perfil_idPerfil") == 1);
        }
        rsAdmin.close();
        psAdmin.close();
    } catch (Exception e) {
        System.out.println("Error verificando admin: " + e.getMessage());
    }

    // Obtener estadísticas
    int totalTickets = 0;
    int ticketsNuevos = 0;
    int ticketsEnProceso = 0;
    int ticketsResueltos = 0;
    int ticketsCerrados = 0;
    int ticketsPendientes = 0;
    int ticketsEsteMes = 0;
    int ticketsResueltosEsteMes = 0;
    int ticketsAsignadosUsuario = 0;
    int totalUsuarios = 0;
    int totalEntidades = 0;
    double tiempoPromedioResolucion = 0;

    try {
        // 1. Estadísticas generales de tickets
        String queryStats = "SELECT Estado, COUNT(*) as cantidad FROM tickets GROUP BY Estado";
        PreparedStatement psStats = cn.prepareStatement(queryStats);
        ResultSet rsStats = psStats.executeQuery();

        while (rsStats.next()) {
            String estado = rsStats.getString("Estado");
            int cantidad = rsStats.getInt("cantidad");
            totalTickets += cantidad;

            switch (estado) {
                case "Nuevos":
                    ticketsNuevos = cantidad;
                    break;
                case "En Proceso":
                    ticketsEnProceso = cantidad;
                    break;
                case "Resuelto":
                    ticketsResueltos = cantidad;
                    break;
                case "Cerrado":
                    ticketsCerrados = cantidad;
                    break;
                case "Pendiente":
                    ticketsPendientes = cantidad;
                    break;
            }
        }
        rsStats.close();
        psStats.close();

        // 2. Tickets creados este mes
        String queryMes = "SELECT COUNT(*) as total FROM tickets WHERE MONTH(Fecha_Apertura) = MONTH(CURDATE()) AND YEAR(Fecha_Apertura) = YEAR(CURDATE())";
        PreparedStatement psMes = cn.prepareStatement(queryMes);
        ResultSet rsMes = psMes.executeQuery();
        if (rsMes.next()) {
            ticketsEsteMes = rsMes.getInt("total");
        }
        rsMes.close();
        psMes.close();

        // 3. Tickets resueltos este mes
        String queryResueltosMes = "SELECT COUNT(*) as total FROM tickets WHERE Estado IN ('Resuelto', 'Cerrado') AND MONTH(Fecha_Resolucion) = MONTH(CURDATE()) AND YEAR(Fecha_Resolucion) = YEAR(CURDATE())";
        PreparedStatement psResueltosMes = cn.prepareStatement(queryResueltosMes);
        ResultSet rsResueltosMes = psResueltosMes.executeQuery();
        if (rsResueltosMes.next()) {
            ticketsResueltosEsteMes = rsResueltosMes.getInt("total");
        }
        rsResueltosMes.close();
        psResueltosMes.close();

        // 4. Tickets asignados al usuario actual (si no es admin)
        if (!isAdmin) {
            String queryAsignados = "SELECT COUNT(*) as total FROM tickets WHERE Usuarios_idUsuarios = ? AND Estado IN ('En Proceso', 'Pendiente')";
            PreparedStatement psAsignados = cn.prepareStatement(queryAsignados);
            psAsignados.setInt(1, user.getId());
            ResultSet rsAsignados = psAsignados.executeQuery();
            if (rsAsignados.next()) {
                ticketsAsignadosUsuario = rsAsignados.getInt("total");
            }
            rsAsignados.close();
            psAsignados.close();
        }

        // 5. Total de usuarios (solo admin)
        if (isAdmin) {
            String queryUsuarios = "SELECT COUNT(*) as total FROM usuarios";
            PreparedStatement psUsuarios = cn.prepareStatement(queryUsuarios);
            ResultSet rsUsuarios = psUsuarios.executeQuery();
            if (rsUsuarios.next()) {
                totalUsuarios = rsUsuarios.getInt("total");
            }
            rsUsuarios.close();
            psUsuarios.close();
        }

        // 6. Total de entidades (solo admin)
        if (isAdmin) {
            String queryEntidades = "SELECT COUNT(*) as total FROM entidades";
            PreparedStatement psEntidades = cn.prepareStatement(queryEntidades);
            ResultSet rsEntidades = psEntidades.executeQuery();
            if (rsEntidades.next()) {
                totalEntidades = rsEntidades.getInt("total");
            }
            rsEntidades.close();
            psEntidades.close();
        }

        // 7. Tiempo promedio de resolución (solo admin)
        if (isAdmin) {
            String queryTiempo = "SELECT AVG(TIMESTAMPDIFF(HOUR, Fecha_Apertura, Fecha_Resolucion)) as promedio FROM tickets WHERE Fecha_Resolucion IS NOT NULL AND Estado IN ('Resuelto', 'Cerrado')";
            PreparedStatement psTiempo = cn.prepareStatement(queryTiempo);
            ResultSet rsTiempo = psTiempo.executeQuery();
            if (rsTiempo.next()) {
                tiempoPromedioResolucion = rsTiempo.getDouble("promedio");
                if (rsTiempo.wasNull()) {
                    tiempoPromedioResolucion = 0;
                }
            }
            rsTiempo.close();
            psTiempo.close();
        }

    } catch (SQLException e) {
        System.out.println("Error obteniendo estadísticas: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SISOTEC LTE 4 - Dashboard</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
        <link rel="stylesheet" href="../CSS/dashboard.css" />

        <!-- Chart.js -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <style>
            .stat-card {
                transition: transform 0.3s, box-shadow 0.3s;
                border-radius: 10px;
                border: none;
            }
            .stat-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
            }
            .stat-icon {
                font-size: 2.5rem;
                opacity: 0.8;
            }
            .stat-number {
                font-size: 2rem;
                font-weight: bold;
            }
            .stat-title {
                font-size: 0.9rem;
                color: #6c757d;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            .card-new {
                background: linear-gradient(45deg, #0d6efd, #0a58ca);
                color: white;
            }
            .card-process {
                background: linear-gradient(45deg, #ffc107, #e0a800);
                color: #000;
            }
            .card-resolved {
                background: linear-gradient(45deg, #198754, #157347);
                color: white;
            }
            .card-closed {
                background: linear-gradient(45deg, #6c757d, #495057);
                color: white;
            }
            .card-pending {
                background: linear-gradient(45deg, #fd7e14, #e8590c);
                color: white;
            }
            .card-users {
                background: linear-gradient(45deg, #6f42c1, #59359c);
                color: white;
            }
            .card-entities {
                background: linear-gradient(45deg, #20c997, #1aa179);
                color: white;
            }
            .card-time {
                background: linear-gradient(45deg, #17a2b8, #138496);
                color: white;
            }

            .quick-actions .btn-action {
                border-radius: 10px;
                padding: 15px;
                text-align: center;
                transition: all 0.3s;
            }
            .btn-action:hover {
                transform: scale(1.05);
            }

            .recent-tickets table tr {
                cursor: pointer;
                transition: background-color 0.2s;
            }
            .recent-tickets table tr:hover {
                background-color: #f8f9fa;
            }

            .chart-container {
                position: relative;
                height: 300px;
            }
        </style>
    </head>

    <body>
        <%@ include file="includes/navbar.jsp"%>
        <%@ include file="includes/header.jsp"%>

        <!-- CONTENIDO PRINCIPAL -->
        <main class="main-content">
            <div class="container-fluid px-4 py-4">

                <!-- BIENVENIDA -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card shadow-sm border-0 bg-light">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-md-8">
                                        <h2 class="h4 fw-bold mb-1">¡Bienvenido, <%= user.getNusuario()!= null ? user.getNusuario(): "Usuario"%>!</h2>
                                        <p class="text-muted mb-0">
                                            <%= isAdmin ? "Panel de administración del sistema de tickets" : "Panel de usuario - Gestión de tickets asignados"%>
                                        </p>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <span class="badge bg-primary fs-6">
                                            <i class="bi bi-calendar-check me-2"></i>
                                            <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())%>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ESTADÍSTICAS PRINCIPALES -->
                <div class="row mb-4">
                    <div class="col-12">
                        <h3 class="h4 fw-bold mb-3">
                            <i class="bi bi-speedometer2 me-2"></i>Estadísticas del Sistema
                        </h3>
                    </div>

                    <!-- Ticket Nuevos -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm card-new">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number"><%= ticketsNuevos%></div>
                                        <div class="stat-title">Nuevos</div>
                                        <small>Sin asignar</small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-plus-circle"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- En Proceso -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm card-process">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number"><%= ticketsEnProceso%></div>
                                        <div class="stat-title">En Proceso</div>
                                        <small>En atención</small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-gear"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Resueltos -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm card-resolved">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number"><%= ticketsResueltos%></div>
                                        <div class="stat-title">Resueltos</div>
                                        <small>Este mes: <%= ticketsResueltosEsteMes%></small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-check-circle"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Cerrados -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm card-closed">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number"><%= ticketsCerrados%></div>
                                        <div class="stat-title">Cerrados</div>
                                        <small>Finalizados</small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-archive"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Estadísticas adicionales para ADMIN -->
                    <% if (isAdmin) {%>
                    <!-- Total Usuarios -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm card-users">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number"><%= totalUsuarios%></div>
                                        <div class="stat-title">Usuarios</div>
                                        <small>Registrados</small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-people"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Total Entidades -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm card-entities">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number"><%= totalEntidades%></div>
                                        <div class="stat-title">Entidades</div>
                                        <small>Clientes/Departamentos</small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-building"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tiempo promedio -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm card-time">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number">
                                            <%= String.format("%.1f", tiempoPromedioResolucion)%>
                                        </div>
                                        <div class="stat-title">Horas Promedio</div>
                                        <small>Tiempo de resolución</small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-clock"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tickets este mes -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm" style="background: linear-gradient(45deg, #6610f2, #520dc2); color: white;">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number"><%= ticketsEsteMes%></div>
                                        <div class="stat-title">Este Mes</div>
                                        <small>Tickets creados</small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-calendar-month"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } else {%>
                    <!-- Para USUARIOS NORMALES -->
                    <!-- Tickets asignados -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card stat-card shadow-sm" style="background: linear-gradient(45deg, #6610f2, #520dc2); color: white;">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-8">
                                        <div class="stat-number"><%= ticketsAsignadosUsuario%></div>
                                        <div class="stat-title">Asignados</div>
                                        <small>Tickets pendientes</small>
                                    </div>
                                    <div class="col-4 text-end">
                                        <i class="stat-icon bi bi-person-check"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>

                <!-- GRÁFICOS Y TABLAS -->
                <div class="row mb-4">
                    <!-- Gráfico de distribución (solo admin) -->
                    <% if (isAdmin) { %>
                    <div class="col-lg-8 mb-4">
                        <div class="card shadow-sm">
                            <div class="card-header bg-white fw-bold">
                                <i class="bi bi-pie-chart me-2"></i>Distribución de Tickets
                            </div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="ticketsChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% }%>

                    <!-- ACCIONES RÁPIDAS -->
                    <div class="<%= isAdmin ? "col-lg-4" : "col-lg-12"%> mb-4">
                        <div class="card shadow-sm">
                            <div class="card-header bg-white fw-bold">
                                <i class="bi bi-lightning me-2"></i>Acciones Rápidas
                            </div>
                            <div class="card-body">
                                <div class="row quick-actions g-3">
                                    <% if (isAdmin) { %>
                                    <div class="col-md-6">
                                        <a href="tickets.jsp" class="btn btn-outline-primary btn-action d-flex flex-column align-items-center">
                                            <i class="bi bi-plus-circle fs-3 mb-2"></i>
                                            <span>Nuevo Ticket</span>
                                        </a>
                                    </div>
                                    <div class="col-md-6">
                                        <a href="tickets.jsp" class="btn btn-outline-success btn-action d-flex flex-column align-items-center">
                                            <i class="bi bi-list-task fs-3 mb-2"></i>
                                            <span>Ver Todos</span>
                                        </a>
                                    </div>
                                    <div class="col-md-6">
                                        <a href="entidades.jsp" class="btn btn-outline-info btn-action d-flex flex-column align-items-center">
                                            <i class="bi bi-building fs-3 mb-2"></i>
                                            <span>Entidades</span>
                                        </a>
                                    </div>
                                    <div class="col-md-6">
                                        <a href="usuarios.jsp" class="btn btn-outline-warning btn-action d-flex flex-column align-items-center">
                                            <i class="bi bi-people fs-3 mb-2"></i>
                                            <span>Usuarios</span>
                                        </a>
                                    </div>
                                    <% } else { %>
                                    <div class="col-md-4">
                                        <a href="tickets.jsp" class="btn btn-outline-primary btn-action d-flex flex-column align-items-center">
                                            <i class="bi bi-eye fs-3 mb-2"></i>
                                            <span>Mis Tickets</span>
                                        </a>
                                    </div>
                                    <div class="col-md-4">
                                        <a href="tickets.jsp?filter=proceso" class="btn btn-outline-warning btn-action d-flex flex-column align-items-center">
                                            <i class="bi bi-gear fs-3 mb-2"></i>
                                            <span>En Proceso</span>
                                        </a>
                                    </div>
                                    <div class="col-md-4">
                                        <a href="tickets.jsp?filter=resueltos" class="btn btn-outline-success btn-action d-flex flex-column align-items-center">
                                            <i class="bi bi-check-circle fs-3 mb-2"></i>
                                            <span>Resueltos</span>
                                        </a>
                                    </div>
                                    <% }%>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TICKETS RECIENTES -->
                <div class="row">
                    <div class="col-12">
                        <div class="card shadow-sm recent-tickets">
                            <div class="card-header bg-white fw-bold d-flex justify-content-between align-items-center">
                                <span>
                                    <i class="bi bi-clock-history me-2"></i>
                                    <%= isAdmin ? "Tickets Recientes" : "Mis Tickets Recientes"%>
                                </span>
                                <a href="tickets.jsp" class="btn btn-sm btn-outline-primary">
                                    Ver todos <i class="bi bi-arrow-right ms-1"></i>
                                </a>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>ID</th>
                                                <th>Título</th>
                                                <th>Estado</th>
                                                <th>Fecha</th>
                                                <th>Solicitante</th>
                                                <% if (isAdmin) { %><th>Asignado a</th><% } %>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                // Consulta para tickets recientes
                                                String queryRecientes;
                                                PreparedStatement psRecientes;

                                                if (isAdmin) {
                                                    queryRecientes = "SELECT t.*, e.Nombre_Entidad, u.Nombre_Usuario as Asignado_A "
                                                            + "FROM tickets t "
                                                            + "LEFT JOIN entidades e ON t.Entidades_idEntidades = e.idEntidades "
                                                            + "LEFT JOIN usuarios u ON t.Usuarios_idUsuarios = u.idUsuarios "
                                                            + "ORDER BY t.Fecha_Apertura DESC LIMIT 10";
                                                    psRecientes = cn.prepareStatement(queryRecientes);
                                                } else {
                                                    queryRecientes = "SELECT t.*, e.Nombre_Entidad "
                                                            + "FROM tickets t "
                                                            + "LEFT JOIN entidades e ON t.Entidades_idEntidades = e.idEntidades "
                                                            + "WHERE t.Usuarios_idUsuarios = ? "
                                                            + "ORDER BY t.Fecha_Apertura DESC LIMIT 10";
                                                    psRecientes = cn.prepareStatement(queryRecientes);
                                                    psRecientes.setInt(1, user.getId());
                                                }

                                                ResultSet rsRecientes = psRecientes.executeQuery();
                                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");

                                                while (rsRecientes.next()) {
                                                    String estado = rsRecientes.getString("Estado");
                                                    String badgeClass = "";

                                                    switch (estado) {
                                                        case "Nuevos":
                                                            badgeClass = "bg-primary";
                                                            break;
                                                        case "En Proceso":
                                                            badgeClass = "bg-warning text-dark";
                                                            break;
                                                        case "Resuelto":
                                                            badgeClass = "bg-success";
                                                            break;
                                                        case "Cerrado":
                                                            badgeClass = "bg-secondary";
                                                            break;
                                                        case "Pendiente":
                                                            badgeClass = "bg-danger";
                                                            break;
                                                    }
                                            %>
                                            <tr onclick="window.location.href = 'tickets.jsp#ticket-<%= rsRecientes.getInt("idTickets")%>'">
                                                <td><strong>#<%= rsRecientes.getInt("idTickets")%></strong></td>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <i class="bi bi-ticket-detailed me-2 text-muted"></i>
                                                        <%= rsRecientes.getString("Titulo").length() > 50
                                                                ? rsRecientes.getString("Titulo").substring(0, 50) + "..."
                                                                : rsRecientes.getString("Titulo")%>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="badge <%= badgeClass%>">
                                                        <%= estado%>
                                                    </span>
                                                </td>
                                                <td>
                                                    <%= sdf.format(rsRecientes.getTimestamp("Fecha_Apertura"))%>
                                                </td>
                                                <td><%= rsRecientes.getString("Solicitante")%></td>
                                                <% if (isAdmin) {%>
                                                <td><%= rsRecientes.getString("Asignado_A") != null ? rsRecientes.getString("Asignado_A") : "Sin asignar"%></td>
                                                <% } %>
                                            </tr>
                                            <%
                                                }
                                                rsRecientes.close();
                                                psRecientes.close();
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- FOOTER -->
        <%@ include file="includes/footer.jsp"%>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                                                function actualizarFechaHora() {
                                                    const ahora = new Date();
                                                    const opcionesFecha = {year: "numeric", month: "2-digit", day: "2-digit"};
                                                    const opcionesHora = {hour: "2-digit", minute: "2-digit", second: "2-digit"};

                                                    const fecha = ahora.toLocaleDateString("es-ES", opcionesFecha);
                                                    const hora = ahora.toLocaleTimeString("es-ES", opcionesHora);

                                                    const fechaHoraElement = document.getElementById("fechaHora");
                                                    if (fechaHoraElement) {
                                                        fechaHoraElement.textContent = fecha + " " + hora;
                                                    }
                                                }

                                                setInterval(actualizarFechaHora, 1000);
                                                actualizarFechaHora();

                                                // Gráfico de distribución (solo para admin)
            <% if (isAdmin) {%>
                                                document.addEventListener('DOMContentLoaded', function () {
                                                    const ctx = document.getElementById('ticketsChart').getContext('2d');
                                                    const ticketsChart = new Chart(ctx, {
                                                        type: 'doughnut',
                                                        data: {
                                                            labels: ['Nuevos', 'En Proceso', 'Resueltos', 'Cerrados', 'Pendientes'],
                                                            datasets: [{
                                                                    data: [
            <%= ticketsNuevos%>,
            <%= ticketsEnProceso%>,
            <%= ticketsResueltos%>,
            <%= ticketsCerrados%>,
            <%= ticketsPendientes%>
                                                                    ],
                                                                    backgroundColor: [
                                                                        '#0d6efd', // Nuevos - Azul
                                                                        '#ffc107', // En Proceso - Amarillo
                                                                        '#198754', // Resueltos - Verde
                                                                        '#6c757d', // Cerrados - Gris
                                                                        '#fd7e14'  // Pendientes - Naranja
                                                                    ],
                                                                    borderWidth: 2,
                                                                    borderColor: '#fff'
                                                                }]
                                                        },
                                                        options: {
                                                            responsive: true,
                                                            maintainAspectRatio: false,
                                                            plugins: {
                                                                legend: {
                                                                    position: 'bottom',
                                                                    labels: {
                                                                        padding: 20,
                                                                        usePointStyle: true
                                                                    }
                                                                },
                                                                tooltip: {
                                                                    callbacks: {
                                                                        label: function (context) {
                                                                            const label = context.label || '';
                                                                            const value = context.raw || 0;
                                                                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                                                            const percentage = Math.round((value / total) * 100);
                                                                            return `${label}: ${value} (${percentage}%)`;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    });
                                                });
            <% }%>

                                                // Función para cargar página en iframe (manteniendo tu función original)
                                                function loadPage(url) {
                                                    const contentFrame = document.getElementById("contentFrame");
                                                    if (contentFrame) {
                                                        contentFrame.src = url;
                                                    }
                                                    const pageTitle = document.querySelector(".page-title h1");
                                                    if (pageTitle) {
                                                        pageTitle.textContent = "Gestión de Usuarios";
                                                    }
                                                }

                                                /* ABRIR/CERRAR SIDEBAR */
                                                const menuToggle = document.getElementById('menuToggle');
                                                if (menuToggle) {
                                                    menuToggle.addEventListener('click', function () {
                                                        const sidebar = document.querySelector('.sidebar');
                                                        const topNav = document.querySelector('.top-nav');
                                                        const mainContent = document.querySelector('.main-content');
                                                        const footer = document.querySelector('.footer');

                                                        if (sidebar)
                                                            sidebar.classList.toggle('active');

                                                        if (sidebar && sidebar.classList.contains('active')) {
                                                            if (topNav)
                                                                topNav.style.left = '280px';
                                                            if (mainContent)
                                                                mainContent.style.marginLeft = '280px';
                                                            if (footer)
                                                                footer.style.marginLeft = '280px';
                                                        } else {
                                                            if (topNav)
                                                                topNav.style.left = '0';
                                                            if (mainContent)
                                                                mainContent.style.marginLeft = '0';
                                                            if (footer)
                                                                footer.style.marginLeft = '0';
                                                        }
                                                    });
                                                }

                                                /* MENÚ DE USUARIO */
                                                const userMenuTrigger = document.getElementById('userMenuTrigger');
                                                const userMenuDropdown = document.getElementById('userMenuDropdown');

                                                if (userMenuTrigger && userMenuDropdown) {
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
                                                }

                                                // Actualizar estadísticas cada 60 segundos
                                                setInterval(function () {
                                                    fetch('ajax/actualizar-estadisticas.jsp')
                                                            .then(response => response.json())
                                                            .then(data => {
                                                                // Actualizar contadores si es necesario
                                                                console.log('Estadísticas actualizadas', data);
                                                            })
                                                            .catch(error => console.error('Error actualizando estadísticas:', error));
                                                }, 60000);
        </script>
    </body>
</html>