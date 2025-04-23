<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sentiment Visualisierung | Multimodal Parliament Explorer</title>
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

        #sentimentChart {
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

        /* Sentiment chart colors */
        .radar-area {
            fill-opacity: 0.6;
        }

        .radar-area.positive {
            fill: #4CAF50;
        }

        .radar-area.neutral {
            fill: #9E9E9E;
        }

        .radar-area.negative {
            fill: #F44336;
        }

        .radar-stroke {
            fill: none;
            stroke-width: 2;
        }

        .radar-stroke.positive {
            stroke: #4CAF50;
        }

        .radar-stroke.neutral {
            stroke: #9E9E9E;
        }

        .radar-stroke.negative {
            stroke: #F44336;
        }

        .radar-circle {
            fill: white;
            stroke-width: 2;
        }

        .radar-circle.positive {
            stroke: #4CAF50;
        }

        .radar-circle.neutral {
            stroke: #9E9E9E;
        }

        .radar-circle.negative {
            stroke: #F44336;
        }

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

        /* Party colors */
        .party-CDU { background-color: #363536; }
        .party-SPD { background-color: #FD5252; }
        .party-FDP { background-color: #F3E767; color: #333; }
        .party-GRUENE, .party-GRÜNE { background-color: #71B877; }
        .party-LINKE { background-color: #FF99D8; }
        .party-AfD { background-color: #71C4FF; }
        .party-CSU { background-color: #22A3FF; }
        .party-default, .party-other { background-color: #ADAEAE; }


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
        <h1>Sentiment Visualisierung</h1>
        <p>Analysieren Sie die Stimmungen in Parlamentsreden mit dem Radar-Chart</p>
    </div>

    <div class="chart-container">
        <div class="chart-title">
            <span>Verteilung der Sentiments (Radar-Chart)</span>
            <button id="filterButton" class="filter-button">
                <i class="fas fa-filter"></i> Reden auswählen
            </button>
        </div>

        <div class="loading-overlay" id="chartLoading">
            <div class="loading-spinner"></div>
            <div>Daten werden geladen...</div>
        </div>

        <div id="sentimentChart">
            <div class="no-data-message">
                <div class="no-data-icon"><i class="fas fa-smile"></i></div>
                <p>Bitte wählen Sie Reden für die Analyse aus</p>
                <button id="startSelectionButton" class="action-button primary-button" style="margin-top: 15px;">
                    <i class="fas fa-filter button-icon"></i> Reden auswählen
                </button>
            </div>
        </div>

        <div class="selection-summary" id="selectionSummary">
            Keine Reden ausgewählt
        </div>

        <div class="chart-tooltip" id="sentimentTooltip"></div>

        <div class="chart-legend" id="sentimentLegend"></div>
    </div>
</div>

<!-- Filter Popup -->
<div class="popup-overlay" id="filterPopup">
    <div class="popup-container">
        <div class="popup-header">
            <h2>Reden für Sentiment-Analyse auswählen</h2>
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
    let sentimentChartData = null;
    let sentimentChartSvg = null;
    let sentimentChartG = null;
    let sentimentChartWidth = 0;
    let sentimentChartHeight = 0;
    let sentimentChartMargin = { top: 50, right: 50, bottom: 50, left: 50 };
    let sentimentChartTooltip = null;
    let sentimentChartContainer = null;
    let sentimentChartSelectedSpeeches = [];
    let selectedSpeakerId = null;

    // Sentiment types
    const sentimentCategories = {
        'positive': {
            label: 'Positiv',
            color: '#4CAF50'
        },
        'neutral': {
            label: 'Neutral',
            color: '#9E9E9E'
        },
        'negative': {
            label: 'Negativ',
            color: '#F44336'
        }
    };

    document.addEventListener('DOMContentLoaded', function() {
        initSentimentChart();
        setupFilterPopup();

        document.getElementById('startSelectionButton').addEventListener('click', function() {
            document.getElementById('filterPopup').style.display = 'flex';
            loadSpeakers();
        });

        // wait for user to select speeches
    });

    /**
     * Initialize the sentiment chart with default dimensions
     */
    function initSentimentChart() {
        // Get container and set dimensions
        sentimentChartContainer = document.getElementById('sentimentChart');
        sentimentChartWidth = sentimentChartContainer.clientWidth;
        sentimentChartHeight = sentimentChartContainer.clientHeight || 500;

        // Create SVG element
        sentimentChartSvg = d3.select('#sentimentChart')
            .append('svg')
            .attr('width', sentimentChartWidth)
            .attr('height', sentimentChartHeight)
            .style('display', 'none'); // Hide initially

        // Create chart group
        sentimentChartG = sentimentChartSvg.append('g')
            .attr('transform', 'translate(' + (sentimentChartWidth/2) + ',' + (sentimentChartHeight/2) + ')');

        sentimentChartTooltip = d3.select('#sentimentTooltip');

        // Handle window resize
        window.addEventListener('resize', function() {
            if (sentimentChartData) {
                // Update dimensions
                sentimentChartWidth = sentimentChartContainer.clientWidth;

                // Update SVG size
                sentimentChartSvg
                    .attr('width', sentimentChartWidth)
                    .attr('height', sentimentChartHeight);

                // Update chart group position
                sentimentChartG.attr('transform', 'translate(' + (sentimentChartWidth/2) + ',' + (sentimentChartHeight/2) + ')');
                renderSentimentChart();
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
                // speech selection
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
            sentimentChartSelectedSpeeches = Array.from(selectedCheckboxes)
                .map(checkbox => checkbox.value);

            // Update chart with selected speeches
            if (sentimentChartSelectedSpeeches.length > 0) {
                updateChartWithSelectedSpeeches();

                const noDataMessage = document.querySelector('#sentimentChart .no-data-message');
                if (noDataMessage) {
                    noDataMessage.style.display = 'none';
                }
                sentimentChartSvg.style('display', '');
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
                // Sort speakers
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
                        const imageUrl = speaker.image

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

                        // Check if sentiment data is available
                        const unavailableClass = speech.sentimentDataAvailable ? '' : 'speech-unavailable';
                        const unavailableTag = speech.sentimentDataAvailable ? '' : '<span class="data-unavailable">Keine Sentiment-Daten</span>';
                        const disabled = speech.sentimentDataAvailable ? '' : 'disabled';

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
     * Update the selection summary text
     */
    function updateSelectionSummary() {
        const summaryContainer = document.getElementById('selectionSummary');

        if (!sentimentChartSelectedSpeeches || sentimentChartSelectedSpeeches.length === 0) {
            summaryContainer.textContent = 'Keine Reden ausgewählt';
        } else {
            const count = sentimentChartSelectedSpeeches.length;
            summaryContainer.textContent = count + ' Rede' + (count === 1 ? '' : 'n') + ' ausgewählt';
        }
    }

    /**
     * Update the chart with selected speeches
     */
    function updateChartWithSelectedSpeeches() {

        document.getElementById('chartLoading').style.display = 'flex';

        if (!sentimentChartSelectedSpeeches || sentimentChartSelectedSpeeches.length === 0) {
            document.getElementById('chartLoading').style.display = 'none';
            return;
        }

        const idsParam = sentimentChartSelectedSpeeches.join(',');

        fetch(`/api/visualizations/sentiments/multiple?ids=${idsParam}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                sentimentChartData = processSentimentData(data);
                renderSentimentChart();
                document.getElementById('chartLoading').style.display = 'none';
            })
            .catch(error => {
                console.error('Error loading sentiment data for selected speeches:', error);
                document.getElementById('chartLoading').style.display = 'none';

                // Show error message in chart
                sentimentChartG.selectAll('*').remove();
                sentimentChartSvg.append('text')
                    .attr('x', sentimentChartWidth / 2)
                    .attr('y', sentimentChartHeight / 2)
                    .attr('text-anchor', 'middle')
                    .style('fill', '#DA6565')
                    .text('Fehler beim Laden der Daten. Bitte versuchen Sie es später erneut.');
            });
    }

    /**
     * Process the raw sentiment data for the radar chart
     * @param {Object} data - The raw sentiment data from the API
     * @returns {Object} - Processed data for the radar chart
     */
    function processSentimentData(data) {
        // Define bins for sentiment values
        const bins = [
            { min: -1.0, max: -0.6, label: "Sehr negativ" },
            { min: -0.6, max: -0.001, label: "Negativ" },
            { min: -0.0, max: 0.0, label: "Neutral" },
            { min: 0.001, max: 0.6, label: "Positiv" },
            { min: 0.6, max: 1.0, label: "Sehr positiv" }
        ];
        const sentimentCounts = bins.map(bin => ({
            axis: bin.label,
            value: 0,
            min: bin.min,
            max: bin.max
        }));

        // Process sentiment data
        if (data && data.sentiments) {
            // Count sentiments in each bin
            for (let i1 = 0; i1 < data.sentiments.length; i1++){
                const sentiment = data.sentiments[i1];
                const value = sentiment.value;

                for (let i = 0; i < bins.length; i++) {
                    if (value >= bins[i].min && value < bins[i].max) {
                        sentimentCounts[i].value++;
                        break;
                    }
                }
            }

            // Normalize values
            const maxCount = Math.max(...sentimentCounts.map(item => item.value));
            if (maxCount > 0) {
                sentimentCounts.forEach(item => {
                    item.value = item.value / maxCount;
                });
            }
        }

        // Group data
        return [
            {
                category: 'negative',
                values: sentimentCounts.slice(0, 2) // First 2 bins are negative
            },
            {
                category: 'neutral',
                values: sentimentCounts.slice(2, 3) // Middle bin is neutral
            },
            {
                category: 'positive',
                values: sentimentCounts.slice(3, 5) // Last 2 bins are positive
            }
        ];
    }

    /**
     * Render the sentiment radar chart with the current data
     */
    function renderSentimentChart() {
        // Clear previous chart
        sentimentChartG.selectAll('*').remove();
        if (!sentimentChartData || sentimentChartData.length === 0) {
            sentimentChartG.append('text')
                .attr('x', 0)
                .attr('y', 0)
                .attr('text-anchor', 'middle')
                .text('Keine Daten verfügbar');
            return;
        }

        // Calculate dimensions
        const radius = Math.min(sentimentChartWidth, sentimentChartHeight) / 2 - sentimentChartMargin.top;

        // Extract all axes from the data
        const allAxes = sentimentChartData.flatMap(d => d.values.map(v => v.axis));
        const uniqueAxes = [...new Set(allAxes)];
        const totalAxes = uniqueAxes.length;

        // Calculate angles for each axis
        const angleSlice = (Math.PI * 2) / totalAxes;

        // Scale for the radius
        const rScale = d3.scaleLinear()
            .range([0, radius])
            .domain([0, 1]);

        // Circles
        const levels = 5;
        for (let level = 0; level < levels; level++) {
            const levelFactor = radius * ((level + 1) / levels);

            // Draw the circle
            sentimentChartG.append('circle')
                .attr('cx', 0)
                .attr('cy', 0)
                .attr('r', levelFactor)
                .attr('class', 'grid-circle')
                .style('fill', 'none')
                .style('stroke', '#CDCDCD')
                .style('stroke-dasharray', '4 4');

            // Add labels
            if (level === levels - 1) {
                sentimentChartG.append('text')
                    .attr('x', 5)
                    .attr('y', -levelFactor + 5)
                    .attr('dy', '0.35em')
                    .style('font-size', '10px')
                    .text((level + 1) * 100 / levels + '%');
            }
        }

        const axis = sentimentChartG.selectAll('.axis')
            .data(uniqueAxes)
            .enter()
            .append('g')
            .attr('class', 'axis');

        // Draw the actual axis lines
        axis.append('line')
            .attr('x1', 0)
            .attr('y1', 0)
            .attr('x2', function(d, i) { return radius * Math.cos(angleSlice * i - Math.PI / 2); })
            .attr('y2', function(d, i) { return radius * Math.sin(angleSlice * i - Math.PI / 2); })
            .attr('class', 'axis-line')
            .style('stroke', '#CDCDCD')
            .style('stroke-width', '1px');

        // Draw axis labels
        axis.append('text')
            .attr('class', 'axis-label')
            .attr('x', function(d, i) { return radius * 1.1 * Math.cos(angleSlice * i - Math.PI / 2); })
            .attr('y', function(d, i) { return radius * 1.1 * Math.sin(angleSlice * i - Math.PI / 2); })
            .attr('text-anchor', function(d, i) {
                const x = radius * Math.cos(angleSlice * i - Math.PI / 2);
                return x < -1 ? 'end' : x > 1 ? 'start' : 'middle';
            })
            .attr('dy', function(d, i) {
                const y = radius * Math.sin(angleSlice * i - Math.PI / 2);
                return y < -1 ? '-0.5em' : y > 1 ? '1em' : '0.35em';
            })
            .style('font-size', '12px')
            .text(d => d);

        // Create a wrapper for the radar areas
        const radarWrapper = sentimentChartG.append('g')
            .attr('class', 'radar-wrapper');

        // Draw the radar areas and strokes for each category
        sentimentChartData.forEach(category => {
            const flatData = {};
            uniqueAxes.forEach(axis => {
                flatData[axis] = 0;
            });

            category.values.forEach(value => {
                flatData[value.axis] = value.value;
            });
            const dataPoints = uniqueAxes.map(axis => ({
                axis: axis,
                value: flatData[axis]
            }));
            const vertices = dataPoints.map((d, i) => {
                return {
                    x: rScale(d.value) * Math.cos(angleSlice * i - Math.PI / 2),
                    y: rScale(d.value) * Math.sin(angleSlice * i - Math.PI / 2),
                    value: d.value,
                    axis: d.axis
                };
            });

            // Create radar areas
            radarWrapper.append('path')
                .datum(vertices)
                .attr('class', 'radar-area ' + category.category)
                .attr('d', function(d) {
                    return "M" + d.map(function(point) {
                        return [point.x, point.y].join(",");
                    }).join("L") + "Z";
                })
                .style('fill', sentimentCategories[category.category].color)
                .style('fill-opacity', 0.6)
                .on('mouseover', function(event, d) {
                    // Show tooltip
                    const categoryLabel = sentimentCategories[category.category].label;
                    sentimentChartTooltip.style('display', 'block')
                        .html(`
                        <div><strong>${categoryLabel}</strong></div>
                        <div>Relative Verteilung: ${Math.round(d3.mean(d.map(p => p.value)) * 100)}%</div>
                    `)
                        .style('left', (event.pageX + 10) + 'px')
                        .style('top', (event.pageY - 40) + 'px');

                    // Highlight area
                    d3.select(this).style('fill-opacity', 0.9);
                })
                .on('mousemove', function(event) {
                    sentimentChartTooltip
                        .style('left', (event.pageX + 10) + 'px')
                        .style('top', (event.pageY - 40) + 'px');
                })
                .on('mouseout', function() {
                    sentimentChartTooltip.style('display', 'none');
                    d3.select(this).style('fill-opacity', 0.6);
                });

            radarWrapper.append('path')
                .datum(vertices)
                .attr('class', 'radar-stroke ' + category.category)
                .attr('d', function(d) {
                    return "M" + d.map(function(point) {
                        return [point.x, point.y].join(",");
                    }).join("L") + "Z";
                })
                .style('stroke', sentimentCategories[category.category].color)
                .style('stroke-width', '2px')
                .style('fill', 'none');

            // Add circles at each vertex
            radarWrapper.selectAll('.radar-circle-' + category.category)
                .data(vertices)
                .enter()
                .append('circle')
                .attr('class', 'radar-circle ' + category.category)
                .attr('cx', d => d.x)
                .attr('cy', d => d.y)
                .attr('r', 4)
                .style('fill', '#fff')
                .style('stroke', sentimentCategories[category.category].color)
                .style('stroke-width', '2px')
                .on('mouseover', function(event, d) {
                    // Show tooltip
                    sentimentChartTooltip.style('display', 'block')
                        .html(`
                        <div><strong>${d.axis}</strong></div>
                        <div>Wert: ${Math.round(d.value * 100)}%</div>
                    `)
                        .style('left', (event.pageX + 10) + 'px')
                        .style('top', (event.pageY - 40) + 'px');

                    // Highlight point
                    d3.select(this).attr('r', 6);
                })
                .on('mousemove', function(event) {
                    sentimentChartTooltip
                        .style('left', (event.pageX + 10) + 'px')
                        .style('top', (event.pageY - 40) + 'px');
                })
                .on('mouseout', function() {
                    sentimentChartTooltip.style('display', 'none');
                    d3.select(this).attr('r', 4);
                });
        });
        createSentimentLegend();
    }

    /**
     * Create a legend for the sentiment chart
     */
    function createSentimentLegend() {
        const legendContainer = document.getElementById('sentimentLegend');
        legendContainer.innerHTML = '';

        // legend items for each sentiment category
        Object.entries(sentimentCategories).forEach(([key, item]) => {
            const legendItem = document.createElement('div');
            legendItem.className = 'legend-item';

            const colorBox = document.createElement('div');
            colorBox.className = 'legend-color';
            colorBox.style.backgroundColor = item.color;

            const label = document.createElement('span');
            label.textContent = item.label;

            legendItem.appendChild(colorBox);
            legendItem.appendChild(label);
            legendContainer.appendChild(legendItem);
        });
    }
    </#noparse>
</script>
</body>
</html>