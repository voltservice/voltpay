// // lib/features/recipient/providers/recipient_controller.dart
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:voltpay/features/recipient/provider/recipient_provider.dart';
//
// part 'recipient_controller.g.dart';
//
// @riverpod
// class RecipientController extends _$RecipientController {
//   @override
//   RecipientParams build() => const RecipientParams.voltpayLookup();
//
//   // 🔹 New methods:
//   void reset() => state = const RecipientParams.voltpayLookup();
//   void update(RecipientParams newParams) => state = newParams;
//
//   void selectMethod(RecipientMethod method) {
//     state = switch (method) {
//       RecipientMethod.voltpayLookup => const RecipientParams.voltpayLookup(),
//       RecipientMethod.bankDetails => const RecipientParams.bankDetails(),
//       RecipientMethod.documentUpload => const RecipientParams.documentUpload(),
//       RecipientMethod.emailRequest => const RecipientParams.emailRequest(),
//     };
//   }
//
//   void patchVoltpay({
//     String? tag,
//     String? email,
//     String? mobile,
//     String? note,
//   }) {
//     state = state.maybeMap(
//       voltpayLookup: (s) => s.copyWith(
//         voltTag: tag ?? s.voltTag,
//         email: email ?? s.email,
//         mobile: mobile ?? s.mobile,
//         note: note ?? s.note,
//       ),
//       orElse: () => state,
//     );
//   }
//
//   void patchBank({
//     String? fullName,
//     String? iban,
//     String? bic,
//     String? swift,
//     String? bankName,
//     String? bankAddress,
//     String? bankCity,
//     String? bankCountry,
//     String? bankPostalCode,
//   }) {
//     state = state.maybeMap(
//       bankDetails: (s) => s.copyWith(
//         fullName: fullName ?? s.fullName,
//         iban: iban ?? s.iban,
//         bic: bic ?? s.bic,
//         swift: swift ?? s.swift,
//         bankName: bankName ?? s.bankName,
//         bankAddress: bankAddress ?? s.bankAddress,
//         bankCity: bankCity ?? s.bankCity,
//         bankCountry: bankCountry ?? s.bankCountry,
//         bankPostalCode: bankPostalCode ?? s.bankPostalCode,
//       ),
//       orElse: () => state,
//     );
//   }
//
//   void patchDocument({String? fileRef, String? docType, String? note}) {
//     state = state.maybeMap(
//       documentUpload: (s) => s.copyWith(
//         fileRef: fileRef ?? s.fileRef,
//         docType: docType ?? s.docType,
//         note: note ?? s.note,
//       ),
//       orElse: () => state,
//     );
//   }
//
//   void patchEmailRequest({String? email, String? fullName, String? note}) {
//     state = state.maybeMap(
//       emailRequest: (s) => s.copyWith(
//         email: email ?? s.email,
//         fullName: fullName ?? s.fullName,
//         note: note ?? s.note,
//       ),
//       orElse: () => state,
//     );
//   }
//
//   // 🔹 Now these are trivial:
//   RecipientMethod get method => state.method;
//   bool get isValid => state.isMeaningful;
//
//   Map<String, Object?> get payload => state.toPayload();
//   List<String> get required => state.requiredFields();
// }
// lib/features/recipient/providers/recipient_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/features/recipient/provider/recipient_provider.dart';

part 'recipient_controller.g.dart';

@riverpod
class RecipientController extends _$RecipientController {
  @override
  RecipientParams build() => const RecipientParams.voltpayLookup();

  void reset() => state = const RecipientParams.voltpayLookup();
  void update(RecipientParams newParams) => state = newParams;

  void selectMethod(RecipientMethod method) {
    state = switch (method) {
      RecipientMethod.voltpayLookup => const RecipientParams.voltpayLookup(),
      RecipientMethod.bankDetails => const RecipientParams.bankDetails(),
      RecipientMethod.documentUpload => const RecipientParams.documentUpload(),
      RecipientMethod.emailRequest => const RecipientParams.emailRequest(),
    };
  }

  // ---------- Patchers (use maybeWhen so we type fields, not private variants) ----------

  void patchVoltpay({
    String? tag,
    String? email,
    String? mobile,
    String? note,
  }) {
    state = state.maybeWhen(
      voltpayLookup: (String voltTag, String em, String mob, String nt) =>
          RecipientParams.voltpayLookup(
            voltTag: tag ?? voltTag,
            email: email ?? em,
            mobile: mobile ?? mob,
            note: note ?? nt,
          ),
      orElse: () => state,
    );
  }

  void patchBank({
    String? fullName,
    String? iban,
    String? bic,
    String? swift,
    String? bankName,
    String? bankAddress,
    String? bankCity,
    String? bankCountry,
    String? bankPostalCode,
  }) {
    state = state.maybeWhen(
      bankDetails:
          (
            String fn,
            String ib,
            String bc,
            String sw,
            String bName,
            String bAddr,
            String bCity,
            String bCountry,
            String bPost,
          ) => RecipientParams.bankDetails(
            fullName: fullName ?? fn,
            iban: iban ?? ib,
            bic: bic ?? bc,
            swift: swift ?? sw,
            bankName: bankName ?? bName,
            bankAddress: bankAddress ?? bAddr,
            bankCity: bankCity ?? bCity,
            bankCountry: bankCountry ?? bCountry,
            bankPostalCode: bankPostalCode ?? bPost,
          ),
      orElse: () => state,
    );
  }

  void patchDocument({String? fileRef, String? docType, String? note}) {
    state = state.maybeWhen(
      documentUpload: (String fr, String dt, String nt) =>
          RecipientParams.documentUpload(
            fileRef: fileRef ?? fr,
            docType: docType ?? dt,
            note: note ?? nt,
          ),
      orElse: () => state,
    );
  }

  void patchEmailRequest({String? email, String? fullName, String? note}) {
    state = state.maybeWhen(
      emailRequest: (String em, String fn, String nt) =>
          RecipientParams.emailRequest(
            email: email ?? em,
            fullName: fullName ?? fn,
            note: note ?? nt,
          ),
      orElse: () => state,
    );
  }

  // ---------- Read-only helpers ----------
  RecipientMethod get method => state.method;
  bool get isValid => state.isMeaningful;
  Map<String, Object?> get payload => state.toPayload();
  List<String> get required => state.requiredFields();
}
