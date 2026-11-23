import fs from 'node:fs/promises';
import path from 'node:path';

const OFFICIAL_PORTAL_URL =
  'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/';
const OFFICIAL_RSS_URL =
  'https://www.salute.gov.it/portale/news/RSS_avvisi_richiami_osa.xml';
const PUBLIC_MIRROR_LIST_URL = 'https://richiamialimenti.it/richiami';
const PUBLIC_MIRROR_BASE = 'https://richiamialimenti.it';

const DEFAULT_HEADERS = {
  'User-Agent':
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  'Accept-Language': 'it-IT,it;q=0.9',
};

function sanitizeHttpUrl(rawUrl, fallback) {
  if (typeof rawUrl !== 'string' || !rawUrl.trim()) return fallback;
  try {
    const parsed = new URL(rawUrl.trim());
    if (parsed.protocol === 'https:' || parsed.protocol === 'http:') {
      return parsed.toString();
    }
    return fallback;
  } catch {
    return fallback;
  }
}

function decodeHtml(text) {
  return String(text || '')
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#039;/g, "'")
    .replace(/&#39;/g, "'")
    .replace(/&nbsp;/g, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function classifyRiskCategory(rawText) {
  const s = String(rawText || '').toLowerCase();
  if (
    s.includes('listeria') ||
    s.includes('salmonella') ||
    s.includes('escherichia') ||
    s.includes('e. coli') ||
    s.includes('stec') ||
    s.includes('microbiolog') ||
    s.includes('batter') ||
    s.includes('stafilococ') ||
    s.includes('botulin') ||
    s.includes('campylobacter') ||
    s.includes('epatite') ||
    s.includes('anisakis') ||
    s.includes('muffe')
  ) {
    return 'microbiologico';
  }
  if (
    s.includes('allergen') ||
    s.includes('arachid') ||
    s.includes('nocciole') ||
    s.includes('mandorle') ||
    s.includes('noci') ||
    s.includes('frutta a guscio') ||
    s.includes('glutine') ||
    s.includes('frumento') ||
    s.includes('grano') ||
    s.includes('latte') ||
    s.includes('lattosio') ||
    s.includes('uova') ||
    s.includes('soia') ||
    s.includes('senape') ||
    s.includes('sesamo') ||
    s.includes('solfiti') ||
    s.includes('anidride solforosa') ||
    s.includes('crostacei') ||
    s.includes('molluschi') ||
    s.includes('sedano') ||
    s.includes('lupini')
  ) {
    return 'allergeni';
  }
  if (
    s.includes('vetro') ||
    s.includes('plastica') ||
    s.includes('metall') ||
    s.includes('corpi estranei') ||
    s.includes('corpo estraneo') ||
    s.includes('framment') ||
    s.includes('legno') ||
    s.includes('fisic')
  ) {
    return 'fisico';
  }
  if (
    s.includes('chimic') ||
    s.includes('aflatossin') ||
    s.includes('ocra') ||
    s.includes('micotossin') ||
    s.includes('istamina') ||
    s.includes('ossido di etilene') ||
    s.includes('pesticid') ||
    s.includes('fitosanitar') ||
    s.includes('cadmio') ||
    s.includes('piombo') ||
    s.includes('mercurio') ||
    s.includes('alcaloid') ||
    s.includes('nitrati') ||
    s.includes('migrazione')
  ) {
    return 'chimico';
  }
  return 'altro';
}

function normalizeIsoDate(raw) {
  if (typeof raw === 'string' && raw.trim()) {
    const trimmed = raw.trim();
    const ddmmyyyy = trimmed.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/);
    if (ddmmyyyy) {
      const [, dd, mm, yyyy] = ddmmyyyy;
      const d = new Date(
        `${yyyy}-${mm.padStart(2, '0')}-${dd.padStart(2, '0')}T09:00:00Z`
      );
      if (!Number.isNaN(d.getTime())) return d.toISOString();
    }
    const parsed = new Date(trimmed);
    if (!Number.isNaN(parsed.getTime())) return parsed.toISOString();
  }
  return new Date().toISOString();
}

function splitLotNumbers(rawLot) {
  const cleaned = String(rawLot || '').trim();
  if (!cleaned) return ['Vedi avviso ufficiale'];
  const parts = cleaned
    .split(/[,;\n]+/)
    .map((p) => p.trim())
    .filter((p) => p.length > 0);
  return parts.length > 0 ? parts : [cleaned];
}

async function tryDirectSaluteGovFetch() {
  try {
    const res = await fetch(OFFICIAL_RSS_URL, {
      headers: {
        ...DEFAULT_HEADERS,
        Accept: 'application/rss+xml, application/xml, text/html;q=0.9',
      },
      signal: AbortSignal.timeout(6000),
    });
    if (!res.ok) return null;

    const xml = await res.text();
    if (
      !xml.includes('<rss') ||
      xml.includes('<title>Gcore</title>') ||
      xml.includes('__SBB__')
    ) {
      return null;
    }

    const itemBlocks = [...xml.matchAll(/<item>([\s\S]*?)<\/item>/gi)];
    const parsed = itemBlocks.slice(0, 30).map((match, i) => {
      const block = match[1];
      const title = decodeHtml(
        (block.match(/<title>([\s\S]*?)<\/title>/i) || [])[1] ||
          'Avviso di richiamo'
      );
      const link = sanitizeHttpUrl(
        decodeHtml((block.match(/<link>([\s\S]*?)<\/link>/i) || [])[1] || ''),
        OFFICIAL_PORTAL_URL
      );
      const pubDate = normalizeIsoDate(
        decodeHtml(
          (block.match(/<pubDate>([\s\S]*?)<\/pubDate>/i) || [])[1] || ''
        )
      );
      const desc = decodeHtml(
        (block.match(/<description>([\s\S]*?)<\/description>/i) || [])[1] ||
          title
      );

      return {
        id: `salute-rss-${i + 1}-${pubDate.slice(0, 10)}`,
        publicationDate: pubDate,
        productName: title,
        brand: 'Vedi scheda ufficiale',
        manufacturer: 'Operatore del Settore Alimentare (OSA)',
        lotNumbers: ['Vedi avviso ufficiale'],
        expirationDate: 'Vedi avviso ufficiale',
        packagingUnit: 'Vedi avviso ufficiale',
        reason: desc || title,
        riskCategory: classifyRiskCategory(`${title} ${desc}`),
        instructions:
          'Non consumare il prodotto interessato dal richiamo e restituirlo al punto vendita di acquisto.',
        officialSourceUrl: link,
        imageUrl: null,
      };
    });

    return parsed.length > 0 ? parsed : null;
  } catch {
    return null;
  }
}

async function fetchFromMinistryMirror() {
  const [page1Res, page2Res] = await Promise.all([
    fetch(PUBLIC_MIRROR_LIST_URL, {
      headers: DEFAULT_HEADERS,
      signal: AbortSignal.timeout(10000),
    }),
    fetch(`${PUBLIC_MIRROR_LIST_URL}?page=2`, {
      headers: DEFAULT_HEADERS,
      signal: AbortSignal.timeout(10000),
    }).catch(() => null),
  ]);

  if (!page1Res.ok) {
    throw new Error(`Errore HTTP ${page1Res.status} su ${PUBLIC_MIRROR_LIST_URL}`);
  }

  const page1Html = await page1Res.text();
  const page2Html = page2Res && page2Res.ok ? await page2Res.text() : '';
  const combinedHtml = `${page1Html}\n${page2Html}`;

  const slugMatches = [
    ...new Set(
      [...combinedHtml.matchAll(/href="(\/richiami\/\d+-[^"]+)"/gi)].map((m) => m[1])
    ),
  ].slice(0, 30);

  if (slugMatches.length === 0) {
    throw new Error('Nessun richiamo trovato nella pagina di elenco.');
  }

  const fetchRecallDetail = async (slug) => {
    try {
      const detailUrl = `${PUBLIC_MIRROR_BASE}${slug}`;
      const res = await fetch(detailUrl, {
        headers: DEFAULT_HEADERS,
        signal: AbortSignal.timeout(8000),
      });
      if (!res.ok) return null;
      const html = await res.text();

      const h1Raw = (html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/i) || [])[1] || '';
      const titleFromH1 = decodeHtml(h1Raw).replace(/^Richiamo\s+/i, '').trim();

      const dtPairs = new Map();
      for (const m of html.matchAll(
        /<dt[^>]*>([\s\S]*?)<\/dt>\s*<dd[^>]*>([\s\S]*?)<\/dd>/gi
      )) {
        const key = decodeHtml(m[1]).toLowerCase();
        const val = decodeHtml(m[2]);
        if (key && val && !dtPairs.has(key)) {
          dtPairs.set(key, val);
        }
      }

      const timeMatch = (html.match(/<time[^>]*datetime="([^"]+)"/i) || [])[1];
      const jsonLdDate = (html.match(/"datePublished"\s*:\s*"([^"]+)"/i) || [])[1];
      let pubDate = normalizeIsoDate(
        dtPairs.get('data richiamo') || timeMatch || jsonLdDate
      );
      if (new Date(pubDate).getTime() > Date.now() + 86_400_000 && jsonLdDate) {
        pubDate = normalizeIsoDate(jsonLdDate);
      }

      const brand =
        dtPairs.get('marchio') ||
        decodeHtml(
          (html.match(/a marchio\s*<a[^>]*>([\s\S]*?)<\/a>/i) || [])[1] || ''
        ) ||
        'Marchio non indicato';

      let productName = titleFromH1 || 'Prodotto alimentare richiamato';
      if (
        brand !== 'Marchio non indicato' &&
        productName.length > brand.length + 2 &&
        productName.toLowerCase().endsWith(brand.toLowerCase())
      ) {
        productName = productName
          .slice(0, productName.length - brand.length)
          .trim();
      }

      const producer = dtPairs.get('produttore') || '';
      const site = dtPairs.get('stabilimento') || dtPairs.get('sede produttore') || '';
      const seller = dtPairs.get('venditore') || '';
      const manufacturer =
        [producer, site].filter(Boolean).join(' — ') ||
        seller ||
        'Operatore del Settore Alimentare (OSA)';

      const lotRaw =
        dtPairs.get('lotto di produzione') ||
        dtPairs.get('lotto') ||
        'Vedi avviso ufficiale';
      const expirationDate =
        dtPairs.get('scadenza / tmc') || 'Vedi avviso ufficiale';
      const packagingUnit =
        dtPairs.get('confezione') ||
        dtPairs.get('peso / confezione') ||
        'Vedi avviso ufficiale';

      const reasonSection =
        (
          html.match(
            /Motivo del richiamo[\s\S]*?<\/h2>\s*<div[^>]*>([\s\S]*?)<\/div>/i
          ) || []
        )[1] || '';
      const reason =
        decodeHtml(reasonSection) ||
        'Non conformità segnalata dal Ministero della Salute.';

      const warnSection =
        (
          html.match(
            /Avvertenze[\s\S]*?<\/h2>\s*<div[^>]*>([\s\S]*?)<\/div>/i
          ) || []
        )[1] || '';
      const instructions =
        decodeHtml(warnSection) ||
        'Non consumare il prodotto appartenente ai lotti indicati e restituirlo al punto vendita per il rimborso o la sostituzione.';

      const saluteMatch = (
        html.match(/href="(https?:\/\/[^"]*salute\.gov\.it[^"]*)"/i) || []
      )[1];
      const officialSourceUrl = sanitizeHttpUrl(saluteMatch, OFFICIAL_PORTAL_URL);

      const imgMatch = (
        html.match(/src="(https:\/\/richiamialimenti\.it\/foto\/[^"]+)"/i) || []
      )[1];
      const imageUrl = imgMatch ? sanitizeHttpUrl(imgMatch, '') || null : null;

      const categoryBadgeText = decodeHtml(
        (html.match(/href="\/motivi\/[^"]+"[^>]*>([\s\S]*?)<\/a>/i) || [])[1] || ''
      );

      const idSlug = slug.replace('/richiami/', '');

      return {
        id: `ms-${idSlug}`,
        publicationDate: pubDate,
        productName,
        brand,
        manufacturer,
        lotNumbers: splitLotNumbers(lotRaw),
        expirationDate,
        packagingUnit,
        reason,
        riskCategory: classifyRiskCategory(
          `${categoryBadgeText} ${reason} ${productName}`
        ),
        instructions,
        officialSourceUrl,
        imageUrl,
      };
    } catch {
      return null;
    }
  };

  const firstBatch = await Promise.all(slugMatches.slice(0, 15).map(fetchRecallDetail));
  const secondBatch = await Promise.all(slugMatches.slice(15, 30).map(fetchRecallDetail));
  const items = [...firstBatch, ...secondBatch].filter(Boolean);

  if (items.length === 0) {
    throw new Error('Impossibile estrarre i dettagli dei richiami.');
  }

  items.sort(
    (a, b) =>
      new Date(b.publicationDate).getTime() - new Date(a.publicationDate).getTime()
  );

  const sources = [
    {
      title: 'Ministero della Salute — Avvisi e richiami di prodotti alimentari',
      url: OFFICIAL_PORTAL_URL,
    },
    ...items
      .filter((it) => it.officialSourceUrl !== OFFICIAL_PORTAL_URL)
      .slice(0, 4)
      .map((it) => ({
        title: `${it.productName} (salute.gov.it)`,
        url: it.officialSourceUrl,
      })),
  ];

  return { items, sources };
}

async function main() {
  const outFile = path.resolve(process.argv[2] || 'dist-pages/recalls.json');
  const outDir = path.dirname(outFile);
  await fs.mkdir(outDir, { recursive: true });

  let payload;
  const directItems = await tryDirectSaluteGovFetch();

  if (directItems && directItems.length > 0) {
    payload = {
      items: directItems,
      source: 'salute.gov.it',
      method: 'direct_official',
      syncedAt: new Date().toISOString(),
      sources: [
        {
          title: 'Ministero della Salute — Feed RSS Richiami OSA',
          url: OFFICIAL_RSS_URL,
        },
        {
          title: 'Ministero della Salute — Avvisi e richiami',
          url: OFFICIAL_PORTAL_URL,
        },
      ],
      note: 'Dati acquisiti direttamente dal feed RSS ufficiale di salute.gov.it.',
    };
  } else {
    const mirrored = await fetchFromMinistryMirror();
    payload = {
      items: mirrored.items,
      source: 'salute.gov.it',
      method: 'ministry_mirror',
      syncedAt: new Date().toISOString(),
      sources: mirrored.sources,
      note: 'Avvisi reali e link ufficiali salute.gov.it sincronizzati automaticamente per la consultazione pubblica.',
    };
  }

  await fs.writeFile(outFile, `${JSON.stringify(payload, null, 2)}\n`, 'utf8');

  const indexHtml = `<!doctype html>
<html lang="it">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Feed JSON — Richiami Alimentari IT</title>
    <style>
      body { font-family: system-ui, -apple-system, sans-serif; max-width: 680px; margin: 48px auto; padding: 0 20px; line-height: 1.6; color: #0f172a; }
      code { background: #f1f5f9; padding: 2px 6px; border-radius: 6px; }
      a { color: #0f5c99; }
    </style>
  </head>
  <body>
    <h1>Feed pubblico — Richiami Alimentari IT</h1>
    <p>Ultimo aggiornamento: <strong>${payload.syncedAt}</strong> (${payload.items.length} avvisi).</p>
    <p>Endpoint JSON: <a href="./recalls.json"><code>./recalls.json</code></a></p>
    <p>Fonte pubblica ufficiale: <a href="${OFFICIAL_PORTAL_URL}" rel="noopener noreferrer">Ministero della Salute (salute.gov.it)</a>.</p>
    <p><a href="./privacy.html">Informativa sulla Privacy</a></p>
  </body>
</html>
`;

  const privacyHtml = `<!doctype html>
<html lang="it">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Privacy Policy — Richiami Alimentari IT</title>
    <style>
      body { font-family: system-ui, -apple-system, sans-serif; max-width: 720px; margin: 48px auto; padding: 0 20px; line-height: 1.65; color: #0f172a; }
      h1, h2 { color: #0a416e; }
    </style>
  </head>
  <body>
    <h1>Informativa sulla Privacy — Richiami Alimentari IT</h1>
    <p><strong>Ultimo aggiornamento:</strong> ${payload.syncedAt.slice(0, 10)}</p>
    <p>Richiami Alimentari IT è un'applicazione informativa indipendente e non è affiliata al Ministero della Salute italiano.</p>
    <h2>1. Dati raccolti</h2>
    <p>L'app non richiede registrazione o account e non raccoglie, vende né condivide dati personali, posizione GPS, contatti o identificativi pubblicitari.</p>
    <h2>2. Salvataggio locale sul dispositivo</h2>
    <p>Preferiti, parole chiave monitorate, cache offline degli avvisi, tema e lingua scelta vengono salvati esclusivamente in locale sul dispositivo dell'utente e possono essere cancellati disinstallando l'app.</p>
    <h2>3. Connessioni di rete</h2>
    <p>Per aggiornare gli avvisi pubblici, l'app scarica un file JSON statico privo di tracciamento e consente all'utente di aprire facoltativamente i link ufficiali su salute.gov.it nel browser.</p>
  </body>
</html>
`;

  await Promise.all([
    fs.writeFile(path.join(outDir, 'index.html'), indexHtml, 'utf8'),
    fs.writeFile(path.join(outDir, 'privacy.html'), privacyHtml, 'utf8'),
  ]);

  console.log(
    `Generato ${outFile} con ${payload.items.length} richiami (metodo: ${payload.method}).`
  );
}

main().catch((err) => {
  console.error('Errore generazione recalls.json:', err);
  process.exit(1);
});
