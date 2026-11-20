import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dompetku/core/database/database_helper.dart';
import 'package:dompetku/data/datasources/debt_datasource.dart';
import 'package:dompetku/data/models/debt_model.dart';
import 'package:dompetku/data/models/debt_payment_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DebtDatasource debtDatasource;

  setUp(() async {
    db = await DatabaseHelper().initDatabase(customPath: inMemoryDatabasePath);
    DatabaseHelper.setDatabaseForTesting(db);
    debtDatasource = DebtDatasource();
  });

  tearDown(() async {
    if (db.isOpen) {
      await db.close();
    }
    DatabaseHelper.setDatabaseForTesting(null);
  });

  test(
    'Pencatatan utang dan piutang baru berhasil disimpan dan diambil',
    () async {
      // 1. Simpan Utang (Payable)
      final debtId = await debtDatasource.insertDebt(
        DebtModel(
          direction: 'payable',
          personName: 'Bank Mandiri',
          principalAmount: 10000000,
          dueDate: DateTime(2027, 6, 30),
          note: 'Pinjaman renovasi',
          createdAt: DateTime.now(),
        ),
      );

      // 2. Simpan Piutang (Receivable)
      final receivableId = await debtDatasource.insertDebt(
        DebtModel(
          direction: 'receivable',
          personName: 'Andi Santoso',
          principalAmount: 2000000,
          createdAt: DateTime.now(),
        ),
      );

      expect(debtId, isPositive);
      expect(receivableId, isPositive);

      // 3. Ambil semua data
      final allDebts = await debtDatasource.getDebts();
      expect(allDebts.length, 2);

      // 4. Filter Utang saja
      final payables = await debtDatasource.getDebts(direction: 'payable');
      expect(payables.length, 1);
      expect(payables.first.personName, 'Bank Mandiri');
      expect(payables.first.isPayable, isTrue);
      expect(payables.first.isSettled, isFalse);
      expect(payables.first.paidAmount, 0);
      expect(payables.first.remainingAmount, 10000000);

      // 5. Filter Piutang saja
      final receivables = await debtDatasource.getDebts(
        direction: 'receivable',
      );
      expect(receivables.length, 1);
      expect(receivables.first.personName, 'Andi Santoso');
      expect(receivables.first.isReceivable, isTrue);

      // 6. Hitung total sisa pokok masing-masing
      final totalPayable = await debtDatasource.getTotalRemaining(
        direction: 'payable',
      );
      final totalReceivable = await debtDatasource.getTotalRemaining(
        direction: 'receivable',
      );
      expect(totalPayable, 10000000);
      expect(totalReceivable, 2000000);
    },
  );

  test(
    'Pembayaran sebagian memperbarui sisa utang dan total kewajiban',
    () async {
      final debtId = await debtDatasource.insertDebt(
        DebtModel(
          direction: 'payable',
          personName: 'Koperasi Karyawan',
          principalAmount: 5000000,
          createdAt: DateTime.now(),
        ),
      );

      // Cicilan 1: 1.500.000
      await debtDatasource.insertPayment(
        DebtPaymentModel(
          debtId: debtId,
          amount: 1500000,
          occurredAt: DateTime.now(),
          note: 'Cicilan bulan 1',
        ),
      );

      final debtAfter1 = await debtDatasource.getDebtById(debtId);
      expect(debtAfter1, isNotNull);
      expect(debtAfter1!.paidAmount, 1500000);
      expect(debtAfter1.remainingAmount, 3500000);
      expect(debtAfter1.isSettled, isFalse);

      // Cicilan 2: 1.000.000
      await debtDatasource.insertPayment(
        DebtPaymentModel(
          debtId: debtId,
          amount: 1000000,
          occurredAt: DateTime.now(),
          note: 'Cicilan bulan 2',
        ),
      );

      final debtAfter2 = await debtDatasource.getDebtById(debtId);
      expect(debtAfter2!.paidAmount, 2500000);
      expect(debtAfter2.remainingAmount, 2500000);

      final totalPayable = await debtDatasource.getTotalRemaining(
        direction: 'payable',
      );
      expect(totalPayable, 2500000);

      final payments = await debtDatasource.getPayments(debtId);
      expect(payments.length, 2);
    },
  );

  test('Pelunasan penuh otomatis mengubah status menjadi settled', () async {
    final debtId = await debtDatasource.insertDebt(
      DebtModel(
        direction: 'receivable',
        personName: 'Rudi',
        principalAmount: 1000000,
        createdAt: DateTime.now(),
      ),
    );

    // Bayar lunas 1.000.000 sekaligus
    await debtDatasource.insertPayment(
      DebtPaymentModel(
        debtId: debtId,
        amount: 1000000,
        occurredAt: DateTime.now(),
        note: 'Transfer lunas',
      ),
    );

    final debt = await debtDatasource.getDebtById(debtId);
    expect(debt!.isSettled, isTrue);
    expect(debt.remainingAmount, 0);
    expect(debt.status, 'settled');

    // Total piutang aktif harus 0 karena sudah lunas
    final totalReceivable = await debtDatasource.getTotalRemaining(
      direction: 'receivable',
    );
    expect(totalReceivable, 0);
  });

  test(
    'Pembayaran melebihi sisa tagihan harus melempar ArgumentError',
    () async {
      final debtId = await debtDatasource.insertDebt(
        DebtModel(
          direction: 'payable',
          personName: 'Teman',
          principalAmount: 500000,
          createdAt: DateTime.now(),
        ),
      );

      // Coba bayar 600.000 (melebihi pokok 500.000)
      expect(
        () => debtDatasource.insertPayment(
          DebtPaymentModel(
            debtId: debtId,
            amount: 600000,
            occurredAt: DateTime.now(),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test('Memperbarui data utang/piutang berhasil', () async {
    final debtId = await debtDatasource.insertDebt(
      DebtModel(
        direction: 'payable',
        personName: 'Budi Lama',
        principalAmount: 1000000,
        createdAt: DateTime.now(),
      ),
    );

    final existing = await debtDatasource.getDebtById(debtId);
    final updated = existing!.copyWith(
      personName: 'Budi Baru',
      principalAmount: 1200000,
    );

    await debtDatasource.updateDebt(updated);

    final result = await debtDatasource.getDebtById(debtId);
    expect(result!.personName, 'Budi Baru');
    expect(result.principalAmount, 1200000);
  });

  test(
    'Menghapus catatan utang secara CASCADE menghapus semua pembayarannya',
    () async {
      final debtId = await debtDatasource.insertDebt(
        DebtModel(
          direction: 'payable',
          personName: 'Hapus Me',
          principalAmount: 2000000,
          createdAt: DateTime.now(),
        ),
      );

      await debtDatasource.insertPayment(
        DebtPaymentModel(
          debtId: debtId,
          amount: 500000,
          occurredAt: DateTime.now(),
        ),
      );

      await debtDatasource.deleteDebt(debtId);

      final debts = await debtDatasource.getDebts();
      expect(debts.isEmpty, isTrue);

      final payments = await debtDatasource.getPayments(debtId);
      expect(payments.isEmpty, isTrue);
    },
  );
}
