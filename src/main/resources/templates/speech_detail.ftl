<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rede Details | Multimodal Parliament Explorer</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="/static/index-styles.css">
    <style>
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .speaker-info {
            display: flex;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }

        .speaker-image {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            margin-right: 20px;
            object-fit: cover;
        }

        .speech-content {
            line-height: 1.6;
            margin-top: 20px;
            font-size: 16px;
            white-space: pre-wrap;
        }
        .speech-text {
            margin-bottom: 10px;
        }

        .speech-comment {
            font-style: italic;
            color: #666;
            margin: 10px 0;
            padding: 5px 10px;
            background-color: #f8f8f8;
            border-left: 3px solid #ddd;
        }

        .party-tag {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 15px;
            color: white;
            background-color: #666;
            margin-top: 5px;
        }

        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 40px;
            height: 20px;
            margin-right: 10px;
        }

        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 34px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 14px;
            width: 14px;
            left: 3px;
            bottom: 3px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: #DA6565;
        }

        input:checked + .slider:before {
            transform: translateX(20px);
        }

        .pos-highlight {
            padding: 2px;
            border-radius: 3px;
        }

        .pos-nn { background-color: #e1bee7; }
        .pos-ne { background-color: #ce93d8; }

        .pos-vvfin { background-color: #b2dfdb; }
        .pos-vvinf { background-color: #80cbc4; }
        .pos-vvpp { background-color: #4db6ac; }
        .pos-vafin { background-color: #26a69a; }
        .pos-vainf { background-color: #009688; }
        .pos-vmfin { background-color: #00897b; }
        .pos-vminf { background-color: #00796b; }

        .pos-adja { background-color: #ffe0b2; }
        .pos-adjd { background-color: #ffcc80; }

        .pos-adv { background-color: #ffcdd2; }
        .pos-proav { background-color: #ef9a9a; }

        .pos-pper { background-color: #c5cae9; }
        .pos-pposat { background-color: #9fa8da; }
        .pos-pws { background-color: #7986cb; }
        .pos-pds { background-color: #5c6bc0; }
        .pos-pis { background-color: #3f51b5; }
        .pos-prels { background-color: #3949ab; }
        .pos-prf { background-color: #303f9f; }

        .pos-art { background-color: #bbdefb; }
        .pos-pdat { background-color: #90caf9; }

        .pos-kon { background-color: #dcedc8; }
        .pos-kous { background-color: #aed581; }

        .pos-appr { background-color: #fff9c4; }

        .pos-card { background-color: #ffecb3; }

        .pos-ptkneg { background-color: #d7ccc8; }
        .pos-ptkzu { background-color: #bcaaa4; }

        .pos-punct { background-color: #f5f5f5; color: #757575; } /*punctuation*/

        .pos-other { background-color: #e0e0e0; }


        /* Loading indicator */
        .loading-indicator {
            display: none;
            text-align: center;
            margin: 20px 0;
        }

        .loading-spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #DA6565;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 0 auto 10px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .back-button {
            display: inline-flex;
            align-items: center;
            margin-bottom: 20px;
            color: #666;
            text-decoration: none;
            font-weight: bold;
            transition: color 0.3s;
        }

        .back-button:hover {
            color: #DA6565;
        }

        .back-button i {
            margin-right: 5px;
        }

        /* POS and Sentiment legends */
        .legend {
            display: none;
            margin-top: 10px;
            padding: 10px;
            background-color: #f8f8f8;
            border-radius: 5px;
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

        /* Toggle controls */
        .controls {
            margin: 20px 0;
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
        }

        .control-group {
            display: flex;
            align-items: center;
        }

        /* Sentiment indicator */
        .sentiment-indicator {
            display: none;
            cursor: pointer;
        }

        /* Sentiment legend */
        .sentiment-example {
            display: flex;
            align-items: center;
            margin-bottom: 5px;
        }

        .sentiment-color {
            width: 15px;
            height: 15px;
            border-radius: 50%;
            margin-right: 5px;
        }

        .entity-highlight {
            padding: 2px;
            border-radius: 3px;
        }

        .entity-person {
            background-color: #ffecb3;
            border-bottom: 2px solid #ffa000;
        }

        .entity-location {
            background-color: #c8e6c9;
            border-bottom: 2px solid #4caf50;
        }

        .entity-organization {
            background-color: #bbdefb;
            border-bottom: 2px solid #2196f3;
        }

        .entity-date {
            background-color: #d1c4e9;
            border-bottom: 2px solid #673ab7;
        }

        .entity-number {
            background-color: #ffcdd2;
            border-bottom: 2px solid #e57373;
        }

        .entity-event {
            background-color: #b3e5fc;
            border-bottom: 2px solid #29b6f6;
        }

        .entity-product {
            background-color: #f8bbd0;
            border-bottom: 2px solid #ec407a;
        }

        .entity-law {
            background-color: #b2dfdb;
            border-bottom: 2px solid #26a69a;
        }

        .entity-language {
            background-color: #ffe0b2;
            border-bottom: 2px solid #ffb74d;
        }

        .entity-misc {
            background-color: #e1bee7;
            border-bottom: 2px solid #9c27b0;
        }

        .entity-other {
            background-color: #f5f5f5;
            border-bottom: 2px solid #9e9e9e;
        }

        .sentiment-indicator {
            display: inline-block;
            width: 16px;
            height: 16px;
            font-size: 20px;
            line-height: 1;
            margin-left: 2px;
            cursor: help;
            vertical-align: middle;
            opacity: 0.7;
            position: relative;
            top: -3px; /* Move the circle */
        }

        .sentiment-negative {
            color: #ffb3b3;
        }

        .sentiment-neutral {
            color: #d9d9d9;
        }

        .sentiment-positive {
            color: #b3ffb3;
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
        <a href="/visualisierungen" class="nav-link">Visualisierungen</a>
        <a href="/redenportal" class="nav-link red-border">Redeportal</a>
        <a href="#footer" class="nav-button">Über Projekt</a>
    </div>
</nav>

<div class="container">
    <a href="/redenportal" class="back-button">
        <i class="fas fa-arrow-left"></i> Zurück zur Übersicht
    </a>

    <h1>Rede Details</h1>

    <!-- Speaker information -->
    <div class="speaker-info">
        <#if speaker?? && speaker.image??>
            <img src="${speaker.image}" alt="${speaker.firstName} ${speaker.name}" class="speaker-image">
        <#else>
            <img src="/static/images/default-profile.png" alt="Unbekannter Redner" class="speaker-image">
        </#if>

        <div>
            <#if speaker??>
                <h2>
                    <#if speaker.title?? && speaker.title != "">${speaker.title} </#if>
                    ${speaker.firstName} ${speaker.name}
                </h2>

                <#if speaker.party?? && speaker.party != "">
                    <div class="party-tag party-${speaker.party!'default'}">${speaker.party}</div>
                </#if>
            <#else>
                <h2>Unbekannter Redner</h2>
            </#if>

            <#if speech.protocol??>
                <div style="margin-top: 10px; color: #666;">
                    <!-- Skip datetime formatting to avoid FreeMarker compatibility issues -->
                    Protokoll: ${speech.protocol.index}
                    <#if speech.protocol.title??>
                        - ${speech.protocol.title}
                    </#if>
                </div>
            </#if>
        </div>
    </div>

    <!-- Toggle controls -->
    <!-- Add this right after the toggle controls -->
    <div class="controls">
        <!-- POS toggle -->
        <div class="control-group">
            <label class="toggle-switch">
                <input type="checkbox" id="toggle-pos">
                <span class="slider"></span>
            </label>
            <span>Wortarten (POS) anzeigen</span>
        </div>

        <!-- Named Entity toggle -->
        <div class="control-group">
            <label class="toggle-switch">
                <input type="checkbox" id="toggle-entities">
                <span class="slider"></span>
            </label>
            <span>Entitäten anzeigen</span>
        </div>
        <!-- Add this to your toggle controls section -->
        <div class="control-group">
            <label class="toggle-switch">
                <input type="checkbox" id="toggle-sentiments">
                <span class="slider"></span>
            </label>
            <span>Stimmungen (Sentiments) anzeigen</span>
        </div>

    </div>
    <!-- If no annotation is available-->
    <div id="annotations-notice" class="annotation-notification" style="display: none; margin: 15px 0; padding: 10px; background-color: #f8f8f8; border-left: 4px solid #DA6565; color: #555;">
        <i class="fas fa-info-circle" style="margin-right: 8px;"></i>
        <span>Für diese Rede sind keine Annotationen (POS-Tags, Entitäten und Sentiments) verfügbar.</span>
    </div>

    <!-- POS legend -->
    <div id="pos-legend" class="legend">
        <div style="font-weight: bold; margin-bottom: 10px;">Wortarten (POS):</div>
        <div style="display: flex; flex-wrap: wrap; gap: 10px;">
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #e1bee7; margin-right: 5px; border-radius: 3px;"></div>
                <span>Nomen (NN)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #ce93d8; margin-right: 5px; border-radius: 3px;"></div>
                <span>Eigennamen (NE)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #b2dfdb; margin-right: 5px; border-radius: 3px;"></div>
                <span>Verben (VVFIN)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #ffe0b2; margin-right: 5px; border-radius: 3px;"></div>
                <span>Adjektive (ADJA)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #ffcdd2; margin-right: 5px; border-radius: 3px;"></div>
                <span>Adverbien (ADV)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #c5cae9; margin-right: 5px; border-radius: 3px;"></div>
                <span>Pronomen (PPER, etc.)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #bbdefb; margin-right: 5px; border-radius: 3px;"></div>
                <span>Artikel (ART)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #fff9c4; margin-right: 5px; border-radius: 3px;"></div>
                <span>Präpositionen (APPR)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #e0e0e0; margin-right: 5px; border-radius: 3px;"></div>
                <span>Andere</span>
            </div>
        </div>
    </div>
    <!-- Entity legend -->
    <div id="entity-legend" class="legend">
        <div style="font-weight: bold; margin-bottom: 10px;">Benannte Entitäten:</div>
        <div style="display: flex; flex-wrap: wrap; gap: 10px;">
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #ffecb3; border-bottom: 2px solid #ffa000; margin-right: 5px; border-radius: 3px;"></div>
                <span>Personen</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #c8e6c9; border-bottom: 2px solid #4caf50; margin-right: 5px; border-radius: 3px;"></div>
                <span>Orte</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #bbdefb; border-bottom: 2px solid #2196f3; margin-right: 5px; border-radius: 3px;"></div>
                <span>Organisationen</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #d1c4e9; border-bottom: 2px solid #673ab7; margin-right: 5px; border-radius: 3px;"></div>
                <span>Datum/Zeit</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #ffcdd2; border-bottom: 2px solid #e57373; margin-right: 5px; border-radius: 3px;"></div>
                <span>Zahlen/Mengen</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #e1bee7; border-bottom: 2px solid #9c27b0; margin-right: 5px; border-radius: 3px;"></div>
                <span>Verschiedenes (MISC)</span>
            </div>
            <div style="display: flex; align-items: center;">
                <div style="width: 15px; height: 15px; background-color: #f5f5f5; border-bottom: 2px solid #9e9e9e; margin-right: 5px; border-radius: 3px;"></div>
                <span>Andere Entitäten</span>
            </div>
        </div>
    </div>
    <!-- Sentiment legend -->
    <div id="sentiment-legend" class="legend">
        <div style="font-weight: bold; margin-bottom: 10px;">Stimmungswerte (Sentiments):</div>
        <div style="display: flex; flex-wrap: wrap; gap: 10px;">
            <div class="sentiment-example">
                <div class="sentiment-color" style="background-color: #ff4d4d;"></div>
                <span>Negativ</span>
            </div>
            <div class="sentiment-example">
                <div class="sentiment-color" style="background-color: #dddddd;"></div>
                <span>Neutral</span>
            </div>
            <div class="sentiment-example">
                <div class="sentiment-color" style="background-color: #4dff4d;"></div>
                <span>Positiv</span>
            </div>
        </div>
    </div>
    <!-- Loading indicators -->
    <div id="loading-indicator" class="loading-indicator">
        <div class="loading-spinner"></div>
        <div>Lade POS-Daten...</div>
    </div>
    <div id="sentiment-loading" class="loading-indicator">
        <div class="loading-spinner"></div>
        <div>Lade Sentiment-Daten...</div>
    </div>
    <div id="entity-loading" class="loading-indicator">
        <div class="loading-spinner"></div>
        <div>Lade Entitäts-Daten...</div>
    </div>
    <!-- Speech -->
    <div class="speech-content" id="speech-content">
        <#if speechText??>
            ${speechText}
        <#else>
            <p>Kein Text für diese Rede verfügbar.</p>
        </#if>
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
    const speechId = "${speechId!''}";
    const speechContent = document.getElementById('speech-content');
    const togglePos = document.getElementById('toggle-pos');
    const toggleEntity = document.getElementById('toggle-entities');
    const posLegend = document.getElementById('pos-legend');
    const entityLegend = document.getElementById('entity-legend');
    const loadingIndicator = document.getElementById('loading-indicator');
    const entityLoading = document.getElementById('entity-loading');
    const sentimentLegend = document.getElementById('sentiment-legend');
    const toggleSentiments = document.getElementById('toggle-sentiments');
    const annotationsAvailable = ${annotationsAvailable?c}; // flag for all annotations

    <#noparse>
    (function() {
        /**
         * Loads the speech text with comments from the API.
         * First tries to fetch structured text content, and if that fails,
         * falls back to plain text.
         */
        function loadSpeechWithComments() {
            fetch(`/api/speech/${speechId}/textContent`)
                .then(response => {
                    if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
                    return response.json();
                })
                .then(data => {
                    if (!data.textContent || !Array.isArray(data.textContent)) {
                        return fetch(`/api/speech/${speechId}/text`)
                            .then(response => response.json())
                            .then(textData => {
                                speechContent.textContent = textData.text || "";
                            });
                    }

                    // Building HTML with text and comments
                    let html = '';

                    for (const item of data.textContent) {
                        if (item.type === 'text') {
                            // Regular speech text - can be highlighted
                            html += `<div class="speech-text">${item.text}</div>`;
                        } else if (item.type === 'comment') {
                            // Comment - should not be highlighted
                            html += `<div class="speech-comment">(${item.text})</div>`;
                        }
                    }
                    speechContent.innerHTML = html;// Set the content
                })
        }

        document.addEventListener('DOMContentLoaded', function() {
            loadSpeechWithComments();
            //visibility
            if (posLegend) posLegend.style.display = 'none';
            if (entityLegend) entityLegend.style.display = 'none';
            if (sentimentLegend) sentimentLegend.style.display = 'none';
            // Notification if annotations are not available
            if (!annotationsAvailable) {
                const annotationMessage = "Für diese Rede sind keine linguistischen Annotationen verfügbar";
                const notice = document.getElementById('annotations-notice');
                if (notice) {
                    notice.style.display = 'block';
                }
                // Disable toggle switches
                if (togglePos) {
                    togglePos.disabled = true;
                    togglePos.parentNode.style.opacity = "0.5";
                }

                if (toggleEntity) {
                    toggleEntity.disabled = true;
                    toggleEntity.parentNode.style.opacity = "0.5";
                }

                if (toggleSentiments) {
                    toggleSentiments.disabled = true;
                    toggleSentiments.parentNode.style.opacity = "0.5";
                }
            } else {
                // Wire up toggle handlers only if annotations are available
                if (togglePos) {
                    togglePos.addEventListener('change', handlePosToggle);
                }
                if (toggleEntity) {
                    toggleEntity.addEventListener('change', handleEntityToggle);
                }
                if (toggleSentiments) {
                    toggleSentiments.addEventListener('change', handleSentimentToggle);
                }
            }
        });
        /**
         * Highlights POS tags in the speech text.
         * Fetches text data and POS annotations from the API and applies
         * highlighting to words based on their grammatic.
         */
        function highlightPOS() {
            // Show loading indicator
            showLoadingIndicator('loading-indicator');

            //Fetch text data
            fetch(`/api/speech/${speechId}/text`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    return response.json();
                })
                .then(textData => {
                    const cleanText = textData.text || speechContent.textContent || "";

                    // Fetch the POS data
                    return fetch(`/api/speech/${speechId}/pos`)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error(`HTTP error! Status: ${response.status}`);
                            }
                            return response.json().then(posData => ({posData, cleanText}));
                        });
                })
                .then(({posData, cleanText}) => {
                    hideLoadingIndicator('loading-indicator');

                    if (!posData || !posData.positions || posData.positions.length === 0) {
                        togglePos.checked = false;
                        return;
                    }

                    try {
                        // Save the current state for comments
                        const originalHTML = speechContent.innerHTML;
                        const comments = Array.from(document.querySelectorAll('.speech-comment')).map(comment => {
                            return comment.outerHTML;
                        });

                        //Reset content and remove all comments temporarily
                        speechContent.textContent = cleanText;

                        // Create a map that assigns a POS tag to each character in the text
                        const charMap = new Array(cleanText.length).fill(null);

                        // Mark each character with its POS tag
                        for (const pos of posData.positions) {
                            if (pos.begin !== undefined && pos.end !== undefined && pos.tag) {
                                for (let i = pos.begin; i < pos.end; i++) {
                                    if (i < cleanText.length) {
                                        charMap[i] = {
                                            tag: pos.tag,
                                            begin: pos.begin,
                                            end: pos.end
                                        };
                                    }
                                }
                            }
                        }

                        // Build HTML by treating characters with the same tag as a unit
                        let html = '';
                        let currentPos = 0;
                        let currentTag = null;
                        let currentBegin = 0;

                        for (let i = 0; i <= cleanText.length; i++) {
                            const charInfo = i < cleanText.length ? charMap[i] : null;
                            const tag = charInfo ? charInfo.tag : null;

                            // Check if we are at a POS boundary or end of text
                            if (tag !== currentTag || i === cleanText.length) {
                                // Output with highlighting
                                if (currentPos < i) {
                                    const text = cleanText.substring(currentPos, i);

                                    if (currentTag) {
                                        // A  word to highlight
                                        const posClass = getPosClass(currentTag);
                                        html += `<span class="pos-highlight ${posClass}" title="${currentTag}: ${text}">${text}</span>`;
                                    } else {
                                        // Untagged text keep as is
                                        html += text;
                                    }
                                }
                                // Start new segment
                                currentPos = i;
                                currentTag = tag;
                                if (tag) {
                                    currentBegin = charInfo.begin;
                                }
                            }
                        }
                        // Set the highlighted text
                        speechContent.innerHTML = html;

                        // insert comments at their original positions
                        const tempDiv = document.createElement('div');
                        comments.forEach(commentHTML => {
                            tempDiv.innerHTML = commentHTML;
                            speechContent.appendChild(tempDiv.firstChild);
                        });

                        // Show the legend
                        if (posLegend) posLegend.style.display = 'block';
                    } catch (error) {
                        togglePos.checked = false;
                    }
                })
                .catch(error => {
                    togglePos.checked = false;
                });
        }

        let originalSpeechContent = null;
        /**
         * Clears POS highlighting from the speech text.
         * Either restores the original content or replaces highlighted spans
         * with their text content.
         */
        function clearPosHighlights() {
            // If we have stored the original content we restore it
            if (originalSpeechContent !== null) {
                speechContent.innerHTML = originalSpeechContent;
                // Hide the legend
                if (posLegend) posLegend.style.display = 'none';
                return;
            }
            // Get all highlights
            const highlights = document.querySelectorAll('.pos-highlight');

            // If no highlights there is nothing to do
            if (highlights.length === 0) return;

            // Process each highlight to replace it with its text content
            for (const highlight of highlights) {
                const text = highlight.textContent;
                const textNode = document.createTextNode(text);
                highlight.parentNode.replaceChild(textNode, highlight);
            }
            speechContent.normalize();

            // Hide the legend
            if (posLegend) posLegend.style.display = 'none';
        }

        /**
         * Returns the appropriate CSS class for a POS tag.
         *
         * @param {string} tag - The POS tag code
         * @return {string} CSS class name for the tag
         */
        function getPosClass(tag) {
            if (!tag) return 'pos-other';

            const lowerTag = tag.toLowerCase();

            if (lowerTag === 'nn') return 'pos-nn';
            if (lowerTag === 'ne') return 'pos-ne';
            if (lowerTag === 'trunc') return 'pos-nn';
            if (lowerTag === 'vvfin') return 'pos-vvfin';
            if (lowerTag === 'vvinf') return 'pos-vvinf';
            if (lowerTag === 'vvizu') return 'pos-vvinf';
            if (lowerTag === 'vvpp') return 'pos-vvpp';
            if (lowerTag === 'vafin') return 'pos-vafin';
            if (lowerTag === 'vaimp') return 'pos-vafin';
            if (lowerTag === 'vainf') return 'pos-vainf';
            if (lowerTag === 'vapp') return 'pos-vapp';
            if (lowerTag === 'vmfin') return 'pos-vmfin';
            if (lowerTag === 'vminf') return 'pos-vminf';
            if (lowerTag === 'vmpp') return 'pos-vmfin';
            if (lowerTag === 'adja') return 'pos-adja';
            if (lowerTag === 'adjd') return 'pos-adjd';
            if (lowerTag === 'adv') return 'pos-adv';
            if (lowerTag === 'proav') return 'pos-proav';
            if (lowerTag === 'pper') return 'pos-pper';
            if (lowerTag === 'pposs') return 'pos-pposat';
            if (lowerTag === 'pposat') return 'pos-pposat';
            if (lowerTag === 'pdat') return 'pos-pdat';
            if (lowerTag === 'pds') return 'pos-pds';
            if (lowerTag === 'piat') return 'pos-pis';
            if (lowerTag === 'pidat') return 'pos-pis';
            if (lowerTag === 'pis') return 'pos-pis';
            if (lowerTag === 'prels') return 'pos-prels';
            if (lowerTag === 'prelat') return 'pos-prels';
            if (lowerTag === 'pwat') return 'pos-pws';
            if (lowerTag === 'pwav') return 'pos-pws';
            if (lowerTag === 'pws') return 'pos-pws';
            if (lowerTag === 'prf') return 'pos-prf';
            if (lowerTag === 'art') return 'pos-art';
            if (lowerTag === 'kon') return 'pos-kon';
            if (lowerTag === 'koui') return 'pos-kous';    //infinitive
            if (lowerTag === 'kous') return 'pos-kous';
            if (lowerTag === 'kokom') return 'pos-kon';
            if (lowerTag === 'appr') return 'pos-appr';
            if (lowerTag === 'apprart') return 'pos-appr';
            if (lowerTag === 'appo') return 'pos-appr';
            if (lowerTag === 'apzr') return 'pos-appr';
            if (lowerTag === 'card') return 'pos-card';
            if (lowerTag === 'ptka') return 'pos-ptkneg';
            if (lowerTag === 'ptkant') return 'pos-ptkneg';
            if (lowerTag === 'ptkneg') return 'pos-ptkneg';
            if (lowerTag === 'ptkvz') return 'pos-ptkzu';
            if (lowerTag === 'ptkzu') return 'pos-ptkzu';
            if (lowerTag === 'fm') return 'pos-other';
            if (lowerTag.startsWith('$')) return 'pos-punct';
            return 'pos-other';
        }

        /**
         * Returns the appropriate CSS class for a sentiment value.
         *
         * @param {number} value - The sentiment value
         * @return {string} CSS class name for the tag
         */
        function getSentimentClass(value) {
            if (value < 0.0) {
                return 'sentiment-negative';
            } else if (value > 0.0) {
                return 'sentiment-positive';
            } else {
                return 'sentiment-neutral';
            }
        }

        /**
         * Clears sentiment indicators from the speech text.
         * Removes all sentiment indicator elements and normalizes text nodes.
         */
        function clearSentimentHighlights() {
            const indicators = document.querySelectorAll('.speech-text .sentiment-indicator');
            for (const el of indicators) {
                el.parentNode.removeChild(el);
            }

            // Normalize text nodes in each speechtext element
            for (let i = 0; i < document.querySelectorAll('.speech-text').length; i++){
                const el = document.querySelectorAll('.speech-text')[i];
                el.normalize();
            }
        }

        /**
         * Highlights sentiment values in the speech text.
         * Adds indicators at the end of sentences to show sentiment.
         */
        function highlightSentiments() {
            // Show loading indicator
            showLoadingIndicator('sentiment-loading');

            // Get only the speechtext elements
            const textElements = document.querySelectorAll('.speech-text');
            if (textElements.length === 0) {
                toggleSentiments.checked = false;
                hideLoadingIndicator('sentiment-loading');
                return;
            }

            fetch(`/api/speech/${speechId}/sentiments`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    return response.json();
                })
                .then(data => {
                    hideLoadingIndicator('sentiment-loading');

                    if (!data || !data.sentiments || data.sentiments.length === 0) {
                        toggleSentiments.checked = false;
                        return;
                    }

                    try {
                        // Keep track of text offset
                        let textOffset = 0;

                        // Process each text element
                        for (const textElement of textElements) {
                            const elementText = textElement.textContent;

                            // Find sentence endings in this element
                            const sentenceEndPattern = /[.!?](\s|$)/g;
                            let match;
                            const sentenceEndings = [];
                            while ((match = sentenceEndPattern.exec(elementText)) !== null) {
                                sentenceEndings.push({
                                    position: match.index, // Position in this element
                                    globalPosition: textOffset + match.index, // Position in the overall text
                                    text: match[0]
                                });
                            }

                            // Match sentiments to sentence endings
                            const sentimentMap = new Map();
                            for (const sentiment of data.sentiments) {
                                if (sentiment.end === undefined || sentiment.value === undefined) continue;

                                // Find the closest sentence ending in this element
                                let closestEnd = null;
                                let minDistance = Infinity;
                                for (const ending of sentenceEndings) {
                                    const distance = Math.abs(sentiment.end - ending.globalPosition);
                                    if (distance < minDistance && distance <= 20) {
                                        minDistance = distance;
                                        closestEnd = ending.position;
                                    }
                                }
                                if (closestEnd !== null) {
                                    if (sentimentMap.has(closestEnd)) {
                                        const existing = sentimentMap.get(closestEnd);
                                        if (Math.abs(sentiment.value) > Math.abs(existing.value)) {
                                            sentimentMap.set(closestEnd, sentiment);
                                        }
                                    } else {
                                        sentimentMap.set(closestEnd, sentiment);
                                    }
                                }
                            }
                            // Process text and add indicators
                            let result = '';
                            let lastPos = 0;
                            const sortedEndings = Array.from(sentimentMap.entries())
                                .sort((a, b) => a[0] - b[0]);
                            for (const [position, sentiment] of sortedEndings) {
                                // Add text before the ending
                                result += elementText.substring(lastPos, position + 1); // Include punctuation
                                // Add indicator
                                const sentimentClass = getSentimentClass(sentiment.value);
                                result += `<span class="sentiment-indicator ${sentimentClass}" title="Stimmungswert: ${sentiment.value.toFixed(2)}">●</span>`;
                                // Update position
                                lastPos = position + 1;
                            }
                            // Add remaining text
                            if (lastPos < elementText.length) {
                                result += elementText.substring(lastPos);
                            }
                            // Update elements content
                            textElement.innerHTML = result;
                            // Update offset for next element
                            textOffset += elementText.length;
                        }
                        // Show the legend
                        if (sentimentLegend) sentimentLegend.style.display = 'block';
                    } catch (error) {
                        // Reset text elements
                        for (const el of textElements) {
                            el.innerHTML = el.textContent;
                        }
                        toggleSentiments.checked = false;
                    }
                })
                .catch(error => {
                    toggleSentiments.checked = false;
                });
        }

        /**
         * Clears named entity highlighting from the speech text.
         * Either restores the original content or replaces highlighted spans
         * with their text content.
         */
        function clearEntityHighlights() {
            // If we have stored the original content we restore it
            if (originalSpeechContent !== null) {
                speechContent.innerHTML = originalSpeechContent;
                // Hide the legend
                if (entityLegend) entityLegend.style.display = 'none';
                return;
            }

            // Fallback if original content wasn't stored
            const highlights = document.querySelectorAll('.entity-highlight');
            if (highlights.length === 0) return;

            // Process each highlight to replace it with its text content
            for (const highlight of highlights) {
                const text = highlight.textContent;
                const textNode = document.createTextNode(text);
                highlight.parentNode.replaceChild(textNode, highlight);
            }

            // Normalize the DOM to merge adjacent text nodes
            speechContent.normalize();

            // Hide the legend
            if (entityLegend) entityLegend.style.display = 'none';
        }

        /**
         * Removes all types of highlighting from the speech text.
         * Resets the display to show the original text without annotations.
         */
        function clearAllHighlights() {
            // Clear POS highlights
            clearPosHighlights();
            if (posLegend) posLegend.style.display = 'none';

            // Clear entity highlights
            clearEntityHighlights();
            if (entityLegend) entityLegend.style.display = 'none';

            // Clear sentiment highlights
            clearSentimentHighlights();
            if (sentimentLegend) sentimentLegend.style.display = 'none';
        }

        /**
         * Handles toggling of POS highlighting.
         * Enables POS highlighting while disabling other annotation types
         * when the toggle is checked and clears POS highlighting when unchecked.
         */
        function handlePosToggle() {
            // Turn off other toggles
            if (togglePos.checked) {
                // Store original content before applying highlights
                if (originalSpeechContent === null) {
                    originalSpeechContent = speechContent.innerHTML;
                }

                if (toggleEntity && toggleEntity.checked) {
                    toggleEntity.checked = false;
                }
                if (toggleSentiments && toggleSentiments.checked) {
                    toggleSentiments.checked = false;
                }
                clearAllHighlights();
                highlightPOS();
            } else {
                clearPosHighlights();
                if (posLegend) posLegend.style.display = 'none';
            }
        }

        /**
         * Handles toggling of entity highlighting.
         * Enables entity highlighting while disabling other annotation types
         * when the toggle is checked, and clears entity highlighting when unchecked.
         */
        function handleEntityToggle() {
            // Turn off other toggles
            if (toggleEntity.checked) {
                // Store original content before applying highlights
                if (originalSpeechContent === null) {
                    originalSpeechContent = speechContent.innerHTML;
                }

                if (togglePos && togglePos.checked) {
                    togglePos.checked = false;
                }
                if (toggleSentiments && toggleSentiments.checked) {
                    toggleSentiments.checked = false;
                }

                clearAllHighlights();
                highlightEntities();
            } else {
                clearEntityHighlights();
                if (entityLegend) entityLegend.style.display = 'none';
            }
        }

        /**
         * Highlights named entities in the speech text.
         * Fetches text data and entity annotations from the API, then applies
         * color-coded highlighting to words based on entity type.
         */
        function highlightEntities() {
            // Show loading indicator
            showLoadingIndicator('entity-loading');
            // Fetch text data
            fetch(`/api/speech/${speechId}/text`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    return response.json();
                })
                .then(textData => {
                    const cleanText = textData.text || speechContent.textContent || "";
                    // Fetch the entity data
                    return fetch(`/api/speech/${speechId}/entities`)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error(`HTTP error! Status: ${response.status}`);
                            }
                            return response.json().then(entityData => ({entityData, cleanText}));
                        });
                })
                .then(({entityData, cleanText}) => {
                    hideLoadingIndicator('entity-loading');

                    if (!entityData || !entityData.entities || entityData.entities.length === 0) {
                        toggleEntity.checked = false;
                        return;
                    }

                    try {
                        // Save the current state for comments
                        const originalHTML = speechContent.innerHTML;
                        const comments = Array.from(document.querySelectorAll('.speech-comment')).map(comment => {
                            return comment.outerHTML;
                        });

                        // Reset content and remove all comments temporarily
                        speechContent.textContent = cleanText;
                        const charMap = new Array(cleanText.length).fill(null);

                        // Mark each character with its entity type
                        for (const entity of entityData.entities) {
                            if (entity.begin !== undefined && entity.end !== undefined && entity.type) {
                                for (let i = entity.begin; i < entity.end; i++) {
                                    if (i < cleanText.length) {
                                        charMap[i] = {
                                            type: entity.type,
                                            begin: entity.begin,
                                            end: entity.end,
                                            text: entity.text || cleanText.substring(entity.begin, entity.end)
                                        };
                                    }
                                }
                            }
                        }


                        // Build HTML by treating characters with the same entity type as a unit
                        let html = '';
                        let currentPos = 0;
                        let currentType = null;
                        let currentBegin = 0;
                        let currentText = '';

                        for (let i = 0; i <= cleanText.length; i++) {
                            const charInfo = i < cleanText.length ? charMap[i] : null;
                            const type = charInfo ? charInfo.type : null;

                            // Check if we are at an entity boundary or end of text
                            if (type !== currentType ||
                                (charInfo && currentType && charInfo.begin !== currentBegin) ||
                                i === cleanText.length) {

                                // Output text with highlighting
                                if (currentPos < i) {
                                    const text = cleanText.substring(currentPos, i);

                                    if (currentType) {
                                        // an entity to highlight
                                        const entityClass = getEntityClass(currentType);
                                        html += `<span class="entity-highlight ${entityClass}" title="${currentType}: ${currentText || text}">${text}</span>`;
                                    } else {
                                        // untagged text
                                        html += text;
                                    }
                                }

                                // Start new segment
                                currentPos = i;
                                currentType = type;
                                if (type) {
                                    currentBegin = charInfo.begin;
                                    currentText = charInfo.text;
                                } else {
                                    currentBegin = 0;
                                    currentText = '';
                                }
                            }
                        }

                        // Set the highlighted text
                        speechContent.innerHTML = html;

                        // Reinsert comments at their original positions
                        const tempDiv = document.createElement('div');
                        comments.forEach(commentHTML => {
                            tempDiv.innerHTML = commentHTML;
                            speechContent.appendChild(tempDiv.firstChild);
                        });

                        // Show the legend
                        if (entityLegend) entityLegend.style.display = 'block';
                    } catch (error) {
                        toggleEntity.checked = false;
                    }
                })
                .catch(error => {
                    toggleEntity.checked = false;
                });
        }

        /**
         * Handles toggling of sentiment highlighting.
         * Enables sentiment indicators while disabling other annotation types
         * when the toggle is checked, and clears sentiment indicators when unchecked.
         */
        function handleSentimentToggle() {
            // Turn off other toggles
            if (toggleSentiments.checked) {
                if (togglePos && togglePos.checked) {
                    togglePos.checked = false;
                }
                if (toggleEntity && toggleEntity.checked) {
                    toggleEntity.checked = false;
                }
                clearAllHighlights();
                highlightSentiments();
            } else {
                clearSentimentHighlights();
                if (sentimentLegend) sentimentLegend.style.display = 'none';
            }
        }

        /**
         * Shows a loading indicator for the specified element.
         *
         * @param {string} id - The ID of the loading indicator element to show
         */
        function showLoadingIndicator(id) {
            const indicator = document.getElementById(id);
            if (indicator) {
                indicator.style.display = 'block';
            }
        }

        /**
         * Returns the appropriate CSS class for an entity type.
         * Maps entity type names to color classes for visualization.
         *
         * @param {string} type - The entity type
         * @return {string} CSS class name for the entity type
         */
        function getEntityClass(type) {
            const normalizedType = type.toUpperCase();

            if (normalizedType === 'PER' ||
                normalizedType === 'PERSON' ||
                normalizedType === 'PERSNAME' ||
                normalizedType === 'INDIVIDUAL') {
                return 'entity-person';
            }
            if (normalizedType === 'LOC' ||
                normalizedType === 'LOCATION' ||
                normalizedType === 'PLACE' ||
                normalizedType === 'GPE' ||
                normalizedType === 'COUNTRY' ||
                normalizedType === 'CITY' ||
                normalizedType === 'STATE' ||
                normalizedType === 'ADDRESS') {
                return 'entity-location';
            }
            if (normalizedType === 'ORG' ||
                normalizedType === 'ORGANIZATION' ||
                normalizedType === 'COMPANY' ||
                normalizedType === 'INSTITUTION' ||
                normalizedType === 'CORP' ||
                normalizedType === 'GROUP') {
                return 'entity-organization';
            }
            if (normalizedType === 'DATE' ||
                normalizedType === 'TIME' ||
                normalizedType === 'DATETIME') {
                return 'entity-date';
            }
            if (normalizedType === 'MONEY' ||
                normalizedType === 'CARDINAL' ||
                normalizedType === 'ORDINAL' ||
                normalizedType === 'QUANTITY' ||
                normalizedType === 'PERCENT') {
                return 'entity-number';
            }
            if (normalizedType === 'EVENT') {
                return 'entity-event';
            }
            if (normalizedType === 'PRODUCT' ||
                normalizedType === 'WORK_OF_ART') {
                return 'entity-product';
            }
            if (normalizedType === 'LAW') {
                return 'entity-law';
            }
            if (normalizedType === 'LANGUAGE') {
                return 'entity-language';
            }
            if (normalizedType === 'MISC' || normalizedType === 'MISCELLANEOUS') {
                return 'entity-misc';
            }
            return 'entity-other';
        }

        /**
         * Hides a loading indicator for the specified element.
         *
         * @param {string} id - The ID of the loading indicator element to hide
         */
        function hideLoadingIndicator(id) {
            const indicator = document.getElementById(id);
            if (indicator) {
                indicator.style.display = 'none';
            }
        }
    })();
    </#noparse>
</script>
</body>
</html>