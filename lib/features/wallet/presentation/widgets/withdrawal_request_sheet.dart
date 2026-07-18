import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

Future<String?> showWithdrawalRequestSheet(
  BuildContext context, {
  required WalletSummary summary,
}) async {
  final amount = TextEditingController();
  final accountHolderName = TextEditingController();
  final accountNumber = TextEditingController();
  final ifscCode = TextEditingController();
  final bankName = TextEditingController();
  final upiId = TextEditingController();
  var method = 'bank';
  final message = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
      final safeBottom = MediaQuery.of(sheetContext).padding.bottom;
      final maxSheetHeight = MediaQuery.of(sheetContext).size.height * 0.95;
      var saving = false;
      String? errorMessage;
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.sm,
                  AppSizes.lg,
                  bottomInset + safeBottom + AppSizes.lg,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Request Withdrawal',
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: saving
                                ? null
                                : () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    Navigator.of(sheetContext).pop();
                                  },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      if (errorMessage != null) ...[
                        AppSizes.vGapMd,
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.md),
                            child: Text(
                              errorMessage!,
                              style: Theme.of(sheetContext).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.danger),
                            ),
                          ),
                        ),
                      ],
                      AppSizes.vGapMd,
                      Text(
                        'Available: ${Formatters.currency(summary.available)}',
                        style: context.text.labelMedium,
                      ),
                      AppSizes.vGapMd,
                      AppTextField(
                        controller: amount,
                        label: 'Amount',
                        hint: 'Enter amount',
                        prefixIcon: Icons.currency_rupee_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      AppSizes.vGapMd,
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'bank',
                            label: Text(context.tr('Bank')),
                            icon: const Icon(Icons.account_balance_outlined),
                          ),
                          ButtonSegment(
                            value: 'upi',
                            label: Text(context.tr('UPI')),
                            icon: const Icon(Icons.qr_code_2_rounded),
                          ),
                        ],
                        selected: {method},
                        onSelectionChanged: saving
                            ? null
                            : (values) {
                                setSheetState(() {
                                  method = values.first;
                                  errorMessage = null;
                                });
                              },
                      ),
                      if (method == 'bank') ...[
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: accountHolderName,
                          label: 'Account holder name',
                          hint: 'Enter name',
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: accountNumber,
                          label: 'Account number',
                          hint: 'Enter account number',
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: ifscCode,
                          label: 'IFSC code',
                          hint: 'Enter Ifsc Code',
                          textInputAction: TextInputAction.next,
                        ),
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: bankName,
                          label: 'Bank name',
                          hint: 'Enter bank name',
                          textInputAction: TextInputAction.done,
                        ),
                      ] else ...[
                        AppSizes.vGapMd,
                        AppTextField(
                          controller: upiId,
                          label: 'UPI ID',
                          hint: 'Enter UPI ID',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                      AppSizes.vGapXl,
                      AppPrimaryButton(
                        label: 'Submit Request',
                        isLoading: saving,
                        onPressed: () async {
                          final value = double.tryParse(amount.text.trim());
                          if (value == null || value <= 0) {
                            setSheetState(() {
                              errorMessage = 'Enter a valid amount';
                            });
                            return;
                          }
                          if (value > summary.available) {
                            setSheetState(() {
                              errorMessage =
                                  'Amount cannot exceed available balance';
                            });
                            return;
                          }
                          final bankPayload = {
                            'accountHolderName': accountHolderName.text.trim(),
                            'accountNumber': accountNumber.text.trim(),
                            'ifscCode': ifscCode.text.trim(),
                            'bankName': bankName.text.trim(),
                          };
                          final upiPayload = {'upiId': upiId.text.trim()};
                          if (method == 'bank' &&
                              bankPayload.values.any((v) => v.isEmpty)) {
                            setSheetState(() {
                              errorMessage = 'Enter all bank details';
                            });
                            return;
                          }
                          if (method == 'upi' && upiPayload['upiId']!.isEmpty) {
                            setSheetState(() {
                              errorMessage = 'Enter UPI ID';
                            });
                            return;
                          }
                          setSheetState(() {
                            saving = true;
                            errorMessage = null;
                          });
                          final res = await sl<WalletRepository>()
                              .requestWithdrawal(
                                amount: value,
                                method: method,
                                bankDetails: method == 'bank'
                                    ? bankPayload
                                    : null,
                                upiDetails: method == 'upi' ? upiPayload : null,
                              );
                          if (!sheetContext.mounted) return;
                          res.fold(
                            (failure) {
                              setSheetState(() {
                                saving = false;
                                errorMessage = failure.message;
                              });
                            },
                            (successMessage) {
                              Navigator.of(sheetContext).pop(successMessage);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
  Future<void>.delayed(const Duration(milliseconds: 350), () {
    amount.dispose();
    accountHolderName.dispose();
    accountNumber.dispose();
    ifscCode.dispose();
    bankName.dispose();
    upiId.dispose();
  });
  return message;
}
