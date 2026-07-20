import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/repositories/wallet_repository.dart';

Future<String?> showAddMoneySheet(BuildContext context) async {
  final amountController = TextEditingController(text: 'Enter amount');
  final purposeController = TextEditingController(text: 'Enter purpose');

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
                              'Add Money to Wallet',
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
                      AppTextField(
                        controller: amountController,
                        label: 'Amount',
                        hint: 'Enter amount',
                        prefixIcon: Icons.currency_rupee_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      AppSizes.vGapMd,
                      AppTextField(
                        controller: purposeController,
                        label: 'Purpose',
                        hint: 'Enter purpose',
                        textInputAction: TextInputAction.done,
                      ),
                      AppSizes.vGapXl,
                      AppPrimaryButton(
                        label: 'Add Money',
                        isLoading: saving,
                        onPressed: () async {
                          final value = double.tryParse(
                            amountController.text.trim(),
                          );
                          if (value == null || value <= 0) {
                            setSheetState(() {
                              errorMessage = 'Enter a valid amount';
                            });
                            return;
                          }
                          final purpose = purposeController.text.trim();
                          if (purpose.isEmpty) {
                            setSheetState(() {
                              errorMessage = 'Purpose is required';
                            });
                            return;
                          }
                          setSheetState(() {
                            saving = true;
                            errorMessage = null;
                          });
                          final res = await sl<WalletRepository>().addMoney(
                            amount: value,
                            gateway: 'razorpay',
                            currency: 'INR',
                            purpose: purpose,
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
    amountController.dispose();
    purposeController.dispose();
  });
  return message;
}
