import 'package:flutter/material.dart';

import '../models/recall_item.dart';
import '../providers/recall_providers.dart';

class AppLanguageOption {
  const AppLanguageOption({
    required this.code,
    required this.shortLabel,
    required this.nativeLabel,
  });

  final String code;
  final String shortLabel;
  final String nativeLabel;
}

class AppLocalizations {
  const AppLocalizations(this.languageCode);

  final String languageCode;

  static const supportedLocales = [
    Locale('it'),
    Locale('en'),
    Locale('es'),
    Locale('de'),
  ];

  static const languageOptions = [
    AppLanguageOption(code: 'it', shortLabel: 'IT', nativeLabel: 'Italiano'),
    AppLanguageOption(code: 'en', shortLabel: 'EN', nativeLabel: 'English'),
    AppLanguageOption(code: 'es', shortLabel: 'ES', nativeLabel: 'Español'),
    AppLanguageOption(code: 'de', shortLabel: 'DE', nativeLabel: 'Deutsch'),
  ];

  static AppLocalizations of(BuildContext context) {
    final code = Localizations.maybeLocaleOf(context)?.languageCode ?? 'it';
    if (code == 'en' || code == 'es' || code == 'de') {
      return AppLocalizations(code);
    }
    return const AppLocalizations('it');
  }

  String get dateLocale {
    switch (languageCode) {
      case 'en':
        return 'en_GB';
      case 'es':
        return 'es_ES';
      case 'de':
        return 'de_DE';
      default:
        return 'it_IT';
    }
  }

  String _pick({
    required String it,
    required String en,
    required String es,
    required String de,
  }) {
    switch (languageCode) {
      case 'en':
        return en;
      case 'es':
        return es;
      case 'de':
        return de;
      default:
        return it;
    }
  }

  String categoryLabel(RiskCategory cat) {
    switch (cat) {
      case RiskCategory.microbiologico:
        return _pick(it: 'Microbiologico', en: 'Microbiological', es: 'Microbiológico', de: 'Mikrobiologisch');
      case RiskCategory.allergeni:
        return _pick(it: 'Allergeni', en: 'Allergens', es: 'Alérgenos', de: 'Allergene');
      case RiskCategory.chimico:
        return _pick(it: 'Chimico', en: 'Chemical', es: 'Químico', de: 'Chemisch');
      case RiskCategory.fisico:
        return _pick(it: 'Fisico', en: 'Physical', es: 'Físico', de: 'Physikalisch');
      case RiskCategory.altro:
        return _pick(it: 'Altro', en: 'Other', es: 'Otro', de: 'Sonstige');
    }
  }

  String timeRangeLabel(TimeRangeFilter filter) {
    switch (filter) {
      case TimeRangeFilter.all:
        return allLabel;
      case TimeRangeFilter.last7Days:
        return _pick(it: '7 giorni', en: '7 days', es: '7 días', de: '7 Tage');
      case TimeRangeFilter.last30Days:
        return _pick(it: '30 giorni', en: '30 days', es: '30 días', de: '30 Tage');
    }
  }

