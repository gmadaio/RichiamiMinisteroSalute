import '../models/recall_item.dart';

class MockRecallsRepository {
  static List<RecallItem> getInitialRecalls() {
    final now = DateTime.now();

    return [
      RecallItem(
        id: 'ms-2026-0142',
        publicationDate: now.subtract(const Duration(days: 1)),
        productName: 'Salame Felino IGP Stagionato Artigianale',
        brand: 'Antichi Sapori Parmensi',
        manufacturer: 'Salumificio Val Parma S.r.l. — Langhirano (PR), Via Emilia 48',
        lotNumbers: const ['L261114A', 'L261115B'],
        expirationDate: '18/02/2027 (TMC)',
        packagingUnit: 'Pezzatura intera sottovuoto da 450 g',
        reason:
            'Rilevata presenza di Listeria monocytogenes in campione prelevato in fase di autocontrollo aziendale.',
        riskCategory: RiskCategory.microbiologico,
        instructions:
            'Non consumare il prodotto appartenente ai lotti indicati. Restituire la confezione integra o aperta al punto vendita per sostituzione o rimborso.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0141',
        publicationDate: now.subtract(const Duration(days: 2)),
        productName: 'Biscotti Frollini Integrali con Gocce di Cioccolato',
        brand: 'Forno delle Colline',
        manufacturer: 'Biscottificio Artigiano Dolciaria S.p.A. — Cuneo (CN), Via Savona 112',
        lotNumbers: const ['26318', '26319'],
        expirationDate: '30/09/2027 (TMC)',
        packagingUnit: 'Sacchetto in carta kraft da 350 g',
        reason:
            'Presenza non dichiarata in etichetta dell’allergene arachidi e tracce di nocciole dovuta a contaminazione crociata sulla linea di confezionamento.',
        riskCategory: RiskCategory.allergeni,
        instructions:
            'Le persone allergiche alle arachidi o alla frutta a guscio non devono consumare il prodotto e devono riconsegnarlo al punto vendita.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0140',
        publicationDate: now.subtract(const Duration(days: 4)),
        productName: 'Pesto Genovese Fresco Senza Aglio',
        brand: 'Riviera Verde',
        manufacturer: 'Laboratorio Gastronomico Ligure S.r.l. — Albenga (SV), Reg. Bagnoli 19',
        lotNumbers: const ['PG-1109', 'PG-1110'],
        expirationDate: '04/12/2026',
        packagingUnit: 'Vasetto in vetro da 180 g',
        reason:
            'Possibile presenza di piccoli frammenti di vetro all’interno del vasetto a seguito di anomalia meccanica durante la tappatura.',
        riskCategory: RiskCategory.fisico,
        instructions:
            'Non aprire né consumare il prodotto. Riportare immediatamente il vasetto presso il punto vendita di acquisto per il rimborso anche senza scontrino.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0139',
        publicationDate: now.subtract(const Duration(days: 5)),
        productName: 'Formaggio d’Alpeggio Stagionato a Latte Crudo',
        brand: 'Malga Alta Quota',
        manufacturer: 'Caseificio Cooperativo Valle Stura — Demonte (CN), Borgata Festiona 7',
        lotNumbers: const ['MAQ-0926'],
        expirationDate: '15/01/2027 (TMC)',
        packagingUnit: 'Spicchio porzionato da 300 g circa',
        reason:
            'Sospetta presenza di Escherichia coli produttore di Shiga-tossina (STEC) rilevata nell’ambito del piano regionale di sorveglianza.',
        riskCategory: RiskCategory.microbiologico,
        instructions:
            'Non consumare il formaggio, in particolare per bambini, anziani, donne in gravidanza e soggetti immunodepressi. Restituire al banco gastronomia.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0136',
        publicationDate: now.subtract(const Duration(days: 9)),
        productName: 'Filetti di Tonno Pinna Gialla all’Olio d’Oliva',
        brand: 'Mare Nostrum Selezione',
        manufacturer: 'Conserve Ittiche Tirreno S.r.l. — Vibo Marina (VV), Via Porto 22',
        lotNumbers: const ['TN26291', 'TN26292'],
        expirationDate: '10/10/2029 (TMC)',
        packagingUnit: 'Vaso in vetro da 200 g (sgocciolato 135 g)',
        reason:
            'Superamento dei limiti massimi di istamina consentiti dalla normativa europea (Reg. CE 2073/2005).',
        riskCategory: RiskCategory.chimico,
        instructions:
            'Non consumare il prodotto. L’istamina non viene eliminata dalla cottura. Riconsegnare i vasetti al punto vendita per il rimborso.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0134',
        publicationDate: now.subtract(const Duration(days: 11)),
        productName: 'Spinaci Foglia Tenera Lavati in Busta',
        brand: 'Orto Fresco Quotidiano',
        manufacturer: 'Agricola Padana IV Gamma S.r.l. — Bergamo (BG), Via delle Serre 14',
        lotNumbers: const ['26-308-B', '26-309-A'],
        expirationDate: '27/11/2026',
        packagingUnit: 'Busta flow-pack da 250 g',
        reason:
            'Possibile contaminazione da Salmonella spp. riscontrata su lotto di materia prima agricola.',
        riskCategory: RiskCategory.microbiologico,
        instructions:
            'Non consumare il prodotto crudo. Si raccomanda di non utilizzare le confezioni interessate e di restituirle al punto vendita.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0131',
        publicationDate: now.subtract(const Duration(days: 14)),
        productName: 'Tiramisù Artigianale Monoporzione',
        brand: 'Pasticceria Dolce Vita',
        manufacturer: 'Laboratorio Dolciario Veneto S.r.l. — Padova (PD), Z.I. Sud 88',
        lotNumbers: const ['TIR-4426'],
        expirationDate: '29/11/2026',
        packagingUnit: 'Vaschetta da 2 x 100 g',
        reason:
            'Mancata indicazione in lingua italiana degli allergeni latte, uova e glutine sull’etichetta posteriore.',
        riskCategory: RiskCategory.allergeni,
        instructions:
            'I consumatori allergici o intolleranti a latte, uova o glutine non devono consumare il prodotto e possono restituirlo al punto vendita.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0128',
        publicationDate: now.subtract(const Duration(days: 18)),
        productName: 'Farina di Mais Fioretto per Polenta',
        brand: 'Molino del Borgo',
        manufacturer: 'Molini Riuniti del Nord S.p.A. — Treviso (TV), Via Calmaggiore 105',
        lotNumbers: const ['FM-8821'],
        expirationDate: '31/05/2027 (TMC)',
        packagingUnit: 'Confezione sottovuoto da 1 kg',
        reason:
            'Presenza di aflatossine B1 e totali superiori ai tenori massimi fissati dal Regolamento (UE) 2023/915.',
        riskCategory: RiskCategory.chimico,
        instructions:
            'Non consumare la farina appartenente al lotto FM-8821. Riportare la confezione al rivenditore per la sostituzione.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0125',
        publicationDate: now.subtract(const Duration(days: 22)),
        productName: 'Hamburger di Bovino Adulto Scottona',
        brand: 'Carni Scelte Italia',
        manufacturer: 'Centro Lavorazione Carni Modena S.r.l. — Castelfranco Emilia (MO)',
        lotNumbers: const ['HB261029', 'HB261030'],
        expirationDate: '05/11/2026',
        packagingUnit: 'Confezione ATM da 2 pezzi (240 g)',
        reason:
            'Possibile presenza di piccoli frammenti di plastica rigida blu provenienti da un nastro trasportatore danneggiato.',
        riskCategory: RiskCategory.fisico,
        instructions:
            'Qualora il prodotto fosse stato congelato in ambito domestico, non consumarlo e riconsegnarlo al punto vendita di acquisto.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0121',
        publicationDate: now.subtract(const Duration(days: 26)),
        productName: 'Salsa di Soia Fermentata Tradizionale',
        brand: 'Oriente in Tavola',
        manufacturer: 'Import Alimentare Asia S.r.l. — Milano (MI), Via Mecenate 76',
        lotNumbers: const ['SOY-2608C'],
        expirationDate: '12/08/2028 (TMC)',
        packagingUnit: 'Bottiglia in vetro da 250 ml',
        reason:
            'Mancata dichiarazione in etichetta dell’allergene grano (glutine) nella lista degli ingredienti tradotta in italiano.',
        riskCategory: RiskCategory.allergeni,
        instructions:
            'I soggetti celiaci o allergici al frumento devono evitare il consumo e restituire la bottiglia presso il punto vendita.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0117',
        publicationDate: now.subtract(const Duration(days: 31)),
        productName: 'Mix di Spezie Curry Dolce in Polvere',
        brand: 'Aromi del Mondo',
        manufacturer: 'Spezieria Mediterranea S.r.l. — Genova (GE), Via Cornigliano 33',
        lotNumbers: const ['CUR-2644'],
        expirationDate: '20/11/2027 (TMC)',
        packagingUnit: 'Barattolo richiudibile da 60 g',
        reason:
            'Rilevati residui di ossido di etilene superiori al limite di rilevabilità analitica nella curcuma impiegata come ingrediente.',
        riskCategory: RiskCategory.chimico,
        instructions:
            'Non utilizzare il prodotto per la preparazione di alimenti. Restituire il barattolo al punto vendita per ottenere il rimborso.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
      RecallItem(
        id: 'ms-2026-0112',
        publicationDate: now.subtract(const Duration(days: 36)),
        productName: 'Latte UHT Parzialmente Scremato Microfiltrato',
        brand: 'Cascina Serena',
        manufacturer: 'Latteria Sociale Lombarda — Lodi (LO), Strada Provinciale 23',
        lotNumbers: const ['LU261015'],
        expirationDate: '15/02/2027 (errata stampa: 15/02/2028)',
        packagingUnit: 'Brik Tetra Pak da 1 L',
        reason:
            'Errore di stampa della data di scadenza / termine minimo di conservazione sulla confezione (anno 2028 anziché 2027).',
        riskCategory: RiskCategory.altro,
        instructions:
            'Il prodotto è idoneo al consumo fino al 15/02/2027. Dopo tale data non consumare o restituire al punto vendita per il cambio.',
        officialSourceUrl:
            'https://www.salute.gov.it/new/it/avvisi/avvisi-e-richiami-di-prodotti-alimentari/',
      ),
    ];
  }
}
