import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

final months = [
  'Yan',
  'Fev',
  'Mar',
  'Apr',
  'May',
  'Iyn',
  'Iyl',
  'Avq',
  'Sen',
  'Okt',
  'Noy',
  'Dek',
];

class LineChartSample2 extends StatelessWidget {
  const LineChartSample2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add padding around the legend
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildLegend(),
        ),
        // Your existing chart
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 100,
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 12,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        months[value.toInt()],
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 100,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(fontSize: 10),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              minX: 0,
              maxX: 11,
              minY: 0,
              maxY: 600,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, 325),
                    FlSpot(1, 258),
                    FlSpot(2, 504),
                    FlSpot(3, 131),
                    FlSpot(4, 409),
                    FlSpot(5, 388),
                    FlSpot(6, 474),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color.fromARGB(48, 125, 109, 245),
                  ),
                ),
                LineChartBarData(
                  spots: [
                    FlSpot(0, 85),
                    FlSpot(1, 62),
                    FlSpot(2, 91),
                    FlSpot(3, 31),
                    FlSpot(4, 100),
                    FlSpot(5, 98),
                    FlSpot(6, 54),
                  ],
                  isCurved: true,
                  color: Colors.red,
                  dotData: FlDotData(show: true),
                  barWidth: 1,
                  aboveBarData: BarAreaData(
                    show: true,
                    color: const Color.fromARGB(64, 244, 67, 54),
                  ),
                  isStepLineChart: false,
                  isStrokeJoinRound: false,
                  lineChartStepData: LineChartStepData(stepDirection: 0.5),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color.fromARGB(64, 244, 67, 54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Custom legend widget
  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 20.0, // horizontal space between items
      runSpacing: 8.0, // vertical space between lines
      children: [
        _legendItem(Colors.blue, 'Cemi'),
        _legendItem(Colors.red, 'Ingilis dili'),
        _legendItem(const Color.fromARGB(255, 60, 244, 54), 'Riyaziyyat'),
        _legendItem(const Color.fromARGB(255, 145, 147, 19), 'Azerbaycan dili'),
        _legendItem(const Color.fromARGB(255, 3, 213, 56), 'Mentiq'),
        // Add more legend items if needed
      ],
    );
  }

  // Helper method to create legend items
  Widget _legendItem(Color color, String text) {
    return InkWell(
      onTap: () {
        // You can add functionality to toggle visibility here
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
