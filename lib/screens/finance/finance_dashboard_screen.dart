import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import 'transaction_form_screen.dart';
import '../../models/models.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  String _periodeSelectionnee = 'Tous'; // 'Tous', 'Ce mois', 'Cette année'

  List<Transaction> _filtrerTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    if (_periodeSelectionnee == 'Ce mois') {
      return transactions.where((tx) => tx.date.month == now.month && tx.date.year == now.year).toList();
    } else if (_periodeSelectionnee == 'Cette année') {
      return transactions.where((tx) => tx.date.year == now.year).toList();
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        title: Text(
          'Comptabilité',
          style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimaryOf(context)),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          if (financeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple));
          }

          final transactionsFiltrees = _filtrerTransactions(financeProvider.transactions);
          
          double totalDepenses = 0;
          double totalRevenus = 0;
          for (var tx in transactionsFiltrees) {
            if (tx.type == 'Dépense') totalDepenses += tx.montant;
            else totalRevenus += tx.montant;
          }
          final solde = totalRevenus - totalDepenses;
          final isPositif = solde >= 0;

          return ListView(
            padding: EdgeInsets.all(AppTheme.spacingXLarge),
            children: [
              // Sélecteur de Période
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tous'),
                    SizedBox(width: AppTheme.spacingSmall),
                    _buildFilterChip('Ce mois'),
                    SizedBox(width: AppTheme.spacingSmall),
                    _buildFilterChip('Cette année'),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingLarge),

              // Vue d'ensemble
              CustomCard(
                padding: EdgeInsets.all(AppTheme.spacingXLarge),
                child: Column(
                  children: [
                    Text('Balance Période', style: AppTheme.sectionSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                    SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      '${isPositif ? '+' : ''}${solde.toStringAsFixed(2)} \$',
                      style: AppTheme.pageTitle.copyWith(
                        color: isPositif ? AppTheme.successGreen : AppTheme.errorRed,
                        fontSize: 34,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetric(
                            context,
                            'Revenus',
                            totalRevenus,
                            AppTheme.successGreen,
                            Icons.arrow_upward,
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppTheme.surfaceColorOf(context)),
                        Expanded(
                          child: _buildMetric(
                            context,
                            'Dépenses',
                            totalDepenses,
                            AppTheme.errorRed,
                            Icons.arrow_downward,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppTheme.spacingXLarge),
              
              // Graphique
              if (transactionsFiltrees.isNotEmpty) ...[
                Text('Dépenses par Catégorie', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                SizedBox(height: AppTheme.spacingMedium),
                CustomCard(
                  padding: EdgeInsets.all(AppTheme.spacingMedium),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: _generateChartData(transactionsFiltrees),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingXLarge),
              ],

              // Historique
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transactions', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryPurple, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionFormScreen()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingSmall),
              
              if (transactionsFiltrees.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXXLarge),
                    child: Text('Aucune transaction sur cette période.', 
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondaryOf(context))),
                  ),
                )
              else
                ...transactionsFiltrees.map((tx) {
                  final isRevenu = tx.type == 'Revenu';
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
                    child: CustomCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isRevenu ? AppTheme.successGreen.withValues(alpha: 0.1) : AppTheme.errorRed.withValues(alpha: 0.1),
                          child: Icon(
                            isRevenu ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isRevenu ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                        ),
                        title: Text(tx.categorie, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                        subtitle: Text(DateFormat('dd MMMM yyyy').format(tx.date)),
                        trailing: Text(
                          '${isRevenu ? '+' : '-'}${tx.montant.toStringAsFixed(0)} \$',
                          style: TextStyle(
                            color: isRevenu ? AppTheme.successGreen : AppTheme.errorRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TransactionFormScreen(transaction: tx)),
                          );
                        },
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _periodeSelectionnee == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _periodeSelectionnee = label;
          });
        }
      },
      selectedColor: AppTheme.primaryPurple,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.primaryPurple),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildMetric(BuildContext context, String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context))),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)} \$',
          style: AppTheme.sectionTitle.copyWith(color: color),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generateChartData(List<Transaction> transactions) {
    final Map<String, double> categories = {};
    for (var tx in transactions) {
      if (tx.type == 'Dépense') {
        categories[tx.categorie] = (categories[tx.categorie] ?? 0) + tx.montant;
      }
    }

    if (categories.isEmpty) return [PieChartSectionData(color: Colors.grey, value: 1, title: '')];

    final colors = [AppTheme.errorRed, AppTheme.warningOrange, AppTheme.primaryPurple, AppTheme.infoBlue, AppTheme.lightPurple];
    int colorIndex = 0;

    return categories.entries.map((e) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '\$${e.value.toStringAsFixed(0)}',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}