  String get appTitle => 'Richiami Alimentari IT';
  String get navHome => _pick(it: 'Richiami', en: 'Recalls', es: 'Alertas', de: 'Rückrufe');
  String get navWatchlist => _pick(it: 'Monitora', en: 'Watchlist', es: 'Seguir', de: 'Merkliste');
  String get navInfo => 'Info';
  String get newBadge => _pick(it: 'NUOVO', en: 'NEW', es: 'NUEVO', de: 'NEU');
  String get allLabel => _pick(it: 'Tutti', en: 'All', es: 'Todos', de: 'Alle');
  String get searchHint => _pick(
        it: 'Cerca prodotto, marca, lotto o produttore',
        en: 'Search product, brand, lot or producer',
        es: 'Buscar producto, marca, lote o fabricante',
        de: 'Produkt, Marke, Charge oder Hersteller suchen',
      );
  String get clearSearch => _pick(it: 'Cancella ricerca', en: 'Clear search', es: 'Borrar búsqueda', de: 'Suche löschen');
  String get lotCheckTooltip => _pick(it: 'Controllo rapido lotto', en: 'Quick lot check', es: 'Comprobar lote', de: 'Chargenprüfung');
  String get lotInputHint => _pick(it: 'Inserisci il codice lotto (es. L261114A)', en: 'Enter lot code (e.g. L261114A)', es: 'Introduce lote (ej. L261114A)', de: 'Chargencode eingeben (z. B. L261114A)');
  String get lotNoMatch => _pick(
        it: 'Nessuna corrispondenza trovata tra gli avvisi caricati.',
        en: 'No match found among loaded recalls.',
        es: 'No se encontraron coincidencias entre los avisos cargados.',
        de: 'Keine Übereinstimmung in den geladenen Rückrufen gefunden.',
      );
  String get periodLabel => _pick(it: 'Periodo:', en: 'Period:', es: 'Período:', de: 'Zeitraum:');
  String get offlineCacheNotice => _pick(
        it: 'Modalità offline · Elenco salvato in cache',
        en: 'Offline mode · Cached recall list',
        es: 'Sin conexión · Lista en caché local',
        de: 'Offline-Modus · Lokaler Cache',
      );
  String offlineSavedOn(String dt) => _pick(
        it: 'Modalità offline · Dati salvati il $dt',
        en: 'Offline mode · Saved on $dt',
        es: 'Sin conexión · Guardado el $dt',
        de: 'Offline-Modus · Gespeichert am $dt',
      );
  String get retry => _pick(it: 'Riprova', en: 'Retry', es: 'Reintentar', de: 'Erneut');
  String get resetFilters => _pick(it: 'Azzera filtri', en: 'Reset filters', es: 'Restablecer filtros', de: 'Filter zurücksetzen');
  String get emptyTitle => _pick(it: 'Nessun richiamo trovato', en: 'No recalls found', es: 'No se encontraron alertas', de: 'Keine Rückrufe gefunden');
  String get emptySubtitle => _pick(
        it: 'Prova a modificare i termini di ricerca, il periodo o il filtro di categoria.',
        en: 'Try adjusting your search terms, period, or risk filter.',
        es: 'Prueba ajustando tu búsqueda, el período o el filtro de riesgo.',
        de: 'Passe Suchbegriff, Zeitraum oder Risikofilter an.',
      );
  String get loadErrorTitle => _pick(
        it: 'Impossibile caricare gli avvisi',
        en: 'Unable to load notices',
        es: 'No se pudieron cargar los avisos',
        de: 'Meldungen konnten nicht geladen werden',
      );
  String unseenBanner(int count) => _pick(
        it: '$count nuovi richiami dall’ultimo controllo',
        en: '$count new recalls since last check',
        es: '$count nuevas alertas desde tu última visita',
        de: '$count neue Rückrufe seit letztem Besuch',
      );
  String get markSeen => _pick(it: 'Segna visti', en: 'Mark seen', es: 'Marcar vistos', de: 'Gelesen');
  String keywordMatches(int count) => _pick(
        it: '$count con parole chiave',
        en: '$count matching keywords',
        es: '$count con palabras clave',
        de: '$count mit Suchwörtern',
      );
  String get pinTop => _pick(it: 'In cima', en: 'Pin top', es: 'Arriba', de: 'Oben');
  String get onlyThese => _pick(it: 'Solo questi', en: 'Only these', es: 'Solo estos', de: 'Nur diese');
  String loadMore(int remaining) => _pick(
        it: 'Carica altri richiami ($remaining rimanenti)',
        en: 'Load more recalls ($remaining left)',
        es: 'Cargar más alertas ($remaining restantes)',
        de: 'Weitere laden ($remaining übrig)',
      );
  String matchesPrefix(String kw) => _pick(
        it: 'Corrisponde a: $kw',
        en: 'Matches: $kw',
        es: 'Coincide con: $kw',
        de: 'Treffer: $kw',
      );
  String lotsLine(String lots) => _pick(
        it: 'Lotti: $lots',
        en: 'Lots: $lots',
        es: 'Lotes: $lots',
        de: 'Chargen: $lots',
      );
  String get chartTitleRisk => _pick(it: 'Distribuzione per rischio', en: 'Risk distribution', es: 'Distribución de riesgos', de: 'Risikoverteilung');
  String get chartTitleTrend => _pick(it: 'Andamento pubblicazioni', en: 'Publication trend', es: 'Tendencia de avisos', de: 'Veröffentlichungstrend');
  String get chartTabRisk => _pick(it: 'Rischio', en: 'Risk', es: 'Riesgo', de: 'Risiko');
  String get chartTabTrend => _pick(it: 'Trend', en: 'Trend', es: 'Tendencia', de: 'Trend');
  String get chartNoticesWord => _pick(it: 'avvisi', en: 'notices', es: 'avisos', de: 'Meldungen');
  String get chartTapFilter => _pick(it: 'tocca per filtrare', en: 'tap to filter', es: 'toca para filtrar', de: 'zum Filtern tippen');
  String get chartRecentSeries => _pick(it: 'serie recente', en: 'recent timeline', es: 'serie reciente', de: 'Zeitverlauf');

