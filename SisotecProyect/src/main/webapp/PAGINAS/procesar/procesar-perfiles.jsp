<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../../DBCONEXION/conexionDB.jsp"%>

<%-- CÓDIGO PARA PROCESAR CRUD --%>
<%
    
    EUsuario user = (EUsuario) session.getAttribute("usuario");

    if (user == null) {
        response.sendRedirect("../../LOGIN/login.html");
        return;
    }

    // Procesar las operaciones CRUD
    if (request.getMethod().equals("POST")) {
        String accion = request.getParameter("accion");
        Connection conCrud = null;
        PreparedStatement psCrud = null;

        try {
            conCrud = cn;

            if (accion != null) {
                switch (accion) {
                    case "crear":
                        // INSERTAR NUEVO PERFIL
                        String nombrePerfil = request.getParameter("nombre_perfil");
                        String estadoPerfil = request.getParameter("estado_perfil");

                        String sqlInsert = "INSERT INTO perfil (Nombre_Perfil, Estado_Perfil) VALUES (?, ?)";
                        psCrud = conCrud.prepareStatement(sqlInsert);
                        psCrud.setString(1, nombrePerfil);
                        psCrud.setInt(2, Integer.parseInt(estadoPerfil));
                        psCrud.executeUpdate();

                        session.setAttribute("mensaje", "Perfil creado exitosamente");
                        session.setAttribute("tipoMensaje", "success");
                        break;

                    case "editar":
                        // ACTUALIZAR PERFIL
                        String idEditar = request.getParameter("idPerfil");
                        String nombreEditar = request.getParameter("nombre_perfil");
                        String estadoEditar = request.getParameter("estado_perfil");

                        String sqlUpdate = "UPDATE perfil SET Nombre_Perfil = ?, Estado_Perfil = ? WHERE idPerfil = ?";
                        psCrud = conCrud.prepareStatement(sqlUpdate);
                        psCrud.setString(1, nombreEditar);
                        psCrud.setInt(2, Integer.parseInt(estadoEditar));
                        psCrud.setInt(3, Integer.parseInt(idEditar));
                        psCrud.executeUpdate();

                        session.setAttribute("mensaje", "Perfil actualizado exitosamente");
                        session.setAttribute("tipoMensaje", "success");
                        break;

                    case "eliminar":
                        // ELIMINAR PERFIL
                        String idEliminar = request.getParameter("idEliminar");

                        String sqlDelete = "DELETE FROM perfil WHERE idPerfil = ?";
                        psCrud = conCrud.prepareStatement(sqlDelete);
                        psCrud.setInt(1, Integer.parseInt(idEliminar));
                        int filas = psCrud.executeUpdate();

                        if (filas > 0) {
                            session.setAttribute("mensaje", "Perfil eliminado exitosamente");
                            session.setAttribute("tipoMensaje", "success");
                        } else {
                            session.setAttribute("mensaje", "No se pudo eliminar el perfil");
                            session.setAttribute("tipoMensaje", "danger");
                        }
                        break;
                }
            }

            // Redirigir para evitar reenvío del formulario
            response.sendRedirect("../perfiles.jsp");
            return;

        } catch (Exception e) {
            session.setAttribute("mensaje", "Error: " + e.getMessage());
            session.setAttribute("tipoMensaje", "danger");
            response.sendRedirect("../perfiles.jsp");
            return;
        } finally {
            try {
                if (psCrud != null) {
                    psCrud.close();
                }
                if (conCrud != null) {
                    conCrud.close();
                }
            } catch (Exception ex) {
            }
        }
    }
%>