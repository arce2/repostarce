import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

/// Atajo para no repetir `AppLocalizations.of(context)!` en cada widget.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
