/// SPDX-License-Identifier: AGPL-3.0-or-later
import 'dart:convert';
import 'dart:math';

import 'package:aewallet/domain/models/token_property.dart';
import 'package:archethic_lib_dart/archethic_lib_dart.dart' as archethic;
import 'package:flutter/foundation.dart';

extension AddTokenTransactionBuilder on archethic.Transaction {
  /// Builds a creation of token Transaction
  static archethic.Transaction build({
    required String tokenName,
    required double tokenInitialSupply,
    required String tokenSymbol,
    required String serviceName,
    required archethic.Keychain keychain,
    required archethic.KeyPair keyPair,
    required int index,
    required String originPrivateKey,
    required String tokenType,
    required List<int> aeip,
    required List<TokenProperty> tokenProperties,
  }) {
    final transaction = archethic.Transaction(
      type: 'token',
      data: archethic.Transaction.initData(),
    );

    var aesKey = '';
    if (tokenProperties.isNotEmpty) {
      aesKey = archethic.uint8ListToHex(
        Uint8List.fromList(
          List<int>.generate(32, (int i) => Random.secure().nextInt(256)),
        ),
      );
    }

    final tokenPropertiesNotProtected = <String, dynamic>{};
    for (final tokenProperty in tokenProperties) {
      if (tokenProperty.publicKeys.isEmpty) {
        tokenPropertiesNotProtected[tokenProperty.propertyName] =
            tokenProperty.propertyValue;
      } else {
        final authorizedPublicKeys = List<String>.empty(growable: true)
          ..add(archethic.uint8ListToHex(keyPair.publicKey));

        for (final publicKey in tokenProperty.publicKeys) {
          authorizedPublicKeys.add(
            publicKey.publicKey,
          );
        }

        final authorizedKeys =
            List<archethic.AuthorizedKey>.empty(growable: true);
        for (final key in authorizedPublicKeys) {
          authorizedKeys.add(
            archethic.AuthorizedKey(
              encryptedSecretKey:
                  archethic.uint8ListToHex(archethic.ecEncrypt(aesKey, key)),
              publicKey: key,
            ),
          );
        }

        final tokenPropertiesProtected = <String, dynamic>{};
        tokenPropertiesProtected[tokenProperty.propertyName] =
            tokenProperty.propertyValue;
        transaction.addOwnership(
          archethic.aesEncrypt(json.encode(tokenPropertiesProtected), aesKey),
          authorizedKeys,
        );
      }
    }

    final token = archethic.Token(
      name: tokenName,
      supply: archethic.toBigInt(tokenInitialSupply),
      type: tokenType,
      symbol: tokenSymbol,
      aeip: aeip,
      tokenProperties: tokenPropertiesNotProtected,
    );

    final content = archethic.tokenToJsonForTxDataContent(
      token,
    );
    transaction
      ..setContent(content)
      ..address = archethic.uint8ListToHex(
        keychain.deriveAddress(
          serviceName,
          index: index + 1,
        ),
      );

    return keychain
        .buildTransaction(
          transaction,
          serviceName,
          index,
        )
        .originSign(originPrivateKey);
  }
}
