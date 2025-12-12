<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../DBCONEXION/conexionDB.jsp"%>


<%    EUsuario user = (EUsuario) session.getAttribute("usuario");
    List<EUsuario> lista = new ArrayList();
    if (user == null) {
        response.sendRedirect("../LOGIN/login.html");
    } else {

        Connection con = cn;
        PreparedStatement ps = null;
        ResultSet rs = null;
        if (con == null) {
            response.sendRedirect("../LOGIN/errorDb.jsp");
        } else {
            try {
                ps = con.prepareStatement(
                        "SELECT * FROM Usuarios"
                );
                rs = ps.executeQuery();

                while (rs.next()) {

                    EUsuario usuario = new EUsuario();

                    usuario.setId(rs.getInt("idUsuarios"));
                    usuario.setUsuario(rs.getString("Usuario"));
                    usuario.setClave(rs.getString("Clave"));
                    usuario.setNusuario(rs.getString("Nombre_Usuario"));
                    usuario.setEmail(rs.getString("Email"));
                    usuario.setPid(rs.getInt("Perfil_idPerfil"));

                    lista.add(usuario);
// <== AGREGA A LA LISTA
                }

            } catch (Exception e) {
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
                                        <i class="bi bi-people-fill me-2"></i>Gestión de Usuarios
                                    </h2>
                                </div>
                                <div class="col-md-6 text-md-end">
                                    <button class="btn btn-light fw-bold" data-bs-toggle="modal" data-bs-target="#modalUsuario">
                                        <i class="bi bi-person-plus me-2"></i>Nuevo Usuario
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TABLA -->
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white border-0 pt-3">
                        <h5 class="mb-0 fw-bold"><i class="bi bi-table me-2"></i>Listado de Usuarios</h5>
                    </div>

                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th width="60">ID</th>
                                        <th>Usuario</th>
                                        <th>Clave</th>
                                        <th>Nombre Completo</th>
                                        <th>Email</th>
                                        <th>Perfil</th>
                                        <th width="100">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (EUsuario u : lista) {
                                            String perfilNombre = "";
                                            String badgeColor = "";

                                            switch (u.getPid()) {
                                                case 1:
                                                    perfilNombre = "Administrador";
                                                    badgeColor = "bg-primary text-primary bg-opacity-10";
                                                    break;
                                                case 2:
                                                    perfilNombre = "Soporte Técnico";
                                                    badgeColor = "bg-warning text-warning bg-opacity-10";
                                                    break;
                                                case 3:
                                                    perfilNombre = "Usuario";
                                                    badgeColor = "bg-success text-success bg-opacity-10";
                                                    break;
                                                default:
                                                    perfilNombre = "No definido";
                                                    badgeColor = "bg-secondary text-secondary bg-opacity-10";
                                            }
                                    %>
                                    <tr>
                                        <td class="fw-bold"><%= u.getId()%></td>
                                        <td><%= u.getUsuario()%></td>
                                        <td><%= u.getClave()%></td>
                                        <td><%= u.getNusuario()%></td>
                                        <td><%= u.getEmail()%></td>
                                        <td>
                                            <span class="badge-perfil <%= badgeColor%>">
                                                <%= perfilNombre%>
                                            </span>
                                        </td>

                                        <td>
                                            <div class="d-flex gap-1">
                                                <button class="btn btn-action btn-warning" title="Editar">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <button class="btn btn-action btn-danger" title="Eliminar">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                                <button class="btn btn-action btn-info" title="Ver">
                                                    <i class="bi bi-eye"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>

                                    <%
                                        } // fin del for
                                    %>
                                </tbody>

                            </table>
                        </div>
                    </div>     
                </div>

            </div>

            <!-- MODAL NUEVO USUARIO -->
            <div class="modal fade" id="modalUsuario" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">

                        <div class="modal-header text-bg-secondary">
                            <h5 class="modal-title fw-bold">
                                <i class="bi bi-person-plus me-2"></i>Nuevo Usuario
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>

                        <div class="modal-body">
                            <form>
                                <div class="row g-3">

                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Usuario *</label>
                                        <input type="text" class="form-control" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Email *</label>
                                        <input type="email" class="form-control" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Nombre Completo *</label>
                                        <input type="text" class="form-control" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Perfil *</label>
                                        <select class="form-select" required>
                                            <option value="">Seleccionar...</option>
                                            <option>Administrador</option>
                                            <option>Soporte Técnico</option>
                                            <option>Usuario</option>
                                        </select>
                                    </div>

                                </div>
                            </form>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="button" class="btn btn-primary">Guardar Usuario</button>
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
