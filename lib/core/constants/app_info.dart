// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

const developerName = 'Nicola De Nicolais';
const developerEmail = 'ndn21dev@gmail.com';

/// Date shown as "last updated" in the privacy policy (in-app and
/// `PRIVACY.md`): change both together.
final privacyPolicyUpdatedAt = DateTime(2026, 10, 24);

/// Online privacy policy. Points to `PRIVACY.md` on GitHub until the
/// portfolio page `https://ndenicolais.github.io/noteep/privacy/` is online.
final uriPrivacyPolicy = Uri.parse(
  'https://github.com/ndenicolais/Noteep/blob/master/PRIVACY.md',
);

/// Links of the Info screen.
final uriSourceCode = Uri.parse('https://github.com/ndenicolais/Noteep');
final uriDeveloperGithub = Uri.parse('https://github.com/ndenicolais');
final uriContactMail = Uri(
  scheme: 'mailto',
  path: developerEmail,
  query: 'subject=Noteep',
);
