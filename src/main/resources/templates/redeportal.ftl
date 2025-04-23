<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Redeportal</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="/static/index-styles.css">
    <style>
        .deputies-container {
            margin-top: 30px;
        }
        .deputies-list {
            list-style: none;
            padding: 0;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 15px;
        }

        .deputy-item {
            background-color: white;
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .deputy-link {
            display: block;
            text-decoration: none;
            color: inherit;
        }

        .deputy-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
            cursor: pointer;
        }

        .deputy-name {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 5px;
            color: #333;
        }

        .deputy-party {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 15px;
            font-size: 14px;
            color: white;
            margin-top: 5px;
        }

        .search-container {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
        }

        .search-input {
            flex-grow: 1;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 30px;
            font-size: 16px;
        }

        .search-input:focus {
            outline: none;
            border-color: #DA6565;
        }

        .search-button {
            background-color: #DA6565;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 30px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .search-button:hover {
            background-color: #C45050;
        }

        .party-filter {
            margin-top: 15px;
            margin-bottom: 25px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .party-tag {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 14px;
            color: white;
            cursor: pointer;
            transition: opacity 0.3s, transform 0.3s;
        }

        .party-tag:hover {
            transform: translateY(-2px);
        }

        .party-tag.active {
            box-shadow: 0 0 0 2px white, 0 0 0 4px currentColor;
        }

        .party-tag.inactive {
            opacity: 0.6;
        }

        /* Party colors */
        .party-CDU { background-color: #363536; }
        .party-SPD { background-color: #FD5252; }
        .party-FDP { background-color: #F3E767;}
        .party-GRUENE, .party-GRÜNE, .party-BÜNDNIS90DIEGRÜNEN, .party-BÜNDNIS90\/DIEGRÜNEN,
        [class*="party-BÜNDNIS"] { background-color: #71B877; }
        .party-LINKE, .party-DIELINKE, [class*="party-DIE"] { background-color: #FF99D8; }
        .party-AfD { background-color: #71C4FF; }
        .party-CSU { background-color: #22A3FF; }
        .party-default, .party-other { background-color: #ADAEAE; }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-titel">
        <h1><a href="/" style="text-decoration: none; color: inherit;">Multimodal Parliament Explorer</a></h1>
    </div>
    <div class="navbar-links">
        <a href="/visualisierungen" class="nav-link">Visualisierungen</a>
        <a href="/redenportal" class="nav-link red-border active">Redeportal</a>
        <a href="#footer" class="nav-button">Über Projekt</a>
    </div>
</nav>

<div class="container">
    <h1>Redeportal des Bundestages</h1>
    <p>Durchsuchen Sie die Abgeordneten des Deutschen Bundestages und entdecken Sie deren Parlamentsreden.</p>

    <!-- Search and filter -->
    <div class="search-container">
        <input type="text" id="deputy-search" class="search-input" placeholder="Name des Abgeordneten suchen...">
        <button id="search-button" class="search-button">
            <i class="fas fa-search"></i> Suchen
        </button>
    </div>

    <!-- Party filters -->
    <div class="party-filter">
        <span class="party-tag party-CDU active" data-party="CDU">CDU</span>
        <span class="party-tag party-SPD active" data-party="SPD">SPD</span>
        <span class="party-tag party-FDP active" data-party="FDP">FDP</span>
        <span class="party-tag party-GRUENE active" data-party="BÜNDNIS 90/DIE GRÜNEN">GRÜNE</span>
        <span class="party-tag party-LINKE active" data-party="DIE LINKE.">DIE LINKE</span>
        <span class="party-tag party-AfD active" data-party="AfD">AfD</span>
        <span class="party-tag party-CSU active" data-party="CSU">CSU</span>
        <span class="party-tag party-default active" data-party="other">Andere</span>
    </div>

    <!-- Deputies list -->
    <div class="deputies-container">
        <ul class="deputies-list">
            <#list speakers as speaker>
                <li class="deputy-item" data-party="${speaker.party!'other'}">
                    <a href="/redeportal/speaker/${speaker.id}" class="deputy-link">
                        <div class="deputy-name">
                            <#if speaker.title?? && speaker.title != "">
                                ${speaker.title}
                            </#if>
                            ${speaker.firstName} ${speaker.name}
                        </div>
                        <#if speaker.party?? && speaker.party != "">
                            <div class="deputy-party party-${speaker.party!'default'}">
                                ${speaker.party}
                            </div>
                        </#if>
                    </a>
                </li>
            <#else>
                <p>Keine Abgeordneten gefunden.</p>
            </#list>
        </ul>
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
    document.addEventListener('DOMContentLoaded', function() {
        const partyTags = document.querySelectorAll('.party-tag');// party filter
        const deputyItems = document.querySelectorAll('.deputy-item');
        for (let i1 = 0; i1 < partyTags.length; i1++){
            const tag = partyTags[i1];
            tag.addEventListener('click', function() {
                // Toggle active/inactive class for visual feedback
                const wasActive = this.classList.contains('active');

                // If all tags are active or all are inactive we only have this one active
                const allActive = Array.from(partyTags).every(function (t) {
                    return t.classList.contains('active');
                });
                const noneActive = Array.from(partyTags).every(function (t) {
                    return !t.classList.contains('active');
                });

                // If all are active and we deactivate one deactivate all others first
                if (allActive && wasActive) {
                    partyTags.forEach(t => {
                        t.classList.remove('active');
                        t.classList.add('inactive');
                    });
                    // Then activate only this one
                    this.classList.add('active');
                    this.classList.remove('inactive');
                }
                // If none are active and we activate one just activate this one
                else if (noneActive && !wasActive) {
                    this.classList.add('active');
                    this.classList.remove('inactive');
                }
                // Otherwise just toggle this one
                else {
                    this.classList.toggle('active');
                    this.classList.toggle('inactive');
                }

                // Get all active party filters
                const activeParties = Array.from(document.querySelectorAll('.party-tag.active'))
                    .map(tag => tag.dataset.party);

                // If no parties are selected, show all speakers
                const showAll = activeParties.length === 0;

                // Show or hide deputies based on active parties
                for (let i = 0; i < deputyItems.length; i++){
                    const item = deputyItems[i];
                    const deputyParty = item.dataset.party;

                    const isGruene = deputyParty === 'BÜNDNIS 90/DIE GRÜNEN';
                    const isLinke = deputyParty === 'DIE LINKE.';
                    const isOther = deputyParty === 'other' || !deputyParty ||
                        !['CDU', 'SPD', 'FDP', 'BÜNDNIS 90/DIE GRÜNEN', 'DIE LINKE.', 'AfD', 'CSU'].includes(deputyParty);


                    if (showAll) { // If no parties are selected  show all deputies
                        item.style.display = '';
                    }
                    // Otherwise only deputies from selected parties
                    else if ((isOther && activeParties.includes('other')) ||
                        (isGruene && activeParties.includes('BÜNDNIS 90/DIE GRÜNEN')) ||
                        (isLinke && activeParties.includes('DIE LINKE.')) ||
                        (!isOther && !isGruene && !isLinke && activeParties.includes(deputyParty))) {
                        item.style.display = '';
                    } else {
                        item.style.display = 'none';
                    }
                }
            });
        }
        const searchInput = document.getElementById('deputy-search');//For searching
        const searchButton = document.getElementById('search-button');
        /**
         * Searches for deputies by name and filters the display accordingly.
         * This function takes the current search input value, converts it to lowercase,
         * and compares it against each deputy name in the list.
         *
         * If the search term is empty, all deputies will be shown.
         */
        function search() {
            const searchTerm = searchInput.value.toLowerCase();
            for (const item of deputyItems) {
                let deputyName;
                deputyName = item.querySelector('.deputy-name').textContent.toLowerCase();
                if (!searchTerm || deputyName.includes(searchTerm)) {
                    if (item.style.display !== 'none' || !item.hasAttribute('style')) {
                        for (const sElement of item.style.removeProperty('display')) {
                        };
                    }
                } else {
                    item.style.display = 'none';
                }
            }
        }
        searchButton.addEventListener('click', search);
        searchInput.addEventListener('keyup', function(event) {
            if (event.key === 'Enter') {
                search();
            }
        });
    });
</script>
</body>
</html>