<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../../DBCONEXION/conexionDB.jsp"%>

<%
    EUsuario user = (EUsuario) session.getAttribute("usuario");

    if (user == null) {
        response.sendRedirect("../LOGIN/login.html");
        return;
    }

    String action = request.getParameter("action");
    String redirectUrl = "../tickets.jsp";
    String mensaje = "";

    // Primero verificar si es administrador
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

    try {
        if ("add".equals(action) && isAdmin) {
            // Crear nuevo ticket (solo admin)
            String titulo = request.getParameter("titulo");
            String solicitante = request.getParameter("solicitante");
            String ubicacion = request.getParameter("ubicacion");
            String entidadId = request.getParameter("entidad");
            String usuarioAsignado = request.getParameter("usuario_asignado");

            // Validar datos requeridos
            if (titulo == null || titulo.trim().isEmpty()
                    || solicitante == null || solicitante.trim().isEmpty()
                    || ubicacion == null || ubicacion.trim().isEmpty()
                    || entidadId == null || entidadId.trim().isEmpty()) {

                session.setAttribute("error", "Todos los campos marcados con * son obligatorios");
                response.sendRedirect(redirectUrl);
                return;
            }

            String sql = "INSERT INTO tickets (Titulo, Estado, Solicitante, Ubicacion_Sede, Entidades_idEntidades, Usuarios_idUsuarios) "
                    + "VALUES (?, 'Nuevos', ?, ?, ?, ?)";

            PreparedStatement ps = cn.prepareStatement(sql);
            ps.setString(1, titulo);
            ps.setString(2, solicitante);
            ps.setString(3, ubicacion);
            ps.setInt(4, Integer.parseInt(entidadId));

            if (usuarioAsignado != null && !usuarioAsignado.isEmpty() && !usuarioAsignado.equals("0")) {
                // Verificar que el usuario asignado no sea admin
                String checkAdmin = "SELECT Perfil_idPerfil FROM usuarios WHERE idUsuarios = ?";
                PreparedStatement psCheck = cn.prepareStatement(checkAdmin);
                psCheck.setInt(1, Integer.parseInt(usuarioAsignado));
                ResultSet rsCheck = psCheck.executeQuery();

                if (rsCheck.next() && rsCheck.getInt("Perfil_idPerfil") != 1) {
                    ps.setInt(5, Integer.parseInt(usuarioAsignado));
                } else {
                    ps.setNull(5, Types.INTEGER);
                }
                rsCheck.close();
                psCheck.close();
            } else {
                ps.setNull(5, Types.INTEGER);
            }

            int rows = ps.executeUpdate();
            if (rows > 0) {
                session.setAttribute("exito", "Ticket creado exitosamente");
            } else {
                session.setAttribute("error", "No se pudo crear el ticket");
            }
            ps.close();

        } else if ("update".equals(action) && isAdmin) {
            // Actualizar ticket (solo admin)
            String id = request.getParameter("id");
            String titulo = request.getParameter("titulo");
            String estado = request.getParameter("estado");
            String solicitante = request.getParameter("solicitante");
            String ubicacion = request.getParameter("ubicacion");
            String entidadId = request.getParameter("entidad");
            String usuarioAsignado = request.getParameter("usuario_asignado");
            String fechaResolucion = request.getParameter("fecha_resolucion");
            String solucion = request.getParameter("solucion");

            if (id == null || id.trim().isEmpty()) {
                session.setAttribute("error", "ID de ticket no válido");
                response.sendRedirect(redirectUrl);
                return;
            }

            String sql = "UPDATE tickets SET "
                    + "Titulo = ?, "
                    + "Estado = ?, "
                    + "Solicitante = ?, "
                    + "Ubicacion_Sede = ?, "
                    + "Entidades_idEntidades = ?, "
                    + "Usuarios_idUsuarios = ?, "
                    + "Fecha_Resolucion = ?, "
                    + "Solucion = ? "
                    + "WHERE idTickets = ?";

            PreparedStatement ps = cn.prepareStatement(sql);
            ps.setString(1, titulo);
            ps.setString(2, estado);
            ps.setString(3, solicitante);
            ps.setString(4, ubicacion);
            ps.setInt(5, Integer.parseInt(entidadId));

            if (usuarioAsignado != null && !usuarioAsignado.isEmpty() && !usuarioAsignado.equals("0")) {
                // Verificar que el usuario asignado no sea admin
                String checkAdmin = "SELECT Perfil_idPerfil FROM usuarios WHERE idUsuarios = ?";
                PreparedStatement psCheck = cn.prepareStatement(checkAdmin);
                psCheck.setInt(1, Integer.parseInt(usuarioAsignado));
                ResultSet rsCheck = psCheck.executeQuery();

                if (rsCheck.next() && rsCheck.getInt("Perfil_idPerfil") != 1) {
                    ps.setInt(6, Integer.parseInt(usuarioAsignado));
                } else {
                    ps.setNull(6, Types.INTEGER);
                }
                rsCheck.close();
                psCheck.close();
            } else {
                ps.setNull(6, Types.INTEGER);
            }

            if (fechaResolucion != null && !fechaResolucion.trim().isEmpty()) {
                ps.setTimestamp(7, Timestamp.valueOf(fechaResolucion.replace("T", " ") + ":00"));
            } else if ("Resuelto".equals(estado) || "Cerrado".equals(estado)) {
                // Si el estado cambia a Resuelto o Cerrado, establecer fecha actual
                ps.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }

            ps.setString(8, solucion);
            ps.setInt(9, Integer.parseInt(id));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                session.setAttribute("exito", "Ticket actualizado exitosamente");
            } else {
                session.setAttribute("error", "No se pudo actualizar el ticket. Verifique el ID.");
            }
            ps.close();

        } else if ("resolver".equals(action)) {
            // Resolver ticket (usuario asignado)
            String id = request.getParameter("id");
            String solucion = request.getParameter("solucion");
            String estado = request.getParameter("estado");

            if (id == null || id.trim().isEmpty()) {
                session.setAttribute("error", "ID de ticket no válido");
                response.sendRedirect(redirectUrl);
                return;
            }

            // Verificar que el usuario actual está asignado a este ticket
            String checkAsignacion = "SELECT idTickets FROM tickets WHERE idTickets = ? AND Usuarios_idUsuarios = ? AND Estado = 'En Proceso'";
            PreparedStatement psCheck = cn.prepareStatement(checkAsignacion);
            psCheck.setInt(1, Integer.parseInt(id));
            psCheck.setInt(2, user.getId());
            ResultSet rsCheck = psCheck.executeQuery();

            if (!rsCheck.next()) {
                session.setAttribute("error", "No tiene permisos para resolver este ticket o no está en estado 'En Proceso'");
                response.sendRedirect(redirectUrl);
                return;
            }
            rsCheck.close();
            psCheck.close();

            String sql = "UPDATE tickets SET "
                    + "Estado = ?, "
                    + "Solucion = ?, "
                    + "Fecha_Resolucion = NOW() "
                    + "WHERE idTickets = ? AND Usuarios_idUsuarios = ?";

            PreparedStatement ps = cn.prepareStatement(sql);
            ps.setString(1, estado);
            ps.setString(2, solucion);
            ps.setInt(3, Integer.parseInt(id));
            ps.setInt(4, user.getId());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                session.setAttribute("exito", "Ticket resuelto exitosamente");
            } else {
                session.setAttribute("error", "No se pudo resolver el ticket");
            }
            ps.close();

        } else if ("cambiarEstado".equals(action) && isAdmin) {
            // Cambiar estado rápido (solo admin)
            String id = request.getParameter("id");
            String nuevoEstado = request.getParameter("estado");

            if (id == null || id.trim().isEmpty() || nuevoEstado == null) {
                session.setAttribute("error", "Parámetros inválidos");
                response.sendRedirect(redirectUrl);
                return;
            }

            String sql = "UPDATE tickets SET Estado = ? WHERE idTickets = ?";
            PreparedStatement ps = cn.prepareStatement(sql);
            ps.setString(1, nuevoEstado);
            ps.setInt(2, Integer.parseInt(id));

            // Si el estado es Resuelto o Cerrado, actualizar fecha de resolución
            if ("Resuelto".equals(nuevoEstado) || "Cerrado".equals(nuevoEstado)) {
                String sqlConFecha = "UPDATE tickets SET Estado = ?, Fecha_Resolucion = NOW() WHERE idTickets = ?";
                ps = cn.prepareStatement(sqlConFecha);
                ps.setString(1, nuevoEstado);
                ps.setInt(2, Integer.parseInt(id));
            }

            int rows = ps.executeUpdate();
            if (rows > 0) {
                session.setAttribute("exito", "Estado cambiado a " + nuevoEstado);
            } else {
                session.setAttribute("error", "No se pudo cambiar el estado");
            }
            ps.close();

        } else if ("delete".equals(action) && isAdmin) {
            // Eliminar ticket (solo admin)
            String id = request.getParameter("id");

            if (id == null || id.trim().isEmpty()) {
                session.setAttribute("error", "ID de ticket no válido");
                response.sendRedirect(redirectUrl);
                return;
            }

            String sql = "DELETE FROM tickets WHERE idTickets = ?";
            PreparedStatement ps = cn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                session.setAttribute("exito", "Ticket eliminado exitosamente");
            } else {
                session.setAttribute("error", "No se pudo eliminar el ticket");
            }
            ps.close();

        } else if ("asignar".equals(action) && isAdmin) {
            // Asignar ticket a usuario (solo admin)
            String id = request.getParameter("id");
            String usuarioId = request.getParameter("usuario_id");

            if (id == null || id.trim().isEmpty() || usuarioId == null || usuarioId.trim().isEmpty()) {
                session.setAttribute("error", "Parámetros inválidos");
                response.sendRedirect(redirectUrl);
                return;
            }

            // Verificar que el usuario a asignar no sea admin
            String checkAdmin = "SELECT Perfil_idPerfil FROM usuarios WHERE idUsuarios = ?";
            PreparedStatement psCheck = cn.prepareStatement(checkAdmin);
            psCheck.setInt(1, Integer.parseInt(usuarioId));
            ResultSet rsCheck = psCheck.executeQuery();

            if (rsCheck.next() && rsCheck.getInt("Perfil_idPerfil") == 1) {
                session.setAttribute("error", "No se puede asignar ticket a un administrador");
                response.sendRedirect(redirectUrl);
                return;
            }
            rsCheck.close();
            psCheck.close();

            String sql = "UPDATE tickets SET "
                    + "Estado = 'En Proceso', "
                    + "Usuarios_idUsuarios = ? "
                    + "WHERE idTickets = ?";

            PreparedStatement ps = cn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(usuarioId));
            ps.setInt(2, Integer.parseInt(id));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                session.setAttribute("exito", "Ticket asignado exitosamente");
            } else {
                session.setAttribute("error", "No se pudo asignar el ticket");
            }
            ps.close();

        } else {
            // Acción no reconocida o sin permisos
            if (!isAdmin && ("add".equals(action) || "update".equals(action) || "delete".equals(action) || "cambiarEstado".equals(action) || "asignar".equals(action))) {
                session.setAttribute("error", "No tiene permisos para realizar esta acción");
            } else {
                session.setAttribute("error", "Acción no reconocida");
            }
        }

    } catch (SQLException e) {
        System.out.println("Error SQL en tickets-process: " + e.getMessage());
        session.setAttribute("error", "Error en base de datos: " + e.getMessage());
        e.printStackTrace();
    } catch (NumberFormatException e) {
        System.out.println("Error de formato numérico: " + e.getMessage());
        session.setAttribute("error", "Error en los datos ingresados");
    } catch (Exception e) {
        System.out.println("Error general en tickets-process: " + e.getMessage());
        session.setAttribute("error", "Error del sistema: " + e.getMessage());
        e.printStackTrace();
    } finally {
        response.sendRedirect(redirectUrl);
    }
%>