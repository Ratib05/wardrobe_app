import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/error_view.dart';
import '../../core/wardrobe_values.dart';
import '../../database/app_database.dart';
import 'wishlist_providers.dart';

String formatCents(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

enum _Action {
  edit,
  purchased,
  purchasedWithoutAdding,
  dismiss,
  restore,
  delete,
}

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: WishlistStatus.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wishlist'),
          actions: [
            IconButton(
              tooltip: 'Wardrobe gaps',
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () => context.push('/wishlist/gaps'),
            ),
          ],
          bottom: TabBar(
            tabs: [for (final s in WishlistStatus.values) Tab(text: s.label)],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/wishlist/new'),
          icon: const Icon(Icons.add),
          label: const Text('Add to wishlist'),
        ),
        body: TabBarView(
          children: [
            for (final s in WishlistStatus.values) _WishlistTab(status: s),
          ],
        ),
      ),
    );
  }
}

class _WishlistTab extends ConsumerWidget {
  const _WishlistTab({required this.status});

  final WishlistStatus status;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WishlistItem w,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Delete '${w.name}'? This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(wishlistRepositoryProvider).delete(w.id);
  }

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    WishlistItem w,
    _Action action,
  ) async {
    final repo = ref.read(wishlistRepositoryProvider);
    switch (action) {
      case _Action.edit:
        context.push('/wishlist/${w.id}');
      case _Action.purchased:
        context.push('/wardrobe/new?fromWishlist=${w.id}');
      case _Action.purchasedWithoutAdding:
        await repo.setStatus(w.id, WishlistStatus.purchased);
      case _Action.dismiss:
        await repo.setStatus(w.id, WishlistStatus.dismissed);
      case _Action.restore:
        await repo.setStatus(w.id, WishlistStatus.planned);
      case _Action.delete:
        await _delete(context, ref, w);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wishlistProvider(status));
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(e),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              status == WishlistStatus.planned
                  ? 'Your wishlist is empty'
                  : 'Nothing here yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final w = list[i];
            final details = [
              w.category.label,
              '${w.priority.label} priority',
              if (w.targetPriceCents != null)
                'Budget ${formatCents(w.targetPriceCents!)}',
            ].join(' · ');
            return ListTile(
              key: ValueKey('wish-${w.id}'),
              title: Text(w.name),
              subtitle: Text(
                w.reason == null ? details : '$details\n${w.reason}',
              ),
              isThreeLine: w.reason != null,
              onTap: () => context.push('/wishlist/${w.id}'),
              trailing: PopupMenuButton<_Action>(
                tooltip: 'Actions',
                onSelected: (a) => _act(context, ref, w, a),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: _Action.edit, child: Text('Edit')),
                  if (status == WishlistStatus.planned) ...[
                    const PopupMenuItem(
                      value: _Action.purchased,
                      child: Text('Mark purchased'),
                    ),
                    const PopupMenuItem(
                      value: _Action.purchasedWithoutAdding,
                      child: Text('Mark purchased without adding'),
                    ),
                    const PopupMenuItem(
                      value: _Action.dismiss,
                      child: Text('Dismiss'),
                    ),
                  ] else
                    const PopupMenuItem(
                      value: _Action.restore,
                      child: Text('Move back to planned'),
                    ),
                  const PopupMenuItem(
                    value: _Action.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
