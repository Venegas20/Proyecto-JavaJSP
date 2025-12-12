
<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../DBCONEXION/conexionDB.jsp"%>


<%    EUsuario user = (EUsuario) session.getAttribute("usuario");

    if (user == null) {
        response.sendRedirect("../LOGIN/login.html");
        return;
    }


%>



<%    PreparedStatement ps = cn.prepareStatement("SELECT * FROM entidades");
    ResultSet rs = ps.executeQuery();

    // Datos para edición (si vienen desde el enlace Editar)
    String idEdit = request.getParameter("edit");
    String nombreEdit = "";
    String ubicacionEdit = "";

    if (idEdit != null) {
        PreparedStatement ps2 = cn.prepareStatement("SELECT * FROM entidades WHERE idEntidades=?");
        ps2.setInt(1, Integer.parseInt(idEdit));
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) {
            nombreEdit = rs2.getString("Nombre_Entidad");
            ubicacionEdit = rs2.getString("Ubicacion");
        }
    }
%>


<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SISOTEC LTE 4</title>

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
                                        <i class="bi bi-people-fill me-2"></i>Gestión de Entidades
                                    </h2>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>

                <!-- TABLA -->
                <div class=" ">
                    

                    <div class="">

                        <div class="row">
                            <div class="col-md-4">

                                <div class="card shadow-sm">
                                    <div class="card-header bg-white fw-bold">
                                        <%= (idEdit != null) ? "Editar Entidad" : "Nueva Entidad"%>
                                    </div>

                                    <div class="card-body">

                                        <form action="procesar/entidades-process.jsp" method="post">

                                            <input type="hidden" name="action" value="<%= (idEdit != null) ? "update" : "add"%>">
                                            <input type="hidden" name="id" value="<%= idEdit != null ? idEdit : ""%>">

                                            <label class="fw-bold">Nombre de la Entidad</label>
                                            <input type="text" name="nombre" class="form-control"
                                                   value="<%= nombreEdit%>" required>

                                            <label class="fw-bold mt-3">Ubicación</label>
                                            <input type="text" name="ubicacion" class="form-control"
                                                   value="<%= ubicacionEdit%>">

                                            <button class="btn btn-primary mt-3 w-100">
                                                <%= (idEdit != null) ? "Actualizar" : "Registrar"%>
                                            </button>

                                            <% if (idEdit != null) { %>
                                            <a href="entidades.jsp" class="btn btn-secondary mt-2 w-100">Cancelar</a>
                                            <% } %>

                                        </form>

                                    </div>
                                </div>

                            </div>
                            <!-- ===========================
                                    TABLA DERECHA
                               ============================ -->
                            <div class="col-md-8">

                                <div class="card shadow-sm">
                                    <div class="card-header bg-white fw-bold">
                                        Listado de Entidades
                                    </div>

                                    <div class="card-body p-0">

                                        <table class="table table-hover mb-0">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Entidad</th>
                                                    <th>Ubicación</th>
                                                    <th width="120">Acciones</th>
                                                </tr>
                                            </thead>

                                            <tbody>
                                                <% while (rs.next()) {%>
                                                <tr>
                                                    <td><%= rs.getInt("idEntidades")%></td>
                                                    <td><%= rs.getString("Nombre_Entidad")%></td>
                                                    <td><%= rs.getString("Ubicacion")%></td>

                                                    <td>
                                                        <a href="entidades.jsp?edit=<%= rs.getInt("idEntidades")%>"
                                                           class="btn btn-warning btn-sm">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>

                                                        <a href="procesar/entidades-process.jsp?action=delete&id=<%= rs.getInt("idEntidades")%>"
                                                           class="btn btn-danger btn-sm">
                                                            <i class="bi bi-trash"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                                <% }%>
                                            </tbody>

                                        </table>

                                    </div>
                                </div>

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


            /* ===============================
             FUNCIÓN PARA CARGAR PÁGINAS EN EL IFRAME
             ==================================*/
            function loadPage(url) {
                document.getElementById("contentFrame").src = url;
                document.querySelector(".page-title h1").textContent = "Gestión de Usuarios";
            }

            /* ABRIR/CERRAR SIDEBAR */
            document.getElementById('menuToggle').addEventListener('click', function () {
                const sidebar = document.querySelector('.sidebar');
                const topNav = document.querySelector('.top-nav');
                const mainContent = document.querySelector('.main-content');
                const footer = document.querySelector('.footer');

                sidebar.classList.toggle('active');

                if (sidebar.classList.contains('active')) {
                    topNav.style.left = '280px';
                    mainContent.style.marginLeft = '280px';
                    footer.style.marginLeft = '280px';
                } else {
                    topNav.style.left = '0';
                    mainContent.style.marginLeft = '0';
                    footer.style.marginLeft = '0';
                }
            });

            /* MENÚ DE USUARIO */
            const userMenuTrigger = document.getElementById('userMenuTrigger');
            const userMenuDropdown = document.getElementById('userMenuDropdown');

            userMenuTrigger.addEventListener('click', function (e) {
                e.stopPropagation();
                const open = userMenuDropdown.style.opacity === '1';
                userMenuDropdown.style.opacity = open ? '0' : '1';
                userMenuDropdown.style.visibility = open ? 'hidden' : 'visible';
                userMenuDropdown.style.transform = open ? 'translateY(-10px)' : 'translateY(0)';
            });

            document.addEventListener('click', () => {
                userMenuDropdown.style.opacity = '0';
                userMenuDropdown.style.visibility = 'hidden';
                userMenuDropdown.style.transform = 'translateY(-10px)';
            });

        </script>

    </body>

</html>
