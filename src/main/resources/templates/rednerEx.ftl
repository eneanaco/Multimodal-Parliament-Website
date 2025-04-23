<!-- rednerEx.ftl by Waled-->

<!DOCTYPE html>
<html lang="de">
<!-- header of the html page with style -->
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Einzelne Rede auswählen</title>
    <link rel="stylesheet" href="/static/index-styles.css">
    <style>
        .selection-container {
            margin-top: 40px;
            text-align: center;
        }

        .selection-list {
            width: 50%;
            margin: auto;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

        .selection-list option {
            padding: 5px;
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
    <h1>Redner auswählen</h1>
    <p>Wählen Sie einen Redner aus und dessen Reden werden exportiert:</p>

    <!-- selection window of a single spekaer over all speakers
    by iterating through the list-->
    <div class="selection-list">
        <form>
            <label for="auswahl">Redner auswählen:</label>
            <select id="auswahl" name="auswahlID" required>
                <#list speakerMap?keys as speakerName>
                    <option value="${speakerName!}">${speakerMap[speakerName]!}</option>
                </#list>
            </select>
        </form>
    </div>




    <!-- Die -->
    <div class="feature-card">
        <h2>XMI</h2>
        <button id="xmi-button" class="feature-button">Export der Reden in XMI</button>
        <h2>PDF</h2>
        <button id="pdf-button" class="feature-button">Export aller Reden in PDF</button>
    </div>

</div>

<!-- This handles the post Route for exporting the sepeeches
 of all speeches of that user. Adding to that is also the
data type choosing-->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('pdf-button').addEventListener('click', () => {
            handleExport('pdf');
        });

        document.getElementById('xmi-button').addEventListener('click', () => {
            handleExport('xmi');
        });

        function handleExport(formatType) {  // Renamed parameter to avoid confusion
            const selectedId = document.getElementById('auswahl').value;
            const form = document.createElement('form');

            // post method for applying function with speaker id and type
            form.action = '/redner/' + formatType + '/' + selectedId;
            form.method = 'post';

            document.body.appendChild(form);
            form.submit();
        }
    });
</script>

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
