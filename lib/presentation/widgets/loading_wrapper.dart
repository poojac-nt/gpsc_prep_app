import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocLoadingWrapper<B extends BlocBase<S>, S> extends StatelessWidget {
  final Widget Function(bool isLoading) builder;
  final bool Function(S state) isLoadingSelector;

  const BlocLoadingWrapper({
    Key? key,
    required this.builder,
    required this.isLoadingSelector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      builder: (context, state) {
        final isLoading = isLoadingSelector(state);
        return builder(isLoading);
      },
    );
  }
}
