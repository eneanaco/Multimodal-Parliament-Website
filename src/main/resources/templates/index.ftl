<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Multimodal Parliament Explorer</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="/static/index-styles.css">
</head>
<body>
<!-- Navbar -->
<nav class="navbar">
    <div class="navbar-titel">
        <h1><a href="/" style="text-decoration: none; color: inherit;">Multimodal Parliament Explorer</a></h1>
    </div>
    <div class="navbar-links">
        <a href="/visualisierungen" class="nav-link">Visualisierungen</a>
        <a href="/redenportal" class="nav-link red-border">Redeportal</a>
        <a href="#footer" class="nav-button">Über Projekt</a>
    </div>
</nav>

<div class="container">
    <div class="welcome-section">
        <h1>Willkommen im Multimodalen Parliament Explorer</h1>
        <p>Entdecken Sie Parlamentsdebatten des Deutschen Bundestages auf eine neue und interaktive Weise.</p>

        <div class="features">
            <div class="feature-card">
                <i class="fas fa-chart-pie"></i>
                <h3>Visualisierungen</h3>
                <p>Interaktive Diagramme zu Themen, Wortarten, Stimmungen und Entitäten</p>
                <a href="/visualisierungen" class="feature-button">Visualisierungen erkunden</a>
            </div>
            <div class="feature-card">
                <i class="fas fa-comments"></i>
                <h3>Redeportal</h3>
                <p>Durchsuchen und analysieren Sie alle Parlamentsreden</p>
                <a href="/redenportal" class="feature-button">Zu den Reden</a>
            </div>
            <div class="feature-card">
                <i class="fas fa-comments"></i>
                <h3>Export</h3>
                <p>Wählen Sie aus welche Reden exportiert werden sollen.</p>
                <a href="/export" class="feature-button">Export-Seite</a>
            </div>
        </div>
    </div>
</div>
<footer id="footer">
    <div class="footer-content">
        <div class="footer-section">
            <h3>Über das Projekt</h3>
            <p>Der Multimodal Parliament Explorer wurde im Rahmen des Programmierpraktikums an der Goethe Universität Frankfurt entwickelt.</p>
        </div>
        <div class="footer-section">
            <h3>Team</h3>
            <p>Entwickelt von: Lawan Mai, Mariia Isaeva, Enea Naco, Waled Niazi</p>
        </div>
    </div>
    <div class="footer-bottom">
        <p>&copy; 2025 Multimodal Parliament Explorer - Goethe Universität Frankfurt</p>
    </div>
</footer>
</body>
</html>