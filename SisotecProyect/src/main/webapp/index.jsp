<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="DBCONEXION/conexionDB.jsp"%>

<%    Connection con = cn;
    if (con == null) {
        response.sendRedirect("LOGIN/errorDB.jsp");
        return;
    }

    var user = session.getAttribute("usuario");
    if (user == null) {
        response.sendRedirect("LOGIN/login.html");
    } else {
        response.sendRedirect("PAGINAS/dashboard.jsp");
    }

%>