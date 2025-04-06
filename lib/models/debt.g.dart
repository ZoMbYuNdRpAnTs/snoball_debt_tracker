// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final int typeId = 0;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debt(
      name: fields[0] as String,
      startingBalance: fields[1] as double,
      balance: fields[2] as double,
      interestRate: fields[3] as double,
      minPayment: fields[4] as double,
      payments: (fields[5] as List).cast<Payment>(),
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.startingBalance)
      ..writeByte(2)
      ..write(obj.balance)
      ..writeByte(3)
      ..write(obj.interestRate)
      ..writeByte(4)
      ..write(obj.minPayment)
      ..writeByte(5)
      ..write(obj.payments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
