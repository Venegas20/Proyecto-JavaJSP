<%@page import="java.sql.*"%>
<%@include file="../../DBCONEXION/conexionDB.jsp"%>

<%    String action = request.getParameter("action");
    PreparedStatement ps;

    if ("add".equals(action)) {
        ps = cn.prepareStatement("INSERT INTO entidades (Nombre_Entidad, Ubicacion) VALUES (?, ?)");
        ps.setString(1, request.getParameter("nombre"));
        ps.setString(2, request.getParameter("ubicacion"));
        ps.executeUpdate();
        response.sendRedirect("../entidades.jsp");
        return;
    }

    if ("update".equals(action)) {
        ps = cn.prepareStatement("UPDATE entidades SET Nombre_Entidad=?, Ubicacion=? WHERE idEntidades=?");
        ps.setString(1, request.getParameter("nombre"));
        ps.setString(2, request.getParameter("ubicacion"));
        ps.setInt(3, Integer.parseInt(request.getParameter("id")));
        ps.executeUpdate();
        response.sendRedirect("../entidades.jsp");
        return;
    }

    if ("delete".equals(action)) {
        ps = cn.prepareStatement("DELETE FROM entidades WHERE idEntidades=?");
        ps.setInt(1, Integer.parseInt(request.getParameter("id")));
        ps.executeUpdate();
        response.sendRedirect("../entidades.jsp");
        return;
    }
%>
