import 'package:flutter/material.dart';

class HourlyForecast extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData icon;

  const HourlyForecast({
    super.key,
    required this.time,
    required this.temperature,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 6,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius:  BorderRadius.circular(20),
          ),
          child:  Column(
            children: [
              Text(time,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold ),maxLines: 1,overflow: TextOverflow.ellipsis,),
              const SizedBox(height: 8),
              Icon(icon,size: 40,),
              const SizedBox(height:8),
              Text('$temperature °C',style: const TextStyle(fontSize: 14,),maxLines: 1,),
            ],
          ),
        ),
      ),
    );
  }
}
