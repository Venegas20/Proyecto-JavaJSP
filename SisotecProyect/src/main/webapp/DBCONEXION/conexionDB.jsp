<%
    java.sql.Connection cn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        cn = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/sisotec_proyecto?useSSL=false&serverTimezone=UTC-5", "root", ""
        );
    } catch (Exception e) {
        out.print(e.getMessage());
    }

%>

