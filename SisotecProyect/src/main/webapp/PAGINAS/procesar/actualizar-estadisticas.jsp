<%@page import="java.sql.*"%>
<%@page import="org.json.JSONObject"%>
<%@ include file="../../DBCONEXION/conexionDB.jsp"%>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    JSONObject json = new JSONObject();
    
    try {
        // Estadísticas rápidas para actualización en tiempo real
        String queryNuevos = "SELECT COUNT(*) as total FROM tickets WHERE Estado = 'Nuevos'";
        String queryProceso = "SELECT COUNT(*) as total FROM tickets WHERE Estado = 'En Proceso'";
        String queryResueltos = "SELECT COUNT(*) as total FROM tickets WHERE Estado = 'Resuelto'";
        String queryCerrados = "SELECT COUNT(*) as total FROM tickets WHERE Estado = 'Cerrado'";
        String queryPendientes = "SELECT COUNT(*) as total FROM tickets WHERE Estado = 'Pendiente'";
        
        PreparedStatement ps;
        ResultSet rs;
        
        // Nuevos
        ps = cn.prepareStatement(queryNuevos);
        rs = ps.executeQuery();
        if (rs.next()) json.put("nuevos", rs.getInt("total"));
        rs.close();
        ps.close();
        
        // En Proceso
        ps = cn.prepareStatement(queryProceso);
        rs = ps.executeQuery();
        if (rs.next()) json.put("enProceso", rs.getInt("total"));
        rs.close();
        ps.close();
        
        // Resueltos
        ps = cn.prepareStatement(queryResueltos);
        rs = ps.executeQuery();
        if (rs.next()) json.put("resueltos", rs.getInt("total"));
        rs.close();
        ps.close();
        
        // Cerrados
        ps = cn.prepareStatement(queryCerrados);
        rs = ps.executeQuery();
        if (rs.next()) json.put("cerrados", rs.getInt("total"));
        rs.close();
        ps.close();
        
        // Pendientes
        ps = cn.prepareStatement(queryPendientes);
        rs = ps.executeQuery();
        if (rs.next()) json.put("pendientes", rs.getInt("total"));
        rs.close();
        ps.close();
        
        json.put("success", true);
        json.put("timestamp", new java.util.Date().getTime());
        
    } catch (SQLException e) {
        json.put("success", false);
        json.put("error", e.getMessage());
    }
    
    out.print(json.toString());
%>