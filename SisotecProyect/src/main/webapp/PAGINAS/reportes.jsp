<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../DBCONEXION/conexionDB.jsp"%>


<%    EUsuario user = (EUsuario) session.getAttribute("usuario");

    Connection con = cn;
    PreparedStatement ps = null;
    ResultSet rs = null;
    if (user == null) {
        response.sendRedirect("../LOGIN/login.html");
        return;
    }

    if (con == null) {
        response.sendRedirect("../LOGIN/errorDb.jsp");
        return;
    }

%>

<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tabla de Perfiles - Estructura</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
        <link rel="stylesheet" href="../CSS/dashboard.css" />


        <style>

            .table td,.table th{
                vertical-align:middle;
            }
            .badge{
                font-size:.85rem;
            }
            @media print{
                .no-print{
                    display:none!important;
                }
                body{
                    font-size:12px;
                }
            }
        </style>
    </head>

    <body>
        <%@ include file="includes/navbar.jsp"%>

        <%@ include file="includes/header.jsp"%>

        <!-- CONTENIDO PRINCIPAL -->
        <main class="main-content">

            <div class="container-fluid mt-4">

                <!-- ENCABEZADO -->
                <div class="row mb-3">
                    <div class="col-md-8">
                        <h3><i class="fa-solid fa-ticket"></i> Reporte General de Tickets</h3>
                        <small class="text-muted">Sistema de Soporte Técnico - SISOTEC</small>
                    </div>
                    <div class="col-md-4 text-end">
                        <p><strong>Fecha:</strong> <%= new java.util.Date()%></p>
                        <p><strong>Entidad:</strong> DIRIS LIMA SUR</p>
                    </div>
                </div>

                <!-- EXPORTAR -->
                <div class="row mb-3 no-print">
                    <div class="col text-end">
                        <button class="btn btn-danger btn-sm" onclick="exportarPdfJS()">
                            <i class="fa-solid fa-file-pdf"></i> PDF
                        </button>
                        <button class="btn btn-success btn-sm" onclick="exportarExcelJS()">
                            <i class="fa-solid fa-file-excel"></i> Excel
                        </button>
                    </div>
                </div>

                <!-- FILTROS -->
                <div class="card mb-3 no-print">
                    <div class="card-header bg-primary text-white">
                        <i class="fa-solid fa-filter"></i> Filtros
                    </div>
                    <div class="card-body">
                        <form method="get" class="row g-3">

                            <!-- ESTADO -->
                            <div class="col-md-3">
                                <label>Estado</label>
                                <select name="estado" class="form-select">
                                    <option value="">Todos</option>
                                    <option value="Nuevos" <%= "Nuevos".equals(request.getParameter("estado")) ? "selected" : ""%>>Nuevos</option>
                                    <option value="En Proceso" <%= "En Proceso".equals(request.getParameter("estado")) ? "selected" : ""%>>En Proceso</option>
                                    <option value="Resuelto" <%= "Resuelto".equals(request.getParameter("estado")) ? "selected" : ""%>>Resuelto</option>
                                </select>
                            </div>

                            <!-- ENTIDAD -->
                            <div class="col-md-3">
                                <label>Entidad</label>
                                <select name="entidad" class="form-select">
                                    <option value="">Todas</option>
                                    <%

                                        PreparedStatement psEntidad = cn.prepareStatement(
                                                "SELECT idEntidades, Nombre_Entidad FROM entidades");
                                        ResultSet rsEntidad = psEntidad.executeQuery();
                                        while (rsEntidad.next()) {
                                            String selected = "";
                                            if (request.getParameter("entidad") != null
                                                    && request.getParameter("entidad").equals(
                                                            String.valueOf(rsEntidad.getInt("idEntidades")))) {
                                                selected = "selected";
                                            }
                                    %>
                                    <option value="<%= rsEntidad.getInt("idEntidades")%>" <%= selected%>>
                                        <%= rsEntidad.getString("Nombre_Entidad")%>
                                    </option>
                                    <%
                                        }
                                        rsEntidad.close();
                                        psEntidad.close();
                                    %>
                                </select>
                            </div>

                            <!-- USUARIO -->
                            <div class="col-md-3">
                                <label>Usuario</label>
                                <select name="usuario" class="form-select">
                                    <option value="">Todos</option>
                                    <%
                                        PreparedStatement psUsuario = cn.prepareStatement(
                                                "SELECT idUsuarios, Usuario FROM usuarios");
                                        ResultSet rsUsuario = psUsuario.executeQuery();
                                        while (rsUsuario.next()) {
                                            String selected = "";
                                            if (request.getParameter("usuario") != null
                                                    && request.getParameter("usuario").equals(
                                                            String.valueOf(rsUsuario.getInt("idUsuarios")))) {
                                                selected = "selected";
                                            }
                                    %>
                                    <option value="<%= rsUsuario.getInt("idUsuarios")%>" <%= selected%>>
                                        <%= rsUsuario.getString("Usuario")%>
                                    </option>
                                    <%
                                        }
                                        rsUsuario.close();
                                        psUsuario.close();
                                    %>
                                </select>
                            </div>

                            <!-- FECHA -->
                            <div class="col-md-3">
                                <label>Fecha</label>
                                <input type="date" name="fecha" class="form-control"
                                       value="<%= request.getParameter("fecha") != null ? request.getParameter("fecha") : ""%>">
                            </div>

                            <div class="col-12 text-end">
                                <a href="reportes.jsp" class="btn btn-secondary btn-sm">
                                    <i class="fa-solid fa-broom"></i> Limpiar
                                </a>
                                <button class="btn btn-primary btn-sm">
                                    <i class="fa-solid fa-search"></i> Buscar
                                </button>
                            </div>

                        </form>
                    </div>
                </div>

                <!-- TABLA -->
                <div class="table-responsive">
                    <table class="table table-bordered table-hover bg-white" id="tablaTickets">
                        <thead class="table-dark text-center">
                            <tr>
                                <th>#</th>
                                <th>Título</th>
                                <th>Estado</th>
                                <th>Fecha</th>
                                <th>Solicitante</th>
                                <th>Entidad</th>
                                <th>Usuario</th>
                                <th>Perfil</th>
                            </tr>
                        </thead>
                        <tbody>

                            <%

                                String estado = request.getParameter("estado");
                                String entidad = request.getParameter("entidad");
                                String usuario = request.getParameter("usuario");
                                String fecha = request.getParameter("fecha");

                                int cont = 1;

                                try {

                                    StringBuilder sql = new StringBuilder();
                                    sql.append(" SELECT t.Titulo, ");
                                    sql.append(" t.Estado, ");
                                    sql.append(" DATE(t.Fecha_Apertura) AS fecha, ");
                                    sql.append(" t.Solicitante, ");
                                    sql.append(" e.Nombre_Entidad, ");
                                    sql.append(" u.Usuario, ");
                                    sql.append(" p.Nombre_Perfil ");
                                    sql.append(" FROM tickets t ");
                                    sql.append(" INNER JOIN entidades e ON t.Entidades_idEntidades = e.idEntidades ");
                                    sql.append(" LEFT JOIN usuarios u ON t.Usuarios_idUsuarios = u.idUsuarios ");
                                    sql.append(" LEFT JOIN perfil p ON u.Perfil_idPerfil = p.idPerfil ");
                                    sql.append(" WHERE 1=1 ");

                                    if (estado != null && !estado.isEmpty()) {
                                        sql.append(" AND t.Estado = ? ");
                                    }
                                    if (entidad != null && !entidad.isEmpty()) {
                                        sql.append(" AND e.idEntidades = ? ");
                                    }
                                    if (usuario != null && !usuario.isEmpty()) {
                                        sql.append(" AND u.idUsuarios = ? ");
                                    }
                                    if (fecha != null && !fecha.isEmpty()) {
                                        sql.append(" AND DATE(t.Fecha_Apertura) = ? ");
                                    }

                                    sql.append(" ORDER BY t.idTickets DESC ");

                                    ps = cn.prepareStatement(sql.toString());

                                    int i = 1;
                                    if (estado != null && !estado.isEmpty()) {
                                        ps.setString(i++, estado);
                                    }
                                    if (entidad != null && !entidad.isEmpty()) {
                                        ps.setInt(i++, Integer.parseInt(entidad));
                                    }
                                    if (usuario != null && !usuario.isEmpty()) {
                                        ps.setInt(i++, Integer.parseInt(usuario));
                                    }
                                    if (fecha != null && !fecha.isEmpty()) {
                                        ps.setString(i++, fecha);
                                    }

                                    rs = ps.executeQuery();

                                    while (rs.next()) {
                                        String badge = "secondary";
                                        if ("Nuevos".equalsIgnoreCase(rs.getString("Estado"))) {
                                            badge = "warning";
                                        }
                                        if ("En Proceso".equalsIgnoreCase(rs.getString("Estado"))) {
                                            badge = "primary";
                                        }
                                        if ("Resuelto".equalsIgnoreCase(rs.getString("Estado")))
                                            badge = "success";
                            %>

                            <tr>
                                <td class="text-center"><%= cont++%></td>
                                <td><%= rs.getString("Titulo")%></td>
                                <td class="text-center">
                                    <span class="badge bg-<%= badge%>"><%= rs.getString("Estado")%></span>
                                </td>
                                <td><%= rs.getString("fecha")%></td>
                                <td><%= rs.getString("Solicitante")%></td>
                                <td><%= rs.getString("Nombre_Entidad")%></td>
                                <td><%= rs.getString("Usuario") != null ? rs.getString("Usuario") : "-"%></td>
                                <td><%= rs.getString("Nombre_Perfil") != null ? rs.getString("Nombre_Perfil") : "-"%></td>
                            </tr>

                            <%
                                }
                            } catch (Exception ex) {
                            %>
                            <tr>
                                <td colspan="8" class="text-danger text-center">
                                    Error: <%= ex.getMessage()%>
                                </td>
                            </tr>
                            <%
                                } finally {
                                    if (rs != null) {
                                        rs.close();
                                    }
                                    if (ps != null) {
                                        ps.close();
                                    }
                                    if (cn != null) {
                                        cn.close();
                                    }
                                }
                            %>

                        </tbody>
                    </table>
                </div>

            </div>

        </main>


        <!-- FOOTER -->
        <%@ include file="includes/footer.jsp"%>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                            /* ===============================
                             FUNCIONES EXISTENTES DEL DASHBOARD
                             ==================================*/
                            function actualizarFechaHora() {
                                const ahora = new Date();

                                // Formato de fecha
                                const opcionesFecha = {
                                    year: "numeric",
                                    month: "2-digit",
                                    day: "2-digit"
                                };

                                // Formato de hora
                                const opcionesHora = {
                                    hour: "2-digit",
                                    minute: "2-digit",
                                    second: "2-digit"
                                };

                                const fecha = ahora.toLocaleDateString("es-ES", opcionesFecha);
                                const hora = ahora.toLocaleTimeString("es-ES", opcionesHora);

                                document.getElementById("fechaHora").textContent = fecha + " " + hora;
                            }

                            // Actualiza cada segundo
                            setInterval(actualizarFechaHora, 1000);

                            // Ejecuta una vez al cargar
                            actualizarFechaHora();
        </script>

        <script src="https://cdn.jsdelivr.net/npm/xlsx/dist/xlsx.full.min.js"></script>

        <script>
                            function obtenerDatosTabla() {
                                const tabla = document.getElementById("tablaTickets");
                                const filas = tabla.querySelectorAll("tbody tr");
                                let datos = [];

                                filas.forEach(fila => {
                                    const celdas = fila.querySelectorAll("td");
                                    if (celdas.length > 0) {
                                        datos.push({
                                            nro: celdas[0].innerText.trim(),
                                            titulo: celdas[1].innerText.trim(),
                                            estado: celdas[2].innerText.trim(),
                                            fecha: celdas[3].innerText.trim(),
                                            solicitante: celdas[4].innerText.trim(),
                                            entidad: celdas[5].innerText.trim(),
                                            usuario: celdas[6].innerText.trim(),
                                            perfil: celdas[7].innerText.trim()
                                        });
                                    }
                                });

                                console.log(datos);
                                return datos;
                            }
                            function exportarExcelJS() {
                                const datos = obtenerDatosTabla();

                                const hoja = XLSX.utils.json_to_sheet(datos);
                                const libro = XLSX.utils.book_new();
                                XLSX.utils.book_append_sheet(libro, hoja, "Tickets");

                                XLSX.writeFile(libro, "reporte_tickets.xlsx");
                            }
        </script>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.29/jspdf.plugin.autotable.min.js"></script>

        <script>
                                    function exportarPdfJS() {
                                        const {jsPDF} = window.jspdf;
                                        const doc = new jsPDF("l", "pt");

                                        doc.text("Reporte General de Tickets", 40, 30);

                                        const tabla = document.getElementById("tablaTickets");
                                        doc.autoTable({
                                            html: tabla,
                                            startY: 50,
                                            theme: "grid"
                                        });

                                        doc.save("reporte_tickets.pdf");
                                    }
        </script>

    </body>
</html>