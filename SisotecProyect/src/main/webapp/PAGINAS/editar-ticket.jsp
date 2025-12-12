<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
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

    if (!isAdmin) {
        response.sendRedirect("tickets.jsp");
        return;
    }

    String idTicket = request.getParameter("edit");
    if (idTicket == null) {
        response.sendRedirect("tickets.jsp");
        return;
    }

    // Obtener información del ticket
    String query = "SELECT t.*, e.Nombre_Entidad, u.Nombre_Usuario as Asignado_A, u.idUsuarios as idUsuarioAsignado " +
                   "FROM tickets t " +
                   "LEFT JOIN entidades e ON t.Entidades_idEntidades = e.idEntidades " +
                   "LEFT JOIN usuarios u ON t.Usuarios_idUsuarios = u.idUsuarios " +
                   "WHERE t.idTickets = ?";
    
    PreparedStatement ps = cn.prepareStatement(query);
    ps.setInt(1, Integer.parseInt(idTicket));
    
    ResultSet rs = ps.executeQuery();
    
    if (!rs.next()) {
        session.setAttribute("error", "Ticket no encontrado");
        response.sendRedirect("tickets.jsp");
        return;
    }
    
    // Formatear fecha para input datetime-local
    String fechaResolucion = "";
    Timestamp ts = rs.getTimestamp("Fecha_Resolucion");
    if (ts != null) {
        fechaResolucion = ts.toLocalDateTime().toString().replace(" ", "T").substring(0, 16);
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Editar Ticket - SISOTEC LTE 4</title>

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
            <div class="container-fluid px-4 py-4">

                <!-- HEADER -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="header-solid text-white p-2 rounded-3 shadow-sm">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <h2 class="h2 fw-bold mb-2 text-dark">
                                        <i class="bi bi-pencil-square me-2"></i>Editar Ticket
                                    </h2>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- FORMULARIO DE EDICIÓN -->
                <div class="row justify-content-center">
                    <div class="col-md-10">
                        <div class="card shadow-sm">
                            <div class="card-header bg-primary text-white fw-bold">
                                <i class="bi bi-ticket-detailed me-2"></i>Ticket #<%= idTicket %>
                            </div>

                            <div class="card-body">
                                <form action="procesar/tickets-process.jsp" method="post">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="id" value="<%= idTicket %>">
                                    
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Título *</label>
                                            <input type="text" name="titulo" class="form-control" 
                                                   value="<%= rs.getString("Titulo") %>" required>
                                        </div>
                                        
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Estado *</label>
                                            <select name="estado" class="form-select" required>
                                                <option value="Nuevos" <%= "Nuevos".equals(rs.getString("Estado")) ? "selected" : "" %>>Nuevos</option>
                                                <option value="En Proceso" <%= "En Proceso".equals(rs.getString("Estado")) ? "selected" : "" %>>En Proceso</option>
                                                <option value="Resuelto" <%= "Resuelto".equals(rs.getString("Estado")) ? "selected" : "" %>>Resuelto</option>
                                                <option value="Cerrado" <%= "Cerrado".equals(rs.getString("Estado")) ? "selected" : "" %>>Cerrado</option>
                                                <option value="Pendiente" <%= "Pendiente".equals(rs.getString("Estado")) ? "selected" : "" %>>Pendiente</option>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Solicitante *</label>
                                            <input type="text" name="solicitante" class="form-control" 
                                                   value="<%= rs.getString("Solicitante") %>" required>
                                        </div>
                                        
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Ubicación/Sede *</label>
                                            <input type="text" name="ubicacion" class="form-control" 
                                                   value="<%= rs.getString("Ubicacion_Sede") %>" required>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Entidad *</label>
                                            <select name="entidad" class="form-select" required>
                                                <option value="">Seleccionar entidad...</option>
                                                <%
                                                    PreparedStatement psEntidades = cn.prepareStatement("SELECT idEntidades, Nombre_Entidad FROM entidades ORDER BY Nombre_Entidad");
                                                    ResultSet rsEntidades = psEntidades.executeQuery();
                                                    while (rsEntidades.next()) {
                                                        String selected = rsEntidades.getInt("idEntidades") == rs.getInt("Entidades_idEntidades") ? "selected" : "";
                                                %>
                                                <option value="<%= rsEntidades.getInt("idEntidades") %>" <%= selected %>>
                                                    <%= rsEntidades.getString("Nombre_Entidad") %>
                                                </option>
                                                <% } 
                                                rsEntidades.close();
                                                psEntidades.close();
                                                %>
                                            </select>
                                        </div>
                                        
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Asignar a</label>
                                            <select name="usuario_asignado" class="form-select">
                                                <option value="">Sin asignar</option>
                                                <%
                                                    PreparedStatement psUsuarios = cn.prepareStatement(
                                                        "SELECT idUsuarios, Nombre_Usuario " +
                                                        "FROM usuarios " +
                                                        "WHERE Perfil_idPerfil != 1 OR Perfil_idPerfil IS NULL " +
                                                        "ORDER BY Nombre_Usuario"
                                                    );
                                                    ResultSet rsUsuarios = psUsuarios.executeQuery();
                                                    while (rsUsuarios.next()) {
                                                        String selected = rsUsuarios.getInt("idUsuarios") == rs.getInt("idUsuarioAsignado") ? "selected" : "";
                                                %>
                                                <option value="<%= rsUsuarios.getInt("idUsuarios") %>" <%= selected %>>
                                                    <%= rsUsuarios.getString("Nombre_Usuario") %>
                                                </option>
                                                <% } 
                                                rsUsuarios.close();
                                                psUsuarios.close();
                                                %>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Fecha Resolución</label>
                                            <input type="datetime-local" name="fecha_resolucion" class="form-control" 
                                                   value="<%= fechaResolucion %>">
                                            <div class="form-text">
                                                Dejar vacío para usar fecha actual cuando el estado sea Resuelto o Cerrado
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Solución</label>
                                        <textarea name="solucion" class="form-control" rows="6"><%= rs.getString("Solucion") != null ? rs.getString("Solucion") : "" %></textarea>
                                    </div>
                                    
                                    <div class="d-flex justify-content-between">
                                        <a href="tickets.jsp" class="btn btn-secondary">
                                            <i class="bi bi-arrow-left me-1"></i> Cancelar
                                        </a>
                                        <div>
                                            <a href="procesar/tickets-process.jsp?action=delete&id=<%= idTicket %>" 
                                               class="btn btn-danger me-2"
                                               onclick="return confirm('¿Está seguro de eliminar este ticket?')">
                                                <i class="bi bi-trash me-1"></i> Eliminar
                                            </a>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="bi bi-save me-1"></i> Guardar Cambios
                                            </button>
                                        </div>
                                    </div>
                                </form>
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
    </body>
</html>
<%
    rs.close();
    ps.close();
%>