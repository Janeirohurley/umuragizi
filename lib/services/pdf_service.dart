import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/currency_service.dart';

class PdfService {
  static Future<void> generateAnimalReport({
    required Animal animal,
    List<Reproduction> repros = const [],
    List<Transaction> transactions = const [],
    String currency = 'USD',
    String locale = 'fr',
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy', locale);
    final rate = CurrencyService.rates[currency] ?? 1.0;
    final symbol = currency == 'BIF' ? 'FBU' : (currency == 'USD' ? '\$' : currency);

    String formatVal(double val) {
      final converted = val * rate;
      return '${converted.toStringAsFixed(currency == 'BIF' ? 0 : 2)} $symbol';
    }
    
    // Calcul financier
    double totalDepenses = 0;
    double totalRevenus = 0;
    for (var tx in transactions) {
      if (tx.type == 'Dépense') totalDepenses += tx.montant;
      else totalRevenus += tx.montant;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('UMURAGIZI', 
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
                    pw.Text('Rapport d\'identification de l\'animal', 
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.Text(dateFormat.format(DateTime.now()), 
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 2, color: PdfColors.purple),
            pw.SizedBox(height: 20),

            // Contenu Principal
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (animal.photoBase64 != null)
                  pw.Container(
                    width: 120,
                    height: 120,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 8,
                      verticalRadius: 8,
                      child: pw.Image(
                        pw.MemoryImage(base64Decode(animal.photoBase64!)),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  )
                else
                  pw.Container(
                    width: 120,
                    height: 120,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Center(child: pw.Text('Pas d\'image')),
                  ),
                
                pw.SizedBox(width: 20),

                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(animal.nom.toUpperCase(), 
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      _buildInfoRow('Espèce', animal.espece),
                      _buildInfoRow('Race', animal.race),
                      _buildInfoRow('Sexe', animal.sexe),
                      _buildInfoRow('Identifiant', animal.identifiant),
                      _buildInfoRow('Âge', animal.ageFormate),
                      _buildInfoRow('Né(e) le', dateFormat.format(animal.dateNaissance)),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Section Finance
            pw.Text('Bilan Financier (${currency})', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Désignation', 'Montant'],
              data: [
                ['Total Dépenses', formatVal(totalDepenses)],
                ['Total Revenus', formatVal(totalRevenus)],
                ['Balance Net', formatVal(totalRevenus - totalDepenses)],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
              cellAlignment: pw.Alignment.centerLeft,
            ),

            pw.SizedBox(height: 30),

            if (animal.sexe == 'Femelle' && repros.isNotEmpty) ...[
              pw.Text('Historique de Reproduction', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Événement', 'Statut'],
                data: repros.map((r) => [
                  dateFormat.format(r.dateEvenement),
                  r.typeEvenement,
                  r.succes ? 'Succès' : 'Échec',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
              ),
            ],

            pw.SizedBox(height: 40),
            
            pw.Center(
              child: pw.Text('Généré par Umuragizi - Votre partenaire d\'élevage intelligent',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Rapport_${animal.nom}.pdf',
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text('$label : ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
