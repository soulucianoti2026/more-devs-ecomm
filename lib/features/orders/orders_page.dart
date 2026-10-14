import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';
import 'package:more_devs_do_zero/shared/widgets/api_view.dart';
import 'package:provider/provider.dart';

String orderStatus(String status) => switch (status) {
  'PENDING' => 'Pendente',
  'PAID' => 'Pago',
  'SHIPPED' => 'Enviado',
  'DELIVERED' => 'Entregue',
  'CANCELED' => 'Cancelado',
  _ => status,
};
String money(num value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
String orderDate(String value) {
  final date = DateTime.parse(value).toLocal();
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  static const route = '/orders';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Meus pedidos')),
    body: ApiView<List<Map<String, dynamic>>>(
      load: context.read<StoreService>().getOrders,
      builder: (context, orders) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Você ainda não tem pedidos.'),
            ),
          for (final order in orders)
            ListTile(
              title: Text(
                '${orderDate(order['createdAt'] as String)} • ${orderStatus(order['status'] as String)}',
              ),
              subtitle: Text(
                '${order['itemCount']} itens • ${money(order['total'] as num)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                OrderDetailPage.route,
                arguments: order['id'],
              ),
            ),
        ],
      ),
    ),
  );
}

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.orderId});
  static const route = '/order';
  final String orderId;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalhes do pedido')),
    body: ApiView<Map<String, dynamic>>(
      load: () => context.read<StoreService>().getOrder(orderId),
      builder: (context, order) => ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SelectableText('Pedido ${order['id']}'),
          Text(orderDate(order['createdAt'] as String)),
          Text('Status: ${orderStatus(order['status'] as String)}'),
          const Divider(),
          for (final item in order['items'] as List)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item['name'] as String),
              subtitle: Text(
                '${item['quantity']} × ${money(item['unitPrice'] as num)}',
              ),
              trailing: Text(money(item['subtotal'] as num)),
            ),
          const Divider(),
          Text(
            'Total: ${money(order['total'] as num)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (order['notes'] != null) Text(order['notes'] as String),
        ],
      ),
    ),
  );
}
