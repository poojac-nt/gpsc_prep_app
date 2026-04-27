part of 'add_product_bloc.dart';

@immutable
abstract class AddProductState {}

class AddProductInitial extends AddProductState {}

class AddProductLoading extends AddProductState {}

class AddProductSuccess extends AddProductState {
  final ProductModel product;
  AddProductSuccess(this.product);
}

class AddProductFailure extends AddProductState {
  final String error;
  AddProductFailure(this.error);
}
