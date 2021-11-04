import 'package:be_still/controllers/app_controller.dart';
import 'package:get/get.dart';

class RootBinding extends Bindings {
  Future<void> dependencies() async {
    // State
    Get.put<AppCOntroller>(AppCOntroller());
  }
}