  String get detailTitle => _pick(it: 'Dettaglio richiamo', en: 'Recall details', es: 'Detalle de la alerta', de: 'Rückrufdetails');
  String publishedOn(String dt) => _pick(it: 'Pubblicato il $dt', en: 'Published on $dt', es: 'Publicado el $dt', de: 'Veröffentlicht am $dt');
  String get lotsUpper => _pick(it: 'LOTTI INTERESSATI', en: 'AFFECTED LOTS', es: 'LOTES AFECTADOS', de: 'BETROFFENE CHARGEN');
  String get expirationUpper => _pick(it: 'SCADENZA / TMC', en: 'EXPIRATION / BBD', es: 'CADUCIDAD / CONS. PREF.', de: 'VERBRAUCHSDATUM / MHD');
  String get reasonUpper => _pick(it: 'MOTIVO DEL RICHIAMO', en: 'REASON FOR RECALL', es: 'MOTIVO DE LA RETIRADA', de: 'RÜCKRUFGRUND');
  String get commercialId => _pick(it: 'Identificazione commerciale', en: 'Commercial identification', es: 'Identificación comercial', de: 'Handelsangaben');
  String get producerLabel => _pick(it: 'Produttore / OSA', en: 'Producer / FBO', es: 'Fabricante / Operador', de: 'Hersteller / Betrieb');
  String get packagingLabel => _pick(it: 'Confezione / Peso', en: 'Package / Weight', es: 'Envase / Peso', de: 'Packung / Gewicht');
  String get whatToDo => _pick(it: 'Cosa fare', en: 'What to do', es: 'Qué hacer', de: 'Was tun');
  String get openOfficial => _pick(it: 'Apri avviso ufficiale su salute.gov.it', en: 'Open official notice on salute.gov.it', es: 'Abrir aviso oficial en salute.gov.it', de: 'Offizielle Meldung auf salute.gov.it öffnen');
  String get openPortalError => _pick(it: 'Impossibile aprire il portale salute.gov.it', en: 'Could not open salute.gov.it', es: 'No se pudo abrir salute.gov.it', de: 'salute.gov.it konnte nicht geöffnet werden');
  String get shareTooltip => _pick(it: 'Condividi', en: 'Share', es: 'Compartir', de: 'Teilen');

