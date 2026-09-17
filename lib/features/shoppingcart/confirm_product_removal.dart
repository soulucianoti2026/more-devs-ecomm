import 'package:flutter/material.dart';

Future<bool> confirmProductRemoval(
  BuildContext context,
  String productName,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Remover produto?'),
          content: Text(
            'A quantidade de "$productName" ficará zerada '
            'e o produto será removido do carrinho. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;
}
