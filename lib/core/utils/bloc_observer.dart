import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    developer.log('onCreate -- ${bloc.runtimeType}', name: 'BlocObserver');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    developer.log(
      'onEvent -- ${bloc.runtimeType}: $event',
      name: 'BlocObserver',
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    developer.log(
      'onChange -- ${bloc.runtimeType}: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
      name: 'BlocObserver',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    developer.log(
      'onTransition -- ${bloc.runtimeType}: ${transition.event.runtimeType}',
      name: 'BlocObserver',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    developer.log(
      'onError -- ${bloc.runtimeType}: $error',
      name: 'BlocObserver',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    developer.log('onClose -- ${bloc.runtimeType}', name: 'BlocObserver');
  }
}
