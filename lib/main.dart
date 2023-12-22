import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const List<Item> _items = [
  Item(
      name: 'Nasi Ayam',
      totalPriceCents: 999,
      uid: '1',
      imageProvider: NetworkImage(
          'https://images.unsplash.com/photo-1630910104722-21fe97230ef9?q=80&w=3556&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=300')),
  Item(
      name: 'Nasi Lemak',
      totalPriceCents: 899,
      uid: '2',
      imageProvider: NetworkImage(
          'https://media.istockphoto.com/id/1471904035/photo/nasi-uduk-indonesian-savoury-steam-rice-cooked-in-coconut-milk.webp?b=1&s=170667a&w=0&k=20&c=nS3khK0AOM1smvVz2l7hZm8I6_OYWzj0LXy79uiFULI=')),
  Item(
      name: 'Satay',
      totalPriceCents: 1499,
      uid: '3',
      imageProvider: NetworkImage(
          'https://images.unsplash.com/photo-1603088549155-6ae9395b928f?q=80&w=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D')),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: OrderingApp(),
    );
  }
}

class OrderingApp extends StatefulWidget {
  const OrderingApp({super.key});

  @override
  State<OrderingApp> createState() => _OrderingAppState();
}

class _OrderingAppState extends State<OrderingApp>
    with TickerProviderStateMixin {
  final List<Customer> _people = [
    Customer(
      name: 'Ahmad',
      imageProvider: const NetworkImage('https://flutter'
          '.dev/docs/cookbook/img-files/effects/split-check/Avatar1.jpg'),
    ),
    Customer(
      name: 'Syahmi',
      imageProvider: const NetworkImage('https://flutter'
          '.dev/docs/cookbook/img-files/effects/split-check/Avatar2.jpg'),
    ),
    Customer(
      name: 'Athirah',
      imageProvider: const NetworkImage('https://flutter'
          '.dev/docs/cookbook/img-files/effects/split-check/Avatar3.jpg'),
    )
  ];

  final GlobalKey _draggableKey = GlobalKey();

  void _itemDroppedOnCostomerCart(
      {required Item item, required Customer customer}) {
    setState(() {
      customer.items.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildContent());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(title: const Text('Order Makanan'));
  }

  Widget _buildContent() {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _buildMenuList(),
              ),
              _buildPeopleRow()
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMenuList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildMenuItem(item: item);
      },
      itemCount: _items.length,
    );
  }

  Widget _buildMenuItem({required Item item}) {
    return LongPressDraggable<Item>(
        data: item,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: DraggingListItem(
          dragKey: _draggableKey,
          photoProvider: item.imageProvider,
        ),
        child: MenuListItem(
          name: item.name,
          price: item.formattedTotalItemPrice,
          photoProvider: item.imageProvider,
        ));
  }

  Widget _buildPeopleRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Row(
        children: _people.map(_buildPersonWithDropZone).toList(),
      ),
    );
  }

  Widget _buildPersonWithDropZone(Customer customer) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child:
            DragTarget<Item>(builder: (context, candidateItems, rejectedItems) {
          return CustomerCart(
            hasItems: customer.items.isNotEmpty,
            highlighted: candidateItems.isNotEmpty,
            customer: customer,
          );
        }, onAccept: (item) {
          _itemDroppedOnCostomerCart(item: item, customer: customer);
        }),
      ),
    );
  }
}

class CustomerCart extends StatelessWidget {
  const CustomerCart({
    super.key,
    required this.customer,
    this.highlighted = false,
    this.hasItems = false,
  });

  final Customer customer;
  final bool highlighted;
  final bool hasItems;

  @override
  Widget build(BuildContext context) {
    final textColor = highlighted ? Colors.white : Colors.black;

    return Transform.scale(
        scale: highlighted ? 1.075 : 1.0,
        child: Material(
          elevation: highlighted ? 8 : 4,
          borderRadius: BorderRadius.circular(22),
          color: highlighted ? const Color(0xFFF64209) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child:
                        Image(image: customer.imageProvider, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  customer.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight:
                            hasItems ? FontWeight.normal : FontWeight.bold,
                      ),
                ),
                Visibility(
                  visible: hasItems,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        customer.formattedTotalItemPrice,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${customer.items.length} item${customer.items.length != 1 ? 's' : ''}',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: textColor,
                                  fontSize: 12,
                                ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class MenuListItem extends StatelessWidget {
  const MenuListItem({
    super.key,
    this.name = '',
    this.price = '',
    required this.photoProvider,
    this.isDepressed = false,
  });

  final String name;
  final String price;
  final ImageProvider photoProvider;
  final bool isDepressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    height: isDepressed ? 115 : 120,
                    width: isDepressed ? 115 : 120,
                    child: Image(
                      image: photoProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DraggingListItem extends StatelessWidget {
  const DraggingListItem({
    super.key,
    required this.dragKey,
    required this.photoProvider,
  });

  final GlobalKey dragKey;
  final ImageProvider photoProvider;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: ClipRRect(
        key: dragKey,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 150,
          width: 150,
          child: Opacity(
            opacity: 0.85,
            child: Image(
              image: photoProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class Item {
  const Item({
    required this.totalPriceCents,
    required this.name,
    required this.uid,
    required this.imageProvider,
  });

  final int totalPriceCents;
  final String name;
  final String uid;
  final ImageProvider imageProvider;
  String get formattedTotalItemPrice =>
      '\$${(totalPriceCents / 100.0).toStringAsFixed(2)}';
}

class Customer {
  Customer({
    required this.name,
    required this.imageProvider,
    List<Item>? items,
  }) : items = items ?? [];

  final String name;
  final ImageProvider imageProvider;
  final List<Item> items;

  String get formattedTotalItemPrice {
    final totalPriceCents =
        items.fold<int>(0, (prev, item) => prev + item.totalPriceCents);
    return '\$${(totalPriceCents / 100.0).toStringAsFixed(2)}';
  }
}
