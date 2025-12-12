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


            .access-denied-container {
               
                margin:  auto;
                padding: 20px;
            }

            .access-card {
                background: white;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                overflow: hidden;
                animation: fadeInUp 0.8s ease-out;
            }

            .access-header {
                background: linear-gradient(to right, #dc3545, #ff6b6b);
                color: white;
                padding: 40px 30px;
                text-align: center;
                position: relative;
                overflow: hidden;
            }

   

            .error-code {
                font-size: 8rem;
                font-weight: 900;
                margin: 0;
                line-height: 1;
                text-shadow: 3px 3px 0 rgba(0, 0, 0, 0.1);
            }

            .error-title {
                font-size: 2.5rem;
                margin-top: 10px;
                font-weight: 700;
            }

            .access-body {
                padding: 40px;
            }

            .icon-container {
                width: 100px;
                height: 100px;
                background: #ffeaea;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 30px;
                border: 5px solid #ffcccc;
            }

            .access-icon {
                font-size: 50px;
                color: #dc3545;
            }

            .permission-list {
                background: #f8f9fa;
                border-radius: 10px;
                padding: 25px;
                margin: 30px 0;
                border-left: 5px solid #dc3545;
            }

            .user-info-card {
                background: #e3f2fd;
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 30px;
                border: 1px solid #bbdefb;
            }

            .btn-access {
                padding: 12px 30px;
                border-radius: 50px;
                font-weight: 600;
                transition: all 0.3s ease;
                display: inline-flex;
                align-items: center;
                gap: 10px;
                border: none;
            }

            .btn-access:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
            }

            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }

                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            @keyframes float {
                from {
                    transform: rotate(0deg);
                }

                to {
                    transform: rotate(360deg);
                }
            }

            .login-form {
                max-width: 400px;
                margin: 30px auto 0;
                padding: 20px;
                background: #f8f9fa;
                border-radius: 10px;
                display: none;
            }

            @media (max-width: 768px) {
                .error-code {
                    font-size: 6rem;
                }

                .error-title {
                    font-size: 2rem;
                }

                .access-body {
                    padding: 30px 20px;
                }
            }
        </style>
    </head>

    <body>
        <%@ include file="includes/navbar.jsp"%>

        <%@ include file="includes/header.jsp"%>

        <!-- CONTENIDO PRINCIPAL -->
        <main class="main-content">
            <div class="access-denied-container">
                <div class="access-card">
                    <!-- Encabezado -->
                    <div class="access-header">
                        <h1 class="error-code">403</h1>
                        <h2 class="error-title">ACCESO DENEGADO</h2>
                        <p class="lead mb-0">No tienes permisos para acceder a este recurso</p>
                    </div>

                    <!-- Cuerpo -->
                    <div class="access-body">
                        <div class="icon-container">
                            <i class="bi bi-shield-lock access-icon"></i>
                        </div>

                        <h3 class="text-center mb-4">Acceso Restringido</h3>

                        <p class="text-center text-muted mb-4">
                            Lo sentimos, pero no tienes los permisos necesarios para acceder a esta página.
                            Esta área está reservada para usuarios con privilegios de administrador.
                        </p>





                        <!-- Botones de acción -->
                        <div class="text-center">
                            <div class="d-flex flex-wrap justify-content-center gap-3">
                                <a href="dashboard.jsp" class="btn btn-primary btn-access">
                                    <i class="bi bi-speedometer2"></i> Ir al Dashboard
                                </a>



                                <button onclick="history.back()" class="btn btn-outline-secondary btn-access">
                                    <i class="bi bi-arrow-left"></i> Volver Atrás
                                </button>


                            </div>

                            <!-- Opción para contactar administrador -->
                            <div class="mt-4">
                                <p class="text-muted">
                                    ¿Crees que esto es un error?
                                    <a href="mailto:admin@empresa.com?subject=Acceso Denegado - Requiero permisos de administrador"
                                       class="text-decoration-none">
                                        <i class="bi bi-envelope"></i> Contacta al administrador
                                    </a>
                                </p>
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


        <script>

            // Simular intento de login como admin
            function attemptAdminLogin() {
                window.location.href = "../logout.jsp";
            }

        </script>
    </body>

</html>
