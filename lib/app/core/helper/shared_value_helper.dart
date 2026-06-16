import 'package:shared_value/shared_value.dart';

final SharedValue<bool> isLoggedIn = SharedValue(
  value: false,
  key: "isLoggedIn",
);

final SharedValue<List<double>> faceEmbedding = SharedValue(
  value: [],
  key: "faceEmbedding",
);


final SharedValue<String> accessToken = SharedValue(
  value: "",
  key: "accessToken",
);


final SharedValue<String> userName = SharedValue(
  value: "",
  key: "userName",
);

final SharedValue<String> userID = SharedValue(
  value: "",
  key: "userID",
);

final SharedValue<String> userRole = SharedValue(
  value: "",
  key: "userRole",
);


final SharedValue<String> userEmail = SharedValue(
  value: "",
  key: "userEmail",
);

final SharedValue<String> userPhone = SharedValue(
  value: "",
  key: "userPhone",
);

final SharedValue<String> lastCheckIn = SharedValue(
  value: "",
  key: "lastCheckIn",
);