  String get watchlistTitle => _pick(it: 'Monitora & Preferiti', en: 'Watchlist & Saved', es: 'Seguimiento y Favoritos', de: 'Merkliste & Favoriten');
  String get savedKeywordsTitle => _pick(it: 'Parole chiave salvate', en: 'Saved keywords', es: 'Palabras clave guardadas', de: 'Gespeicherte Suchwörter');
  String get savedKeywordsDesc => _pick(
        it: 'Evidenzia automaticamente nella Home gli avvisi che contengono allergeni, ingredienti o marche di tuo interesse.',
        en: 'Automatically highlights recalls on the Home tab containing allergens, ingredients, or brands you monitor.',
        es: 'Destaca automáticamente en Inicio las alertas que contengan alérgenos, ingredientes o marcas de tu interés.',
        de: 'Hebt auf der Startseite automatisch Rückrufe mit relevanten Allergenen, Zutaten oder Marken hervor.',
      );
  String get keywordInputHint => _pick(
        it: 'Es. latte, uova, salame, glutine...',
        en: 'E.g. milk, eggs, salami, gluten...',
        es: 'Ej. leche, huevos, salami, gluten...',
        de: 'Z. B. Milch, Eier, Salami, Gluten...',
      );
  String get noKeywords => _pick(
        it: 'Nessuna parola chiave attiva al momento.',
        en: 'No active keywords right now.',
        es: 'Sin palabras clave activas.',
        de: 'Derzeit keine aktiven Suchwörter.',
      );
  String get savedRecallsTitle => _pick(it: 'Richiami salvati', en: 'Saved recalls', es: 'Alertas guardadas', de: 'Gespeicherte Rückrufe');
  String get savedRecallsDesc => _pick(
        it: 'Disponibili localmente anche senza connessione Internet.',
        en: 'Available locally even without an internet connection.',
        es: 'Disponibles localmente incluso sin conexión a Internet.',
        de: 'Auch ohne Internetverbindung lokal abrufbar.',
      );
  String get noSavedTitle => _pick(it: 'Nessun richiamo salvato', en: 'No saved recalls', es: 'Sin alertas guardadas', de: 'Keine gespeicherten Rückrufe');
  String get noSavedDesc => _pick(
        it: 'Tocca il segnalibro su una scheda per conservarla qui offline.',
        en: 'Tap the bookmark icon on any recall card to save it offline.',
        es: 'Toca el marcador en cualquier alerta para guardarla aquí.',
        de: 'Tippe auf das Lesezeichen einer Meldung, um sie offline zu sichern.',
      );

