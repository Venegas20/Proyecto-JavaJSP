<%@page import="java.sql.*"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ include file="../../DBCONEXION/conexionDB.jsp"%>

<%
    String idTicket = request.getParameter("id");
    if (idTicket == null || idTicket.isEmpty()) {
        out.print("<div class='alert alert-danger'>ID de ticket no proporcionado</div>");
        return;
    }
    
    // Verificar que sea numérico
    try {
        Integer.parseInt(idTicket);
    } catch (NumberFormatException e) {
        out.print("<div class='alert alert-danger'>ID de ticket inválido</div>");
        return;
    }
    
    String query = "SELECT t.*, e.Nombre_Entidad, u.Nombre_Usuario as Asignado_A " +
                   "FROM tickets t " +
                   "LEFT JOIN entidades e ON t.Entidades_idEntidades = e.idEntidades " +
                   "LEFT JOIN usuarios u ON t.Usuarios_idUsuarios = u.idUsuarios " +
                   "WHERE t.idTickets = ?";
    
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        ps = cn.prepareStatement(query);
        ps.setInt(1, Integer.parseInt(idTicket));
        rs = ps.executeQuery();
        
        if (!rs.next()) {
            out.print("<div class='alert alert-warning'>Ticket no encontrado</div>");
            return;
        }
        
        String estado = rs.getString("Estado");
        String badgeClass = "";
        
        if (estado != null) {
            switch(estado) {
                case "Nuevos": 
                    badgeClass = "badge-nuevo"; 
                    break;
                case "En Proceso": 
                    badgeClass = "badge-en-proceso"; 
                    break;
                case "Resuelto": 
                    badgeClass = "badge-resuelto"; 
                    break;
                case "Cerrado": 
                    badgeClass = "badge-cerrado"; 
                    break;
                case "Pendiente": 
                    badgeClass = "badge-pendiente"; 
                    break;
                default: 
                    badgeClass = "badge-secondary";
            }
        }
        
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>

<!-- MODAL individual -->
<div class="modal fade" id="detalleTicketModal<%= idTicket %>" tabindex="-1" aria-labelledby="detalleTicketModalLabel<%= idTicket %>" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="detalleTicketModalLabel<%= idTicket %>">
                    <i class="bi bi-ticket-detailed me-2"></i>Ticket #<%= idTicket %>
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row mb-3">
                    <div class="col-12">
                        <h4><%= rs.getString("Titulo") != null ? rs.getString("Titulo") : "Sin título" %></h4>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="card mb-3">
                            <div class="card-header bg-light">
                                <strong>Información General</strong>
                            </div>
                            <div class="card-body">
                                <p><strong>Estado:</strong> 
                                    <span class="badge <%= badgeClass %>"><%= estado != null ? estado : "Desconocido" %></span>
                                </p>
                                
                                <% 
                                    Timestamp fechaApertura = rs.getTimestamp("Fecha_Apertura");
                                    if (fechaApertura != null) {
                                %>
                                <p><strong>Fecha Apertura:</strong> 
                                    <%= dtf.format(fechaApertura.toLocalDateTime()) %>
                                </p>
                                <% } %>
                                
                                <% 
                                    Timestamp fechaResolucion = rs.getTimestamp("Fecha_Resolucion");
                                    if (fechaResolucion != null) {
                                %>
                                <p><strong>Fecha Resolución:</strong> 
                                    <%= dtf.format(fechaResolucion.toLocalDateTime()) %>
                                </p>
                                <% } %>
                                
                                <p><strong>Entidad:</strong> 
                                    <%= rs.getString("Nombre_Entidad") != null ? rs.getString("Nombre_Entidad") : "Sin entidad" %>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="card mb-3">
                            <div class="card-header bg-light">
                                <strong>Información de Contacto</strong>
                            </div>
                            <div class="card-body">
                                <p><strong>Solicitante:</strong> 
                                    <%= rs.getString("Solicitante") != null ? rs.getString("Solicitante") : "No especificado" %>
                                </p>
                                
                                <p><strong>Ubicación/Sede:</strong> 
                                    <%= rs.getString("Ubicacion_Sede") != null ? rs.getString("Ubicacion_Sede") : "No especificada" %>
                                </p>
                                
                                <p><strong>Asignado a:</strong> 
                                    <%= rs.getString("Asignado_A") != null ? rs.getString("Asignado_A") : "Sin asignar" %>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <% if (rs.getString("Solucion") != null && !rs.getString("Solucion").isEmpty()) { %>
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header bg-light">
                                <strong>Solución Aplicada</strong>
                            </div>
                            <div class="card-body">
                                <div class="alert alert-light border">
                                    <%= rs.getString("Solucion").replace("\n", "<br>") %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } else { %>
                <div class="row">
                    <div class="col-12">
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle me-2"></i>Este ticket aún no tiene una solución registrada.
                        </div>
                    </div>
                </div>
                <% } %>
                
                <!-- Historial de cambios (opcional, si tienes tabla de historial) -->
                <!--
                <div class="row mt-3">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header bg-light">
                                <strong>Historial</strong>
                            </div>
                            <div class="card-body">
                                <small class="text-muted">Aquí iría el historial de cambios...</small>
                            </div>
                        </div>
                    </div>
                </div>
                -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="bi bi-x-circle me-1"></i> Cerrar
                </button>
                <% 
                    // Obtener información del usuario en sesión
                    String userRol = "";
                    try {
                        Object usuarioObj = session.getAttribute("usuario");
                        if (usuarioObj != null) {
                            Class<?> usuarioClass = usuarioObj.getClass();
                            java.lang.reflect.Method getRolMethod = usuarioClass.getMethod("getRol");
                            userRol = (String) getRolMethod.invoke(usuarioObj);
                        }
                    } catch (Exception e) {
                        // Ignorar error
                    }
                    
                    // Solo mostrar botones de acción si el usuario tiene permisos
                    if ("admin".equals(userRol)) {
                %>
                <a href="editar-ticket.jsp?edit=<%= idTicket %>" class="btn btn-warning">
                    <i class="bi bi-pencil me-1"></i> Editar
                </a>
                <% 
                    } else if (rs.getInt("Usuarios_idUsuarios") > 0 && "En Proceso".equals(estado)) {
                        // Verificar si el usuario actual es el asignado al ticket
                        boolean esUsuarioAsignado = false;
                        try {
                            Object usuarioObj = session.getAttribute("usuario");
                            if (usuarioObj != null) {
                                Class<?> usuarioClass = usuarioObj.getClass();
                                java.lang.reflect.Method getIdMethod = usuarioClass.getMethod("getId");
                                int userId = (Integer) getIdMethod.invoke(usuarioObj);
                                esUsuarioAsignado = (userId == rs.getInt("Usuarios_idUsuarios"));
                            }
                        } catch (Exception e) {
                            // Ignorar error
                        }
                        
                        if (esUsuarioAsignado) {
                %>
                <a href="resolver-ticket.jsp?id=<%= idTicket %>" class="btn btn-success">
                    <i class="bi bi-check-circle me-1"></i> Resolver
                </a>
                <% 
                        }
                    } 
                %>
            </div>
        </div>
    </div>
</div>

<%
    } catch (SQLException e) {
        out.print("<div class='alert alert-danger'>Error de base de datos: " + e.getMessage() + "</div>");
    } catch (Exception e) {
        out.print("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        // Cerrar recursos
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
    }
%>