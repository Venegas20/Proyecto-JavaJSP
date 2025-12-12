<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../DBCONEXION/conexionDB.jsp"%>

<%-- CÓDIGO PARA PROCESAR CRUD --%>
<%
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
            response.sendRedirect("perfil.jsp");
            return;
            
        } catch (Exception e) {
            session.setAttribute("mensaje", "Error: " + e.getMessage());
            session.setAttribute("tipoMensaje", "danger");
            response.sendRedirect("perfil.jsp");
            return;
        } finally {
            try {
                if (psCrud != null) psCrud.close();
                if (conCrud != null) conCrud.close();
            } catch (Exception ex) {}
        }
    }
%>

<%
    EUsuario user = (EUsuario) session.getAttribute("usuario");
    List<ResultSet> listaPerfiles = new ArrayList<>();
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
                ps = con.prepareStatement("SELECT * FROM perfil ORDER BY idPerfil");
                rs = ps.executeQuery();
                
                while (rs.next()) {
                    listaPerfiles.add(rs);
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    if (con != null) con.close();
                } catch (Exception ex) {}
            }
        }
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
            .card {
                border-radius: 10px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                border: none;
                margin-bottom: 20px;
            }

            .card-header {
                background-color: #4a6bdf;
                color: white;
                border-radius: 10px 10px 0 0 !important;
                padding: 15px 20px;
                font-weight: 600;
            }

            .table th {
                background-color: #f1f5fd;
                font-weight: 600;
                color: #333;
                border-bottom: 2px solid #dee2e6;
            }

            .table td {
                vertical-align: middle;
            }

            h2 {
                color: #333;
                font-weight: 600;
                margin-bottom: 20px;
                border-left: 5px solid #4a6bdf;
                padding-left: 15px;
            }

            .perfil-id {
                font-weight: 600;
                color: #4a6bdf;
                background-color: #f0f4ff;
                padding: 3px 8px;
                border-radius: 4px;
            }

            .btn-action {
                padding: 5px 10px;
                margin: 0 2px;
                border-radius: 5px;
                font-size: 0.85rem;
            }

            .btn-view {
                background-color: #17a2b8;
                color: white;
                border: none;
            }

            .btn-edit {
                background-color: #ffc107;
                color: #212529;
                border: none;
            }

            .btn-delete {
                background-color: #dc3545;
                color: white;
                border: none;
            }

            .btn-create {
                background-color: #28a745;
                color: white;
                border: none;
                padding: 8px 16px;
                font-weight: 500;
            }

            .btn-create:hover {
                background-color: #218838;
            }

            .modal-header {
                background-color: #4a6bdf;
                color: white;
            }

            .form-label {
                font-weight: 500;
                color: #555;
            }

            .badge-status {
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 0.8rem;
                font-weight: 500;
            }

            .status-active {
                background-color: #d1f7e5;
                color: #0a8154;
            }

            .status-inactive {
                background-color: #ffeaea;
                color: #d83b3b;
            }

            .actions-header {
                min-width: 180px;
            }

            .search-box {
                max-width: 300px;
            }
            
            /* Estilo para mensajes de alerta */
            .alert {
                border-radius: 8px;
                border: none;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
        </style>
    </head>

    <body>
        <%@ include file="includes/navbar.jsp"%>

        <%@ include file="includes/header.jsp"%>

        <!-- CONTENIDO PRINCIPAL -->
        <main class="main-content">

            <div class="col">
                
                <!-- MOSTRAR MENSAJES DE CONFIRMACIÓN -->
                <%
                    String mensaje = (String) session.getAttribute("mensaje");
                    String tipoMensaje = (String) session.getAttribute("tipoMensaje");
                    if (mensaje != null) {
                %>
                <div class="row mb-3">
                    <div class="col-12">
                        <div class="alert alert-<%= tipoMensaje != null ? tipoMensaje : "success" %> alert-dismissible fade show" role="alert">
                            <i class="bi bi-check-circle me-2"></i><%= mensaje %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </div>
                </div>
                <%
                        // Limpiar mensajes después de mostrarlos
                        session.removeAttribute("mensaje");
                        session.removeAttribute("tipoMensaje");
                    }
                %>

                <!-- Título y botón crear -->
                <div class=" d-flex justify-content-between align-items-center mb-4">
                    <h2>Gestión de Perfiles</h2>
                    <button type="button" class="btn btn-create" onclick="nuevoPerfil()" data-bs-toggle="modal" data-bs-target="#createModal">
                        <i class="fas fa-plus-circle me-2"></i>Crear Nuevo Perfil
                    </button>
                </div>

                <!-- Card para la tabla -->
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="fas fa-users me-2"></i>Lista de Perfiles</span>
                        <div class="input-group search-box">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" placeholder="Buscar perfil..." id="buscarPerfil" onkeyup="filtrarPerfiles()">
                        </div>
                    </div>

                    <div class="table-responsive">
                        <!-- Tabla de perfiles -->
                        <table class="table table-hover mb-0" id="tablaPerfiles">
                            <thead>
                                <tr>
                                    <th scope="col" width="10%">ID</th>
                                    <th scope="col">Nombre del Perfil</th>
                                    <th scope="col" width="15%">Estado</th>
                                    <th scope="col" class="actions-header">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (listaPerfiles.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="4" class="text-center py-4">
                                        <i class="fas fa-info-circle me-2"></i>No hay perfiles registrados
                                    </td>
                                </tr>
                                <%
                                    } else {
                                        for (ResultSet perfil : listaPerfiles) {
                                            int id = perfil.getInt("idPerfil");
                                            String nombre = perfil.getString("Nombre_Perfil");
                                            int estado = perfil.getInt("Estado_Perfil");
                                            String estadoTexto = (estado == 1) ? "Activo" : "Inactivo";
                                            String estadoClase = (estado == 1) ? "status-active" : "status-inactive";
                                            String iconoEstado = (estado == 1) ? "fa-check-circle" : "fa-times-circle";
                                %>
                                <!-- Fila de perfil -->
                                <tr id="fila-<%= id %>">
                                    <td><span class="perfil-id"><%= id %></span></td>
                                    <td><%= nombre %></td>
                                    <td>
                                        <span class="badge-status <%= estadoClase %>">
                                            <i class="fas <%= iconoEstado %> me-1"></i> <%= estadoTexto %>
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn btn-view btn-action" onclick="verPerfil(<%= id %>, '<%= nombre %>', <%= estado %>)">
                                            <i class="fas fa-eye"></i> Ver
                                        </button>
                                        <button class="btn btn-edit btn-action" onclick="editarPerfil(<%= id %>, '<%= nombre %>', <%= estado %>)" data-bs-toggle="modal" data-bs-target="#editModal">
                                            <i class="fas fa-edit"></i> Editar
                                        </button>
                                        <button class="btn btn-delete btn-action" onclick="eliminarPerfil(<%= id %>, '<%= nombre %>')" data-bs-toggle="modal" data-bs-target="#deleteModal">
                                            <i class="fas fa-trash"></i> Eliminar
                                        </button>
                                    </td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>

        <!-- ========== MODALES ========== -->

        <!-- Modal para Ver Perfil -->
        <div class="modal fade" id="viewModal" tabindex="-1" aria-labelledby="viewModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="viewModalLabel">
                            <i class="fas fa-eye me-2"></i>Detalles del Perfil
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">ID del Perfil:</label>
                            <div class="form-control bg-light" id="viewId"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Nombre del Perfil:</label>
                            <div class="form-control bg-light" id="viewNombre"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Estado:</label>
                            <div id="viewEstado"></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal para Crear Perfil -->
        <div class="modal fade" id="createModal" tabindex="-1" aria-labelledby="createModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="createModalLabel">
                            <i class="fas fa-plus-circle me-2"></i>Crear Nuevo Perfil
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                aria-label="Close"></button>
                    </div>
                    <form id="formCrear" action="perfiles.jsp" method="POST">
                        <div class="modal-body">
                            <input type="hidden" name="accion" value="crear">
                            <div class="mb-3">
                                <label for="createNombre" class="form-label">Nombre del Perfil *</label>
                                <input type="text" class="form-control" id="createNombre" name="nombre_perfil" placeholder="Ej: Auditor" maxlength="50" required>
                                <div class="form-text">Máximo 50 caracteres</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Estado *</label>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="estado_perfil" id="createActivo" value="1" checked required>
                                    <label class="form-check-label" for="createActivo">
                                        Activo
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="estado_perfil" id="createInactivo" value="0" required>
                                    <label class="form-check-label" for="createInactivo">
                                        Inactivo
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-success">Crear Perfil</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Modal para Editar Perfil -->
        <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="editModalLabel">
                            <i class="fas fa-edit me-2"></i>Editar Perfil
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                aria-label="Close"></button>
                    </div>
                    <form id="formEditar" action="perfiles.jsp" method="POST">
                        <div class="modal-body">
                            <input type="hidden" name="accion" value="editar">
                            <input type="hidden" id="editId" name="idPerfil" value="">
                            <div class="mb-3">
                                <label class="form-label">ID del Perfil:</label>
                                <div class="form-control bg-light" id="editIdDisplay"></div>
                                <div class="form-text">El ID no se puede modificar</div>
                            </div>
                            <div class="mb-3">
                                <label for="editNombre" class="form-label">Nombre del Perfil *</label>
                                <input type="text" class="form-control" id="editNombre" name="nombre_perfil" maxlength="50" required>
                                <div class="form-text">Máximo 50 caracteres</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Estado *</label>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="estado_perfil" id="editActivo" value="1" required>
                                    <label class="form-check-label" for="editActivo">
                                        Activo
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="estado_perfil" id="editInactivo" value="0" required>
                                    <label class="form-check-label" for="editInactivo">
                                        Inactivo
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-warning">Guardar Cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Modal para Eliminar Perfil -->
        <div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title" id="deleteModalLabel">
                            <i class="fas fa-exclamation-triangle me-2"></i>Confirmar Eliminación
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                aria-label="Close"></button>
                    </div>
                    <form id="formEliminar" action="perfiles.jsp" method="POST">
                        <div class="modal-body">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" id="deleteId" name="idEliminar" value="">
                            <div class="text-center mb-4">
                                <i class="fas fa-trash-alt fa-3x text-danger mb-3"></i>
                                <h5>¿Está seguro de eliminar este perfil?</h5>
                                <p class="text-muted">Esta acción no se puede deshacer. Se eliminará permanentemente el perfil seleccionado.</p>
                            </div>
                            <div class="alert alert-warning">
                                <strong>Perfil a eliminar:</strong><br>
                                <span class="perfil-id me-2" id="deleteIdDisplay"></span> - <span id="deleteNombre"></span>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-danger">Eliminar Perfil</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- FOOTER -->
        <%@ include file="includes/footer.jsp"%>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            // Variables globales
            let perfilActualId = 0;
            let perfilActualNombre = '';
            
            // Función para filtrar perfiles en la tabla
            function filtrarPerfiles() {
                const input = document.getElementById('buscarPerfil');
                const filter = input.value.toUpperCase();
                const table = document.getElementById('tablaPerfiles');
                const tr = table.getElementsByTagName('tr');
                
                for (let i = 1; i < tr.length; i++) {
                    const tdNombre = tr[i].getElementsByTagName('td')[1];
                    if (tdNombre) {
                        const txtValue = tdNombre.textContent || tdNombre.innerText;
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            tr[i].style.display = "";
                        } else {
                            tr[i].style.display = "none";
                        }
                    }
                }
            }
            
            // Función para mostrar detalles del perfil
            function verPerfil(id, nombre, estado) {
                perfilActualId = id;
                perfilActualNombre = nombre;
                
                document.getElementById('viewId').textContent = id;
                document.getElementById('viewNombre').textContent = nombre;
                
                const estadoTexto = (estado == 1) ? 'Activo' : 'Inactivo';
                const estadoClase = (estado == 1) ? 'status-active' : 'status-inactive';
                const icono = (estado == 1) ? 'fa-check-circle' : 'fa-times-circle';
                
                document.getElementById('viewEstado').innerHTML = `
                    <span class="badge-status ${estadoClase}">
                        <i class="fas ${icono} me-1"></i> ${estadoTexto}
                    </span>
                `;
                
                document.getElementById('viewModalLabel').innerHTML = `
                    <i class="fas fa-eye me-2"></i>Viendo Perfil: ${nombre}
                `;
                
                const modal = new bootstrap.Modal(document.getElementById('viewModal'));
                modal.show();
            }
            
            // Función para preparar edición de perfil
            function editarPerfil(id, nombre, estado) {
                perfilActualId = id;
                perfilActualNombre = nombre;
                
                document.getElementById('editId').value = id;
                document.getElementById('editIdDisplay').textContent = id;
                document.getElementById('editNombre').value = nombre;
                
                if (estado == 1) {
                    document.getElementById('editActivo').checked = true;
                } else {
                    document.getElementById('editInactivo').checked = true;
                }
                
                document.getElementById('editModalLabel').innerHTML = `
                    <i class="fas fa-edit me-2"></i>Editando Perfil: ${nombre}
                `;
            }
            
            // Función para preparar eliminación de perfil
            function eliminarPerfil(id, nombre) {
                perfilActualId = id;
                perfilActualNombre = nombre;
                
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteIdDisplay').textContent = `ID: ${id}`;
                document.getElementById('deleteNombre').textContent = nombre;
            }
            
            // Función para limpiar formulario de creación
            function nuevoPerfil() {
                document.getElementById('formCrear').reset();
                document.getElementById('createActivo').checked = true;
            }
            
            // Limpiar formulario de creación cuando se cierre el modal
            document.getElementById('createModal').addEventListener('hidden.bs.modal', function () {
                nuevoPerfil();
            });
            
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

            /* FUNCIÓN PARA CARGAR PÁGINAS EN EL IFRAME */
            function loadPage(url) {
                document.getElementById("contentFrame").src = url;
                document.querySelector(".page-title h1").textContent = "Gestión de Perfiles";
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