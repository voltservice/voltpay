import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipient_provider.freezed.dart';
part 'recipient_provider.g.dart';

/// How the user wants to add a recipient.
enum RecipientMethod {
  voltpayLookup, // VoltPay tag / email / mobile
  bankDetails, // Full name + IBAN
  documentUpload, // Image/PDF import
  emailRequest, // Ask recipient by email
}

/// Discriminated union for the input of each method.
/// You get exhaustiveness checking in switch/case.
@freezed
sealed class RecipientParams with _$RecipientParams {
  const RecipientParams._();

  /// 1) Find on VoltPay
  const factory RecipientParams.voltpayLookup({
    /// VoltPay tag, prefixed or not (e.g. @sam or sam)
    @Default('') String voltTag,

    /// Optional fallback identifiers
    @Default('') String email,
    @Default('') String mobile,

    /// Optional note to include
    @Default('') String note,
  }) = _VoltpayLookup;

  /// 2) Bank details
  const factory RecipientParams.bankDetails({
    @Default('') String fullName,
    @Default('') String iban,
    @Default('') String bic,
    @Default('') String swift,
    @Default('') String bankName,
    @Default('') String bankAddress,
    @Default('') String bankCity,
    @Default('') String bankCountry,
    @Default('') String bankPostalCode,
  }) = _BankDetails;

  /// 3) Uploading Document
  const factory RecipientParams.documentUpload({
    /// Local file path or uploaded storage id
    @Default('') String fileRef,

    /// MIME/type label if you want to constrain later
    @Default('') String docType,

    /// Optional note to include
    @Default('') String note,
  }) = _DocumentUpload;

  /// 4) Pay by email
  const factory RecipientParams.emailRequest({
    @Default('') String email,
    @Default('') String fullName,

    /// optional note to include
    @Default('') String note,
  }) = _EmailRequest;

  factory RecipientParams.fromJson(Map<String, dynamic> json) =>
      _$RecipientParamsFromJson(json);

  /// Quick helpers
  RecipientMethod get method => when(
    voltpayLookup: (String voltTag, String email, String mobile, String note) =>
        RecipientMethod.voltpayLookup,
    bankDetails:
        (
          String fullName,
          String iban,
          String bic,
          String swift,
          String bankName,
          String bankAddress,
          String bankCity,
          String bankCountry,
          String bankPostalCode,
        ) => RecipientMethod.bankDetails,
    documentUpload: (String fileRef, String docType, String note) =>
        RecipientMethod.documentUpload,
    emailRequest: (String email, String fullName, String note) =>
        RecipientMethod.emailRequest,
  );

  bool get isMeaningful => when(
    voltpayLookup: (String voltTag, String email, String mobile, String note) =>
        voltTag.isNotEmpty || email.isNotEmpty || mobile.isNotEmpty,
    bankDetails:
        (
          String fullName,
          String iban,
          String bic,
          String swift,
          String bankName,
          String bankAddress,
          String bankCity,
          String bankCountry,
          String bankPostalCode,
        ) => fullName.trim().isNotEmpty && iban.trim().isNotEmpty,
    documentUpload: (String fileRef, String docType, String note) =>
        fileRef.isNotEmpty,
    emailRequest: (String email, String fullName, String note) =>
        email.isNotEmpty,
  );
}

extension RecipientParamsX on RecipientParams {
  RecipientMethod get method => when(
    voltpayLookup: (String voltTag, String email, String mobile, String note) =>
        RecipientMethod.voltpayLookup,
    bankDetails:
        (
          String fullName,
          String iban,
          String bic,
          String swift,
          String bankName,
          String bankAddress,
          String bankCity,
          String bankCountry,
          String bankPostalCode,
        ) => RecipientMethod.bankDetails,
    documentUpload: (String fileRef, String docType, String note) =>
        RecipientMethod.documentUpload,
    emailRequest: (String email, String fullName, String note) =>
        RecipientMethod.emailRequest,
  );

  bool get isMeaningful => when(
    voltpayLookup: (String voltTag, String email, String mobile, String note) =>
        voltTag.isNotEmpty || email.isNotEmpty || mobile.isNotEmpty,
    bankDetails:
        (
          String fullName,
          String iban,
          String bic,
          String swift,
          String bankName,
          String bankAddress,
          String bankCity,
          String bankCountry,
          String bankPostalCode,
        ) => fullName.trim().isNotEmpty && iban.trim().isNotEmpty,
    documentUpload: (String fileRef, String docType, String note) =>
        fileRef.isNotEmpty,
    emailRequest: (String email, String fullName, String note) =>
        email.isNotEmpty,
  );

  /// Optional: a normalized payload for API calls.
  Map<String, Object?> toPayload() => map(
    voltpayLookup: (_VoltpayLookup v) => <String, Object?>{
      'method': 'voltpayLookup',
      'voltTag': v.voltTag,
      'email': v.email,
      'mobile': v.mobile,
      if (v.note.isNotEmpty) 'note': v.note,
    },
    bankDetails: (_BankDetails b) => <String, Object?>{
      'method': 'bankDetails',
      'fullName': b.fullName,
      'iban': b.iban,
      if (b.bic.isNotEmpty) 'bic': b.bic,
      if (b.swift.isNotEmpty) 'swift': b.swift,
      if (b.bankName.isNotEmpty) 'bankName': b.bankName,
      if (b.bankAddress.isNotEmpty) 'bankAddress': b.bankAddress,
      if (b.bankCity.isNotEmpty) 'bankCity': b.bankCity,
      if (b.bankCountry.isNotEmpty) 'bankCountry': b.bankCountry,
      if (b.bankPostalCode.isNotEmpty) 'bankPostalCode': b.bankPostalCode,
    },
    documentUpload: (_DocumentUpload d) => <String, Object?>{
      'method': 'documentUpload',
      'fileRef': d.fileRef,
      if (d.docType.isNotEmpty) 'docType': d.docType,
      if (d.note.isNotEmpty) 'note': d.note,
    },
    emailRequest: (_EmailRequest e) => <String, Object?>{
      'method': 'emailRequest',
      'email': e.email,
      if (e.fullName.isNotEmpty) 'fullName': e.fullName,
      if (e.note.isNotEmpty) 'note': e.note,
    },
  );

  /// Optional: field hints to drive forms dynamically.
  List<String> requiredFields() => when(
    voltpayLookup: (_, _, _, _) => const <String>['voltTag|email|mobile'],
    bankDetails: (_, String _, _, _, _, _, _, _, _) => const <String>[
      'fullName',
      'iban',
    ],
    documentUpload: (_, _, _) => const <String>['fileRef'],
    emailRequest: (_, _, _) => const <String>['email'],
  );
}
