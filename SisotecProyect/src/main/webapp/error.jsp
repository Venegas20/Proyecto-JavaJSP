


<%-- error.jsp en raíz --%>
<%@page isErrorPage="true" contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Error</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="container mt-5">
        <div class="alert alert-danger">
            <h1>❌ Error en la aplicación</h1>
            <h4>Mensaje:</h4>
            <p><%= exception != null ? exception.getMessage() : "Error desconocido"%></p>

            <h4>Stack Trace:</h4>
            <pre class="bg-light p-3"><%
                if (exception != null) {
                    java.io.StringWriter sw = new java.io.StringWriter();
                    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
                    exception.printStackTrace(pw);
                    out.print(sw.toString());
                }
                %></pre>

            <h4>Información adicional:</h4>
            <p><strong>URL:</strong> <%= request.getRequestURL()%></p>
            <p><strong>Usuario en sesión:</strong> <%= session.getAttribute("usuario") != null ? "Sí" : "No"%></p>

            <a href="javascript:history.back()" class="btn btn-secondary mt-3">← Volver</a>
            <a href="../LOGIN/login.html" class="btn btn-primary mt-3 ms-2">Ir al login</a>
        </div>
    </body>
</html>