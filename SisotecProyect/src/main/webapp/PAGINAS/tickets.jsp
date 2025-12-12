<%@page import="Entidades.EUsuario"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page errorPage="../error.jsp" %>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../DBCONEXION/conexionDB.jsp"%>

<%    EUsuario user = (EUsuario) session.getAttribute("usuario");

    if (user == null) {
        response.sendRedirect("../LOGIN/login.html");
        return;
    }

    // DEBUG: Mostrar información del usuario
    System.out.println("Usuario ID: " + user.getId());
    System.out.println("Usuario PID: " + user.getPid());
    System.out.println("Usuario Rol: " + user.getPid());

    // Verificar si es administrador - CORREGIDO
    boolean isAdmin = false;
    try {

        // Opción 2: Por pid
        if (!isAdmin && user.getPid() == 1) {
            isAdmin = true;
        }
    } catch (Exception e) {
        System.out.println("Error verificando admin: " + e.getMessage());
    }

    System.out.println("Es admin: " + isAdmin);

    // Preparar la consulta según el rol
    String query = "";
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        if (isAdmin) {
            // Administrador: todos los tickets de los últimos 60 días
            query = "SELECT t.*, e.Nombre_Entidad, u.Nombre_Usuario as Asignado_A "
                    + "FROM tickets t "
                    + "LEFT JOIN entidades e ON t.Entidades_idEntidades = e.idEntidades "
                    + "LEFT JOIN usuarios u ON t.Usuarios_idUsuarios = u.idUsuarios "
                    + "WHERE t.Fecha_Apertura >= DATE_SUB(NOW(), INTERVAL 60 DAY) "
                    + "ORDER BY t.Fecha_Apertura DESC "
                    + "LIMIT 50"; // Agregado LIMIT por seguridad

            System.out.println("Consulta ADMIN: " + query);
            ps = cn.prepareStatement(query);
        } else {
            // Usuario normal: solo tickets asignados a él
            query = "SELECT t.*, e.Nombre_Entidad, u.Nombre_Usuario as Asignado_A "
                    + "FROM tickets t "
                    + "LEFT JOIN entidades e ON t.Entidades_idEntidades = e.idEntidades "
                    + "LEFT JOIN usuarios u ON t.Usuarios_idUsuarios = u.idUsuarios "
                    + "WHERE t.Usuarios_idUsuarios = ? "
                    + "ORDER BY t.Fecha_Apertura DESC "
                    + "LIMIT 50";

            System.out.println("Consulta USER: " + query);
            ps = cn.prepareStatement(query);
            ps.setInt(1, user.getId());
        }

        rs = ps.executeQuery();
        System.out.println("Consulta ejecutada exitosamente");

    } catch (SQLException e) {
        System.out.println("ERROR SQL: " + e.getMessage());
        System.out.println("SQL State: " + e.getSQLState());
        System.out.println("Error Code: " + e.getErrorCode());
        e.printStackTrace();
        throw e; // Propaga el error para verlo en la página
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SISOTEC LTE 4 - Tickets</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
        <link rel="stylesheet" href="../CSS/dashboard.css" />

        <style>
            .badge-estado {
                font-size: 0.8em;
                padding: 4px 8px;
            }
            .badge-nuevo {
                background-color: #0d6efd;
            }
            .badge-en-proceso {
                background-color: #ffc107;
                color: #000;
            }
            .badge-resuelto {
                background-color: #198754;
            }
            .badge-cerrado {
                background-color: #6c757d;
            }
            .badge-pendiente {
                background-color: #fd7e14;
            }
            .debug-info {
                background: #f8f9fa;
                border-left: 4px solid #0d6efd;
                padding: 10px;
                margin: 10px 0;
                font-size: 12px;
            }
        </style>
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
                                        <i class="bi bi-ticket-detailed me-2"></i>Gestión de Tickets
                                    </h2>
                                </div>
                                <div class="col-md-6 text-end">
                                    <% if (isAdmin) { %>
                                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#nuevoTicketModal">
                                        <i class="bi bi-plus-circle me-1"></i> Nuevo Ticket
                                    </button>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- FILTROS -->
                <% if (isAdmin) { %>
                <div class="row mb-3">
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <form method="get" class="row g-3">
                                    <div class="col-md-3">
                                        <label class="form-label fw-bold">Estado</label>
                                        <select name="estado" class="form-select">
                                            <option value="">Todos</option>
                                            <option value="Nuevos">Nuevos</option>
                                            <option value="En Proceso">En Proceso</option>
                                            <option value="Resuelto">Resuelto</option>
                                            <option value="Cerrado">Cerrado</option>
                                            <option value="Pendiente">Pendiente</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-bold">Desde</label>
                                        <input type="date" name="fechaDesde" class="form-control">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-bold">Hasta</label>
                                        <input type="date" name="fechaHasta" class="form-control">
                                    </div>
                                    <div class="col-md-3 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="bi bi-filter me-1"></i> Filtrar
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
                <% }%>

                <!-- TABLA DE TICKETS -->
                <div class="row">
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-white fw-bold d-flex justify-content-between align-items-center">
                                <span>Listado de Tickets</span>
                                <span class="badge bg-primary">
                                    <%= isAdmin ? "Vista Administrador (Últimos 60 días)" : "Mis Tickets Asignados"%>
                                </span>
                            </div>

                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>ID</th>
                                                <th>Título</th>
                                                <th>Estado</th>
                                                <th>Fecha Apertura</th>
                                                <th>Solicitante</th>
                                                <th>Ubicación</th>
                                                <th>Entidad</th>
                                                <th>Asignado a</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>

                                        <tbody>
                                            <%
                                                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                                                int contador = 0;
                                                boolean tieneDatos = false;

                                                try {
                                                    while (rs != null && rs.next()) {
                                                        tieneDatos = true;
                                                        contador++;
                                                        String estado = rs.getString("Estado");
                                                        String badgeClass = "";

                                                        if (estado != null) {
                                                            switch (estado) {
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
                                            %>
                                            <tr>
                                                <td><strong>#<%= rs.getInt("idTickets")%></strong></td>
                                                <td><%= rs.getString("Titulo") != null ? rs.getString("Titulo") : ""%></td>
                                                <td>
                                                    <span class="badge <%= badgeClass%> badge-estado">
                                                        <%= estado != null ? estado : "Desconocido"%>
                                                    </span>
                                                </td>
                                                <td>
                                                    <%
                                                        Timestamp fechaApertura = rs.getTimestamp("Fecha_Apertura");
                                                        if (fechaApertura != null) {
                                                            out.print(dtf.format(fechaApertura.toLocalDateTime()));
                                                        } else {
                                                            out.print("");
                                                        }
                                                    %>
                                                </td>
                                                <td><%= rs.getString("Solicitante") != null ? rs.getString("Solicitante") : ""%></td>
                                                <td><%= rs.getString("Ubicacion_Sede") != null ? rs.getString("Ubicacion_Sede") : ""%></td>
                                                <td><%= rs.getString("Nombre_Entidad") != null ? rs.getString("Nombre_Entidad") : "Sin entidad"%></td>
                                                <td><%= rs.getString("Asignado_A") != null ? rs.getString("Asignado_A") : "Sin asignar"%></td>
                                                <td>
                                                    <div class="btn-group" role="group">
                                                        <% if (!isAdmin && "En Proceso".equals(estado)) {%>
                                                        <a href="resolver-ticket.jsp?id=<%= rs.getInt("idTickets")%>" 
                                                           class="btn btn-success btn-sm" title="Resolver">
                                                            <i class="bi bi-check-circle"></i>
                                                        </a>
                                                        <% } %>

                                                        <% if (isAdmin) {%>
                                                        <a href="editar-ticket.jsp?edit=<%= rs.getInt("idTickets")%>" 
                                                           class="btn btn-warning btn-sm" title="Editar">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>
                                                        <% }%>

                                                        <button type="button" class="btn btn-info btn-sm" 
                                                                onclick="mostrarDetalle(<%= rs.getInt("idTickets")%>)"
                                                                title="Ver detalles">
                                                            <i class="bi bi-eye"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                            <%
                                                } // fin while

                                                if (!tieneDatos) {
                                            %>
                                            <tr>
                                                <td colspan="9" class="text-center py-4">
                                                    <div class="text-muted">
                                                        <i class="bi bi-inbox fs-1"></i>
                                                        <p class="mt-2">No hay tickets disponibles</p>
                                                        <% if (isAdmin) { %>
                                                        <button class="btn btn-primary btn-sm mt-2" 
                                                                data-bs-toggle="modal" data-bs-target="#nuevoTicketModal">
                                                            Crear primer ticket
                                                        </button>
                                                        <% } %>
                                                    </div>
                                                </td>
                                            </tr>
                                            <%
                                                }

                                            } catch (SQLException e) {
                                                System.out.println("Error procesando ResultSet: " + e.getMessage());
                                            %>
                                            <tr>
                                                <td colspan="9" class="text-center text-danger py-4">
                                                    Error al cargar tickets: <%= e.getMessage()%>
                                                </td>
                                            </tr>
                                            <%
                                                } finally {
                                                    // Cerrar recursos
                                                    try {
                                                        if (rs != null) {
                                                            rs.close();
                                                        }
                                                    } catch (Exception e) {
                                                    }
                                                    try {
                                                        if (ps != null) {
                                                            ps.close();
                                                        }
                                                    } catch (Exception e) {
                                                    }
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal Nuevo Ticket (Solo Admin) -->
                <% if (isAdmin) {
                        PreparedStatement psEntidades = null;
                        PreparedStatement psUsuarios = null;
                        ResultSet rsEntidades = null;
                        ResultSet rsUsuarios = null;

                        try {
                            psEntidades = cn.prepareStatement("SELECT idEntidades, Nombre_Entidad FROM entidades ORDER BY Nombre_Entidad");
                            rsEntidades = psEntidades.executeQuery();

                            psUsuarios = cn.prepareStatement("SELECT idUsuarios, Nombre_Usuario FROM usuarios WHERE Perfil_idPerfil != 1 OR Perfil_idPerfil IS NULL ORDER BY Nombre_Usuario");
                            rsUsuarios = psUsuarios.executeQuery();
                %>
                <div class="modal fade" id="nuevoTicketModal" tabindex="-1">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg-primary text-white">
                                <h5 class="modal-title">Nuevo Ticket</h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <form action="procesar/tickets-process.jsp" method="post">
                                <div class="modal-body">
                                    <input type="hidden" name="action" value="add">

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Título *</label>
                                        <input type="text" name="titulo" class="form-control" required>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Solicitante *</label>
                                        <input type="text" name="solicitante" class="form-control" required>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Ubicación/Sede *</label>
                                        <input type="text" name="ubicacion" class="form-control" required>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Entidad *</label>
                                        <select name="entidad" class="form-select" required>
                                            <option value="">Seleccionar entidad...</option>
                                            <% while (rsEntidades.next()) {%>
                                            <option value="<%= rsEntidades.getInt("idEntidades")%>">
                                                <%= rsEntidades.getString("Nombre_Entidad")%>
                                            </option>
                                            <% } %>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Asignar a (opcional)</label>
                                        <select name="usuario_asignado" class="form-select">
                                            <option value="">Sin asignar</option>
                                            <% while (rsUsuarios.next()) {%>
                                            <option value="<%= rsUsuarios.getInt("idUsuarios")%>">
                                                <%= rsUsuarios.getString("Nombre_Usuario")%>
                                            </option>
                                            <% } %>
                                        </select>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                    <button type="submit" class="btn btn-primary">Crear Ticket</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <%
                        } catch (Exception e) {
                            System.out.println("Error cargando modales: " + e.getMessage());
                        } finally {
                            try {
                                if (rsEntidades != null) {
                                    rsEntidades.close();
                                }
                            } catch (Exception e) {
                            }
                            try {
                                if (psEntidades != null) {
                                    psEntidades.close();
                                }
                            } catch (Exception e) {
                            }
                            try {
                                if (rsUsuarios != null) {
                                    rsUsuarios.close();
                                }
                            } catch (Exception e) {
                            }
                            try {
                                if (psUsuarios != null) {
                                    psUsuarios.close();
                                }
                            } catch (Exception e) {
                            }
                        }
                    }%>
            </div>


        </main>

        <!-- MODALES DE DETALLE (fuera del bucle) -->
        <!-- Se cargarán dinámicamente -->

        <!-- FOOTER -->
        <%@ include file="includes/footer.jsp"%>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                                                                    // Función para mostrar detalles dinámicamente
                                                                    function mostrarDetalle(idTicket) {
                                                                        // Cargar detalles via AJAX
                                                                        fetch('procesar/detalle-ticket.jsp?id=' + idTicket)
                                                                                .then(response => response.text())
                                                                                .then(html => {
                                                                                    console.log(html)
                                                                                    // Crear y mostrar modal dinámico
                                                                                    const modalDiv = document.createElement('div');
                                                                                    modalDiv.innerHTML = html;
                                                                                    document.body.appendChild(modalDiv);

                                                                                    // Mostrar modal
                                                                                    const modal = new bootstrap.Modal(document.getElementById('detalleTicketModal' + idTicket));
                                                                                    modal.show();

                                                                                    // Limpiar al cerrar
                                                                                    modalDiv.firstChild.addEventListener('hidden.bs.modal', function () {
                                                                                        document.body.removeChild(modalDiv.firstChild);
                                                                                    });
                                                                                })
                                                                                .catch(error => {
                                                                                    alert('Error al cargar detalles del ticket');
                                                                                    console.error(error);
                                                                                });
                                                                    }

                                                                    // Función para filtrar tickets
                                                                    function filtrarTickets() {
                                                                        const estado = document.querySelector('[name="estado"]').value;
                                                                        const fechaDesde = document.querySelector('[name="fechaDesde"]').value;
                                                                        const fechaHasta = document.querySelector('[name="fechaHasta"]').value;

                                                                        window.location.href = 'tickets.jsp?estado=' + estado + '&desde=' + fechaDesde + '&hasta=' + fechaHasta;
                                                                    }

                                                                    // Función para actualizar estado rápidamente (solo admin)
                                                                    function cambiarEstado(idTicket, nuevoEstado) {
                                                                        if (confirm('¿Cambiar estado a ' + nuevoEstado + '?')) {
                                                                            fetch('procesar/tickets-process.jsp', {
                                                                                method: 'POST',
                                                                                headers: {
                                                                                    'Content-Type': 'application/x-www-form-urlencoded',
                                                                                },
                                                                                body: 'action=cambiarEstado&id=' + idTicket + '&estado=' + nuevoEstado
                                                                            })
                                                                                    .then(response => response.text())
                                                                                    .then(data => {
                                                                                        location.reload();
                                                                                    })
                                                                                    .catch(error => {
                                                                                        alert('Error al cambiar estado');
                                                                                    });
                                                                        }
                                                                    }
        </script>

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