<%
    Class.forName("com.mysql.jdbc.Driver");
    java.sql.Connection cn = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/sisotec_proyecto", "root", ""
    );
    %>

