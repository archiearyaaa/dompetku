import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dompetku/core/database/database_helper.dart';
import 'package:dompetku/data/datasources/savings_datasource.dart';
import 'package:dompetku/data/models/savings_goal_model.dart';
import 'package:dompetku/data/models/savings_movement_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late SavingsDatasource savingsDatasource;

  setUp(() async {
    db = await DatabaseHelper().initDatabase(customPath: inMemoryDatabasePath);
    DatabaseHelper.setDatabaseForTesting(db);
    savingsDatasource = SavingsDatasource();
  });

  tearDown(() async {
    if (db.isOpen) {
      await db.close();
    }
    DatabaseHelper.setDatabaseForTesting(null);
  });

  test(
    'Target tabungan baru dapat ditambahkan dan diambil dengan benar',
    () async {
      final goal = SavingsGoalModel(
        name: 'Dana Darurat',
        targetAmount: 10000000,
        targetDate: DateTime(2027, 12, 31),
        isArchived: false,
        createdAt: DateTime.now(),
      );

      final goalId = await savingsDatasource.insertSavingsGoal(goal);
      expect(goalId, isPositive);

      final goals = await savingsDatasource.getSavingsGoals();
      expect(goals.length, 1);
      expect(goals.first.id, goalId);
      expect(goals.first.name, 'Dana Darurat');
      expect(goals.first.targetAmount, 10000000);
      expect(goals.first.currentAmount, 0);
      expect(goals.first.isAchieved, isFalse);
      expect(goals.first.remainingAmount, 10000000);
    },
  );

  test(
    'Mutasi setoran menambah saldo target tabungan dan total tabungan',
    () async {
      final goalId = await savingsDatasource.insertSavingsGoal(
        SavingsGoalModel(
          name: 'Liburan Akhir Tahun',
          targetAmount: 5000000,
          createdAt: DateTime.now(),
        ),
      );

      // Setoran 1: 1.500.000
      await savingsDatasource.insertMovement(
        SavingsMovementModel(
          goalId: goalId,
          amount: 1500000,
          type: 'deposit',
          note: 'Gaji bulan ini',
          occurredAt: DateTime.now(),
        ),
      );

      // Setoran 2: 500.000
      await savingsDatasource.insertMovement(
        SavingsMovementModel(
          goalId: goalId,
          amount: 500000,
          type: 'deposit',
          note: 'Sisa uang jajan',
          occurredAt: DateTime.now(),
        ),
      );

      final updatedGoal = await savingsDatasource.getSavingsGoalById(goalId);
      expect(updatedGoal, isNotNull);
      expect(updatedGoal!.currentAmount, 2000000);
      expect(updatedGoal.remainingAmount, 3000000);
      expect(updatedGoal.progressPercentage, closeTo(0.4, 0.001));

      final totalSavings = await savingsDatasource.getTotalSavings();
      expect(totalSavings, 2000000);

      final movements = await savingsDatasource.getMovements(goalId);
      expect(movements.length, 2);
    },
  );

  test('Mutasi penarikan mengurangi saldo tabungan', () async {
    final goalId = await savingsDatasource.insertSavingsGoal(
      SavingsGoalModel(
        name: 'Beli Gadget',
        targetAmount: 3000000,
        createdAt: DateTime.now(),
      ),
    );

    // Setor 2.000.000
    await savingsDatasource.insertMovement(
      SavingsMovementModel(
        goalId: goalId,
        amount: 2000000,
        type: 'deposit',
        occurredAt: DateTime.now(),
      ),
    );

    // Tarik 500.000
    await savingsDatasource.insertMovement(
      SavingsMovementModel(
        goalId: goalId,
        amount: 500000,
        type: 'withdrawal',
        note: 'Keperluan mendesak',
        occurredAt: DateTime.now(),
      ),
    );

    final goal = await savingsDatasource.getSavingsGoalById(goalId);
    expect(goal!.currentAmount, 1500000);

    final total = await savingsDatasource.getTotalSavings();
    expect(total, 1500000);
  });

  test(
    'Penarikan melebihi saldo tabungan harus melempar ArgumentError',
    () async {
      final goalId = await savingsDatasource.insertSavingsGoal(
        SavingsGoalModel(
          name: 'Tabungan Motor',
          targetAmount: 20000000,
          createdAt: DateTime.now(),
        ),
      );

      // Setor 1.000.000
      await savingsDatasource.insertMovement(
        SavingsMovementModel(
          goalId: goalId,
          amount: 1000000,
          type: 'deposit',
          occurredAt: DateTime.now(),
        ),
      );

      // Coba tarik 1.500.000 (melebihi saldo 1.000.000)
      expect(
        () => savingsDatasource.insertMovement(
          SavingsMovementModel(
            goalId: goalId,
            amount: 1500000,
            type: 'withdrawal',
            occurredAt: DateTime.now(),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test('Update target tabungan berhasil mengubah data', () async {
    final goalId = await savingsDatasource.insertSavingsGoal(
      SavingsGoalModel(
        name: 'Renovasi Kamar',
        targetAmount: 5000000,
        createdAt: DateTime.now(),
      ),
    );

    final existing = await savingsDatasource.getSavingsGoalById(goalId);
    final updated = existing!.copyWith(
      name: 'Renovasi Rumah',
      targetAmount: 8000000,
    );

    await savingsDatasource.updateSavingsGoal(updated);

    final result = await savingsDatasource.getSavingsGoalById(goalId);
    expect(result!.name, 'Renovasi Rumah');
    expect(result.targetAmount, 8000000);
  });

  test(
    'Mengarsipkan target tabungan menyembunyikannya dari daftar aktif',
    () async {
      final goalId = await savingsDatasource.insertSavingsGoal(
        SavingsGoalModel(
          name: 'Target Sementara',
          targetAmount: 1000000,
          createdAt: DateTime.now(),
        ),
      );

      await savingsDatasource.archiveSavingsGoal(goalId);

      final activeGoals = await savingsDatasource.getSavingsGoals(
        includeArchived: false,
      );
      expect(activeGoals.any((g) => g.id == goalId), isFalse);

      final allGoals = await savingsDatasource.getSavingsGoals(
        includeArchived: true,
      );
      expect(allGoals.any((g) => g.id == goalId), isTrue);
    },
  );

  test(
    'Menghapus target tabungan secara otomatis menghapus mutasi terkait (CASCADE)',
    () async {
      final goalId = await savingsDatasource.insertSavingsGoal(
        SavingsGoalModel(
          name: 'Target Hapus',
          targetAmount: 2000000,
          createdAt: DateTime.now(),
        ),
      );

      await savingsDatasource.insertMovement(
        SavingsMovementModel(
          goalId: goalId,
          amount: 500000,
          type: 'deposit',
          occurredAt: DateTime.now(),
        ),
      );

      // Hapus goal
      await savingsDatasource.deleteSavingsGoal(goalId);

      final goals = await savingsDatasource.getSavingsGoals();
      expect(goals.isEmpty, isTrue);

      final movements = await savingsDatasource.getMovements(goalId);
      expect(movements.isEmpty, isTrue);
    },
  );
}
