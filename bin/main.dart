import 'package:nrfutil/terminal/logger.dart';

import 'nrfutil.dart' as nrfutil;

void main(List<String> arguments) {
  logger?.warning(
    'This command is deprecated and replaced with "dart run nrfutil"',
  );
  nrfutil.main(arguments);
}