/// SPDX-License-Identifier: AGPL-3.0-or-later
import 'package:aewallet/application/settings/settings.dart';
import 'package:aewallet/application/settings/theme.dart';
import 'package:aewallet/localization.dart';
import 'package:aewallet/ui/util/styles.dart';
import 'package:aewallet/ui/widgets/components/icons.dart';
import 'package:aewallet/util/get_it_instance.dart';
import 'package:aewallet/util/haptic_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

/// A widget for displaying a mnemonic phrase
class MnemonicDisplay extends ConsumerStatefulWidget {
  const MnemonicDisplay({
    super.key,
    required this.wordList,
    this.obscureSeed = false,
    required this.explanation,
  });

  final List<String> wordList;
  final bool obscureSeed;
  final Widget explanation;

  @override
  ConsumerState<MnemonicDisplay> createState() => _MnemonicDisplayState();
}

class _MnemonicDisplayState extends ConsumerState<MnemonicDisplay> {
  late bool _seedObscured;
  int curWord = 0;

  @override
  void initState() {
    super.initState();
    _seedObscured = true;
    curWord = 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(ThemeProviders.selectedTheme);
    final preferences = ref.watch(SettingsProviders.settings);
    return Column(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            sl.get<HapticUtil>().feedback(
                  FeedbackType.light,
                  preferences.activeVibrations,
                );
            if (widget.obscureSeed) {
              setState(() {
                _seedObscured = !_seedObscured;
              });
            }
          },
          child: Column(
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.center,
                children: widget.wordList.asMap().entries.map((MapEntry entry) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Chip(
                      avatar: CircleAvatar(
                        backgroundColor: theme.numMnemonicBackground,
                        child: Text(
                          (entry.key + 1).toString(),
                          style: theme.textStyleSize12W100Primary60,
                        ),
                      ),
                      label: Text(
                        _seedObscured && widget.obscureSeed
                            ? '•' * 6
                            : entry.value,
                        style: theme.textStyleSize12W400Primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Tap to reveal or hide
              if (widget.obscureSeed)
                Container(
                  margin: const EdgeInsetsDirectional.only(top: 8),
                  child: _seedObscured
                      ? AutoSizeText(
                          AppLocalization.of(context)!.tapToReveal,
                          style: theme.textStyleSize14W600Primary,
                        )
                      : Text(
                          AppLocalization.of(context)!.tapToHide,
                          style: theme.textStyleSize14W600Primary,
                        ),
                ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        UiIcons.about,
                        color: theme.text,
                        size: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    widget.explanation,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
