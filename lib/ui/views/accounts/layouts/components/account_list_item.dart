/// SPDX-License-Identifier: AGPL-3.0-or-later
import 'package:aewallet/application/account/providers.dart';
import 'package:aewallet/application/contact.dart';
import 'package:aewallet/application/market_price.dart';
import 'package:aewallet/application/settings/primary_currency.dart';
import 'package:aewallet/application/settings/settings.dart';
import 'package:aewallet/application/settings/theme.dart';
import 'package:aewallet/model/data/account.dart';
import 'package:aewallet/model/primary_currency.dart';
import 'package:aewallet/ui/util/routes.dart';
import 'package:aewallet/ui/util/styles.dart';
import 'package:aewallet/ui/views/accounts/layouts/components/account_list_item_token_info.dart';
import 'package:aewallet/ui/views/contacts/layouts/contact_detail.dart';
import 'package:aewallet/ui/widgets/components/sheet_util.dart';
import 'package:aewallet/ui/widgets/components/show_sending_animation.dart';
import 'package:aewallet/util/currency_util.dart';
import 'package:aewallet/util/get_it_instance.dart';
import 'package:aewallet/util/haptic_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class AccountListItem extends ConsumerWidget {
  const AccountListItem({
    super.key,
    required this.account,
  });
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(ThemeProviders.selectedTheme);
    final settings = ref.watch(SettingsProviders.settings);
    final primaryCurrency =
        ref.watch(PrimaryCurrencyProviders.selectedPrimaryCurrency);
    final contact = ref.watch(
      ContactProviders.getContactWithName(
        account.name,
      ),
    );

    final selectedAccount =
        ref.watch(AccountProviders.selectedAccount).valueOrNull;
    final asyncFiatAmount = ref.watch(
      MarketPriceProviders.convertedToSelectedCurrency(
        nativeAmount: account.balance?.nativeTokenValue ?? 0,
      ),
    );
    final fiatAmountString = asyncFiatAmount.maybeWhen(
      data: (fiatAmount) => CurrencyUtil.format(
        settings.currency.name,
        fiatAmount,
      ),
      orElse: () => '--',
    );

    return contact.map(
      data: (data) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () async {
              sl.get<HapticUtil>().feedback(
                    FeedbackType.light,
                    ref.read(
                      SettingsProviders.settings.select(
                        (value) => value.activeVibrations,
                      ),
                    ),
                  );

              if (selectedAccount!.name != account.name) {
                ShowSendingAnimation.build(context, theme);
                await ref
                    .read(AccountProviders.accounts.notifier)
                    .selectAccount(account);
                await ref
                    .read(AccountProviders.account(account.name).notifier)
                    .refreshRecentTransactions();
              }

              ref
                  .read(SettingsProviders.settings.notifier)
                  .resetMainScreenCurrentPage();
              Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
            },
            onLongPress: () {
              sl.get<HapticUtil>().feedback(
                    FeedbackType.light,
                    settings.activeVibrations,
                  );

              Sheets.showAppHeightNineSheet(
                context: context,
                ref: ref,
                widget: ContactDetail(
                  contact: data.value,
                ),
              );
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: theme.backgroundAccountsListCardSelected!,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              color: theme.backgroundAccountsListCardSelected,
              child: Container(
                height: 85,
                color: account.selected!
                    ? theme.backgroundAccountsListCardSelected
                    : theme.backgroundAccountsListCard,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: AutoSizeText(
                        account.name,
                        style: theme.textStyleSize12W400Primary,
                      ),
                    ),
                    if (settings.showBalances)
                      primaryCurrency.primaryCurrency ==
                              AvailablePrimaryCurrencyEnum.native
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                AutoSizeText(
                                  '${account.balance!.nativeTokenValueToString()} ${account.balance!.nativeTokenName}',
                                  style: theme.textStyleSize12W400Primary,
                                  textAlign: TextAlign.end,
                                ),
                                AutoSizeText(
                                  fiatAmountString,
                                  textAlign: TextAlign.end,
                                  style: theme.textStyleSize12W400Primary,
                                ),
                                AccountListItemTokenInfo(account: account),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                AutoSizeText(
                                  fiatAmountString,
                                  textAlign: TextAlign.end,
                                  style: theme.textStyleSize12W400Primary,
                                ),
                                AutoSizeText(
                                  '${account.balance!.nativeTokenValueToString()} ${selectedAccount!.balance!.nativeTokenName}',
                                  style: theme.textStyleSize12W400Primary,
                                  textAlign: TextAlign.end,
                                ),
                                AccountListItemTokenInfo(account: account),
                              ],
                            )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          AutoSizeText(
                            '···········',
                            style: theme.textStyleSize12W600Primary60,
                          ),
                          AutoSizeText(
                            '···········',
                            style: theme.textStyleSize12W600Primary60,
                          ),
                          AutoSizeText(
                            '···········',
                            style: theme.textStyleSize12W600Primary60,
                          ),
                          AutoSizeText(
                            '···········',
                            style: theme.textStyleSize12W600Primary60,
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (error) => const SizedBox(),
      loading: (loading) => const SizedBox(),
    );
  }
}
