// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

// Cross-platform file download/save.
// On web  → triggers a browser download via dart:html.
// On io   → saves to the Downloads folder (or app documents as fallback).
export 'downloader_stub.dart'
    if (dart.library.html) 'downloader_web.dart'
    if (dart.library.io) 'downloader_io.dart';
