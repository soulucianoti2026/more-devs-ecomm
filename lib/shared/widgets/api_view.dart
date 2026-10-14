import 'package:flutter/material.dart';

class ApiView<T> extends StatefulWidget {
  const ApiView({super.key, required this.load, required this.builder});
  final Future<T> Function() load;
  final Widget Function(BuildContext, T) builder;
  @override
  State<ApiView<T>> createState() => _ApiViewState<T>();
}

class _ApiViewState<T> extends State<ApiView<T>> {
  late Future<T> _future;
  @override
  void initState() {
    super.initState();
    _future = Future<T>(() => widget.load());
  }

  Future<void> _reload() async {
    final future = widget.load();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      /* FutureBuilder displays the error. */
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(snapshot.error.toString(), textAlign: TextAlign.center),
                TextButton(
                  onPressed: _reload,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _reload,
        child: widget.builder(context, snapshot.data as T),
      );
    },
  );
}
