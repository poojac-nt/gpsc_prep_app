import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/models/payloads/product_payload.dart';
import 'package:gpsc_prep_app/data/repositories/admin_repository.dart';
import 'package:gpsc_prep_app/domain/entities/product_model.dart';
import 'package:meta/meta.dart';

part 'add_product_event.dart';
part 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final AdminRepository _adminRepository;

  AddProductBloc(this._adminRepository) : super(AddProductInitial()) {
    on<AddProductRequested>(_onAddProductRequested);
  }

  Future<void> _onAddProductRequested(
    AddProductRequested event,
    Emitter<AddProductState> emit,
  ) async {
    emit(AddProductLoading());
    final result = await _adminRepository.createProduct(event.payload);

    result.fold(
      (failure) => emit(AddProductFailure(failure.message)),
      (product) => emit(AddProductSuccess(product)),
    );
  }
}
