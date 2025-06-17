import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'ImmoLink Mobile'**
  String get name;

  /// No description provided for @hello_world.
  ///
  /// In en, this message translates to:
  /// **'Hello World'**
  String get hello_world;

  /// No description provided for @example_text.
  ///
  /// In en, this message translates to:
  /// **'This is an example of ImmoLink Mobile'**
  String get example_text;

  /// No description provided for @world_text.
  ///
  /// In en, this message translates to:
  /// **'This world is so beautiful'**
  String get world_text;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @location_not_found.
  ///
  /// In en, this message translates to:
  /// **'No data found for the specified lot.'**
  String get location_not_found;

  /// No description provided for @location_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while retrieving data.'**
  String get location_error;

  /// No description provided for @lot_number.
  ///
  /// In en, this message translates to:
  /// **'Lot Number'**
  String get lot_number;

  /// No description provided for @moughataa.
  ///
  /// In en, this message translates to:
  /// **'Moughataa'**
  String get moughataa;

  /// No description provided for @lotissement.
  ///
  /// In en, this message translates to:
  /// **'Lotissement'**
  String get lotissement;

  /// No description provided for @lot.
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get lot;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @index.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get index;

  /// No description provided for @moughataa_label.
  ///
  /// In en, this message translates to:
  /// **'Moughataa'**
  String get moughataa_label;

  /// No description provided for @lotissement_label.
  ///
  /// In en, this message translates to:
  /// **'Lotissement'**
  String get lotissement_label;

  /// No description provided for @search_button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_button;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published since'**
  String get published;

  /// No description provided for @anytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get anytime;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @this_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get this_week;

  /// No description provided for @this_month.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get this_month;

  /// No description provided for @this_year.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get this_year;

  /// No description provided for @transaction_type.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get transaction_type;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @clear_filter.
  ///
  /// In en, this message translates to:
  /// **'Effacer les filtres'**
  String get clear_filter;

  /// No description provided for @property_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get property_type;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @min_price.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get min_price;

  /// No description provided for @max_price.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get max_price;

  /// No description provided for @surface_area.
  ///
  /// In en, this message translates to:
  /// **'Surface Area'**
  String get surface_area;

  /// No description provided for @min_area.
  ///
  /// In en, this message translates to:
  /// **'Min Area'**
  String get min_area;

  /// No description provided for @max_area.
  ///
  /// In en, this message translates to:
  /// **'Max Area'**
  String get max_area;

  /// No description provided for @for_sale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get for_sale;

  /// No description provided for @for_rent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get for_rent;

  /// No description provided for @no_properties_found.
  ///
  /// In en, this message translates to:
  /// **'No properties match your criteria'**
  String get no_properties_found;

  /// No description provided for @dont_miss_new_properties.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss new properties that might interest you!'**
  String get dont_miss_new_properties;

  /// No description provided for @create_alert.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Alert'**
  String get create_alert;

  /// No description provided for @alert_notification.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a property matching your criteria is published'**
  String get alert_notification;

  /// No description provided for @search_results.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get search_results;

  /// No description provided for @bedrooms.
  ///
  /// In en, this message translates to:
  /// **'bedrooms'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'bathrooms'**
  String get bathrooms;

  /// No description provided for @square_meters.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get square_meters;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @welcome_message.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ImmoLink'**
  String get welcome_message;

  /// No description provided for @search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search for a property...'**
  String get search_placeholder;

  /// No description provided for @featured_properties.
  ///
  /// In en, this message translates to:
  /// **'Featured Properties'**
  String get featured_properties;

  /// No description provided for @promoted_properties.
  ///
  /// In en, this message translates to:
  /// **'Promoted Properties'**
  String get promoted_properties;

  /// No description provided for @recent_properties.
  ///
  /// In en, this message translates to:
  /// **'Recent Properties'**
  String get recent_properties;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all;

  /// No description provided for @no_properties.
  ///
  /// In en, this message translates to:
  /// **'No properties available'**
  String get no_properties;

  /// No description provided for @property_details.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get property_details;

  /// No description provided for @contact_agent.
  ///
  /// In en, this message translates to:
  /// **'Contact Agent'**
  String get contact_agent;

  /// No description provided for @share_property.
  ///
  /// In en, this message translates to:
  /// **'Share Property'**
  String get share_property;

  /// No description provided for @save_property.
  ///
  /// In en, this message translates to:
  /// **'Save Property'**
  String get save_property;

  /// No description provided for @property_features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get property_features;

  /// No description provided for @property_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get property_description;

  /// No description provided for @property_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get property_location;

  /// No description provided for @property_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get property_price;

  /// No description provided for @property_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get property_status;

  /// No description provided for @property_area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get property_area;

  /// No description provided for @property_rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get property_rooms;

  /// No description provided for @property_bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get property_bathrooms;

  /// No description provided for @property_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get property_bedrooms;

  /// No description provided for @property_garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get property_garage;

  /// No description provided for @property_pool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get property_pool;

  /// No description provided for @property_garden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get property_garden;

  /// No description provided for @property_terrace.
  ///
  /// In en, this message translates to:
  /// **'Terrace'**
  String get property_terrace;

  /// No description provided for @property_balcony.
  ///
  /// In en, this message translates to:
  /// **'Balcony'**
  String get property_balcony;

  /// No description provided for @property_elevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get property_elevator;

  /// No description provided for @property_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get property_security;

  /// No description provided for @property_parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get property_parking;

  /// No description provided for @property_air_conditioning.
  ///
  /// In en, this message translates to:
  /// **'Air Conditioning'**
  String get property_air_conditioning;

  /// No description provided for @property_heating.
  ///
  /// In en, this message translates to:
  /// **'Heating'**
  String get property_heating;

  /// No description provided for @property_furnished.
  ///
  /// In en, this message translates to:
  /// **'Furnished'**
  String get property_furnished;

  /// No description provided for @property_unfurnished.
  ///
  /// In en, this message translates to:
  /// **'Unfurnished'**
  String get property_unfurnished;

  /// No description provided for @property_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get property_new;

  /// No description provided for @property_old.
  ///
  /// In en, this message translates to:
  /// **'Old'**
  String get property_old;

  /// No description provided for @property_renovated.
  ///
  /// In en, this message translates to:
  /// **'Renovated'**
  String get property_renovated;

  /// No description provided for @property_to_renovate.
  ///
  /// In en, this message translates to:
  /// **'To Renovate'**
  String get property_to_renovate;

  /// No description provided for @property_sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get property_sold;

  /// No description provided for @property_rented.
  ///
  /// In en, this message translates to:
  /// **'Rented'**
  String get property_rented;

  /// No description provided for @property_available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get property_available;

  /// No description provided for @property_reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get property_reserved;

  /// No description provided for @property_under_contract.
  ///
  /// In en, this message translates to:
  /// **'Under Contract'**
  String get property_under_contract;

  /// No description provided for @property_under_offer.
  ///
  /// In en, this message translates to:
  /// **'Under Offer'**
  String get property_under_offer;

  /// No description provided for @property_under_negotiation.
  ///
  /// In en, this message translates to:
  /// **'Under Negotiation'**
  String get property_under_negotiation;

  /// No description provided for @property_under_construction.
  ///
  /// In en, this message translates to:
  /// **'Under Construction'**
  String get property_under_construction;

  /// No description provided for @property_under_renovation.
  ///
  /// In en, this message translates to:
  /// **'Under Renovation'**
  String get property_under_renovation;

  /// No description provided for @property_under_demolition.
  ///
  /// In en, this message translates to:
  /// **'Under Demolition'**
  String get property_under_demolition;

  /// No description provided for @property_under_restoration.
  ///
  /// In en, this message translates to:
  /// **'Under Restoration'**
  String get property_under_restoration;

  /// No description provided for @property_under_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Under Maintenance'**
  String get property_under_maintenance;

  /// No description provided for @property_under_inspection.
  ///
  /// In en, this message translates to:
  /// **'Under Inspection'**
  String get property_under_inspection;

  /// No description provided for @property_under_appraisal.
  ///
  /// In en, this message translates to:
  /// **'Under Appraisal'**
  String get property_under_appraisal;

  /// No description provided for @property_under_auction.
  ///
  /// In en, this message translates to:
  /// **'Under Auction'**
  String get property_under_auction;

  /// No description provided for @property_under_foreclosure.
  ///
  /// In en, this message translates to:
  /// **'Under Foreclosure'**
  String get property_under_foreclosure;

  /// No description provided for @property_under_repossession.
  ///
  /// In en, this message translates to:
  /// **'Under Repossession'**
  String get property_under_repossession;

  /// No description provided for @property_under_eviction.
  ///
  /// In en, this message translates to:
  /// **'Under Eviction'**
  String get property_under_eviction;

  /// No description provided for @property_under_lease.
  ///
  /// In en, this message translates to:
  /// **'Under Lease'**
  String get property_under_lease;

  /// No description provided for @property_under_rental.
  ///
  /// In en, this message translates to:
  /// **'Under Rental'**
  String get property_under_rental;

  /// No description provided for @property_under_sale.
  ///
  /// In en, this message translates to:
  /// **'Under Sale'**
  String get property_under_sale;

  /// No description provided for @property_under_purchase.
  ///
  /// In en, this message translates to:
  /// **'Under Purchase'**
  String get property_under_purchase;

  /// No description provided for @property_under_transfer.
  ///
  /// In en, this message translates to:
  /// **'Under Transfer'**
  String get property_under_transfer;

  /// No description provided for @property_under_donation.
  ///
  /// In en, this message translates to:
  /// **'Under Donation'**
  String get property_under_donation;

  /// No description provided for @property_under_inheritance.
  ///
  /// In en, this message translates to:
  /// **'Under Inheritance'**
  String get property_under_inheritance;

  /// No description provided for @property_under_gift.
  ///
  /// In en, this message translates to:
  /// **'Under Gift'**
  String get property_under_gift;

  /// No description provided for @property_under_exchange.
  ///
  /// In en, this message translates to:
  /// **'Under Exchange'**
  String get property_under_exchange;

  /// No description provided for @property_under_barter.
  ///
  /// In en, this message translates to:
  /// **'Under Barter'**
  String get property_under_barter;

  /// No description provided for @property_under_swap.
  ///
  /// In en, this message translates to:
  /// **'Under Swap'**
  String get property_under_swap;

  /// No description provided for @property_under_trade.
  ///
  /// In en, this message translates to:
  /// **'Under Trade'**
  String get property_under_trade;

  /// No description provided for @property_under_business.
  ///
  /// In en, this message translates to:
  /// **'Under Business'**
  String get property_under_business;

  /// No description provided for @property_under_investment.
  ///
  /// In en, this message translates to:
  /// **'Under Investment'**
  String get property_under_investment;

  /// No description provided for @property_under_development.
  ///
  /// In en, this message translates to:
  /// **'Under Development'**
  String get property_under_development;

  /// No description provided for @property_under_planning.
  ///
  /// In en, this message translates to:
  /// **'Under Planning'**
  String get property_under_planning;

  /// No description provided for @property_under_design.
  ///
  /// In en, this message translates to:
  /// **'Under Design'**
  String get property_under_design;

  /// No description provided for @property_under_architecture.
  ///
  /// In en, this message translates to:
  /// **'Under Architecture'**
  String get property_under_architecture;

  /// No description provided for @property_under_engineering.
  ///
  /// In en, this message translates to:
  /// **'Under Engineering'**
  String get property_under_engineering;

  /// No description provided for @property_under_repair.
  ///
  /// In en, this message translates to:
  /// **'Under Repair'**
  String get property_under_repair;

  /// No description provided for @property_under_upgrade.
  ///
  /// In en, this message translates to:
  /// **'Under Upgrade'**
  String get property_under_upgrade;

  /// No description provided for @property_under_modernization.
  ///
  /// In en, this message translates to:
  /// **'Under Modernization'**
  String get property_under_modernization;

  /// No description provided for @continue_without_login.
  ///
  /// In en, this message translates to:
  /// **'Continue without login'**
  String get continue_without_login;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
