import 'package:nrfutil/terminal/constants.dart';
import 'package:nrfutil/main.dart' as nrfutil;
import 'package:nrfutil/src/version.dart';

void main(List<String> arguments) {
  print(introMessage(packageVersion));
  nrfutil.createFromArguments(arguments);
}