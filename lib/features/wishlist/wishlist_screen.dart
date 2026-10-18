import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/widgets/error_view.dart';
import '../../app/widgets/page_header.dart';
import '../../core/wardrobe_values.dart';
import '../../database/app_database.dart';
import 'gap_ideas.dart';
import 'gap_providers.dart';
import 'wishlist_providers.dart';

String formatCents(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

/// "A$120", or "A$12.50" when there are cents.
String formatBudget(int cents) =>
    cents % 100 == 0 ? 'A\$${cents ~/ 100}' : 'A\$${formatCents(cents)}';

enum _Action {
  edit,
  purchased,
  purchasedWithoutAdding,
  dismiss,
  restore,
  delete,
}

/// Gaps in the wardrobe (ideas) and the wishlist, on one page.
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  WishlistStatus _status = WishlistStatus.planned;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;
    final add = FilledButton.icon(
      key: const Key('add-wishlist'),
      onPressed: () => context.push('/wishlist/new'),
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Add manually'),
    );
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 40,
          compact ? 16 : 32,
          compact ? 16 : 40,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              eyebrow: 'Based on your wardrobe',
              title: 'Gaps & wishlist',
              compact: compact,
              trailing: add,
            ),
            const SizedBox(height: 24),
            Text('IDEAS', style: monoCaption(context)),
            const SizedBox(height: 8),
            const GapIdeas(),
            const SizedBox(height: 32),
            Text('YOUR WISHLIST', style: monoCaption(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in WishlistStatus.values)
                  ChoiceChip(
                    key: Key('status-${s.name}'),
                    label: Text(s.label),
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _WishlistTable(status: _status, compact: compact),
          ],
        ),
      ),
    );
  }
}

class _WishlistTable extends ConsumerWidget {
  const _WishlistTable({required this.status, required this.compact});

  final WishlistStatus status;
  final bool compact;

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
    final unlocks = ref.watch(wishlistUnlocksProvider).value ?? const {};
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(e),
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              status == WishlistStatus.planned
                  ? 'Your wishlist is empty'
                  : 'Nothing here yet',
              style: const TextStyle(color: AppColors.muted),
            ),
          );
        }
        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (!compact) _header(context),
              for (final w in list)
                _row(context, ref, w, unlocks[w.id], compact),
            ],
          ),
        );
      },
    );
  }

  static const _gap = SizedBox(width: 12);

  Widget _header(BuildContext context) {
    Widget h(String t, {int flex = 1, double? width}) {
      final text = Text(t.toUpperCase(), style: monoCaption(context));
      return width != null
          ? SizedBox(width: width, child: text)
          : Expanded(flex: flex, child: text);
    }

    return Container(
      color: const Color(0xFFF7F6F1),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          h('Item', flex: 3),
          _gap,
          h('Priority', width: 90),
          _gap,
          h('Budget', width: 80),
          _gap,
          h('Unlocks', width: 100),
          _gap,
          h('Note', flex: 3),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, WidgetRef ref, WishlistItem w) =>
      PopupMenuButton<_Action>(
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
            const PopupMenuItem(value: _Action.dismiss, child: Text('Dismiss')),
          ] else
            const PopupMenuItem(
              value: _Action.restore,
              child: Text('Move back to planned'),
            ),
          const PopupMenuItem(value: _Action.delete, child: Text('Delete')),
        ],
      );

  Widget _pill(WishlistPriority p) {
    final (bg, fg) = switch (p) {
      WishlistPriority.high => (AppColors.primary, Colors.white),
      WishlistPriority.medium => (AppColors.primarySoft, AppColors.primary),
      WishlistPriority.low => (AppColors.placeholder, AppColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        p.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    WidgetRef ref,
    WishlistItem w,
    int? unlocked,
    bool compact,
  ) {
    final note = w.reason ?? w.notes;
    final unlockText = unlocked == null || status != WishlistStatus.planned
        ? '—'
        : '+$unlocked outfit${unlocked == 1 ? '' : 's'}';
    final budget = w.targetPriceCents == null
        ? '—'
        : formatBudget(w.targetPriceCents!);
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(w.category.label.toUpperCase(), style: monoCaption(context)),
      ],
    );
    return InkWell(
      key: ValueKey('wish-${w.id}'),
      onTap: () => context.push('/wishlist/${w.id}'),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: compact
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _pill(w.priority),
                            Text(budget),
                            Text(unlockText),
                          ],
                        ),
                        if (note != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              note,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _menu(context, ref, w),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 3, child: title),
                  _gap,
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _pill(w.priority),
                    ),
                  ),
                  _gap,
                  SizedBox(width: 80, child: Text(budget)),
                  _gap,
                  SizedBox(width: 100, child: Text(unlockText)),
                  _gap,
                  Expanded(
                    flex: 3,
                    child: Text(
                      note ?? '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                  _menu(context, ref, w),
                ],
              ),
      ),
    );
  }
}
