import 'package:aewallet/application/authentication/authentication.dart';
import 'package:aewallet/application/settings/language.dart';
import 'package:aewallet/application/settings/settings.dart';
import 'package:aewallet/application/settings/theme.dart';
import 'package:aewallet/application/wallet/wallet.dart';
import 'package:aewallet/localization.dart';
import 'package:aewallet/model/available_language.dart';
import 'package:aewallet/ui/util/dimens.dart';
import 'package:aewallet/ui/util/styles.dart';
import 'package:aewallet/ui/widgets/components/app_button_tiny.dart';
import 'package:aewallet/ui/widgets/components/dialog.dart';
import 'package:aewallet/util/case_converter.dart';
import 'package:aewallet/util/get_it_instance.dart';
import 'package:aewallet/util/haptic_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Package imports:
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

abstract class DurationFormatters {
  static String _twoDigitsFormatter(int value) =>
      value.toString().padLeft(2, '0');

  static String hhmmss(Duration duration) =>
      '${_twoDigitsFormatter(duration.inHours)}:${_twoDigitsFormatter(duration.inMinutes % 60)}:${_twoDigitsFormatter(duration.inSeconds % 60)}';
}

abstract class AppLockScreenProviders {
  static final remainingLockSeconds = FutureProvider.autoDispose<String>(
    (ref) async {
      final remainingDuration = await ref.watch(
        AuthenticationProviders.lockCountdown.future,
      );

      return DurationFormatters.hhmmss(remainingDuration);
    },
  );
}

class AppLockScreen extends ConsumerWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalization.of(context)!;
    final theme = ref.watch(ThemeProviders.selectedTheme);
    final activeVibrations = ref.watch(
      SettingsProviders.settings.select((value) => value.activeVibrations),
    );
    final isLocked =
        ref.watch(AuthenticationProviders.isLockCountdownRunning).valueOrNull ??
            true;
    final countDownString = ref
            .watch(
              AppLockScreenProviders.remainingLockSeconds,
            )
            .valueOrNull ??
        '';

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.backgroundDarkest,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      theme.background3Small!,
                    ),
                    fit: BoxFit.fitHeight,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[theme.backgroundDark!, theme.background!],
                  ),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) =>
                  SafeArea(
                minimum: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.035,
                  top: MediaQuery.of(context).size.height * 0.075,
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsetsDirectional.only(
                                  start: smallScreen(context) ? 15 : 20,
                                ),
                                height: 50,
                                child: TextButton(
                                  onPressed: () {
                                    final language = ref.read(
                                      LanguageProviders.selectedLanguage,
                                    );
                                    AppDialogs.showConfirmDialog(
                                        context,
                                        ref,
                                        CaseChange.toUpperCase(
                                          localizations.warning,
                                          language.getLocaleString(),
                                        ),
                                        localizations.removeWalletDetail,
                                        localizations.removeWalletAction, () {
                                      // Show another confirm dialog
                                      AppDialogs.showConfirmDialog(
                                        context,
                                        ref,
                                        localizations.areYouSure,
                                        localizations.removeWalletReassurance,
                                        localizations.yes,
                                        () async {
                                          await ref
                                              .read(
                                                SessionProviders
                                                    .session.notifier,
                                              )
                                              .logout();
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                            '/',
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                      );
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      FaIcon(
                                        FontAwesomeIcons.rightFromBracket,
                                        size: 16,
                                        color: theme.text,
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsetsDirectional.only(
                                          start: 4,
                                        ),
                                        child: Text(
                                          localizations.removeWallet,
                                          style:
                                              theme.textStyleSize14W600Primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isLocked)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Text(
                                localizations.locked,
                                style: theme.textStyleSize24W700EquinoxPrimary,
                              ),
                            ),
                          Container(
                            width: MediaQuery.of(context).size.width - 100,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 20,
                            ),
                            child: Text(
                              localizations.tooManyFailedAttempts,
                              style: theme.textStyleSize14W600Primary,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AppButtonTiny(
                          AppButtonTinyType.primary,
                          isLocked ? countDownString : localizations.unlock,
                          Dimens.buttonBottomDimens,
                          key: const Key('unlock'),
                          onPressed: () {
                            if (isLocked) return;

                            sl.get<HapticUtil>().feedback(
                                  FeedbackType.light,
                                  activeVibrations,
                                );
                            Navigator.pop(context);
                          },
                          disabled: isLocked,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
