String formatBigNumber(int n) {
  var abs = n.abs();
  if (abs < 1000) {
    return "$n";
  }
  if (abs >= 1000 && abs < 100000) {
    return "${(n / 1000).toStringAsFixed(1)}k";
  }
  return "${(n ~/ 1000)}k";
}
