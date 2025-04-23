<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>POS Visualisierung | Multimodal Parliament Explorer</title>
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

        #posChart {
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

        /* Selection steps */
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

        /* Button styles */
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

        /* POS chart legend and tooltip */
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

        .pos-description-title {
            font-weight: bold;
            margin-bottom: 5px;
        }

        /* Party colors */
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
        <h1>Wortarten (POS) Visualisierung</h1>
        <p>Analysieren Sie die Verteilung von Wortarten in Parlamentsreden</p>
    </div>

    <div class="chart-container">
        <div class="chart-title">
            <span>POS Verteilung</span>
            <button id="filterButton" class="filter-button">
                <i class="fas fa-filter"></i> Reden auswählen
            </button>
        </div>

        <div class="loading-overlay" id="chartLoading">
            <div class="loading-spinner"></div>
            <div>Daten werden geladen...</div>
        </div>

        <div id="posChart">
            <div class="no-data-message">
                <div class="no-data-icon"><i class="fas fa-chart-bar"></i></div>
                <p>Bitte wählen Sie Reden für die Analyse aus</p>
                <button id="startSelectionButton" class="action-button primary-button" style="margin-top: 15px;">
                    <i class="fas fa-filter button-icon"></i> Reden auswählen
                </button>
            </div>
        </div>

        <div class="selection-summary" id="selectionSummary">
            Keine Reden ausgewählt
        </div>

        <div class="chart-tooltip" id="posTooltip"></div>

        <div class="chart-legend" id="posLegend"></div>
    </div>
</div>

