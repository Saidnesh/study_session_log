import 'package:flutter/material.dart';

/// Bottom bar: Previous | Page x of y | Next.
/// Buttons are disabled at the first/last page and when there are no records.
class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasRecords;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasRecords,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canGoBack = hasRecords && currentPage > 1;
    final canGoForward = hasRecords && currentPage < totalPages;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: canGoBack ? onPrevious : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
            ),
            Text(
              hasRecords ? 'Page $currentPage of $totalPages' : 'No pages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            OutlinedButton(
              onPressed: canGoForward ? onNext : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('Next'), Icon(Icons.chevron_right)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
