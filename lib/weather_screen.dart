import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AdditionalInfoItem.dart';
import 'HourlyForecast.dart';
import 'package:http/http.dart' as http;
import 'SecretConstant.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  late  Future<Map<String,dynamic >> weather;

  Future<Map<String,dynamic >> getCurrentWeather() async{
    try{
      String cityName= 'mumbai';
      final res = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=19.0330&lon=73.0297&APPID=$openWeatherAPIKey'),
      );

      final data = jsonDecode(res.body);

      if(data['cod']!='200')
        {
          throw 'An Unexpected error occurred';
        }
      return data;
    }
    catch (e)
    {
      throw e.toString();
    }
  }
  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('Weather App',style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.bold,
          ),
          ),

          centerTitle: true,
          actions:  [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(onPressed: () {
                setState(() {
                  weather= getCurrentWeather();
                });
              },
                  icon: const Icon(Icons.refresh)),
            )
          ],
        ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting)
            {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
          if(snapshot.hasError)
            {
              return Center(child: Text(snapshot.error.toString()));
            }

          final data = snapshot.data!;
          final currentWeatherData= data['list'][0];
          final currentTemp= ((currentWeatherData['main']['temp'])-273.15).toStringAsFixed(2);
          final currentSky = currentWeatherData['weather'][0]['main'];
          final humidity= currentWeatherData['main']['humidity'];
          final pressure = currentWeatherData['main']['pressure'];
          final windSpeed = ((currentWeatherData['wind']['speed'])*3.6).toStringAsFixed(1);


          return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[

              //main card
             SizedBox(
               width: double.infinity,
               child: Card(
                 elevation: 15,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(30)
                 ),
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(30),
                   child: BackdropFilter(
                     filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
                     child: Padding(
                       padding: const EdgeInsets.all(13.0),
                       child: Column(
                         children: [
                           Text('$currentTemp °C',
                             style: TextStyle(
                             fontSize: 32,
                             fontWeight: FontWeight.bold,
                           ),
                           ),
                           const SizedBox(height: 14,),

                           ShaderMask(
                             shaderCallback: (Rect bounds) {
                               return LinearGradient(
                                 colors: currentSky == 'Clouds' || currentSky == 'Rain'
                                     ? [Colors.blue, Colors.lightBlueAccent]
                                     : [Colors.red, Colors.orangeAccent],
                                 begin: Alignment.topLeft,
                                 end: Alignment.bottomRight,
                               ).createShader(bounds);
                             },
                             blendMode: BlendMode.srcIn,
                             child: Icon(
                               currentSky == 'Clouds' || currentSky == 'Rain'
                                   ? Icons.cloud
                                   : Icons.sunny,
                               size: 90,
                             ),
                           ),

                           Text(currentSky,style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
               ),
             ),

              //Weather Forecast Card
              const SizedBox(height:20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text('Hourly Forecast',
                  style: TextStyle(
                  fontSize: 24,
                    fontWeight: FontWeight.bold,
                ),
                ),
              ),
              const SizedBox(height:16),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  itemCount: 6,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context,index){

                    final hourlyForecastInfo =  data['list'][index+1];
                    final hourlySky = hourlyForecastInfo['weather'][0]['main'];
                    final hourlyTemp = ((hourlyForecastInfo['main']['temp'])-273.15).toStringAsFixed(2);
                    final hourlyTime =  hourlyForecastInfo['dt_txt'].toString();
                    final timee= DateTime.parse(hourlyTime);

                    return HourlyForecast(
                        time: DateFormat.j().format(timee),
                        temperature: hourlyTemp,
                        icon: hourlySky== 'Clouds' || hourlySky == 'Rain' ?
                                Icons.cloud:
                                Icons.sunny,
                    );
                    }),
              ),
              //Additional Information Card
              const SizedBox(height:20),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Additional Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,),
                  ),
                ),
              ),
              const SizedBox(height:16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '$humidity %'  ,
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '$windSpeed km/h',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: '$pressure hPa',
                  ),
                ],
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}


