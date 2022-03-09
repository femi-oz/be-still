class FollowedPrayer {
  String? prayerId;
  String? groupId;

  FollowedPrayer({this.prayerId, this.groupId});

  FollowedPrayer.fromJson(Map<String, dynamic> json) {
    prayerId = json['prayerId'];
    groupId = json['groupId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['prayerId'] = this.prayerId;
    data['groupId'] = this.groupId;
    return data;
  }
}
