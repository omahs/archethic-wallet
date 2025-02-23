/// SPDX-License-Identifier: AGPL-3.0-or-later
import 'package:aewallet/application/account/providers.dart';
import 'package:aewallet/application/settings/theme.dart';
import 'package:aewallet/localization.dart';
import 'package:aewallet/model/data/account_balance.dart';
import 'package:aewallet/ui/util/amount_formatters.dart';
import 'package:aewallet/ui/util/styles.dart';
import 'package:aewallet/ui/views/tokens_fungibles/bloc/provider.dart';
import 'package:aewallet/ui/widgets/components/sheet_detail_card.dart';
import 'package:aewallet/util/number_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTokenDetail extends ConsumerWidget {
  const AddTokenDetail({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalization.of(context)!;
    final theme = ref.watch(ThemeProviders.selectedTheme);
    final addToken = ref.watch(AddTokenFormProvider.addTokenForm);
    final accountSelected =
        ref.watch(AccountProviders.selectedAccount).valueOrNull;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          SheetDetailCard(
            children: [
              Text(
                localizations.tokenName,
                style: theme.textStyleSize12W400Primary,
              ),
              Expanded(
                child: Text(
                  addToken.name,
                  style: theme.textStyleSize12W400Primary,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          SheetDetailCard(
            children: [
              Text(
                localizations.tokenSymbol,
                style: theme.textStyleSize12W400Primary,
              ),
              Text(
                addToken.symbol,
                style: theme.textStyleSize12W400Primary,
              ),
            ],
          ),
          SheetDetailCard(
            children: [
              Text(
                localizations.tokenInitialSupply,
                style: theme.textStyleSize12W400Primary,
              ),
              Text(
                NumberUtil.formatThousands(addToken.initialSupply),
                style: theme.textStyleSize12W400Primary,
              ),
            ],
          ),
          SheetDetailCard(
            children: [
              Text(
                localizations.estimatedFees,
                style: theme.textStyleSize12W400Primary,
              ),
              Text(
                AmountFormatters.standardSmallValue(
                  addToken.feeEstimationOrZero,
                  AccountBalance.cryptoCurrencyLabel,
                ),
                style: theme.textStyleSize12W400Primary,
              ),
            ],
          ),
          SheetDetailCard(
            children: [
              Text(
                localizations.availableAfterCreation,
                style: theme.textStyleSize12W400Primary,
              ),
              Text(
                AmountFormatters.standard(
                  accountSelected!.balance!.nativeTokenValue -
                      addToken.feeEstimationOrZero,
                  addToken.symbolFees(context),
                ),
                style: theme.textStyleSize12W400Primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
