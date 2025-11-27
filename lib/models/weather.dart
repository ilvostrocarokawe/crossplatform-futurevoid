class Weather {
  final String cityName;
  final double temperature; // in Kelvin o Celsius a seconda di &units
  final String description;
  final int conditionCode; // weather[0].id

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.conditionCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      description: (json['weather'][0]['description'] as String),
      conditionCode: json['weather'][0]['id'] as int,
    );
  }
}
