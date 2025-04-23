<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Named Entities Visualisierung | Multimodal Parliament Explorer</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="/static/index-styles.css">
    <style>
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .page-title {
            margin-bottom: 30px;
            text-align: center;
        }

        .chart-container {
            background-color: white;
            border-radius: 8px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            position: relative;
            min-height: 600px;
        }

        .chart-title {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.2rem;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        #entityChart {
            width: 100%;
            height: 500px;
        }

        .filter-button {
            background-color: #DA6565;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            transition: background-color 0.3s;
        }

        .filter-button:hover {
            background-color: #c45050;
        }

        /* Filter popup */
        .popup-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 1000;
            display: none;
        }

        .popup-container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            width: 90%;
            max-width: 900px;
            max-height: 80vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .popup-header {
            padding: 15px 20px;
            background-color: #f5f5f5;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .popup-header h2 {
            margin: 0;
            font-size: 1.3rem;
        }

        .popup-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #666;
        }

        .popup-content {
            padding: 20px;
            overflow-y: auto;
            flex-grow: 1;
        }

        .popup-footer {
            padding: 15px 20px;
            background-color: #f5f5f5;
            border-top: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        /* Selection*/
        .selection-steps {
            display: flex;
            margin-bottom: 20px;
        }

        .step {
            flex: 1;
            text-align: center;
            padding: 10px;
            background-color: #f5f5f5;
            border-radius: 4px;
            margin: 0 5px;
            position: relative;
        }

        .step.active {
            background-color: #DA6565;
            color: white;
            font-weight: bold;
        }

        .step:not(:last-child):after {
            content: "";
            position: absolute;
            top: 50%;
            right: -15px;
            width: 10px;
            height: 10px;
            border-top: 2px solid #ccc;
            border-right: 2px solid #ccc;
            transform: translateY(-50%) rotate(45deg);
        }

        /* Speaker selection */
        .speaker-search {
            margin-bottom: 20px;
        }

        .search-input {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
        }

        .speaker-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
        }

        .speaker-card {
            background-color: #f9f9f9;
            border-radius: 8px;
            padding: 15px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }

        .speaker-card:hover {
            background-color: #f0f0f0;
            transform: translateY(-3px);
        }

        .speaker-card.selected {
            background-color: #fbe9e7;
            box-shadow: 0 0 0 2px #DA6565;
        }

        .speaker-image {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            object-fit: cover;
            margin: 0 auto 10px;
        }

        .speaker-name {
            font-weight: bold;
            margin-bottom: 5px;
            font-size: 0.9rem;
        }

        .speaker-party {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 15px;
            font-size: 12px;
            color: white;
        }

        /* Speech selection */
        .speech-list {
            max-height: 50vh;
            overflow-y: auto;
            border: 1px solid #eee;
            border-radius: 8px;
        }

        .speech-item {
            display: flex;
            align-items: flex-start;
            padding: 12px 15px;
            border-bottom: 1px solid #eee;
            transition: background-color 0.2s;
        }

        .speech-item:hover {
            background-color: #f9f9f9;
        }

        .speech-checkbox {
            margin-right: 15px;
            margin-top: 3px;
        }

        .speech-details {
            flex-grow: 1;
        }

        .speech-date {
            font-size: 0.8rem;
            color: #666;
            margin-bottom: 3px;
        }

        .speech-title {
            font-weight: bold;
            margin-bottom: 5px;
        }

        .speech-preview {
            font-size: 0.9rem;
            color: #555;
        }

        .speech-unavailable {
            opacity: 0.5;
        }

        .data-unavailable {
            display: inline-block;
            background-color: #ffcdd2;
            color: #b71c1c;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 11px;
            margin-left: 8px;
        }

        /* Selection summary */
        .selection-summary {
            margin-top: 10px;
            font-size: 0.9rem;
            color: #666;
        }

        /* Loading state */
        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(255, 255, 255, 0.8);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 10;
            display: none;
        }

        .loading-spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #DA6565;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin-bottom: 15px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Button */
        .action-button {
            padding: 8px 16px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            border: none;
            transition: all 0.3s;
        }

        .primary-button {
            background-color: #DA6565;
            color: white;
        }

        .primary-button:hover {
            background-color: #c45050;
        }

        .secondary-button {
            background-color: #f5f5f5;
            color: #333;
            border: 1px solid #ddd;
        }

        .secondary-button:hover {
            background-color: #e0e0e0;
        }

        .button-icon {
            margin-right: 5px;
        }

        /* Entity chart legend */
        .chart-legend {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 20px;
            justify-content: center;
        }

        .legend-item {
            display: flex;
            align-items: center;
            font-size: 0.9rem;
        }

        .legend-color {
            width: 15px;
            height: 15px;
            margin-right: 5px;
            border-radius: 2px;
        }

        .chart-tooltip {
            position: absolute;
            background-color: rgba(255, 255, 255, 0.9);
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 8px 12px;
            font-size: 0.9rem;
            pointer-events: none;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            z-index: 100;
            display: none;
        }

        .entity-description-title {
            font-weight: bold;
            margin-bottom: 5px;
        }

        /* Entity colors */
        .entity-PER, .entity-PERSON { fill: #ffecb3; }
        .entity-LOC, .entity-LOCATION { fill: #c8e6c9; }
        .entity-ORG, .entity-ORGANIZATION { fill: #bbdefb; }
        .entity-MISC { fill: #e1bee7; }
        .entity-other { fill: #e0e0e0; }

        .party-CDU { background-color: #363536; }
        .party-SPD { background-color: #FD5252; }
        .party-FDP { background-color: #F3E767; color: #333; }
        .party-GRUENE, .party-GRÜNE { background-color: #71B877; }
        .party-LINKE { background-color: #FF99D8; }
        .party-AfD { background-color: #71C4FF; }
        .party-CSU { background-color: #22A3FF; }
        .party-default, .party-other { background-color: #ADAEAE; }

        /* No data message */
        .no-data-message {
            text-align: center;
            padding: 50px 20px;
            color: #666;
        }

        .no-data-icon {
            font-size: 3rem;
            margin-bottom: 15px;
            color: #ddd;
        }

        .depth-0 { opacity: 1; }
        .depth-1 { opacity: 0.8; }
        .depth-2 { opacity: 0.6; }
    </style>
</head>
<body>
<!-- Navbar -->
<nav class="navbar">
    <div class="navbar-titel">
        <h1>Multimodal Parliament Explorer</h1>
    </div>
    <div class="navbar-links">
        <a href="/visualisierungen" class="nav-link active">Visualisierungen</a>
        <a href="/redenportal" class="nav-link red-border">Redeportal</a>
        <a href="#footer" class="nav-button">Über Projekt</a>
    </div>
</nav>

<div class="container">
    <div class="page-title">
        <h1>Named Entities Visualisierung</h1>
        <p>Analysieren Sie die Verteilung von benannten Entitäten in Parlamentsreden</p>
    </div>

    <div class="chart-container">
        <div class="chart-title">
            <span>Verteilung der Named Entities (Sunburst)</span>
            <button id="filterButton" class="filter-button">
                <i class="fas fa-filter"></i> Reden auswählen
            </button>
        </div>

        <div class="loading-overlay" id="chartLoading">
            <div class="loading-spinner"></div>
            <div>Daten werden geladen...</div>
        </div>

        <div id="entityChart">
            <div class="no-data-message">
                <div class="no-data-icon"><i class="fas fa-sun"></i></div>
                <p>Bitte wählen Sie Reden für die Analyse aus</p>
                <button id="startSelectionButton" class="action-button primary-button" style="margin-top: 15px;">
                    <i class="fas fa-filter button-icon"></i> Reden auswählen
                </button>
            </div>
        </div>

        <div class="selection-summary" id="selectionSummary">
            Keine Reden ausgewählt
        </div>

        <div class="chart-tooltip" id="entityTooltip"></div>

        <div class="chart-legend" id="entityLegend"></div>
    </div>
</div>

<!-- Filter Popup -->
<div class="popup-overlay" id="filterPopup">
    <div class="popup-container">
        <div class="popup-header">
            <h2>Reden für Named Entity-Analyse auswählen</h2>
            <button class="popup-close" id="closePopup">&times;</button>
        </div>

        <div class="popup-content">
            <!-- Selection steps -->
            <div class="selection-steps">
                <div class="step active" id="step1">1. Redner auswählen</div>
                <div class="step" id="step2">2. Reden auswählen</div>
            </div>

            <!-- Speaker Selection -->
            <div id="speakerSelection">
                <div class="speaker-search">
                    <input type="text" id="speakerSearchInput" class="search-input" placeholder="Redner suchen...">
                </div>

                <div class="speaker-grid" id="speakerGrid">
                    <!-- Speakers will be loaded here -->
                    <div class="no-data-message">
                        <div class="no-data-icon"><i class="fas fa-spinner fa-spin"></i></div>
                        <p>Lade Redner...</p>
                    </div>
                </div>
            </div>

            <!-- Speech Selection -->
            <div id="speechSelection" style="display: none;">
                <div id="selectedSpeakerInfo" class="speaker-info"></div>

                <div class="speech-list" id="speechList">
                    <!-- Speeches will be loaded here-->
                    <div class="no-data-message">
                        <div class="no-data-icon"><i class="fas fa-spinner fa-spin"></i></div>
                        <p>Lade Reden...</p>
                    </div>
                </div>

                <div class="selection-summary" id="popupSelectionSummary">
                    Keine Reden ausgewählt
                </div>
            </div>
        </div>

        <div class="popup-footer">
            <div>
                <button class="action-button secondary-button" id="backButton" style="display: none;">
                    <i class="fas fa-arrow-left button-icon"></i> Zurück
                </button>
            </div>
            <div>
                <button class="action-button secondary-button" id="cancelButton">Abbrechen</button>
                <button class="action-button primary-button" id="nextButton">
                    Weiter <i class="fas fa-arrow-right button-icon"></i>
                </button>
                <button class="action-button primary-button" id="applyButton" style="display: none;">
                    <i class="fas fa-check button-icon"></i> Anwenden
                </button>
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

<script>
    <#noparse >
    // Variables to store state
    let entityChartData = null;
    let entityChartSvg = null;
    let entityChartG = null;
    let entityChartWidth = 0;
    let entityChartHeight = 0;
    let entityChartMargin = { top: 40, right: 30, bottom: 40, left: 30 };
    let entityChartTooltip = null;
    let entityChartContainer = null;
    let entityChartSelectedSpeeches = [];
    let selectedSpeakerId = null;

    // Entity color
    const entityColorMap = {
        'PER': '#ffecb3',
        'PERSON': '#ffecb3',
        'LOC': '#c8e6c9',
        'LOCATION': '#c8e6c9',
        'ORG': '#bbdefb',
        'ORGANIZATION': '#bbdefb',
        'MISC': '#e1bee7',
        'default': '#e0e0e0'
    };

    // Entity type descriptions
    const entityDescriptions = {
        'PER': 'Person (Personen, Namen)',
        'PERSON': 'Person (Personen, Namen)',
        'LOC': 'Ort (Länder, Städte, geographische Orte)',
        'LOCATION': 'Ort (Länder, Städte, geographische Orte)',
        'ORG': 'Organisation (Firmen, Behörden, Institutionen)',
        'ORGANIZATION': 'Organisation (Firmen, Behörden, Institutionen)',
        'MISC': 'Sonstige (Andere benannte Entitäten)'
    };

    document.addEventListener('DOMContentLoaded', function() {
        initEntityChart();
        setupFilterPopup();

        // Set up the start selection button
        document.getElementById('startSelectionButton').addEventListener('click', function() {
            document.getElementById('filterPopup').style.display = 'flex';
            loadSpeakers();
        });

        // wait for user to select speeches
    });

    /**
     * Initialize the entity chart with default dimensions
     */
    function initEntityChart() {
        // Get container and set dimensions
        entityChartContainer = document.getElementById('entityChart');
        entityChartWidth = entityChartContainer.clientWidth;
        entityChartHeight = entityChartContainer.clientHeight || 500;

        // Create SVG element
        entityChartSvg = d3.select('#entityChart')
            .append('svg')
            .attr('width', entityChartWidth)
            .attr('height', entityChartHeight)
            .style('display', 'none'); // Hide initially

        // Create chart group
        entityChartG = entityChartSvg.append('g')
            .attr('transform', `translate(${entityChartWidth / 2}, ${entityChartHeight / 2})`);

        entityChartTooltip = d3.select('#entityTooltip');

        // Handle window resize
        window.addEventListener('resize', function() {
            if (entityChartData) {
                // Update dimensions
                entityChartWidth = entityChartContainer.clientWidth;

                // Update SVG size
                entityChartSvg
                    .attr('width', entityChartWidth)
                    .attr('height', entityChartHeight);

                entityChartG.attr('transform', `translate(${entityChartWidth / 2}, ${entityChartHeight / 2})`);
                renderEntityChart();
            }
        });
    }

    /**
     * Set up the filter popup functionality
     */
    function setupFilterPopup() {
        const filterPopup = document.getElementById('filterPopup');
        const filterButton = document.getElementById('filterButton');
        const closePopup = document.getElementById('closePopup');
        const cancelButton = document.getElementById('cancelButton');
        const nextButton = document.getElementById('nextButton');
        const backButton = document.getElementById('backButton');
        const applyButton = document.getElementById('applyButton');

        const speakerSelection = document.getElementById('speakerSelection');
        const speechSelection = document.getElementById('speechSelection');
        const step1 = document.getElementById('step1');
        const step2 = document.getElementById('step2');

        // Speaker search
        const speakerSearchInput = document.getElementById('speakerSearchInput');
        speakerSearchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();

            // Find all speaker cards
            const speakerCards = document.querySelectorAll('.speaker-card');

            // Show/hide based on search term
            speakerCards.forEach(card => {
                const speakerName = card.querySelector('.speaker-name').textContent.toLowerCase();
                if (speakerName.includes(searchTerm)) {
                    card.style.display = '';
                } else {
                    card.style.display = 'none';
                }
            });
        });

        // Open popup
        filterButton.addEventListener('click', function() {
            filterPopup.style.display = 'flex';
            // Load speakers if not already loaded
            loadSpeakers();
        });

        // Close popup handlers
        closePopup.addEventListener('click', function() {
            filterPopup.style.display = 'none';
        });

        cancelButton.addEventListener('click', function() {
            filterPopup.style.display = 'none';
        });

        // Navigation between steps
        nextButton.addEventListener('click', function() {
            if (selectedSpeakerId) {
                // Show speech selection
                speakerSelection.style.display = 'none';
                speechSelection.style.display = 'block';

                step1.classList.remove('active');
                step2.classList.add('active');

                nextButton.style.display = 'none';
                applyButton.style.display = 'inline-flex';
                backButton.style.display = 'inline-flex';

                // Load speeches for the selected speaker
                loadSpeechesBySpeaker(selectedSpeakerId);
            } else {
                alert('Bitte wählen Sie zuerst einen Redner aus.');
            }
        });

        backButton.addEventListener('click', function() {
            // Go back to speaker selection
            speakerSelection.style.display = 'block';
            speechSelection.style.display = 'none';

            step1.classList.add('active');
            step2.classList.remove('active');

            nextButton.style.display = 'inline-flex';
            applyButton.style.display = 'none';
            backButton.style.display = 'none';
        });

        // Apply selection and update chart
        applyButton.addEventListener('click', function() {
            // Get selected speeches
            const selectedCheckboxes = document.querySelectorAll('.speech-checkbox:checked');
            entityChartSelectedSpeeches = Array.from(selectedCheckboxes)
                .map(checkbox => checkbox.value);

            // Update chart with selected speeches
            if (entityChartSelectedSpeeches.length > 0) {
                updateChartWithSelectedSpeeches();

                // Hide the no-data message and show the SVG
                const noDataMessage = document.querySelector('#entityChart .no-data-message');
                if (noDataMessage) {
                    noDataMessage.style.display = 'none';
                }
                entityChartSvg.style('display', '');
            } else {
                alert('Bitte wählen Sie mindestens eine Rede aus.');
                return;
            }

            // Update selection summary
            updateSelectionSummary();

            // Close popup
            filterPopup.style.display = 'none';
        });
    }

    /**
     * Load all speakers for the filter popup
     */
    function loadSpeakers() {
        const speakerGrid = document.getElementById('speakerGrid');

        // Check if speakers are already loaded
        if (speakerGrid.querySelector('.speaker-card')) {
            return;
        }

        // Show loading state
        speakerGrid.innerHTML = `
        <div class="no-data-message">
            <div class="no-data-icon"><i class="fas fa-spinner fa-spin"></i></div>
            <p>Lade Redner...</p>
        </div>
    `;

        // Fetch speakers from API
        fetch('/api/redeportal/speakers')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(speakers => {
                // Sort speakers by name
                speakers.sort((a, b) => {
                    const nameA = `${a.firstName} ${a.name}`.toLowerCase();
                    const nameB = `${b.firstName} ${b.name}`.toLowerCase();
                    return nameA.localeCompare(nameB);
                });

                // Generate speaker cards
                let html = '';

                if (speakers.length === 0) {
                    html = `
                    <div class="no-data-message">
                        <div class="no-data-icon"><i class="fas fa-user-slash"></i></div>
                        <p>Keine Redner gefunden</p>
                    </div>
                `;
                } else {
                    speakers.forEach(speaker => {
                        // Use default image if none provided
                        const imageUrl = speaker.image || '/static/images/default-profile.png';

                        html += `
                        <div class="speaker-card" data-speaker-id="${speaker.id}">
                            <img src="${imageUrl}" alt="${speaker.firstName} ${speaker.name}" class="speaker-image">
                            <div class="speaker-name">
                                ${speaker.title ? speaker.title + ' ' : ''}${speaker.firstName} ${speaker.name}
                            </div>`;

                        if (speaker.party) {
                            html += `<div class="speaker-party party-${speaker.party}">${speaker.party}</div>`;
                        }

                        html += `</div>`;
                    });
                }

                speakerGrid.innerHTML = html;

                // Add click event to speaker cards
                document.querySelectorAll('.speaker-card').forEach(card => {
                    card.addEventListener('click', function() {
                        // Remove selected class from all cards
                        document.querySelectorAll('.speaker-card').forEach(c => {
                            c.classList.remove('selected');
                        });

                        // Add selected class to clicked card
                        this.classList.add('selected');

                        // Store selected speaker ID
                        selectedSpeakerId = this.dataset.speakerId;
                    });
                });
            })
            .catch(error => {
                console.error('Error loading speakers:', error);
                speakerGrid.innerHTML = `
                <div class="no-data-message">
                    <div class="no-data-icon"><i class="fas fa-exclamation-circle"></i></div>
                    <p>Fehler beim Laden der Redner: ${error.message}</p>
                </div>
            `;
            });
    }

    /**
     * Load speeches for a specific speaker
     * @param {string} speakerId - ID of the selected speaker
     */
    function loadSpeechesBySpeaker(speakerId) {
        const speechList = document.getElementById('speechList');
        const selectedSpeakerInfo = document.getElementById('selectedSpeakerInfo');

        // Show loading state
        speechList.innerHTML = `
        <div class="no-data-message">
            <div class="no-data-icon"><i class="fas fa-spinner fa-spin"></i></div>
            <p>Lade Reden...</p>
        </div>
    `;

        // Get selected speaker information
        const selectedCard = document.querySelector(`.speaker-card.selected`);
        if (selectedCard) {
            selectedSpeakerInfo.innerHTML = selectedCard.innerHTML;
        }

        // Fetch speeches from API
        fetch(`/api/speaker/${speakerId}/speeches`)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(speeches => {
                // Generate speech items
                let html = '';

                if (speeches.length === 0) {
                    html = `
                    <div class="no-data-message">
                        <div class="no-data-icon"><i class="fas fa-comment-slash"></i></div>
                        <p>Keine Reden für diesen Redner gefunden</p>
                    </div>
                `;
                } else {
                    speeches.forEach(speech => {
                        // Format date if available
                        let dateStr = '';
                        if (speech.date) {
                            const date = new Date(speech.date);
                            dateStr = date.toLocaleDateString('de-DE');
                        }

                        // Check if entity data is available
                        const unavailableClass = speech.entityDataAvailable ? '' : 'speech-unavailable';
                        const unavailableTag = speech.entityDataAvailable ? '' : '<span class="data-unavailable">Keine Entity-Daten</span>';
                        const disabled = speech.entityDataAvailable ? '' : 'disabled';

                        html += `
                        <div class="speech-item ${unavailableClass}">
                            <input type="checkbox" class="speech-checkbox" value="${speech.id}" ${disabled}>
                            <div class="speech-details">
                                <div class="speech-date">${dateStr}</div>
                                <div class="speech-title">
                                    ${speech.title || speech.agendaTitle || 'Rede'}
                                    ${unavailableTag}
                                </div>
                                <div class="speech-preview">${speech.preview || ''}</div>
                            </div>
                        </div>
                    `;
                    });
                }

                speechList.innerHTML = html;

                // Update selection count when checkboxes change
                document.querySelectorAll('.speech-checkbox').forEach(checkbox => {
                    checkbox.addEventListener('change', updatePopupSelectionCount);
                });

                // Initial update of selection count
                updatePopupSelectionCount();
            })
            .catch(error => {
                console.error('Error loading speeches:', error);
                speechList.innerHTML = `
                <div class="no-data-message">
                    <div class="no-data-icon"><i class="fas fa-exclamation-circle"></i></div>
                    <p>Fehler beim Laden der Reden: ${error.message}</p>
                </div>
            `;
            });
    }

    /**
     * Update the selection count in the popup
     */
    function updatePopupSelectionCount() {
        const selectedCheckboxes = document.querySelectorAll('.speech-checkbox:checked');
        const count = selectedCheckboxes.length;

        const summary = document.getElementById('popupSelectionSummary');
        if (count === 0) {
            summary.textContent = 'Keine Reden ausgewählt';
        } else {
            summary.textContent = count + ' Rede' + (count === 1 ? '' : 'n') + ' ausgewählt';
        }
    }

    /**
     * Update the selection summary text
     */
    function updateSelectionSummary() {
        const summaryContainer = document.getElementById('selectionSummary');

        if (!entityChartSelectedSpeeches || entityChartSelectedSpeeches.length === 0) {
            summaryContainer.textContent = 'Keine Reden ausgewählt';
        } else {
            const count = entityChartSelectedSpeeches.length;
            summaryContainer.textContent = count + ' Rede' + (count === 1 ? '' : 'n') + ' ausgewählt';
        }
    }

    /**
     * Update the chart with selected speeches
     */
    function updateChartWithSelectedSpeeches() {
        // Show loading state
        document.getElementById('chartLoading').style.display = 'flex';

        if (!entityChartSelectedSpeeches || entityChartSelectedSpeeches.length === 0) {
            // If no speeches are selected, show the initial state
            document.getElementById('chartLoading').style.display = 'none';
            return;
        }

        // Format the IDs as a comma-separated string for the API
        const idsParam = entityChartSelectedSpeeches.join(',');

        fetch(`/api/visualizations/entities/multiple?ids=${idsParam}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                entityChartData = processEntityData(data);
                renderEntityChart();
                document.getElementById('chartLoading').style.display = 'none';
            })
            .catch(error => {
                console.error('Error loading entity data for selected speeches:', error);
                document.getElementById('chartLoading').style.display = 'none';

                // Show error message in chart
                entityChartG.selectAll('*').remove();
                entityChartSvg.append('text')
                    .attr('x', entityChartWidth / 2)
                    .attr('y', entityChartHeight / 2)
                    .attr('text-anchor', 'middle')
                    .style('fill', '#DA6565')
                    .text('Fehler beim Laden der Daten. Bitte versuchen Sie es später erneut.');
            });
    }

    /**
     * Process the raw entity data into a hierarchical structure for the sunburst chart
     * @param {Object} data - The raw entity data from the API
     * @returns {Object} - Hierarchical data structure for the sunburst chart
     */
    function processEntityData(data) {
        // Create root node for the hierarchy
        const root = {
            name: "Entities",
            children: []
        };

        // Group entities by type
        const entityTypes = {};

        if (data && data.entities) {
            data.entities.forEach(entity => {
                const type = entity.type || 'MISC';

                if (!entityTypes[type]) {
                    entityTypes[type] = {
                        name: type,
                        children: []
                    };
                    root.children.push(entityTypes[type]);
                }

                // Group entities by text within each type
                const entityTexts = {};

                // Process entity texts
                if (entity.items) {
                    entity.items.forEach(item => {
                        const text = item.text;
                        const count = item.count || 1;

                        if (!entityTexts[text]) {
                            entityTexts[text] = {
                                name: text,
                                value: 0
                            };
                            entityTypes[type].children.push(entityTexts[text]);
                        }

                        entityTexts[text].value += count;
                    });
                }
            });
        }

        return root;
    }

    /**
     * Render the entity sunburst chart with the current data
     */
    function renderEntityChart() {
        // Clear previous chart
        entityChartG.selectAll('*').remove();
        if (!entityChartData || !entityChartData.children || entityChartData.children.length === 0) {
            entityChartG.append('text')
                .attr('x', 0)
                .attr('y', 0)
                .attr('text-anchor', 'middle')
                .text('Keine Daten verfügbar');
            return;
        }
        const radius = Math.min(entityChartWidth, entityChartHeight) / 2 - 40;

        // Create a partition layout
        const partition = d3.partition()
            .size([2 * Math.PI, radius]);

        // Convert data to hierarchy
        const root = d3.hierarchy(entityChartData)
            .sum(d => d.value || 0);

        partition(root);

        // Create an arc generator
        const arc = d3.arc()
            .startAngle(d => d.x0)
            .endAngle(d => d.x1)
            .innerRadius(d => d.y0)
            .outerRadius(d => d.y1);

        const colorFn = d => {
            if (d.depth === 0) return '#ffffff';
            if (d.depth === 1) {
                return entityColorMap[d.data.name] || entityColorMap.default;
            }
            return entityColorMap[d.parent.data.name] || entityColorMap.default;
        };

        const path = entityChartG.selectAll('path')
            .data(root.descendants().filter(d => d.depth))
            .enter()
            .append('path')
            .attr('d', arc)
            .attr('fill', colorFn)
            .attr('class', d => `depth-${d.depth}`)
            .style('stroke', '#fff')
            .style('stroke-width', '0.5px')
            .on('mouseover', function(event, d) {
                // Get entity type
                const entityType = d.depth === 1 ? d.data.name : d.parent.data.name;
                const entityName = d.data.name;
                const entityCount = d.value;
                const entityDescription = entityDescriptions[entityType] || entityType;

                entityChartTooltip.style('display', 'block')
                    .html(`
                    <div class="entity-description-title">${entityName}</div>
                    <div>Typ: ${entityDescription}</div>
                    <div>Anzahl: ${entityCount}</div>
                `)
                    .style('left', (event.pageX + 10) + 'px')
                    .style('top', (event.pageY - 40) + 'px');

                // Highlight segment
                d3.select(this)
                    .style('opacity', 1)
                    .style('stroke', '#333')
                    .style('stroke-width', '1.5px');
            })
            .on('mousemove', function(event) {
                entityChartTooltip
                    .style('left', (event.pageX + 10) + 'px')
                    .style('top', (event.pageY - 40) + 'px');
            })
            .on('mouseout', function() {
                entityChartTooltip.style('display', 'none');

                // Remove highlight
                d3.select(this)
                    .style('opacity', null)
                    .style('stroke', '#fff')
                    .style('stroke-width', '0.5px');
            });

        // Add labels for the main entity types
        entityChartG.selectAll('text')
            .data(root.descendants().filter(d => d.depth === 1 && (d.x1 - d.x0) > 0.2))
            .enter()
            .append('text')
            .attr('transform', function(d) {
                const x = (d.x0 + d.x1) / 2;
                const y = (d.y0 + d.y1) / 2;
                const angle = x - Math.PI / 2;
                const radius = y;
                const rotate = angle * (180 / Math.PI);
                return "rotate(" + rotate + ") translate(" + radius + ",0) " + (rotate > 90 && rotate < 270 ? "rotate(180)" : "");
            })
            .attr('dy', '0.35em')
            .attr('text-anchor', d => {
                const x = (d.x0 + d.x1) / 2;
                const angle = x - Math.PI / 2;
                const rotate = angle * (180 / Math.PI);
                return rotate > 90 && rotate < 270 ? 'end' : 'start';
            })
            .style('font-size', '10px')
            .style('fill', '#333')
            .text(d => d.data.name);

        // Create legend
        createEntityLegend();
    }

    /**
     * Create a legend for the entity chart
     */
    function createEntityLegend() {
        const legendContainer = document.getElementById('entityLegend');
        legendContainer.innerHTML = '';

        // Create legend items
        const legendTypes = [
            { type: 'PERSON', label: 'Personen' },
            { type: 'LOCATION', label: 'Orte' },
            { type: 'ORGANIZATION', label: 'Organisationen' },
            { type: 'MISC', label: 'Sonstige' }
        ];

        legendTypes.forEach(item => {
            const color = entityColorMap[item.type] || entityColorMap.default;

            const legendItem = document.createElement('div');
            legendItem.className = 'legend-item';

            const colorBox = document.createElement('div');
            colorBox.className = 'legend-color';
            colorBox.style.backgroundColor = color;

            const label = document.createElement('span');
            label.textContent = item.label;

            legendItem.appendChild(colorBox);
            legendItem.appendChild(label);
            legendContainer.appendChild(legendItem);
        });
    }
    </#noparse>
</script>