<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reden von ${speaker.firstName} ${speaker.name}</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="/static/index-styles.css">
    <style>
        .speaker-profile {
            display: flex;
            gap: 30px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            padding: 20px;
            margin-bottom: 30px;
            align-items: center;
        }

        .speaker-image {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }

        .speaker-details {
            flex: 1;
        }

        .speaker-name {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .speaker-info {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 15px;
        }

        .info-item {
            display: flex;
            align-items: center;
            color: #666;
        }

        .info-item i {
            margin-right: 8px;
            color: #DA6565;
        }

        .party-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 14px;
            color: white;
            margin-bottom: 10px;
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

        .speeches-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .speech-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            padding: 20px;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .speech-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }

        .speech-date {
            color: #666;
            font-size: 14px;
            margin-bottom: 8px;
        }

        .speech-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 12px;
            color: #333;
        }

        .speech-text {
            color: #666;
            margin-bottom: 15px;
            line-height: 1.5;
        }

        .speech-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #eee;
            font-size: 14px;
            color: #666;
        }

        .speech-link {
            color: #DA6565;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            font-weight: bold;
            transition: color 0.2s;
        }

        .speech-link:hover {
            color: #C45050;
        }

        .speech-link i {
            margin-left: 5px;
        }

        .no-speeches {
            text-align: center;
            padding: 40px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            color: #666;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            margin-bottom: 20px;
            color: #666;
            text-decoration: none;
            font-weight: bold;
        }

        .back-link:hover {
            color: #DA6565;
        }

        .back-link i {
            margin-right: 5px;
        }

        .speeches-count {
            margin-bottom: 20px;
            font-size: 16px;
            color: #666;
        }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-titel">
        <h1><a href="/" style="text-decoration: none; color: inherit;">Multimodal Parliament Explorer</a></h1>
    </div>
    <div class="navbar-links">
        <a href="/visualisierungen" class="nav-link">Visualisierungen</a>
        <a href="/redeportal" class="nav-link red-border active">Redeportal</a>
        <a href="#footer" class="nav-button">Über Projekt</a>
    </div>
</nav>

<div class="container">
    <a href="/redenportal" class="back-link">
        <i class="fas fa-arrow-left"></i> Zurück zur Abgeordnetenliste
    </a>

    <!-- Speaker Profile -->
    <div class="speaker-profile">
        <img src="${speaker.image!" "}" alt="${speaker.firstName} ${speaker.name}" class="speaker-image">
        <div class="speaker-details">
            <div class="speaker-name">
                <#if speaker.title?? && speaker.title != "">
                    ${speaker.title}
                </#if>
                ${speaker.firstName} ${speaker.name}

                <#if speaker.party?? && speaker.party != "">
                    <span class="party-badge party-${speaker.party!'default'}">${speaker.party}</span>
                </#if>
            </div>

            <div class="speaker-info">
                <#if speaker.beruf?? && speaker.beruf != "">
                    <div class="info-item">
                        <i class="fas fa-briefcase"></i> ${speaker.beruf}
                    </div>
                </#if>

                <#if speaker.geburtsdatum??>
                    <div class="info-item">
                        <i class="fas fa-birthday-cake"></i> ${speaker.geburtsdatum?string("dd.MM.yyyy")}
                    </div>
                </#if>

                <#if speaker.geburtsort?? && speaker.geburtsort != "">
                    <div class="info-item">
                        <i class="fas fa-map-marker-alt"></i> ${speaker.geburtsort}
                    </div>
                </#if>

                <#if speaker.akademischertitel?? && speaker.akademischertitel != "">
                    <div class="info-item">
                        <i class="fas fa-graduation-cap"></i> ${speaker.akademischertitel}
                    </div>
                </#if>
            </div>

            <#if speaker.vita?? && speaker.vita != "">
                <div class="speaker-bio">
                    <p>${speaker.vita}</p>
                </div>
            </#if>
        </div>
    </div>

    <!-- Speeches List -->
    <h2>Parlamentsreden</h2>
    <div class="speeches-count">
        <#if speeches?size == 0>
            Keine Reden gefunden.
        <#elseif speeches?size == 1>
            1 Rede gefunden.
        <#else>
            ${speeches?size} Reden gefunden.
        </#if>
    </div>

    <#if speeches?size == 0>
        <div class="no-speeches">
            <p>Es wurden keine Reden für diesen Abgeordneten gefunden.</p>
            <p>Versuchen Sie es später erneut oder wählen Sie einen anderen Abgeordneten aus.</p>
        </div>
    <#else>
        <div class="speeches-list">
            <#list speeches as speech>
                <div class="speech-card">
                    <#if speech.protocol?? && speech.protocol.date??>
                        <div class="speech-date">
                            <i class="far fa-calendar-alt"></i> ${(speech.protocol.date?number_to_datetime)?string("dd.MM.yyyy")}
                        </div>
                    </#if>

                    <div class="speech-title">
                        <#if speech.agenda?? && speech.agenda.title??>
                            ${speech.agenda.title}
                        <#elseif speech.protocol?? && speech.protocol.title??>
                            ${speech.protocol.title}
                        <#else>
                            Rede im Bundestag
                        </#if>
                    </div>

                    <div class="speech-text">
                        <#if speech.text??>
                            <#if speech.text?length gt 200>
                                ${speech.text?substring(0, 200)}...
                            <#else>
                                ${speech.text}
                            </#if>
                        </#if>
                    </div>

                    <div class="speech-meta">
                        <div class="speech-protocol">
                            <#if speech.protocol?? && speech.protocol.index??>
                                Protokoll ${speech.protocol.index}
                            </#if>

                            <#if speech.agenda?? && speech.agenda.index??>
                                | Tagesordnungspunkt ${speech.agenda.index}
                            </#if>
                        </div>

                        <a href="/redeportal/speech/${speech.id}" class="speech-link">
                            Vollständige Rede ansehen <i class="fas fa-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </#list>
        </div>
    </#if>
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