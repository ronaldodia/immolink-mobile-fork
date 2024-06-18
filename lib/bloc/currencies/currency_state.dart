import 'package:equatable/equatable.dart';
import 'package:immolink_mobile/models/Currency.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object> get props => [];
}

class CurrencyInitial extends CurrencyState {
  final Currency selectedCurrency;
  final List<Currency> currencies;

  const CurrencyInitial(this.selectedCurrency, this.currencies);

  @override
  List<Object> get props => [selectedCurrency, currencies];
}

class CurrencyChangedState extends CurrencyState {
  final Currency selectedCurrency;
  final List<Currency> currencies;

  const CurrencyChangedState({required this.selectedCurrency, required this.currencies});

  @override
  List<Object> get props => [selectedCurrency, currencies];
}
