import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppCOntroller extends GetxController with SingleGetTickerProviderMixin {
  TabController tabController;
  Rx<int> _currentPage = 0.obs;
  int get currentPage => _currentPage.value;

  @override
  void onInit() {
    tabController = new TabController(length: 13, vsync: this);
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
