/// Philippine peso display without a formatting package.
String formatPesos(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return '₱$whole.${parts.last}';
}