<!-- Filter Popup -->
<div class="popup-overlay" id="filterPopup">
    <div class="popup-container">
        <div class="popup-header">
            <h2>Reden für POS-Analyse auswählen</h2>
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
                    <!-- Speeches will be loaded here -->
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
    <#noparse>
    // Variables to store state
    let posChartData = [];
    let posChartSvg = null;
    let posChartG = null;
    let posChartWidth = 0;
    let posChartHeight = 0;
    let posChartMargin = { top: 40, right: 30, bottom: 90, left: 60 };
    let posChartX = null;
    let posChartY = null;
    let posChartXAxis = null;
    let posChartYAxis = null;
    let posChartTooltip = null;
    let posChartContainer = null;
    let posChartSelectedSpeeches = [];
    let selectedSpeakerId = null;

    // POS tag color mapping
    const posColorMap = {

        'NN': '#e1bee7',
        'NE': '#ce93d8',


        'VVFIN': '#b2dfdb',
        'VVINF': '#80cbc4',
        'VVPP': '#4db6ac',
        'VAFIN': '#26a69a',
        'VAINF': '#009688',
        'VMFIN': '#00897b',
        'VMINF': '#00796b',


        'ADJA': '#ffe0b2',
        'ADJD': '#ffcc80',


        'ADV': '#ffcdd2',
        'PROAV': '#ef9a9a',


        'PPER': '#c5cae9',
        'PPOSAT': '#9fa8da',
        'PWS': '#7986cb',
        'PDS': '#5c6bc0',
        'PIS': '#3f51b5',
        'PRELS': '#3949ab',
        'PRF': '#303f9f',


        'ART': '#bbdefb',
        'PDAT': '#90caf9',


        'KON': '#dcedc8',
        'KOUS': '#aed581',


        'APPR': '#fff9c4',


        'CARD': '#ffecb3',


        'PTKNEG': '#d7ccc8',
        'PTKZU': '#bcaaa4',


        '$,': '#f5f5f5',
        '$.': '#f5f5f5',
        '$(': '#f5f5f5',

        // Default for other tags
        'default': '#e0e0e0'
    };

    // POS tag descriptions
    const posDescriptions = {
        'NN': 'Nomen (normales Substantiv)',
        'NE': 'Eigennamen (Name einer Person, Ort, etc.)',
        'VVFIN': 'Finites Vollverb',
        'VVINF': 'Infinitiv eines Vollverbs',
        'VVPP': 'Partizip Perfekt eines Vollverbs',
        'VAFIN': 'Finites Hilfsverb',
        'VAINF': 'Infinitiv eines Hilfsverbs',
        'VMFIN': 'Finites Modalverb',
        'VMINF': 'Infinitiv eines Modalverbs',
        'ADJA': 'Attributives Adjektiv',
        'ADJD': 'Prädikatives oder adverbiales Adjektiv',
        'ADV': 'Adverb',
        'PROAV': 'Pronominaladverb',
        'PPER': 'Personalpronomen',
        'PPOSAT': 'Possessivpronomen (attributiv)',
        'PWS': 'Interrogativpronomen',
        'PDS': 'Demonstrativpronomen',
        'PIS': 'Indefinitpronomen',
        'PRELS': 'Relativpronomen',
        'PRF': 'Reflexivpronomen',
        'ART': 'Artikel',
        'PDAT': 'Demonstrativartikel',
        'KON': 'Nebenordnende Konjunktion',
        'KOUS': 'Unterordnende Konjunktion',
        'APPR': 'Präposition',
        'CARD': 'Kardinalzahl',
        'PTKNEG': 'Negationspartikel',
        'PTKZU': 'zu-Partikel',
        '$,': 'Komma',
        '$.': 'Satzendzeichen',
        '$(': 'Sonstige Satzzeichen'
    };

    document.addEventListener('DOMContentLoaded', function() {
        initPosChart();
        setupFilterPopup();

        // Set up the start selection button
        document.getElementById('startSelectionButton').addEventListener('click', function() {
            document.getElementById('filterPopup').style.display = 'flex';
            loadSpeakers();
        });

        //wait for user to select speeches
    });

    /**
     * Initialize the POS chart with default dimensions
     */
    function initPosChart() {
        // Get container and set dimensions
        posChartContainer = document.getElementById('posChart');
        posChartWidth = posChartContainer.clientWidth;
        posChartHeight = posChartContainer.clientHeight || 500;

        // Create SVG element
        posChartSvg = d3.select('#posChart')
            .append('svg')
            .attr('width', posChartWidth)
            .attr('height', posChartHeight)
            .style('display', 'none');

        // Create chart group
        posChartG = posChartSvg.append('g')
            .attr('transform', `translate(${posChartMargin.left}, ${posChartMargin.top})`);

        posChartTooltip = d3.select('#posTooltip');

        // Handle window resize
        window.addEventListener('resize', function() {
            if (posChartData.length > 0) {
                // Update dimensions
                posChartWidth = posChartContainer.clientWidth;

                // Update SVG size
                posChartSvg.attr('width', posChartWidth);

                // Re-render chart
                renderPosChart();
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

            // Find all speaker
            const speakerCards = document.querySelectorAll('.speaker-card');

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
            loadSpeakers();
        });

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
            posChartSelectedSpeeches = Array.from(selectedCheckboxes)
                .map(checkbox => checkbox.value);

            // Update chart with selected speeches
            if (posChartSelectedSpeeches.length > 0) {
                updateChartWithSelectedSpeeches();

                // Hide the no-data message and show the SVG
                const noDataMessage = document.querySelector('#posChart .no-data-message');
                if (noDataMessage) {
                    noDataMessage.style.display = 'none';
                }
                posChartSvg.style('display', '');
            } else {
                alert('Bitte wählen Sie mindestens eine Rede aus.');
                return;
            }
            updateSelectionSummary();
            filterPopup.style.display = 'none';
        });
    }

    /**
     * Load all speakers for the filter popup
     */
    function loadSpeakers() {
        const speakerGrid = document.getElementById('speakerGrid');
        if (speakerGrid.querySelector('.speaker-card')) {
            return;
        }

        // loading state
        speakerGrid.innerHTML = `
        <div class="no-data-message">
            <div class="no-data-icon"><i class="fas fa-spinner fa-spin"></i></div>
            <p>Lade Redner...</p>
        </div>
    `;

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

                //speaker cards
                let html = '';

                if (speakers.length === 0) {
                    html = `
                    <div class="no-data-message">
                        <div class="no-data-icon"><i class="fas fa-user-slash"></i></div>
                        <p>Keine Redner gefunden</p>
                    </div>
                `;
                } else {
                    for (const speaker of speakers) {
                        // Use default image if none provided
                        const imageUrl = speaker.image;

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
                    }
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

        fetch(`/api/speaker/${speakerId}/speeches`)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(speeches => {
                // speech items
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
                        let dateStr = '';
                        if (speech.date) {
                            const date = new Date(speech.date);
                            dateStr = date.toLocaleDateString('de-DE');
                        }

                        // Check if POS data is available
                        const unavailableClass = speech.posDataAvailable ? '' : 'speech-unavailable';
                        const unavailableTag = speech.posDataAvailable ? '' : '<span class="data-unavailable">Keine POS-Daten</span>';
                        const disabled = speech.posDataAvailable ? '' : 'disabled';

                        html += `
                        <div class="speech-item ${unavailableClass}">
                            <input type="checkbox" class="speech-checkbox" value="${speech.id}" ${disabled}>
                            <div class="speech-details">
                                <div class="speech-date">${dateStr}</div>
                                <div class="speech-title">
                                    ${speech.title || speech.agendaTitle || 'Rede'}
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
     * Load POS data from the API - this will fetch all data or data for selected speeches
     * @param {boolean} showLoading - Whether to show loading indicator
     */
    function loadPosData(showLoading = true) {
        if (showLoading) {
            document.getElementById('chartLoading').style.display = 'flex';
        }

        fetch('/api/visualizations/pos/overall')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                posChartData = data.items;
                renderPosChart();
                document.getElementById('chartLoading').style.display = 'none';
            })
            .catch(error => {
                console.error('Error loading POS data:', error);
                document.getElementById('chartLoading').style.display = 'none';

                // Show error message in chart
                posChartG.selectAll('*').remove();
                posChartSvg.append('text')
                    .attr('x', posChartWidth / 2)
                    .attr('y', posChartHeight / 2)
                    .attr('text-anchor', 'middle')
                    .style('fill', '#DA6565')
                    .text('Fehler beim Laden der Daten. Bitte versuchen Sie es später erneut.');
            });
    }

    /**
     * Update the chart with selected speeches
     */
    function updateChartWithSelectedSpeeches() {
        document.getElementById('chartLoading').style.display = 'flex';

        if (!posChartSelectedSpeeches || posChartSelectedSpeeches.length === 0) {
            // If no speeches are selected show the initial state
            document.getElementById('chartLoading').style.display = 'none';
            return;
        }
        const idsParam = posChartSelectedSpeeches.join(',');

        fetch(`/api/visualizations/pos/multiple?ids=${idsParam}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                posChartData = data.items;
                renderPosChart();
                document.getElementById('chartLoading').style.display = 'none';
            })
            .catch(error => {
                console.error('Error loading POS data for selected speeches:', error);
                document.getElementById('chartLoading').style.display = 'none';

                // Show error message in chart
                posChartG.selectAll('*').remove();
                posChartSvg.append('text')
                    .attr('x', posChartWidth / 2)
                    .attr('y', posChartHeight / 2)
                    .attr('text-anchor', 'middle')
                    .style('fill', '#DA6565')
                    .text('Fehler beim Laden der Daten. Bitte versuchen Sie es später erneut.');
            });
    }

    /**
     * Update the selection summary text
     */
    function updateSelectionSummary() {
        const summaryContainer = document.getElementById('selectionSummary');

        if (!posChartSelectedSpeeches || posChartSelectedSpeeches.length === 0) {
            summaryContainer.textContent = 'Keine Reden ausgewählt';
        } else {
            const count = posChartSelectedSpeeches.length;
            summaryContainer.textContent = count + ' Rede' + (count === 1 ? '' : 'n') + ' ausgewählt';
        }
    }

    /**
     * Render the POS chart with the current data
     */
    function renderPosChart() {
        // Clear previous chart
        posChartG.selectAll('*').remove();

        // Check if we have data
        if (!posChartData || posChartData.length === 0) {
            posChartG.append('text')
                .attr('x', (posChartWidth - posChartMargin.left - posChartMargin.right) / 2)
                .attr('y', (posChartHeight - posChartMargin.top - posChartMargin.bottom) / 2)
                .attr('text-anchor', 'middle')
                .text('Keine Daten verfügbar');
            return;
        }

        const chartWidth = posChartWidth - posChartMargin.left - posChartMargin.right;
        const chartHeight = posChartHeight - posChartMargin.top - posChartMargin.bottom;

        const topPOSTags = posChartData
            .sort((a, b) => b.count - a.count)
            .slice(0, 20);

        // Create scales
        posChartX = d3.scaleBand()
            .domain(topPOSTags.map(d => d.tag))
            .range([0, chartWidth])
            .padding(0.2);

        posChartY = d3.scaleLinear()
            .domain([0, d3.max(topPOSTags, d => d.count) * 1.1]) // 10% padding
            .range([chartHeight, 0]);

        // Create and add axes
        posChartG.append('g')
            .attr('transform', `translate(0, ${chartHeight})`)
            .call(d3.axisBottom(posChartX))
            .selectAll('text')
            .attr('transform', 'rotate(-45)')
            .style('text-anchor', 'end')
            .attr('dx', '-.8em')
            .attr('dy', '.15em');

        posChartG.append('g')
            .call(d3.axisLeft(posChartY).ticks(5));

        //axes labels
        posChartG.append('text')
            .attr('x', chartWidth / 2)
            .attr('y', chartHeight + posChartMargin.bottom - 10)
            .attr('text-anchor', 'middle')
            .text('POS Tag');

        posChartG.append('text')
            .attr('transform', 'rotate(-90)')
            .attr('x', -chartHeight / 2)
            .attr('y', -posChartMargin.left + 15)
            .attr('text-anchor', 'middle')
            .text('Häufigkeit');

        // Create bars
        posChartG.selectAll('.bar')
            .data(topPOSTags)
            .enter()
            .append('rect')
            .attr('class', 'bar')
            .attr('x', d => posChartX(d.tag))
            .attr('y', d => posChartY(d.count))
            .attr('width', posChartX.bandwidth())
            .attr('height', d => chartHeight - posChartY(d.count))
            .attr('fill', d => posColorMap[d.tag] || posColorMap.default)
            .on('mouseover', function(event, d) {
                const tooltip = d3.select('#posTooltip');
                tooltip.style('display', 'block')
                    .html(`
                    <div class="pos-description-title">${d.tag}</div>
                    <div>${posDescriptions[d.tag] || d.tag}</div>
                    <div>Häufigkeit: ${d.count.toLocaleString()}</div>
                `)
                    .style('left', (event.pageX + 10) + 'px')
                    .style('top', (event.pageY - 40) + 'px');

                // Highlight bar
                d3.select(this)
                    .attr('stroke', '#333')
                    .attr('stroke-width', 2);
            })
            .on('mousemove', function(event) {
                d3.select('#posTooltip')
                    .style('left', (event.pageX + 10) + 'px')
                    .style('top', (event.pageY - 40) + 'px');
            })
            .on('mouseout', function() {
                d3.select('#posTooltip').style('display', 'none');

                d3.select(this).attr('stroke', null);
            });

        // Add value labels on top
        posChartG.selectAll('.bar-label')
            .data(topPOSTags)
            .enter()
            .append('text')
            .attr('class', 'bar-label')
            .attr('x', d => posChartX(d.tag) + posChartX.bandwidth() / 2)
            .attr('y', d => posChartY(d.count) - 5)
            .attr('text-anchor', 'middle')
            .style('font-size', '10px')
            .text(d => d.count > 100 ? d.count.toLocaleString() : '');

        // Create legend
        createPosLegend(topPOSTags);
    }

    /**
     * Create a legend for the POS chart
     * @param {Array} posData - The POS data to create legend for
     */
    function createPosLegend(posData) {
        const legendContainer = document.getElementById('posLegend');
        legendContainer.innerHTML = '';

        const topTags = posData.slice(0, 8);

        topTags.forEach(tag => {
            const color = posColorMap[tag.tag] || posColorMap.default;
            const description = posDescriptions[tag.tag] || tag.tag;

            const legendItem = document.createElement('div');
            legendItem.className = 'legend-item';

            const colorBox = document.createElement('div');
            colorBox.className = 'legend-color';
            colorBox.style.backgroundColor = color;

            const label = document.createElement('span');
            label.textContent = `${tag.tag}: ${description.split(' ')[0]}`;

            legendItem.appendChild(colorBox);
            legendItem.appendChild(label);
            legendContainer.appendChild(legendItem);
        });
    }
    </#noparse>
</script>
</body>
</html>