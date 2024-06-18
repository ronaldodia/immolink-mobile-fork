import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:immolink_mobile/bloc/languages/localization_bloc.dart';
import 'package:immolink_mobile/models/LanguageModel.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var groupValue = context.read<LocalizationBloc>().state.locale.languageCode;
    return  BlocConsumer<LocalizationBloc, LocalizationState>(
      listener: (context, state){
        groupValue = state.locale.languageCode;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title:  Text(AppLocalizations.of(context)!.name),
          ),
          body: ListView.builder(
            itemCount: languageModel.length,
            itemBuilder: (context, index){
            var item = languageModel[index];
            return RadioListTile(
              value: item.languageCode, 
              title: Text(item.language),
              subtitle: Text(item.subLanguage),
              groupValue: groupValue, 
              onChanged: (value){
                  BlocProvider.of<LocalizationBloc>(context).add(LoadLocalization(Locale(item.languageCode)));
              });
          }),
        );
      }
    );
  }
}