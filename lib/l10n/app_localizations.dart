import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rn.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('rn'),
    Locale('sw')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Umuragizi'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @animals.
  ///
  /// In fr, this message translates to:
  /// **'Animaux'**
  String get animals;

  /// No description provided for @finance.
  ///
  /// In fr, this message translates to:
  /// **'Finances'**
  String get finance;

  /// No description provided for @reproduction.
  ///
  /// In fr, this message translates to:
  /// **'Reproduction'**
  String get reproduction;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languagern.
  ///
  /// In fr, this message translates to:
  /// **'Kirundi'**
  String get languagern;

  /// No description provided for @languagefr.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languagefr;

  /// No description provided for @languageen.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get languageen;

  /// No description provided for @languagesw.
  ///
  /// In fr, this message translates to:
  /// **'Swahili'**
  String get languagesw;

  /// No description provided for @currency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get currency;

  /// No description provided for @currencybif.
  ///
  /// In fr, this message translates to:
  /// **'Franc Burundais'**
  String get currencybif;

  /// No description provided for @currencyusd.
  ///
  /// In fr, this message translates to:
  /// **'Dollar Américain'**
  String get currencyusd;

  /// No description provided for @currencykes.
  ///
  /// In fr, this message translates to:
  /// **'Shilling Kenyan'**
  String get currencykes;

  /// No description provided for @currencyeur.
  ///
  /// In fr, this message translates to:
  /// **'Euro'**
  String get currencyeur;

  /// No description provided for @totalAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Total Animaux'**
  String get totalAnimals;

  /// No description provided for @gestations.
  ///
  /// In fr, this message translates to:
  /// **'Gestations'**
  String get gestations;

  /// No description provided for @expenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get expenses;

  /// No description provided for @revenues.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get revenues;

  /// No description provided for @netInvestment.
  ///
  /// In fr, this message translates to:
  /// **'Investissement Net'**
  String get netInvestment;

  /// No description provided for @addAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un Animal'**
  String get addAnimal;

  /// No description provided for @editAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'Animal'**
  String get editAnimal;

  /// No description provided for @deleteAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'Animal'**
  String get deleteAnimal;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la suppression'**
  String get confirmDelete;

  /// No description provided for @irreversibleAction.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get irreversibleAction;

  /// No description provided for @noData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible'**
  String get noData;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher...'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all;

  /// No description provided for @month.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get month;

  /// No description provided for @year.
  ///
  /// In fr, this message translates to:
  /// **'Cette année'**
  String get year;

  /// No description provided for @synchronization.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get synchronization;

  /// No description provided for @dataManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des Données'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données'**
  String get exportData;

  /// No description provided for @restoreData.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer les données'**
  String get restoreData;

  /// No description provided for @syncNow.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser maintenant'**
  String get syncNow;

  /// No description provided for @successSync.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation réussie'**
  String get successSync;

  /// No description provided for @successRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restauration réussie'**
  String get successRestore;

  /// No description provided for @statistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statistics;

  /// No description provided for @global.
  ///
  /// In fr, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @byCategory.
  ///
  /// In fr, this message translates to:
  /// **'Par catégorie'**
  String get byCategory;

  /// No description provided for @byAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Par animal'**
  String get byAnimal;

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get hello;

  /// No description provided for @overview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get overview;

  /// No description provided for @late.
  ///
  /// In fr, this message translates to:
  /// **'Retard'**
  String get late;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Fait'**
  String get done;

  /// No description provided for @tasks.
  ///
  /// In fr, this message translates to:
  /// **'Tâches'**
  String get tasks;

  /// No description provided for @see.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get see;

  /// No description provided for @seeMore.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get seeMore;

  /// No description provided for @allDone.
  ///
  /// In fr, this message translates to:
  /// **'Tout est fait !'**
  String get allDone;

  /// No description provided for @species.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get species;

  /// No description provided for @noAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal'**
  String get noAnimal;

  /// No description provided for @stats.
  ///
  /// In fr, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder toutes vos données'**
  String get exportDataSubtitle;

  /// No description provided for @importData.
  ///
  /// In fr, this message translates to:
  /// **'Importer les données'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer depuis un fichier'**
  String get importDataSubtitle;

  /// No description provided for @backupDrive.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder sur Drive'**
  String get backupDrive;

  /// No description provided for @backupDriveSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser vos données'**
  String get backupDriveSubtitle;

  /// No description provided for @restoreDrive.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer depuis Drive'**
  String get restoreDrive;

  /// No description provided for @restoreDriveSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Récupérer vos données sauvegardées'**
  String get restoreDriveSubtitle;

  /// No description provided for @preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @themeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Clair ou sombre'**
  String get themeSubtitle;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @application.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Version et informations'**
  String get aboutSubtitle;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearance;

  /// No description provided for @exportSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Données exportées avec succès'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'export'**
  String get exportError;

  /// No description provided for @importSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Données importées avec succès'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'import'**
  String get importError;

  /// No description provided for @driveConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connecté à Google Drive'**
  String get driveConnected;

  /// No description provided for @driveDisconnected.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecté de Google Drive'**
  String get driveDisconnected;

  /// No description provided for @driveBackupSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde Google Drive réussie'**
  String get driveBackupSuccess;

  /// No description provided for @driveBackupError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de sauvegarde'**
  String get driveBackupError;

  /// No description provided for @driveRestoreSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Restauration Google Drive réussie'**
  String get driveRestoreSuccess;

  /// No description provided for @driveNoBackup.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sauvegarde trouvée'**
  String get driveNoBackup;

  /// No description provided for @appDescription.
  ///
  /// In fr, this message translates to:
  /// **'Application de gestion d\'élevage'**
  String get appDescription;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @lastSync.
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchronisation: '**
  String get lastSync;

  /// No description provided for @syncEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation activée'**
  String get syncEnabled;

  /// No description provided for @syncDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Activer la synchronisation cloud'**
  String get syncDisabled;

  /// No description provided for @pinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code PIN'**
  String get pinTitle;

  /// No description provided for @pinSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce code est requis pour accéder à l\'application'**
  String get pinSubtitle;

  /// No description provided for @pinError.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN incorrect'**
  String get pinError;

  /// No description provided for @setPin.
  ///
  /// In fr, this message translates to:
  /// **'Définir le code PIN'**
  String get setPin;

  /// No description provided for @changePin.
  ///
  /// In fr, this message translates to:
  /// **'Changer le code PIN'**
  String get changePin;

  /// No description provided for @removePin.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le code PIN'**
  String get removePin;

  /// No description provided for @confirmPin.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le code PIN'**
  String get confirmPin;

  /// No description provided for @enterPin.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code PIN'**
  String get enterPin;

  /// No description provided for @pinSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN défini avec succès'**
  String get pinSuccess;

  /// No description provided for @pinChangeSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN changé avec succès'**
  String get pinChangeSuccess;

  /// No description provided for @pinRemoveSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN supprimé avec succès'**
  String get pinRemoveSuccess;

  /// No description provided for @pinMismatchError.
  ///
  /// In fr, this message translates to:
  /// **'Les codes PIN ne correspondent pas'**
  String get pinMismatchError;

  /// No description provided for @pinEmptyError.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN ne peut pas être vide'**
  String get pinEmptyError;

  /// No description provided for @pinLengthError.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN doit comporter au moins 4 chiffres'**
  String get pinLengthError;

  /// No description provided for @pinNumericError.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN doit être composé uniquement de chiffres'**
  String get pinNumericError;

  /// No description provided for @pinConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le code PIN'**
  String get pinConfirm;

  /// No description provided for @pinConfirmSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez à nouveau votre code PIN'**
  String get pinConfirmSubtitle;

  /// No description provided for @enterPinSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre code PIN pour continuer'**
  String get enterPinSubtitle;

  /// No description provided for @skip.
  ///
  /// In fr, this message translates to:
  /// **'Passer pour l\'instant'**
  String get skip;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @age.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get age;

  /// No description provided for @identifier.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get identifier;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @male.
  ///
  /// In fr, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In fr, this message translates to:
  /// **'Femelle'**
  String get female;

  /// No description provided for @alimentation.
  ///
  /// In fr, this message translates to:
  /// **'Alimentation'**
  String get alimentation;

  /// No description provided for @production.
  ///
  /// In fr, this message translates to:
  /// **'Production'**
  String get production;

  /// No description provided for @sante.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get sante;

  /// No description provided for @reminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels'**
  String get reminders;

  /// No description provided for @qrScanHint.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ce code pour identifier rapidement cet animal'**
  String get qrScanHint;

  /// No description provided for @deleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteConfirm;

  /// No description provided for @noFeeding.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alimentation'**
  String get noFeeding;

  /// No description provided for @noFeedingRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alimentation enregistrée'**
  String get noFeedingRecorded;

  /// No description provided for @noHealthData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée de santé'**
  String get noHealthData;

  /// No description provided for @growth.
  ///
  /// In fr, this message translates to:
  /// **'Croissance'**
  String get growth;

  /// No description provided for @transactionHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des transactions'**
  String get transactionHistory;

  /// No description provided for @balanceEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Évolution du solde'**
  String get balanceEvolution;

  /// No description provided for @noTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction enregistrée'**
  String get noTransaction;

  /// No description provided for @noProduction.
  ///
  /// In fr, this message translates to:
  /// **'Aucune production'**
  String get noProduction;

  /// No description provided for @productionHint.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez lait, œufs, laine...'**
  String get productionHint;

  /// No description provided for @noReminder.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rappel'**
  String get noReminder;

  /// No description provided for @noReminderScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rappel programmé'**
  String get noReminderScheduled;

  /// No description provided for @noReproEvent.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement de reproduction'**
  String get noReproEvent;

  /// No description provided for @calvingPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Vêlage prévu'**
  String get calvingPlanned;

  /// No description provided for @newEvent.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel événement'**
  String get newEvent;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @eventType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'événement'**
  String get eventType;

  /// No description provided for @gestationConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Gestation confirmée ?'**
  String get gestationConfirmed;

  /// No description provided for @notesOptional.
  ///
  /// In fr, this message translates to:
  /// **'Notes (Optionnel)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In fr, this message translates to:
  /// **'Détails, numéro de lot, observation...'**
  String get notesHint;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @birthReminderGenerated.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de naissance généré pour le'**
  String get birthReminderGenerated;

  /// No description provided for @birthImminent.
  ///
  /// In fr, this message translates to:
  /// **'Mise bas imminente'**
  String get birthImminent;

  /// No description provided for @birthPrepare.
  ///
  /// In fr, this message translates to:
  /// **'Préparez-vous pour la naissance prévue vers le'**
  String get birthPrepare;

  /// No description provided for @eventDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de l\'événement'**
  String get eventDate;

  /// No description provided for @scanQrCode.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le QR Code'**
  String get scanQrCode;

  /// No description provided for @scanHint.
  ///
  /// In fr, this message translates to:
  /// **'Pointez vers le QR Code ou Tagger'**
  String get scanHint;

  /// No description provided for @animalNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal trouvé avec l\'identifiant'**
  String get animalNotFound;

  /// No description provided for @newAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel animal'**
  String get newAnimal;

  /// No description provided for @addPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter photo'**
  String get addPhoto;

  /// No description provided for @informations.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get informations;

  /// No description provided for @animalName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'animal'**
  String get animalName;

  /// No description provided for @animalNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est requis'**
  String get animalNameRequired;

  /// No description provided for @breed.
  ///
  /// In fr, this message translates to:
  /// **'Race'**
  String get breed;

  /// No description provided for @breedRequired.
  ///
  /// In fr, this message translates to:
  /// **'La race est requise'**
  String get breedRequired;

  /// No description provided for @characteristics.
  ///
  /// In fr, this message translates to:
  /// **'Caractéristiques'**
  String get characteristics;

  /// No description provided for @genealogy.
  ///
  /// In fr, this message translates to:
  /// **'Généalogie (optionnel)'**
  String get genealogy;

  /// No description provided for @selectMother.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner la mère'**
  String get selectMother;

  /// No description provided for @noMother.
  ///
  /// In fr, this message translates to:
  /// **'Aucune mère'**
  String get noMother;

  /// No description provided for @noFemaleAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune femelle disponible'**
  String get noFemaleAvailable;

  /// No description provided for @noFemaleAvailableDesc.
  ///
  /// In fr, this message translates to:
  /// **'Aucune femelle de la même espèce avec l\'age requis n\'est disponible.'**
  String get noFemaleAvailableDesc;

  /// No description provided for @understood.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get understood;

  /// No description provided for @unknownMother.
  ///
  /// In fr, this message translates to:
  /// **'Mère inconnue'**
  String get unknownMother;

  /// No description provided for @selectFather.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner le père'**
  String get selectFather;

  /// No description provided for @noFather.
  ///
  /// In fr, this message translates to:
  /// **'Aucun père'**
  String get noFather;

  /// No description provided for @noMaleAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mâle disponible'**
  String get noMaleAvailable;

  /// No description provided for @noMaleAvailableDesc.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mâle de la même espèce avec l\'âge requis n\'est disponible.'**
  String get noMaleAvailableDesc;

  /// No description provided for @unknownFather.
  ///
  /// In fr, this message translates to:
  /// **'Père inconnu'**
  String get unknownFather;

  /// No description provided for @mother.
  ///
  /// In fr, this message translates to:
  /// **'Mère'**
  String get mother;

  /// No description provided for @father.
  ///
  /// In fr, this message translates to:
  /// **'Père'**
  String get father;

  /// No description provided for @genetics.
  ///
  /// In fr, this message translates to:
  /// **'Génétique'**
  String get genetics;

  /// No description provided for @ebv.
  ///
  /// In fr, this message translates to:
  /// **'EBV'**
  String get ebv;

  /// No description provided for @inbreedingCoefficient.
  ///
  /// In fr, this message translates to:
  /// **'Coefficient de consanguinité'**
  String get inbreedingCoefficient;

  /// No description provided for @calculate.
  ///
  /// In fr, this message translates to:
  /// **'Calculer'**
  String get calculate;

  /// No description provided for @recalculate.
  ///
  /// In fr, this message translates to:
  /// **'Recalculer'**
  String get recalculate;

  /// No description provided for @lastCalculated.
  ///
  /// In fr, this message translates to:
  /// **'Dernier calcul'**
  String get lastCalculated;

  /// No description provided for @notCalculated.
  ///
  /// In fr, this message translates to:
  /// **'Non calculé'**
  String get notCalculated;

  /// No description provided for @noGeneticData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée génétique'**
  String get noGeneticData;

  /// No description provided for @geneticHint.
  ///
  /// In fr, this message translates to:
  /// **'Lancez un calcul pour comparer cet animal aux performances et au pedigree du troupeau.'**
  String get geneticHint;

  /// No description provided for @incompletePedigree.
  ///
  /// In fr, this message translates to:
  /// **'Pedigree incomplet'**
  String get incompletePedigree;

  /// No description provided for @incompletePedigreeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez la mère et le père pour améliorer la précision du coefficient de consanguinité.'**
  String get incompletePedigreeDesc;

  /// No description provided for @selectSpecies.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une espèce'**
  String get selectSpecies;

  /// No description provided for @status.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// No description provided for @finances.
  ///
  /// In fr, this message translates to:
  /// **'Finances (optionnel)'**
  String get finances;

  /// No description provided for @purchasePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get purchasePrice;

  /// No description provided for @additionalNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes supplémentaires'**
  String get additionalNotes;

  /// No description provided for @addAnimalBtn.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter l\'animal'**
  String get addAnimalBtn;

  /// No description provided for @birthDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get birthDate;

  /// No description provided for @statutActif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get statutActif;

  /// No description provided for @statutVendu.
  ///
  /// In fr, this message translates to:
  /// **'Vendu'**
  String get statutVendu;

  /// No description provided for @statutMort.
  ///
  /// In fr, this message translates to:
  /// **'Mort'**
  String get statutMort;

  /// No description provided for @statutReforme.
  ///
  /// In fr, this message translates to:
  /// **'Réformé'**
  String get statutReforme;

  /// No description provided for @especeBovinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Bovin'**
  String get especeBovinLabel;

  /// No description provided for @especeOvinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ovin'**
  String get especeOvinLabel;

  /// No description provided for @especeCaprinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Caprin'**
  String get especeCaprinLabel;

  /// No description provided for @especePorcinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Porcin'**
  String get especePorcinLabel;

  /// No description provided for @especeVolailleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Volaille'**
  String get especeVolailleLabel;

  /// No description provided for @especeEquinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Équin'**
  String get especeEquinLabel;

  /// No description provided for @especeLapinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Lapin'**
  String get especeLapinLabel;

  /// No description provided for @activeCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} actifs'**
  String activeCount(Object count);

  /// No description provided for @especeBovin.
  ///
  /// In fr, this message translates to:
  /// **'ex: Vache, Taureau, Veau'**
  String get especeBovin;

  /// No description provided for @especeOvin.
  ///
  /// In fr, this message translates to:
  /// **'ex: Mouton, Brebis, Bélier'**
  String get especeOvin;

  /// No description provided for @especeCaprin.
  ///
  /// In fr, this message translates to:
  /// **'ex: Chèvre, Bouc, Chevreau'**
  String get especeCaprin;

  /// No description provided for @especePorcin.
  ///
  /// In fr, this message translates to:
  /// **'ex: Porc, Truie, Porcelet'**
  String get especePorcin;

  /// No description provided for @especeVolaille.
  ///
  /// In fr, this message translates to:
  /// **'ex: Poule, Coq, Dindon'**
  String get especeVolaille;

  /// No description provided for @especeEquin.
  ///
  /// In fr, this message translates to:
  /// **'ex: Cheval, Âne, Mule'**
  String get especeEquin;

  /// No description provided for @especeLapin.
  ///
  /// In fr, this message translates to:
  /// **'ex: Lapin, Lapine'**
  String get especeLapin;

  /// No description provided for @myTasks.
  ///
  /// In fr, this message translates to:
  /// **'Mes Tâches'**
  String get myTasks;

  /// No description provided for @inProgress.
  ///
  /// In fr, this message translates to:
  /// **'en cours'**
  String get inProgress;

  /// No description provided for @allAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Tous les animaux'**
  String get allAnimals;

  /// No description provided for @selectAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un animal'**
  String get selectAnimal;

  /// No description provided for @newTask.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle tâche'**
  String get newTask;

  /// No description provided for @editTask.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la tâche'**
  String get editTask;

  /// No description provided for @taskType.
  ///
  /// In fr, this message translates to:
  /// **'Type de tâche'**
  String get taskType;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// No description provided for @title.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get title;

  /// No description provided for @titleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le titre est requis'**
  String get titleRequired;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionRequired.
  ///
  /// In fr, this message translates to:
  /// **'La description est requise'**
  String get descriptionRequired;

  /// No description provided for @planning.
  ///
  /// In fr, this message translates to:
  /// **'Planification'**
  String get planning;

  /// No description provided for @recurringTask.
  ///
  /// In fr, this message translates to:
  /// **'Tâche récurrente'**
  String get recurringTask;

  /// No description provided for @repeatsAutomatically.
  ///
  /// In fr, this message translates to:
  /// **'Se répète automatiquement'**
  String get repeatsAutomatically;

  /// No description provided for @repeatUnit.
  ///
  /// In fr, this message translates to:
  /// **'Unité de répétition'**
  String get repeatUnit;

  /// No description provided for @hours.
  ///
  /// In fr, this message translates to:
  /// **'Heures'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In fr, this message translates to:
  /// **'Jours'**
  String get days;

  /// No description provided for @everyHours.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les'**
  String get everyHours;

  /// No description provided for @frequency.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence'**
  String get frequency;

  /// No description provided for @everyWeek.
  ///
  /// In fr, this message translates to:
  /// **'Chaque semaine'**
  String get everyWeek;

  /// No description provided for @everyMonth.
  ///
  /// In fr, this message translates to:
  /// **'Chaque mois'**
  String get everyMonth;

  /// No description provided for @every3Months.
  ///
  /// In fr, this message translates to:
  /// **'Tous les 3 mois'**
  String get every3Months;

  /// No description provided for @every6Months.
  ///
  /// In fr, this message translates to:
  /// **'Tous les 6 mois'**
  String get every6Months;

  /// No description provided for @everyYear.
  ///
  /// In fr, this message translates to:
  /// **'Chaque année'**
  String get everyYear;

  /// No description provided for @setDuration.
  ///
  /// In fr, this message translates to:
  /// **'Définir une durée'**
  String get setDuration;

  /// No description provided for @taskStopsAuto.
  ///
  /// In fr, this message translates to:
  /// **'La tâche s\'arrêtera automatiquement'**
  String get taskStopsAuto;

  /// No description provided for @endDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get endDate;

  /// No description provided for @selectDate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get selectDate;

  /// No description provided for @createTask.
  ///
  /// In fr, this message translates to:
  /// **'Créer la tâche'**
  String get createTask;

  /// No description provided for @filterLate.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get filterLate;

  /// No description provided for @filterUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get filterUpcoming;

  /// No description provided for @allUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'Tout est à jour !'**
  String get allUpToDate;

  /// No description provided for @noTask.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche'**
  String get noTask;

  /// No description provided for @noTaskLate.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche en retard'**
  String get noTaskLate;

  /// No description provided for @noTaskToday.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche pour aujourd\'hui'**
  String get noTaskToday;

  /// No description provided for @noTaskUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche à venir'**
  String get noTaskUpcoming;

  /// No description provided for @noTaskScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche programmée'**
  String get noTaskScheduled;

  /// No description provided for @addTask.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une tâche'**
  String get addTask;

  /// No description provided for @addAnimalFirst.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez d\'abord un animal'**
  String get addAnimalFirst;

  /// No description provided for @deleteTask.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la tâche ?'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer'**
  String get deleteTaskConfirm;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer « {name} » ?'**
  String confirmDeleteMessage(String name);

  /// No description provided for @recurringHours.
  ///
  /// In fr, this message translates to:
  /// **'Récurrent ({n} heures)'**
  String recurringHours(Object n);

  /// No description provided for @recurringDays.
  ///
  /// In fr, this message translates to:
  /// **'Récurrent ({n} jours)'**
  String recurringDays(Object n);

  /// No description provided for @until.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'au'**
  String get until;

  /// No description provided for @typeVaccination.
  ///
  /// In fr, this message translates to:
  /// **'Vaccination'**
  String get typeVaccination;

  /// No description provided for @typeVermifuge.
  ///
  /// In fr, this message translates to:
  /// **'Vermifuge'**
  String get typeVermifuge;

  /// No description provided for @typeVetVisit.
  ///
  /// In fr, this message translates to:
  /// **'Visite vétérinaire'**
  String get typeVetVisit;

  /// No description provided for @typeSpecificCare.
  ///
  /// In fr, this message translates to:
  /// **'Soin spécifique'**
  String get typeSpecificCare;

  /// No description provided for @typeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get typeOther;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @ageMonths.
  ///
  /// In fr, this message translates to:
  /// **'{n} mois'**
  String ageMonths(int n);

  /// No description provided for @ageYear.
  ///
  /// In fr, this message translates to:
  /// **'{n} an'**
  String ageYear(int n);

  /// No description provided for @ageYears.
  ///
  /// In fr, this message translates to:
  /// **'{n} ans'**
  String ageYears(int n);

  /// No description provided for @ageYearMonths.
  ///
  /// In fr, this message translates to:
  /// **'{n} an et {m} mois'**
  String ageYearMonths(int n, int m);

  /// No description provided for @ageYearsMonths.
  ///
  /// In fr, this message translates to:
  /// **'{n} ans et {m} mois'**
  String ageYearsMonths(int n, int m);

  /// No description provided for @newTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Transaction'**
  String get newTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la Transaction'**
  String get editTransaction;

  /// No description provided for @category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get category;

  /// No description provided for @invalidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un montant valide'**
  String get invalidAmount;

  /// No description provided for @catFood.
  ///
  /// In fr, this message translates to:
  /// **'Alimentation'**
  String get catFood;

  /// No description provided for @catVet.
  ///
  /// In fr, this message translates to:
  /// **'Frais Vétérinaires'**
  String get catVet;

  /// No description provided for @catEquipment.
  ///
  /// In fr, this message translates to:
  /// **'Matériel'**
  String get catEquipment;

  /// No description provided for @catAnimalBuy.
  ///
  /// In fr, this message translates to:
  /// **'Achat animal'**
  String get catAnimalBuy;

  /// No description provided for @catCare.
  ///
  /// In fr, this message translates to:
  /// **'Soin et Cosmétique'**
  String get catCare;

  /// No description provided for @catOtherExpense.
  ///
  /// In fr, this message translates to:
  /// **'Autre Dépense'**
  String get catOtherExpense;

  /// No description provided for @catAnimalSale.
  ///
  /// In fr, this message translates to:
  /// **'Vente animal'**
  String get catAnimalSale;

  /// No description provided for @catMilk.
  ///
  /// In fr, this message translates to:
  /// **'Lait'**
  String get catMilk;

  /// No description provided for @catMeat.
  ///
  /// In fr, this message translates to:
  /// **'Viande'**
  String get catMeat;

  /// No description provided for @catSubsidy.
  ///
  /// In fr, this message translates to:
  /// **'Subvention'**
  String get catSubsidy;

  /// No description provided for @catOtherRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Autre Revenu'**
  String get catOtherRevenue;

  /// No description provided for @herd.
  ///
  /// In fr, this message translates to:
  /// **'Troupeau'**
  String get herd;

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Actifs'**
  String get active;

  /// No description provided for @avgAge.
  ///
  /// In fr, this message translates to:
  /// **'Âge moyen'**
  String get avgAge;

  /// No description provided for @sexRatio.
  ///
  /// In fr, this message translates to:
  /// **'Répartition sexes'**
  String get sexRatio;

  /// No description provided for @males.
  ///
  /// In fr, this message translates to:
  /// **'Mâles'**
  String get males;

  /// No description provided for @females.
  ///
  /// In fr, this message translates to:
  /// **'Femelles'**
  String get females;

  /// No description provided for @healthCare.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get healthCare;

  /// No description provided for @totalCare.
  ///
  /// In fr, this message translates to:
  /// **'Total soins'**
  String get totalCare;

  /// No description provided for @thisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get thisMonth;

  /// No description provided for @weightMax.
  ///
  /// In fr, this message translates to:
  /// **'Poids max'**
  String get weightMax;

  /// No description provided for @weightAvg.
  ///
  /// In fr, this message translates to:
  /// **'Poids moyen'**
  String get weightAvg;

  /// No description provided for @weightEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Évolution du poids'**
  String get weightEvolution;

  /// No description provided for @bySpecies.
  ///
  /// In fr, this message translates to:
  /// **'Répartition par espèce'**
  String get bySpecies;

  /// No description provided for @balance.
  ///
  /// In fr, this message translates to:
  /// **'Solde'**
  String get balance;

  /// No description provided for @feedings.
  ///
  /// In fr, this message translates to:
  /// **'Alimentations'**
  String get feedings;

  /// No description provided for @careByType.
  ///
  /// In fr, this message translates to:
  /// **'Par type de soin'**
  String get careByType;

  /// No description provided for @productionTotals.
  ///
  /// In fr, this message translates to:
  /// **'Totaux par type'**
  String get productionTotals;

  /// No description provided for @addFeeding.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter alimentation'**
  String get addFeeding;

  /// No description provided for @editFeeding.
  ///
  /// In fr, this message translates to:
  /// **'Modifier alimentation'**
  String get editFeeding;

  /// No description provided for @foodType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'aliment'**
  String get foodType;

  /// No description provided for @foodTypeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le type est requis'**
  String get foodTypeRequired;

  /// No description provided for @quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get unit;

  /// No description provided for @unitPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix unitaire (optionnel)'**
  String get unitPrice;

  /// No description provided for @dateTime.
  ///
  /// In fr, this message translates to:
  /// **'Date et heure'**
  String get dateTime;

  /// No description provided for @required.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get required;

  /// No description provided for @feedingTracking.
  ///
  /// In fr, this message translates to:
  /// **'Suivi Alimentaire'**
  String get feedingTracking;

  /// No description provided for @addAnimalToStart.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un animal pour commencer'**
  String get addAnimalToStart;

  /// No description provided for @deleteFeeding.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'alimentation'**
  String get deleteFeeding;

  /// No description provided for @deleteEntryConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer cette entrée ?'**
  String get deleteEntryConfirm;

  /// No description provided for @addMeasure.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter mesure'**
  String get addMeasure;

  /// No description provided for @weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids (kg)'**
  String get weight;

  /// No description provided for @weightRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le poids est requis'**
  String get weightRequired;

  /// No description provided for @height.
  ///
  /// In fr, this message translates to:
  /// **'Taille (cm) - optionnel'**
  String get height;

  /// No description provided for @physicalState.
  ///
  /// In fr, this message translates to:
  /// **'État physique'**
  String get physicalState;

  /// No description provided for @stateExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get stateExcellent;

  /// No description provided for @stateGood.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get stateGood;

  /// No description provided for @stateMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get stateMedium;

  /// No description provided for @stateWeak.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get stateWeak;

  /// No description provided for @addHealth.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter santé'**
  String get addHealth;

  /// No description provided for @careType.
  ///
  /// In fr, this message translates to:
  /// **'Type de soin'**
  String get careType;

  /// No description provided for @medicineOptional.
  ///
  /// In fr, this message translates to:
  /// **'Médicament (optionnel)'**
  String get medicineOptional;

  /// No description provided for @vetOptional.
  ///
  /// In fr, this message translates to:
  /// **'Vétérinaire (optionnel)'**
  String get vetOptional;

  /// No description provided for @paid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paid;

  /// No description provided for @paidQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Le soin est-il payé ?'**
  String get paidQuestion;

  /// No description provided for @costOptional.
  ///
  /// In fr, this message translates to:
  /// **'Coût (optionnel)'**
  String get costOptional;

  /// No description provided for @typeTraitement.
  ///
  /// In fr, this message translates to:
  /// **'Traitement'**
  String get typeTraitement;

  /// No description provided for @typeMaladie.
  ///
  /// In fr, this message translates to:
  /// **'Maladie'**
  String get typeMaladie;

  /// No description provided for @typeVisite.
  ///
  /// In fr, this message translates to:
  /// **'Visite vétérinaire'**
  String get typeVisite;

  /// No description provided for @healthAndGrowth.
  ///
  /// In fr, this message translates to:
  /// **'Santé & Croissance'**
  String get healthAndGrowth;

  /// No description provided for @noGrowthData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée de croissance'**
  String get noGrowthData;

  /// No description provided for @heightLabel.
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get heightLabel;

  /// No description provided for @addProduction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter production'**
  String get addProduction;

  /// No description provided for @editProduction.
  ///
  /// In fr, this message translates to:
  /// **'Modifier production'**
  String get editProduction;

  /// No description provided for @productionType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get productionType;

  /// No description provided for @unitPriceRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Prix unitaire (optionnel → crée un revenu)'**
  String get unitPriceRevenue;

  /// No description provided for @pricePerUnit.
  ///
  /// In fr, this message translates to:
  /// **'Prix par unité'**
  String get pricePerUnit;

  /// No description provided for @tooYoungWarning.
  ///
  /// In fr, this message translates to:
  /// **'{name} a {age}. L\'âge minimum recommandé pour \"{type}\" est {min}.'**
  String tooYoungWarning(String name, String age, String type, String min);

  /// No description provided for @prodMilk.
  ///
  /// In fr, this message translates to:
  /// **'Lait'**
  String get prodMilk;

  /// No description provided for @prodEggs.
  ///
  /// In fr, this message translates to:
  /// **'Œufs'**
  String get prodEggs;

  /// No description provided for @prodWool.
  ///
  /// In fr, this message translates to:
  /// **'Laine'**
  String get prodWool;

  /// No description provided for @prodOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get prodOther;

  /// No description provided for @birthDashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prochaines Naissances'**
  String get birthDashboardTitle;

  /// No description provided for @noBirthsScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune naissance prévue'**
  String get noBirthsScheduled;

  /// No description provided for @selectTime.
  ///
  /// In fr, this message translates to:
  /// **'Choisir l\'heure'**
  String get selectTime;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'rn', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'rn':
      return AppLocalizationsRn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
