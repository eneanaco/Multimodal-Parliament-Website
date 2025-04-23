<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visualisierungen</title>
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
<!-- Navbar -->
<nav class="navbar">
    <div class="navbar-titel">
        <h1><a href="/" style="text-decoration: none; color: inherit;">Multimodal Parliament Explorer</a></h1>
    </div>
    <div class="navbar-links">
        <a href="/visualisierungen" class="nav-link active">Visualisierungen</a>
        <a href="/redenportal" class="nav-link red-border">Redeportal</a>
        <a href="#footer" class="nav-button">Über Projekt</a>
    </div>
</nav>

<div class="container">
    <h1>Visualisierungen auswählen</h1>
    <p>Wählen Sie eine der folgenden Visualisierungen aus, um detaillierte Einblicke in die Parlamentsreden zu erhalten.</p>

    <div class="visualization-grid">
        <!-- POS Diagram Card -->
        <div class="visualization-card" onclick="window.location.href='/visualisierungen/pos'">
            <div class="visualization-icon">
                <i class="fas fa-chart-bar"></i>
            </div>
            <h2>POS-Analyse</h2>
            <p>Verteilung der Wortarten (Parts of Speech) als vertikale Bar-Chart. Erkennen Sie, welche Wortarten in den Reden dominieren.</p>
            <a href="/visualisierungen/pos" class="view-button">Visualisierung anzeigen</a>
        </div>

        <!-- Topic Bubble Chart Card -->
        <div class="visualization-card" onclick="window.location.href='/visualisierungen/topics'">
            <div class="visualization-icon">
                <i class="fas fa-circle"></i>
            </div>
            <h2>Topic-Verteilung</h2>
            <p>Themenverteilung der Parlamentsreden als Bubble-Chart. Entdecken Sie die häufigsten Themen in den Debatten.</p>
            <a href="/visualisierungen/topics" class="view-button">Visualisierung anzeigen</a>
        </div>

        <!-- Sentiment Radar Chart Card -->
        <div class="visualization-card" onclick="window.location.href='/visualisierungen/sentiment'">
            <div class="visualization-icon">
                <i class="fas fa-smile"></i>
            </div>
            <h2>Sentiment-Analyse</h2>
            <p>Verteilung der Stimmungen als Radar-Chart. Analysieren Sie die emotionale Dynamik in den Parlamentsreden.</p>
            <a href="/visualisierungen/sentiment" class="view-button">Visualisierung anzeigen</a>
        </div>

        <!-- Named Entities Sunburst Card -->
        <div class="visualization-card" onclick="window.location.href='/visualisierungen/entities'">
            <div class="visualization-icon">
                <i class="fas fa-sun"></i>
            </div>
            <h2>Named Entities</h2>
            <p>Verteilung der benannten Entitäten als Sunburst-Diagramm. Erfahren Sie, welche Personen, Organisationen und Orte erwähnt werden.</p>
            <a href="/visualisierungen/entities" class="view-button">Visualisierung anzeigen</a>
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