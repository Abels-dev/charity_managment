import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueX<T> on AsyncValue<T> {
  bool get isLoadingInitial => isLoading && !hasValue;

  String errorMessage() {
    return when(
      data: (_) => '',
      loading: () => '',
      error: (error, _) => error.toString(),
    );
  }

  Widget whenView({
    required Widget Function(T value) data,
    Widget? loading,
    Widget Function(Object error, StackTrace stackTrace)? errorBuilder,
  }) {
    return when(
      data: data,
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        if (errorBuilder != null) {
          return errorBuilder(error, stackTrace);
        }
        return Center(child: Text('Error: $error'));
      },
    );
  }
}
