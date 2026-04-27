part of 'add_product_bloc.dart';

@immutable
abstract class AddProductEvent {}

class AddProductRequested extends AddProductEvent {
  final ProductPayload payload;

  AddProductRequested({required this.payload});
}
