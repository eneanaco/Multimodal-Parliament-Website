<!-- einzeln.ftl by Waled-->

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

        .feature-card {
            margin-top: 20px;
            text-align: center;
        }

        .feature-button {
            margin: 10px;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
            border: none;
            border-radius: 5px;
            background-color: #007BFF;
            color: white;
        }

        .feature-button:hover {
            background-color: #0056b3;
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
    <h1>Rede auswählen</h1>
    <p>Wählen Sie eine Rede aus, welche exportiert wird.:</p>

    <!-- selection window over all CAS-speeches, which was inputed -->
    <div class="selection-list">
        <form id="export-form">
            <label for="auswahl">Rede auswählen:</label>
            <!-- iterate over list and have it as option to select -->
            <select id="auswahl" name="auswahlID" required>
                <#list speechList as casId>
                    <option value="${casId!}">${casId!}</option>
                </#list>
            </select>
        </form>
    </div>

    <!-- Export-Buttons -->
    <div class="feature-card">
        <h2>Export-Optionen</h2>

        <!-- XMI Export -->
        <button id="xmi-button" class="feature-button">Export der Rede in XMI</button>

        <!-- PDF Export -->
        <button id="pdf-button" class="feature-button">Export der Rede in PDF</button>
    </div>

</div>

<!-- JavaScript für Export-Logik -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Event Listener pdf-button
        document.getElementById('pdf-button').addEventListener('click', () => {
            handleExportPDF();
        });

        // Event Listener xmi-button
        document.getElementById('xmi-button').addEventListener('click', () => {
            handleExportXMI();
        });

        // post route to export a single speech for further use in functions.
        function handleExportPDF() {
            const selectedId = document.getElementById('auswahl').value;
            const url = `/einzeln/pdf/${selectedId}`;

            const form = document.getElementById('export-form');

            if (form) {
                form.action = `/einzeln/pdf`;
                form.method = 'post';
                form.submit();
            } else {
                console.error("Formular not found!");
            }

            window.location.href = url;
        }

           // post route to export a single speech for further use in functions.
            function handleExportXMI() {
                const selectedId = document.getElementById('auswahl').value;
                const url = `/einzeln/xmi/${selectedId}`;

                const form = document.getElementById('export-form');

                if (form) {
                    form.action = `/einzeln/xmi`;
                    form.method = 'post';
                    form.submit();
                } else {
                    console.error("Formular not found!");
                }

                window.location.href = url;
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
