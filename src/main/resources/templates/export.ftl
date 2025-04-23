<!-- export.ftl by Waled-->

<!DOCTYPE html>
<html lang="de">
<!-- header of the html page with style -->
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Export-Auswahl</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="/static/index-styles.css">
    <style>
        .visualization-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 40px;
        }

        .visualization-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            padding: 20px;
            text-align: center;
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
        }

        .visualization-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
        }

        .visualization-icon {
            font-size: 48px;
            margin-bottom: 15px;
            color: #DA6565;
        }

        .visualization-card h2 {
            color: #333;
            margin-bottom: 10px;
        }

        .visualization-card p {
            color: #666;
            margin-bottom: 20px;
        }

        .view-button {
            display: inline-block;
            background-color: #DA6565;
            color: white;
            padding: 8px 20px;
            border-radius: 30px;
            text-decoration: none;
            font-weight: bold;
            transition: background-color 0.3s;
        }

        .view-button:hover {
            background-color: #C45050;
        }
    </style>
</head>
<body>
<!-- Navigation bar at the top used like all the other .ftl files -->
<nav class="navbar">
    <div class="navbar-titel">
        <h1><a href="/" style="text-decoration: none; color: inherit;">Multimodal Parliament Explorer</a></h1>
    </div>
    <div class="navbar-links">
        <a href="/visualisierungen" class="nav-link active">Visualisierungen</a>
        <a href="/redenportal" class="nav-link red-border">Redeportal</a>
        <a href="/export" class="nav-link red-border">Export-Auswahl</a>

        <a href="#footer" class="nav-button">Über Projekt</a>

    </div>
</nav>

<!-- some text to explain -->
<div class="container">
    <h1>Export Option auswählen</h1>
    <p>Wählen Sie eine der folgenden Export-Optionen aus.</p>



    <!-- Buttons to decide the type of export by deciding for how many speeches
     and it leads to the next page for further exporting.-->
    <div class="visualization-grid">
        <div class="feature-card">
            <h2>Alle</h2>
            <a href="/alle/" class="feature-button">Export aller reden</a>
            <h2>Einzeln</h2>
            <a href="/einzelne" class="feature-button">Export der einzelnen Reden</a>
            <h2>Mehrere</h2>
            <a href="/mehrere" class="feature-button">Export mehrerer Reden</a>
            <h2>Redner</h2>
            <a href="/redner" class="feature-button">Export nach Redner</a>
        </div>

    </div>
</div>

<!-- The footer of the page with some information  -->
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
