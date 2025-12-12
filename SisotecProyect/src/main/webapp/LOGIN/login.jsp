<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../DBCONEXION/conexionDB.jsp"%>

<%    String username = request.getParameter("username");
    String password = request.getParameter("password");
    EUsuario usuario = null;
    
    if (username == null || password == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    boolean acceso = false;
    boolean errorConexion = false;
    
    Connection con = cn;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // La variable con viene desde conexionDB.jsp
    if (con == null) {
        errorConexion = true;
    } else {
        try {
            ps = con.prepareStatement(
                    "SELECT u.*,p.Nombre_Perfil FROM usuarios u LEFT JOIN perfil p ON u.Perfil_idPerfil = p.idPerfil WHERE u.Usuario=? AND u.Clave=?"
            );
            ps.setString(1, username);
            ps.setString(2, password);
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                acceso = true;
                usuario = new EUsuario();
                usuario.setId(rs.getInt("idUsuarios"));
                usuario.setUsuario(rs.getString("Usuario"));
                usuario.setClave(rs.getString("Clave"));
                usuario.setNusuario(rs.getString("Nombre_Usuario"));
                usuario.setEmail(rs.getString("Email"));
                usuario.setPid(rs.getInt("Perfil_idPerfil"));
                usuario.setNombre_perfil(rs.getString("Nombre_Perfil"));
                
            }
            
        } catch (Exception e) {
            errorConexion = true;
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (Exception ex) {
            }
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception ex) {
            }
            try {
                if (con != null) {
                    con.close();
                }
            } catch (Exception ex) {
            }
        }
    }

    // ❌ Error de conexión
    if (errorConexion) {
%>
<html>
    <head>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    </head>
    <body>
        <script>
            Swal.fire({
                icon: "error",
                title: "Error de Conexión",
                text: "No se pudo conectar a la base de datos."
            }).then(() => window.location = "login.html");
        </script>
    </body>
</html>
<%        
        return;
    }

    // ❌ Usuario incorrecto
    if (!acceso) {
%>
<html>
    <head>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    </head>
    <body>
        <script>
            Swal.fire({
                icon: "error",
                title: "Acceso Denegado",
                text: "Usuario o contraseña incorrectos."
            }).then(() => window.location = "login.html");
        </script>
    </body>
</html>
<%        
        return;
    }

    // ✅ Login Correcto
    session.setAttribute("usuario", usuario);
%>

<html>
    <head>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    </head>
    <body>
        <script>
            Swal.fire({
                icon: "success",
                title: "Bienvenido",
                text: "Inicio de sesión exitoso.",
                timer: 1500,
                showConfirmButton: false
            }).then(() => window.location = "../PAGINAS/dashboard.jsp");
        </script>
    </body>
</html>
