import 'package:nrfutil/terminal/constants.dart';
import 'package:nrfutil/main.dart' as nrfutil;
import 'package:nrfutil/src/version.dart';
import 'package:nrfutil/terminal/logger.dart';

void main(List<String> arguments) {
  logger = NRFLogger(true);
  logger?.verbose(introMessage(packageVersion));
  nrfutil.createFromArguments(arguments);
}