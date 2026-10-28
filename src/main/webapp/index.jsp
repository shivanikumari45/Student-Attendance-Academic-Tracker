<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- 1. Database Connection Configuration ---
    String url = "jdbc:mysql://localhost:3306/student_db?useSSL=false&allowPublicKeyRetrieval=true";
    String user = "root";
    String pass = "Student@123"; // <-- Apna MySQL Password confirm kar lo
    
    Connection con = null;
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(url, user, pass);

    // --- 2. Action Handling (Create, Update, Delete) ---
    String action = request.getParameter("action");

    // DELETE Action
    if ("delete".equals(action)) {
        int id = Integer.parseInt(request.getParameter("id"));
        PreparedStatement ps = con.prepareStatement("DELETE FROM students WHERE id = ?");
        ps.setInt(1, id);
        ps.executeUpdate();
        ps.close();
        response.sendRedirect("index.jsp");
        return;
    }

    // CREATE OR UPDATE (Form Submit)
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String idParam = request.getParameter("id");
        String rollNo = request.getParameter("rollNo");
        String name = request.getParameter("name");
        int totalClasses = Integer.parseInt(request.getParameter("totalClasses"));
        int attendedClasses = Integer.parseInt(request.getParameter("attendedClasses"));
        String grade = request.getParameter("grade");

        if (idParam == null || idParam.trim().isEmpty()) {
            // INSERT (Create)
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO students (roll_no, name, total_classes, attended_classes, grade) VALUES (?, ?, ?, ?, ?)"
            );
            ps.setString(1, rollNo);
            ps.setString(2, name);
            ps.setInt(3, totalClasses);
            ps.setInt(4, attendedClasses);
            ps.setString(5, grade);
            ps.executeUpdate();
            ps.close();
        } else {
            // UPDATE
            PreparedStatement ps = con.prepareStatement(
                "UPDATE students SET roll_no=?, name=?, total_classes=?, attended_classes=?, grade=? WHERE id=?"
            );
            ps.setString(1, rollNo);
            ps.setString(2, name);
            ps.setInt(3, totalClasses);
            ps.setInt(4, attendedClasses);
            ps.setString(5, grade);
            ps.setInt(6, Integer.parseInt(idParam));
            ps.executeUpdate();
            ps.close();
        }
        response.sendRedirect("index.jsp");
        return;
    }

    // EDIT PRE-FILL (Fetch single student data)
    String editId = request.getParameter("editId");
    String rollNoVal = "", nameVal = "", gradeVal = "A";
    int totalVal = 0, attendedVal = 0;

    if (editId != null && !editId.isEmpty()) {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM students WHERE id = ?");
        ps.setInt(1, Integer.parseInt(editId));
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            rollNoVal = rs.getString("roll_no");
            nameVal = rs.getString("name");
            totalVal = rs.getInt("total_classes");
            attendedVal = rs.getInt("attended_classes");
            gradeVal = rs.getString("grade");
        }
        rs.close();
        ps.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Attendance & Academic Portal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --bg-base: #031716;
            --bg-card: rgba(3, 47, 48, 0.7);
            --border-glow: #0A7075;
            --accent-teal: #0C969C;
            --accent-soft: #6BA3BE;
            --surface-input: rgba(3, 23, 22, 0.8);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --danger: #ef4444;
            --success: #10b981;
            --warning: #f59e0b;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        }

        body {
            background: radial-gradient(circle at 10% 20%, #032F30 0%, var(--bg-base) 100%);
            color: var(--text-main);
            min-height: 100vh;
            padding: 40px 20px;
            display: flex;
            justify-content: center;
        }

        .wrapper {
            max-width: 1100px;
            width: 100%;
        }

        /* Top Header */
        .app-header {
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(10, 112, 117, 0.3);
            padding-bottom: 18px;
        }

        .app-header h1 {
            font-size: 26px;
            font-weight: 700;
            background: linear-gradient(135deg, #f8fafc 30%, var(--accent-teal) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: -0.5px;
        }

        .badge-system {
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            color: var(--accent-soft);
            background: rgba(107, 163, 190, 0.1);
            border: 1px solid rgba(107, 163, 190, 0.25);
            padding: 5px 12px;
            border-radius: 20px;
        }

        /* Glassmorphic Panel */
        .glass-card {
            background: var(--bg-card);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(10, 112, 117, 0.5);
            border-radius: 16px;
            padding: 26px;
            box-shadow: 0 20px 40px -15px rgba(3, 23, 22, 0.8);
            margin-bottom: 30px;
            transition: border-color 0.3s ease;
        }

        .glass-card:hover {
            border-color: var(--accent-teal);
        }

        .card-title {
            font-size: 15px;
            font-weight: 600;
            color: var(--accent-soft);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Form Grid */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 18px;
        }

        .input-group label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }

        .input-group input, .input-group select {
            width: 100%;
            padding: 12px 14px;
            background: var(--surface-input);
            border: 1px solid rgba(39, 77, 96, 0.8);
            color: var(--text-main);
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            outline: none;
            transition: all 0.2s ease;
        }

        .input-group input:focus, .input-group select:focus {
            border-color: var(--accent-teal);
            box-shadow: 0 0 0 3px rgba(12, 150, 156, 0.2);
            background: rgba(3, 23, 22, 1);
        }

        .actions-bar {
            margin-top: 22px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn {
            padding: 11px 22px;
            font-size: 14px;
            font-weight: 600;
            border-radius: 8px;
            cursor: pointer;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #0A7075 0%, var(--accent-teal) 100%);
            color: #ffffff;
            box-shadow: 0 4px 14px rgba(12, 150, 156, 0.35);
        }

        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(12, 150, 156, 0.55);
        }

        .btn-secondary {
            background: rgba(39, 77, 96, 0.5);
            color: var(--text-muted);
            border: 1px solid rgba(107, 163, 190, 0.2);
        }

        .btn-secondary:hover {
            color: var(--text-main);
            background: rgba(39, 77, 96, 0.8);
        }

        /* Modern Table */
        .table-responsive {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid rgba(10, 112, 117, 0.4);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 14px;
            background: var(--bg-card);
        }

        thead {
            background: rgba(10, 112, 117, 0.3);
            border-bottom: 1px solid rgba(10, 112, 117, 0.5);
        }

        th {
            padding: 14px 18px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--accent-soft);
        }

        td {
            padding: 16px 18px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.04);
            vertical-align: middle;
        }

        tbody tr {
            transition: background 0.15s ease;
        }

        tbody tr:hover {
            background: rgba(12, 150, 156, 0.08);
        }

        /* Progress Bar for Attendance */
        .pct-container {
            width: 140px;
        }

        .pct-header {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .progress-track {
            height: 6px;
            width: 100%;
            background: rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            border-radius: 10px;
            transition: width 0.4s ease;
        }

        /* Badges */
        .badge {
            display: inline-block;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 700;
            border-radius: 6px;
            text-transform: uppercase;
        }

        .grade-pill {
            background: rgba(12, 150, 156, 0.15);
            color: var(--accent-teal);
            border: 1px solid rgba(12, 150, 156, 0.4);
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 6px;
        }

        .badge-danger {
            background: rgba(239, 68, 68, 0.15);
            color: var(--danger);
            border: 1px solid rgba(239, 68, 68, 0.3);
        }

        .badge-success {
            background: rgba(16, 185, 129, 0.15);
            color: var(--success);
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .action-link {
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            margin-right: 14px;
            transition: opacity 0.2s;
        }

        .action-link:hover {
            opacity: 0.75;
        }

        .link-edit { color: var(--accent-soft); }
        .link-delete { color: var(--danger); }
    </style>
</head>
<body>

<div class="wrapper">
    <!-- Header -->
    <div class="app-header">
        <div>
            <h1>Student Attendance & Academic Tracker</h1>
            <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">Lightweight JDBC-powered database management portal</p>
        </div>
        <span class="badge-system">JDBC Direct Engine</span>
    </div>

    <!-- Dynamic Record Form -->
    <div class="glass-card">
        <div class="card-title">
            <span><%= (editId != null) ? "✏️ Update Student Record" : "➕ Register New Student" %></span>
        </div>

        <form action="index.jsp" method="post">
            <input type="hidden" name="id" value="<%= (editId != null) ? editId : "" %>">

            <div class="form-grid">
                <div class="input-group">
                    <label>Roll Number</label>
                    <input type="text" name="rollNo" value="<%= rollNoVal %>" required placeholder="e.g. 21BCS101">
                </div>
                <div class="input-group">
                    <label>Student Name</label>
                    <input type="text" name="name" value="<%= nameVal %>" required placeholder="e.g. Aman Kumar">
                </div>
                <div class="input-group">
                    <label>Total Classes</label>
                    <input type="number" name="totalClasses" value="<%= (totalVal > 0) ? totalVal : "" %>" required placeholder="0" min="1">
                </div>
                <div class="input-group">
                    <label>Attended</label>
                    <input type="number" name="attendedClasses" value="<%= (attendedVal > 0) ? attendedVal : "" %>" required placeholder="0" min="0">
                </div>
                <div class="input-group">
                    <label>Academic Grade</label>
                    <select name="grade">
                        <option value="A+" <%= "A+".equals(gradeVal) ? "selected" : "" %>>A+ (Outstanding)</option>
                        <option value="A" <%= "A".equals(gradeVal) ? "selected" : "" %>>A (Excellent)</option>
                        <option value="B" <%= "B".equals(gradeVal) ? "selected" : "" %>>B (Good)</option>
                        <option value="C" <%= "C".equals(gradeVal) ? "selected" : "" %>>C (Average)</option>
                        <option value="D" <%= "D".equals(gradeVal) ? "selected" : "" %>>D (Pass)</option>
                        <option value="F" <%= "F".equals(gradeVal) ? "selected" : "" %>>F (Fail)</option>
                    </select>
                </div>
            </div>

            <div class="actions-bar">
                <button type="submit" class="btn btn-primary">
                    <%= (editId != null) ? "Save Changes" : "Register Student" %>
                </button>
                <% if (editId != null) { %>
                    <a href="index.jsp" class="btn btn-secondary">Cancel Edit</a>
                <% } %>
            </div>
        </form>
    </div>

    <!-- Data Table View -->
    <div class="table-responsive">
        <table>
            <thead>
                <tr>
                    <th>Student Info</th>
                    <th>Roll Number</th>
                    <th>Classes Ratio</th>
                    <th>Attendance Progress</th>
                    <th>Status</th>
                    <th>Grade</th>
                    <th style="text-align: right;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    Statement st = con.createStatement();
                    ResultSet rs = st.executeQuery("SELECT * FROM students ORDER BY id DESC");
                    boolean hasData = false;

                    while (rs.next()) {
                        hasData = true;
                        int id = rs.getInt("id");
                        String roll = rs.getString("roll_no");
                        String sname = rs.getString("name");
                        int tot = rs.getInt("total_classes");
                        int att = rs.getInt("attended_classes");
                        String grd = rs.getString("grade");

                        double pct = (tot > 0) ? ((double) att / tot) * 100 : 0.0;
                        boolean isShortage = pct < 75.0;

                        // Visual color mapping
                        String barColor = isShortage ? "var(--danger)" : "var(--success)";
                        if (!isShortage && pct < 80.0) barColor = "var(--warning)";
                %>
                    <tr>
                        <td>
                            <div style="font-weight: 600; color: #fff;"><%= sname %></div>
                            <div style="font-size: 11px; color: var(--text-muted);">Ref: #<%= id %></div>
                        </td>
                        <td>
                            <span style="font-family: monospace; font-size: 13px; font-weight: 600; color: var(--accent-soft);">
                                <%= roll %>
                            </span>
                        </td>
                        <td style="color: var(--text-muted); font-size: 13px;">
                            <b style="color: #fff;"><%= att %></b> / <%= tot %>
                        </td>
                        <td>
                            <div class="pct-container">
                                <div class="pct-header">
                                    <span style="color: <%= barColor %>;"><%= String.format("%.1f", pct) %>%</span>
                                </div>
                                <div class="progress-track">
                                    <div class="progress-fill" style="width: <%= Math.min(100, Math.max(0, pct)) %>%; background: <%= barColor %>;"></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="badge <%= isShortage ? "badge-danger" : "badge-success" %>">
                                <%= isShortage ? "Shortage" : "Eligible" %>
                            </span>
                        </td>
                        <td>
                            <span class="grade-pill"><%= grd %></span>
                        </td>
                        <td style="text-align: right;">
                            <a href="index.jsp?editId=<%= id %>" class="action-link link-edit">Edit</a>
                            <a href="index.jsp?action=delete&id=<%= id %>" class="action-link link-delete" onclick="return confirm('Remove this student record?')">Delete</a>
                        </td>
                    </tr>
                <%
                    }
                    if (!hasData) {
                %>
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 40px 20px;">
                            No students registered yet. Add a student using the form above.
                        </td>
                    </tr>
                <%
                    }
                    rs.close();
                    st.close();
                    con.close();
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>