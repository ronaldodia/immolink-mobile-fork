import 'package:equatable/equatable.dart';
import 'package:immolink_mobile/models/Currency.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object> get props => [];
}

class ChangeCurrency extends CurrencyEvent {
  final Currency currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object> get props => [currency];
}
