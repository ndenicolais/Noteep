// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

/// Calcola il numero di colonne in base alla larghezza dello schermo
int gridColumns(double width) {
  if (width >= 1400) return 6;
  if (width >= 1100) return 5;
  if (width >= 850) return 4;
  if (width >= 600) return 3;
  return 2;
}

/// Number of items placed in masonry column [col] when [count] items are
/// dealt round-robin across [cols] columns (item i → column i % cols).
int masonryColumnLength(int count, int cols, int col) {
  if (col >= count) return 0;
  return (count - col + cols - 1) ~/ cols;
}
