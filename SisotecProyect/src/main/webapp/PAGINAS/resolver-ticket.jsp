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

    // Si es admin, redirigir a tickets
    if (isAdmin) {
        response.sendRedirect("tickets.jsp");
        return;
    }

    String idTicket = request.getParameter("id");
    if (idTicket == null) {
        response.sendRedirect("tickets.jsp");
        return;
    }

    // Obtener información del ticket y verificar que está asignado al usuario
    String query = "SELECT t.*, e.Nombre_Entidad " +
                   "FROM tickets t " +
                   "LEFT JOIN entidades e ON t.Entidades_idEntidades = e.idEntidades " +
                   "WHERE t.idTickets = ? AND t.Usuarios_idUsuarios = ? AND t.Estado = 'En Proceso'";
    
    PreparedStatement ps = cn.prepareStatement(query);
    ps.setInt(1, Integer.parseInt(idTicket));
    ps.setInt(2, user.getId());
    
    ResultSet rs = ps.executeQuery();
    
    if (!rs.next()) {
        session.setAttribute("error", "No tiene permisos para resolver este ticket o no está en estado 'En Proceso'");
        response.sendRedirect("tickets.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Resolver Ticket - SISOTEC LTE 4</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
        <link rel="stylesheet" href="../CSS/dashboard.css" />
        
        <style>
            .ticket-info-card {
                border-left: 4px solid #198754;
            }
        </style>
    </head>

    <body>
        <%@ include file="includes/navbar.jsp"%>
        <%@ include file="includes/header.jsp"%>

        <!-- Mostrar mensajes de error/éxito -->
        <% if (session.getAttribute("error") != null) { %>
        <div class="container mt-3">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= session.getAttribute("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </div>
        <% session.removeAttribute("error"); } %>
        
        <% if (session.getAttribute("exito") != null) { %>
        <div class="container mt-3">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <%= session.getAttribute("exito") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </div>
        <% session.removeAttribute("exito"); } %>

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
                                        <i class="bi bi-check-circle me-2"></i>Resolver Ticket
                                    </h2>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- FORMULARIO DE RESOLUCIÓN -->
                <div class="row justify-content-center">
                    <div class="col-md-8">
                        <div class="card shadow-sm">
                            <div class="card-header bg-success text-white fw-bold">
                                <i class="bi bi-ticket-detailed me-2"></i>Ticket #<%= idTicket %>
                            </div>

                            <div class="card-body">
                                <!-- Información del Ticket -->
                                <div class="card ticket-info-card mb-4">
                                    <div class="card-body">
                                        <h5 class="card-title"><%= rs.getString("Titulo") %></h5>
                                        <hr>
                                        <div class="row">
                                            <div class="col-md-6">
                                                <p><strong>Solicitante:</strong> <%= rs.getString("Solicitante") %></p>
                                                <p><strong>Ubicación:</strong> <%= rs.getString("Ubicacion_Sede") %></p>
                                            </div>
                                            <div class="col-md-6">
                                                <p><strong>Entidad:</strong> <%= rs.getString("Nombre_Entidad") %></p>
                                                <p><strong>Fecha Apertura:</strong> <%= rs.getTimestamp("Fecha_Apertura") %></p>
                                            </div>
                                        </div>
                                        <% if (rs.getString("Solucion") != null && !rs.getString("Solucion").isEmpty()) { %>
                                        <div class="mt-3">
                                            <p><strong>Solución anterior:</strong></p>
                                            <div class="alert alert-warning">
                                                <%= rs.getString("Solucion") %>
                                            </div>
                                        </div>
                                        <% } %>
                                    </div>
                                </div>

                                <!-- Formulario de Resolución -->
                                <form action="procesar/tickets-process.jsp" method="post">
                                    <input type="hidden" name="action" value="resolver">
                                    <input type="hidden" name="id" value="<%= idTicket %>">
                                    
                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Solución *</label>
                                        <textarea name="solucion" class="form-control" rows="8" 
                                                  placeholder="Describa la solución aplicada al problema..." required><%= rs.getString("Solucion") != null ? rs.getString("Solucion") : "" %></textarea>
                                        <div class="form-text">
                                            Sea lo más detallado posible. Incluya pasos seguidos, componentes reemplazados, 
                                            configuración aplicada, etc.
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Estado Final *</label>
                                        <select name="estado" class="form-select" required>
                                            <option value="Resuelto" <%= "Resuelto".equals(rs.getString("Estado")) ? "selected" : "" %>>Resuelto</option>
                                            <option value="Cerrado" <%= "Cerrado".equals(rs.getString("Estado")) ? "selected" : "" %>>Cerrado</option>
                                            <option value="Pendiente" <%= "Pendiente".equals(rs.getString("Estado")) ? "selected" : "" %>>Pendiente (Requiere seguimiento)</option>
                                        </select>
                                        <div class="form-text">
                                            <strong>Resuelto:</strong> El problema ha sido solucionado completamente.<br>
                                            <strong>Cerrado:</strong> El ticket se cierra (ej: problema duplicado, no es un problema).<br>
                                            <strong>Pendiente:</strong> Requiere más información o seguimiento.
                                        </div>
                                    </div>
                                    
                                    <div class="d-flex justify-content-between">
                                        <a href="tickets.jsp" class="btn btn-secondary">
                                            <i class="bi bi-arrow-left me-1"></i> Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-success">
                                            <i class="bi bi-check-circle me-1"></i> Registrar Solución
                                        </button>
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
        
        <script>
            // Validar formulario antes de enviar
            document.querySelector('form').addEventListener('submit', function(e) {
                const solucion = document.querySelector('textarea[name="solucion"]').value.trim();
                if (solucion.length < 10) {
                    e.preventDefault();
                    alert('La solución debe tener al menos 10 caracteres');
                    return false;
                }
            });
        </script>
    </body>
</html>
<%
    rs.close();
    ps.close();
%>