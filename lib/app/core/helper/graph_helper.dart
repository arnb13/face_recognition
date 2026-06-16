class SalesChartData {
  SalesChartData(
    this.x,
    this.y,
    this.y1,
  );

  final String x;
  final double? y;
  final double? y1;
}

class TargetData {
  TargetData(this.year, this.target, this.achievement);

  final int year;
  final double target;
  final double achievement;
}

class BrandData {
  BrandData(this.x, this.y);

  final String x;
  final double y;
}