  String get infoTitle => _pick(it: 'Info & Avvertenze', en: 'Info & Notices', es: 'Info y Avisos', de: 'Info & Hinweise');
  String get disclaimerTitle => _pick(it: 'Avvertenza importante (Disclaimer)', en: 'Important Notice (Disclaimer)', es: 'Aviso importante (Disclaimer)', de: 'Wichtiger Hinweis (Disclaimer)');
  String get disclaimerBody => _pick(
        it: 'Richiami Alimentari IT è uno strumento informativo indipendente che aggrega avvisi pubblici diffusi dal Ministero della Salute italiano. Questa applicazione non è affiliata, sponsorizzata né gestita da alcun ente governativo. Per ogni verifica definitiva fai sempre riferimento ai bollettini ufficiali pubblicati su salute.gov.it.',
        en: 'Richiami Alimentari IT is an independent informational tool aggregating public notices from the Italian Ministry of Health. It is not affiliated with, sponsored, or operated by any government agency. Always verify official bulletins on salute.gov.it.',
        es: 'Richiami Alimentari IT es una herramienta informativa independiente que recopila avisos públicos del Ministerio de Sanidad de Italia. No está afiliada ni gestionada por ningún organismo oficial. Consulta siempre salute.gov.it.',
        de: 'Richiami Alimentari IT ist ein unabhängiges Informationswerkzeug für öffentliche Meldungen des italienischen Gesundheitsministeriums. Es besteht keine Zugehörigkeit zu einer Behörde. Maßgeblich sind stets die offiziellen Hinweise auf salute.gov.it.',
      );
  String get appearanceTitle => _pick(it: 'Aspetto dell’applicazione', en: 'App appearance', es: 'Aspecto de la app', de: 'Erscheinungsbild');
  String get themeSystem => _pick(it: 'Sistema', en: 'System', es: 'Sistema', de: 'System');
  String get themeLight => _pick(it: 'Chiaro', en: 'Light', es: 'Claro', de: 'Hell');
  String get themeDark => _pick(it: 'Scuro', en: 'Dark', es: 'Oscuro', de: 'Dunkel');
  String get languageTitle => _pick(it: 'Lingua dell’app', en: 'App language', es: 'Idioma de la app', de: 'App-Sprache');
  String get guideTitle => _pick(it: 'Come leggere Lotto e Scadenza / TMC', en: 'How to read Lot & Expiration / BBD', es: 'Cómo leer Lote y Caducidad', de: 'Charge & MHD / Verbrauchsdatum');
  String get lotBulletTitle => _pick(it: 'Numero di lotto (L)', en: 'Lot number (L)', es: 'Número de lote (L)', de: 'Chargennummer (L)');
  String get lotBulletBody => _pick(
        it: 'Identifica un gruppo omogeneo di unità prodotte nelle stesse condizioni. È spesso preceduto dalla lettera "L" vicino al codice a barre o sul tappo.',
        en: 'Identifies units produced under identical conditions, often printed after "L" near the barcode or cap.',
        es: 'Identifica unidades producidas en las mismas condiciones; suele ir tras la letra "L" junto al código de barras.',
        de: 'Kennzeichnet eine einheitlich produzierte Charge; oft hinter „L“ nahe dem Barcode oder Deckel.',
      );
  String get expBulletTitle => _pick(it: 'Data di scadenza ("Da consumare entro")', en: 'Use-by date ("Da consumare entro")', es: 'Fecha de caducidad ("Da consumare entro")', de: 'Verbrauchsdatum ("Da consumare entro")');
  String get expBulletBody => _pick(
        it: 'Indicata sui prodotti rapidamente deperibili (freschi). Indica il limite tassativo oltre il quale l’alimento non deve essere consumato.',
        en: 'Strict safety deadline for perishable fresh foods: do not consume past this date.',
        es: 'Límite estricto para alimentos frescos perecederos: no consumir después de esa fecha.',
        de: 'Strenge Frist für leicht verderbliche Frischeprodukte: danach nicht mehr verzehren.',
      );
  String get tmcBulletTitle => _pick(it: 'TMC ("Da consumarsi preferibilmente entro")', en: 'Best Before ("Da consumarsi preferibilmente entro")', es: 'Consumo preferente ("Da consumarsi preferibilmente entro")', de: 'MHD ("Da consumarsi preferibilmente entro")');
  String get tmcBulletBody => _pick(
        it: 'Termine Minimo di Conservazione: indica fino a quando il prodotto conserva le sue proprietà specifiche se conservato correttamente.',
        en: 'Minimum durability date indicating how long optimal quality is preserved under proper storage.',
        es: 'Indica hasta cuándo el alimento conserva sus propiedades óptimas si se almacena bien.',
        de: 'Gibt an, bis wann das Produkt bei sachgemäßer Lagerung seine optimale Qualität behält.',
      );
  String get sourcePrivacyTitle => _pick(it: 'Fonte dati e Privacy', en: 'Data source & Privacy', es: 'Fuente de datos y Privacidad', de: 'Datenquelle & Datenschutz');
  String get sourcePrivacyBody => _pick(
        it: 'Tutti gli avvisi rimandano al portale ufficiale salute.gov.it. Le parole chiave monitorate, i richiami salvati e la cache offline restano memorizzati esclusivamente sul tuo dispositivo senza tracciamento né account.',
        en: 'All notices link to the official salute.gov.it portal. Monitored keywords, bookmarks, and offline cache stay strictly on your device with zero tracking.',
        es: 'Todos los avisos enlazan con salute.gov.it. Palabras clave, favoritos y caché permanecen solo en tu dispositivo sin rastreo.',
        de: 'Alle Meldungen verweisen auf salute.gov.it. Suchwörter, Favoriten und Cache bleiben ohne Tracking lokal auf deinem Gerät.',
      );
  String get visitPortal => _pick(it: 'Visita portale salute.gov.it', en: 'Visit salute.gov.it', es: 'Visitar salute.gov.it', de: 'salute.gov.it besuchen');
}
