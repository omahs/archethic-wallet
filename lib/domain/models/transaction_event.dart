import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'transaction_event.freezed.dart';

@freezed
class TransactionError with _$TransactionError {
  const TransactionError._();
  const factory TransactionError.timeout() = _TransactionTimeout;
  const factory TransactionError.connectivity() = _TransactionConnectionError;
  const factory TransactionError.consensusNotReached() =
      _TransactionConsensusNotReachedError;
  const factory TransactionError.invalidTransaction() = _TransactionInvalid;
  const factory TransactionError.invalidConfirmation() =
      _TransactionInvalidConfirmation;
  const factory TransactionError.insufficientFunds() =
      _TransactionInsufficientFunds;
  const factory TransactionError.other({
    String? reason,
  }) = _TransactionOtherError;

  String get message => map(
        timeout: (_) => 'connection timeout',
        connectivity: (_) => 'connectivity issue',
        consensusNotReached: (_) => 'consensus not reached',
        invalidTransaction: (_) => 'invalid transaction',
        invalidConfirmation: (_) => 'invalid confirmation',
        insufficientFunds: (_) => 'insufficient funds',
        other: (other) => other.reason ?? 'other reason',
      );
}

@freezed
class TransactionConfirmation with _$TransactionConfirmation {
  const factory TransactionConfirmation({
    required String transactionAddress,
    @Default(0) int nbConfirmations,
    @Default(0) int maxConfirmations,
  }) = _TransactionConfirmation;

  const TransactionConfirmation._();

  bool get isFullyConfirmed => nbConfirmations >= maxConfirmations;

  double get confirmationRatio => max(1, maxConfirmations / nbConfirmations);

  static bool isEnoughConfirmations(int nbConfirmations, int maxConfirmations) {
    if (nbConfirmations > 0) {
      return true;
    } else {
      return false;
    }
  }
}
