import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppCOntroller extends GetxController with SingleGetTickerProviderMixin {
  late TabController tabController;
  Rx<int> _currentPage = 0.obs;
  int get currentPage => _currentPage.value;
  Rx<int> _settingsTab = 0.obs;
  int get settingsTab => _settingsTab.value;
  set settingsTab(int i) => _settingsTab.value = i;

  @override
  void onInit() {
    tabController = new TabController(length: 14, vsync: this);
    super.onInit();
  }

  setCurrentPage(int index, bool animate) {
    if (animate)
      tabController.animateTo(index);
    else
      tabController.index = index;

    _currentPage.value = index;
  }
}
