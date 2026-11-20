import 'package:flutter_test/flutter_test.dart';

import 'package:dompetku/data/models/category_model.dart';
import 'package:dompetku/data/models/debt_model.dart';
import 'package:dompetku/data/models/debt_payment_model.dart';
import 'package:dompetku/data/models/savings_goal_model.dart';
import 'package:dompetku/data/models/savings_movement_model.dart';
import 'package:dompetku/data/models/transaction_model.dart';

void main() {
  group('CategoryModel', () {
    test('fromMap dan toMap bekerja bolak-balik', () {
      final now = DateTime(2026, 11, 19, 12, 0);
      final model = CategoryModel(
        id: 1,
        name: 'Gaji',
        type: 'income',
        icon: 'wallet',
        color: '0xFF22C55E',
        isDefault: true,
        isArchived: false,
        createdAt: now,
      );

      final map = model.toMap();
      final fromMap = CategoryModel.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.name, 'Gaji');
      expect(fromMap.type, 'income');
      expect(fromMap.icon, 'wallet');
      expect(fromMap.isDefault, isTrue);
      expect(fromMap.isArchived, isFalse);
      expect(fromMap.createdAt, now);
    });

    test('copyWith memperbarui field yang ditentukan', () {
      final model = CategoryModel(
        id: 1,
        name: 'Lama',
        type: 'expense',
        createdAt: DateTime.now(),
      );

      final updated = model.copyWith(name: 'Baru');
      expect(updated.name, 'Baru');
      expect(updated.id, 1);
      expect(updated.type, 'expense');
    });
  });

  group('TransactionModel', () {
    test('fromMap dan toMap valid', () {
      final now = DateTime(2026, 11, 19, 14, 0);
      final model = TransactionModel(
        id: 10,
        type: 'expense',
        amount: 25000,
        categoryId: 2,
        note: 'Makan siang',
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(model.isExpense, isTrue);
      expect(model.isIncome, isFalse);

      final map = model.toMap();
      final fromMap = TransactionModel.fromMap(map);

      expect(fromMap.id, 10);
      expect(fromMap.amount, 25000);
      expect(fromMap.note, 'Makan siang');
    });

    test('assert melempar AssertionError jika nominal <= 0', () {
      expect(
        () => TransactionModel(
          type: 'income',
          amount: 0,
          categoryId: 1,
          occurredAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('SavingsGoalModel & SavingsMovementModel', () {
    test('kalkulasi progres dan sisa tabungan', () {
      final goal = SavingsGoalModel(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000,
        createdAt: DateTime.now(),
        currentAmount: 2500000,
      );

      expect(goal.progressPercentage, 0.25);
      expect(goal.remainingAmount, 7500000);
      expect(goal.isAchieved, isFalse);

      final achievedGoal = goal.copyWith(currentAmount: 12000000);
      expect(achievedGoal.progressPercentage, 1.0);
      expect(achievedGoal.remainingAmount, 0);
      expect(achievedGoal.isAchieved, isTrue);
    });

    test('SavingsMovementModel mendeteksi tipe deposit/withdrawal', () {
      final deposit = SavingsMovementModel(
        goalId: 1,
        type: 'deposit',
        amount: 500000,
        occurredAt: DateTime.now(),
      );
      expect(deposit.isDeposit, isTrue);
      expect(deposit.isWithdrawal, isFalse);

      final withdrawal = SavingsMovementModel(
        goalId: 1,
        type: 'withdrawal',
        amount: 200000,
        occurredAt: DateTime.now(),
      );
      expect(withdrawal.isDeposit, isFalse);
      expect(withdrawal.isWithdrawal, isTrue);
    });
  });

  group('DebtModel & DebtPaymentModel', () {
    test('kalkulasi sisa utang dan status lunas', () {
      final debt = DebtModel(
        id: 1,
        direction: 'payable',
        personName: 'Budi',
        principalAmount: 500000,
        createdAt: DateTime.now(),
        paidAmount: 200000,
      );

      expect(debt.isPayable, isTrue);
      expect(debt.isReceivable, isFalse);
      expect(debt.remainingAmount, 300000);
      expect(debt.isSettled, isFalse);

      final settledDebt = debt.copyWith(paidAmount: 500000);
      expect(settledDebt.remainingAmount, 0);
      expect(settledDebt.isSettled, isTrue);
    });

    test('DebtPaymentModel fromMap dan toMap bekerja benar', () {
      final now = DateTime(2026, 11, 19);
      final payment = DebtPaymentModel(
        id: 5,
        debtId: 1,
        amount: 150000,
        occurredAt: now,
        note: 'Cicilan 1',
      );

      final map = payment.toMap();
      final fromMap = DebtPaymentModel.fromMap(map);

      expect(fromMap.id, 5);
      expect(fromMap.amount, 150000);
      expect(fromMap.note, 'Cicilan 1');
    });
  });
}
