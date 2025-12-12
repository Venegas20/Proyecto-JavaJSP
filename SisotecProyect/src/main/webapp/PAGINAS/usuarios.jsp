<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="Entidades.EUsuario"%>
<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- 🔗 IMPORTAMOS LA CONEXIÓN EXTERNA -->
<%@ include file="../DBCONEXION/conexionDB.jsp"%>

<%-- CÓDIGO PARA PROCESAR CRUD --%>
<%    // Procesar las operaciones CRUD
    if (request.getMethod().equals("POST")) {
        String accion = request.getParameter("accion");
        Connection conCrud = null;
        PreparedStatement psCrud = null;

        try {
            conCrud = cn;

            if (accion != null) {
                switch (accion) {
                    case "crear":
                        // INSERTAR NUEVO USUARIO
                        String usuario = request.getParameter("usuario");
                        String clave = request.getParameter("clave");
                        String nombre_usuario = request.getParameter("nombre_usuario");
                        String email = request.getParameter("email");
                        String perfil_id = request.getParameter("perfil_id");

                        String sqlInsert = "INSERT INTO usuarios (Usuario, Clave, Nombre_Usuario, Email, Perfil_idPerfil) VALUES (?, ?, ?, ?, ?)";
                        psCrud = conCrud.prepareStatement(sqlInsert);
                        psCrud.setString(1, usuario);
                        psCrud.setString(2, clave);
                        psCrud.setString(3, nombre_usuario);
                        psCrud.setString(4, email);
                        psCrud.setInt(5, Integer.parseInt(perfil_id));
                        psCrud.executeUpdate();

                        session.setAttribute("mensaje", "Usuario creado exitosamente");
                        session.setAttribute("tipoMensaje", "success");
                        break;

                    case "editar":
                        // ACTUALIZAR USUARIO
                        String idEditar = request.getParameter("idUsuario");
                        String usuarioEditar = request.getParameter("usuario");
                        String claveEditar = request.getParameter("clave");
                        String nombreEditar = request.getParameter("nombre_usuario");
                        String emailEditar = request.getParameter("email");
                        String perfilEditar = request.getParameter("perfil_id");

                        String sqlUpdate = "UPDATE usuarios SET Usuario = ?, Clave = ?, Nombre_Usuario = ?, Email = ?, Perfil_idPerfil = ? WHERE idUsuarios = ?";
                        psCrud = conCrud.prepareStatement(sqlUpdate);
                        psCrud.setString(1, usuarioEditar);
                        psCrud.setString(2, claveEditar);
                        psCrud.setString(3, nombreEditar);
                        psCrud.setString(4, emailEditar);
                        psCrud.setInt(5, Integer.parseInt(perfilEditar));
                        psCrud.setInt(6, Integer.parseInt(idEditar));
                        psCrud.executeUpdate();

                        session.setAttribute("mensaje", "Usuario actualizado exitosamente");
                        session.setAttribute("tipoMensaje", "success");
                        break;

                    case "eliminar":
                        // ELIMINAR USUARIO
                        String idEliminar = request.getParameter("idEliminar");

                        String sqlDelete = "DELETE FROM usuarios WHERE idUsuarios = ?";
                        psCrud = conCrud.prepareStatement(sqlDelete);
                        psCrud.setInt(1, Integer.parseInt(idEliminar));
                        int filas = psCrud.executeUpdate();

                        if (filas > 0) {
                            session.setAttribute("mensaje", "Usuario eliminado exitosamente");
                            session.setAttribute("tipoMensaje", "success");
                        } else {
                            session.setAttribute("mensaje", "No se pudo eliminar el usuario");
                            session.setAttribute("tipoMensaje", "danger");
                        }
                        break;
                }
            }

            // Redirigir para evitar reenvío del formulario
            response.sendRedirect("usuarios.jsp");
            return;

        } catch (Exception e) {
            session.setAttribute("mensaje", "Error: " + e.getMessage());
            session.setAttribute("tipoMensaje", "danger");
            response.sendRedirect("usuarios.jsp");
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

<%
    EUsuario user = (EUsuario) session.getAttribute("usuario");
    List<EUsuario> lista = new ArrayList();
    if (user == null) {
        response.sendRedirect("../LOGIN/login.html");
        return;
    }
    if (user != null && user.getPid() != 1) {
        response.sendRedirect("error403.jsp");
        return;
    }

    Connection con = cn;
    PreparedStatement ps = null;
    ResultSet rs = null;
    if (con == null) {
        response.sendRedirect("../LOGIN/errorDb.jsp");
    } else {
        try {
            ps = con.prepareStatement(
                    "SELECT u.*,p.Nombre_Perfil, p.Estado_Perfil FROM Usuarios u LEFT JOIN perfil p ON u.Perfil_idPerfil = p.idPerfil ORDER BY u.idUsuarios"
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
                usuario.setNombre_perfil(rs.getString("Nombre_Perfil"));

                lista.add(usuario);
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

            } catch (Exception ex) {
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
        <style>
            /* Estilo para los badges de perfil */
            .badge-perfil {
                padding: 0.35em 0.65em;
                font-size: 0.75em;
                font-weight: 600;
                border-radius: 0.375rem;
                border: 1px solid;
            }

            /* Botones de acción */
            .btn-action {
                width: 32px;
                height: 32px;
                padding: 0;
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            /* Efecto hover en filas de tabla */
            .table-custom tbody tr:hover {
                background-color: rgba(0, 0, 0, 0.02);
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
                                        <i class="bi bi-people-fill me-2"></i>Gestión de Usuarios
                                    </h2>
                                </div>
                                <div class="col-md-6 text-md-end">
                                    <button class="btn btn-light fw-bold" onclick="nuevoUsuario()" data-bs-toggle="modal" data-bs-target="#modalUsuario">
                                        <i class="bi bi-person-plus me-2"></i>Nuevo Usuario
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- MOSTRAR MENSAJES DE CONFIRMACIÓN -->
                <%
                    String mensaje = (String) session.getAttribute("mensaje");
                    String tipoMensaje = (String) session.getAttribute("tipoMensaje");
                    if (mensaje != null) {
                %>
                <div class="row mb-3">
                    <div class="col-12">
                        <div class="alert alert-<%= tipoMensaje != null ? tipoMensaje : "success"%> alert-dismissible fade show" role="alert">
                            <i class="bi bi-check-circle me-2"></i><%= mensaje%>
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
                                            String badgeColor = "";

                                            switch (u.getPid()) {
                                                case 1:
                                                    badgeColor = "bg-primary text-primary bg-opacity-10";
                                                    break;
                                                case 2:
                                                    badgeColor = "bg-warning text-warning bg-opacity-10";
                                                    break;
                                                case 3:
                                                    badgeColor = "bg-success text-success bg-opacity-10";
                                                    break;
                                                default:
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
                                                <%= u.getNombre_perfil()%>
                                            </span>
                                        </td>

                                        <td>
                                            <div class="d-flex gap-1">
                                                <button class="btn btn-action btn-warning" title="Editar" onclick="editarUsuario(<%= u.getId()%>, '<%= u.getUsuario()%>', '<%= u.getClave()%>', '<%= u.getNusuario()%>', '<%= u.getEmail()%>', <%= u.getPid()%>)">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <button class="btn btn-action btn-danger" title="Eliminar" onclick="eliminarUsuario(<%= u.getId()%>)">
                                                    <i class="bi bi-trash"></i>
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

            <!-- MODAL NUEVO/EDITAR USUARIO -->
            <div class="modal fade" id="modalUsuario" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">

                        <div class="modal-header text-bg-secondary">
                            <h5 class="modal-title fw-bold">
                                <i class="bi bi-person-plus me-2"></i>Nuevo Usuario
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>

                        <form id="formUsuario" action="usuarios.jsp" method="POST">
                            <div class="modal-body">
                                <input type="hidden" id="accion" name="accion" value="crear">
                                <input type="hidden" id="idUsuario" name="idUsuario" value="0">

                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Usuario *</label>
                                        <input type="text" id="usuario" name="usuario" class="form-control" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Contraseña *</label>
                                        <input type="password" id="clave" name="clave" class="form-control" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Nombre Completo *</label>
                                        <input type="text" id="nombre_usuario" name="nombre_usuario" class="form-control" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Email *</label>
                                        <input type="email" id="email" name="email" class="form-control" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Perfil *</label>
                                        <select class="form-select" id="perfil_id" name="perfil_id" required>
                                            <option value="">Seleccionar...</option>
                                            <%
                                                // Cargar perfiles directamente aquí
                                                Connection conSelect = null;
                                                PreparedStatement psSelect = null;
                                                ResultSet rsSelect = null;
                                                boolean hayPerfiles = false;

                                                try {
                                                    conSelect = cn;
                                                    String sql = "SELECT idPerfil, Nombre_Perfil FROM perfil WHERE Estado_Perfil = 1 ORDER BY Nombre_Perfil";
                                                    psSelect = conSelect.prepareStatement(sql);
                                                    rsSelect = psSelect.executeQuery();

                                                    // Verificar si hay resultados
                                                    if (rsSelect.next()) {
                                                        hayPerfiles = true;
                                                        // Volver al primer registro
                                                        rsSelect.beforeFirst();

                                                        // Procesar todos los registros
                                                        while (rsSelect.next()) {
                                                            int idPerfil = rsSelect.getInt("idPerfil");
                                                            String nombrePerfil = rsSelect.getString("Nombre_Perfil");
                                            %>
                                            <option value="<%= idPerfil%>"><%= nombrePerfil%></option>
                                            <%
                                                }
                                            } else {
                                                // No hay perfiles activos
                                            %>
                                            <option value="" disabled>No hay perfiles activos</option>
                                            <%
                                                }
                                            } catch (Exception e) {
                                                // Error en la consulta
%>
                                            <option value="" disabled><%= e.getMessage()%> </option>
                                            <%
                                                } finally {
                                                    // Cerrar recursos
                                                    try {
                                                        if (rsSelect != null) {
                                                            rsSelect.close();
                                                        }
                                                        if (psSelect != null) {
                                                            psSelect.close();
                                                        }
                                                        if (conSelect != null) {
                                                            conSelect.close();
                                                        }
                                                    } catch (Exception ex) {
                                                    }
                                                }

                                                // Si no hay perfiles después del procesamiento
                                                if (!hayPerfiles) {
                                            %>
                                            <option value="" disabled>No hay perfiles disponibles</option>
                                            <%
                                                }
                                            %>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" class="btn btn-primary" id="btnGuardarUsuario">Guardar Usuario</button>
                            </div>
                        </form>

                    </div>
                </div>
            </div>

            <!-- MODAL DE CONFIRMACIÓN PARA ELIMINAR -->
            <div class="modal fade" id="modalConfirmar" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header bg-danger text-white">
                            <h5 class="modal-title fw-bold">
                                <i class="bi bi-exclamation-triangle me-2"></i>Confirmar Eliminación
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <p class="mb-0">¿Está seguro de eliminar este usuario? Esta acción no se puede deshacer.</p>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="button" class="btn btn-danger" id="btnConfirmarEliminar">Eliminar</button>
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
                                                    // Variables globales para los modales
                                                    let usuarioActualId = 0;

                                                    // Función para abrir modal de edición
                                                    function editarUsuario(id, usuario, clave, nombre, email, perfil) {
                                                        usuarioActualId = id;

                                                        // Llenar el formulario con los datos del usuario
                                                        document.getElementById('accion').value = 'editar';
                                                        document.getElementById('idUsuario').value = id;
                                                        document.getElementById('usuario').value = usuario;
                                                        document.getElementById('clave').value = clave;
                                                        document.getElementById('nombre_usuario').value = nombre;
                                                        document.getElementById('email').value = email;
                                                        document.getElementById('perfil_id').value = perfil;

                                                        // Cambiar título del modal
                                                        document.querySelector('#modalUsuario .modal-title').innerHTML = '<i class="bi bi-pencil me-2"></i>Editar Usuario';
                                                        document.querySelector('#modalUsuario .modal-footer .btn-primary').textContent = 'Actualizar Usuario';

                                                        // Mostrar modal
                                                        const modal = new bootstrap.Modal(document.getElementById('modalUsuario'));
                                                        modal.show();
                                                    }

                                                    // Función para limpiar formulario al crear nuevo
                                                    function nuevoUsuario() {
                                                        usuarioActualId = 0;

                                                        document.getElementById('accion').value = 'crear';
                                                        document.getElementById('idUsuario').value = '0';
                                                        document.getElementById('formUsuario').reset();
                                                        document.getElementById('perfil_id').value = '';

                                                        document.querySelector('#modalUsuario .modal-title').innerHTML = '<i class="bi bi-person-plus me-2"></i>Nuevo Usuario';
                                                        document.querySelector('#modalUsuario .modal-footer .btn-primary').textContent = 'Guardar Usuario';
                                                    }

                                                    // Función para eliminar usuario
                                                    function eliminarUsuario(id) {
                                                        usuarioActualId = id;

                                                        // Mostrar modal de confirmación
                                                        const modalConfirmar = new bootstrap.Modal(document.getElementById('modalConfirmar'));
                                                        modalConfirmar.show();
                                                    }

                                                    // Configurar botón de confirmar eliminación
                                                    document.getElementById('btnConfirmarEliminar').addEventListener('click', function () {
                                                        // Crear formulario oculto para enviar la solicitud de eliminación
                                                        const form = document.createElement('form');
                                                        form.method = 'POST';
                                                        form.action = 'usuarios.jsp';

                                                        const accionInput = document.createElement('input');
                                                        accionInput.type = 'hidden';
                                                        accionInput.name = 'accion';
                                                        accionInput.value = 'eliminar';
                                                        form.appendChild(accionInput);

                                                        const idInput = document.createElement('input');
                                                        idInput.type = 'hidden';
                                                        idInput.name = 'idEliminar';
                                                        idInput.value = usuarioActualId;
                                                        form.appendChild(idInput);

                                                        document.body.appendChild(form);
                                                        form.submit();
                                                    });

                                                    // Limpiar formulario cuando se cierre el modal
                                                    document.getElementById('modalUsuario').addEventListener('hidden.bs.modal', function () {
                                                        nuevoUsuario(); // Restablece a estado de creación
                                                    });

                                                    // Cuando se abra el modal para nuevo usuario, limpiarlo
                                                    document.querySelector('[data-bs-target="#modalUsuario"]').addEventListener('click', nuevoUsuario);

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

    </body>

</html>