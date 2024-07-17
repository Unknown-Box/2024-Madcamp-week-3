import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class ExpenditureRadarChart extends StatefulWidget {
  const ExpenditureRadarChart({super.key});

  @override
  State<ExpenditureRadarChart> createState() => _ExpenditureRadarChartState();
}

class _ExpenditureRadarChartState extends State<ExpenditureRadarChart> {
  List<List<dynamic>> data = [];
  Map<String, Map<String, int>> monthlyCategoryData = {};
  int _currentMonthIndex = 0;
  String _currentChartType = 'radar';
  List<String> months = [];
  List<String> categories = ["식비", "카페", "온라인 쇼핑", "생활", "패션", "뷰티", "교통", "의료", "저축", "통신비", "구독 서비스", "기타"];

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> loadCSV() async {
    final rawData = await rootBundle.loadString('assets/expenditures.csv');
    List<List<dynamic>> csvData = const CsvToListConverter(eol: '\n').convert(rawData);
    processCSVData(csvData);
  }

  void processCSVData(List<List<dynamic>> csvData) {
    if (csvData.isEmpty) {
      print('CSV data is empty');
      return;
    }

    // Skip the header row
    for (var i = 1; i < csvData.length; i++) {
      var row = csvData[i];
      DateTime date = DateTime.parse(row[1]);
      String category = row[5];
      int value = row[3];

      String month = DateFormat('yyyy-MM').format(date);
      if (!monthlyCategoryData.containsKey(month)) {
        monthlyCategoryData[month] = {};
        months.add(month);
      }

      if (!monthlyCategoryData[month]!.containsKey(category)) {
        monthlyCategoryData[month]![category] = 0;
      }

      monthlyCategoryData[month]![category] = monthlyCategoryData[month]![category]! + value;
    }

    // Sort months in ascending order
    months.sort((a, b) => a.compareTo(b));

    // Ensure data is set after processing
    setState(() {
      data = csvData;
      print('Data processing complete, data length: ${data.length}');
    });
  }

  String getRadarChartOption(String month) {
    var values = categories.map((category) => monthlyCategoryData[month]![category] ?? 0).toList();

    var maxValues = categories.map((category) {
      int maxValue = 0;
      monthlyCategoryData.forEach((_, categoryData) {
        if (categoryData.containsKey(category)) {
          maxValue = maxValue > categoryData[category]! ? maxValue : categoryData[category]!;
        }
      });
      return maxValue;
    }).toList();

    var indicators = categories.asMap().entries.map((entry) {
      int index = entry.key;
      String category = entry.value;
      return '{ name: "$category", max: ${maxValues[index]}}';
    }).toList();

    Color startColor = const Color(0xFF40C4FF); // Blue
    Color endColor = const Color(0xFF4CAF50); // Green
    Color middleColor = const Color(0xFF40C4FF); // Blue for the end

    // Calculate the current month index (0-based)
    int monthIndex = int.parse(month.substring(5)) - 1;

    // Calculate the gradient step
    double ratio;
    Color interpolatedColor;

    if (monthIndex <= 6) {
      // Interpolating between startColor and endColor
      ratio = monthIndex / 6.0;
      interpolatedColor = Color.lerp(startColor, endColor, ratio)!;
    } else {
      // Interpolating between endColor and middleColor
      ratio = (monthIndex - 6) / 6.0;
      interpolatedColor = Color.lerp(endColor, middleColor, ratio)!;
    }

    String colorHex = '#${interpolatedColor.value.toRadixString(16).substring(2)}';

    return '''
    {
      backgroundColor: '#333344',
      graphic: {
        elements: [
          {
            type: 'text',
            left: 'center',
            top: '5%',
            style: {
              text: '${month.substring(5)}',
              font: 'bold 50px sans-serif',
              lineDash: [0, 200],
              lineDashOffset: 0,
              fill: 'transparent',
              stroke: '#FFF',
              lineWidth: 1
            },
            keyframeAnimation: {
              duration: 500,
              loop: false,
              keyframes: [
                {
                  percent: 0.8,
                  style: {
                    fill: 'transparent',
                    lineDashOffset: 200,
                    lineDash: [200, 0]
                  }
                },
                {
                  // Stop for a while.
                  percent: 0.8,
                  style: {
                    fill: 'transparent'
                  }
                },
                {
                  percent: 1,
                  style: {
                    fill: 'white'
                  }
                }
              ]
            }
          }
        ]
      },
      tooltip: {
        trigger: 'item',
        backgroundColor: 'rgba(28, 28, 30, 0.7)',
        borderColor: '#40C4FF',
        borderWidth: 1,
        textStyle: {
          color: '#FFE0E0E0',
          fontSize: 14
        }
      },
      radar: {
        indicator: [${indicators.join(', ')}],
        radius: 120,
        splitLine: {
          lineStyle: {
            color: [
              'rgba(255, 255, 255, 0.5)',
              'rgba(255, 255, 255, 0.4)',
              'rgba(255, 255, 255, 0.3)',
              'rgba(255, 255, 255, 0.2)',
              'rgba(255, 255, 255, 0.1)',
            ]
          }
        },
        splitArea: {
          areaStyle: {
            color: ['#444455']
          }
        },
        axisLine: {
          lineStyle: {
            color: 'rgba(255, 255, 255, 0.5)'
          }
        },
        center: ["50%", "50%"]
      },
      series: [{
        name: '월간 지출액',
        type: 'radar',
        smooth: true,
        data: [{
          value: ${values.toString()},
          name: 'Expenditures',
          symbolSize: 0,
          areaStyle: {
            color: '${colorHex}33'
          },
          lineStyle: {
            color: '$colorHex',
            smooth: true
          },
          itemStyle: {
            color: '$colorHex'
          }
        }]
      }]
    }
    ''';
  }

  String getPieChartOption(String month) {
    var pieData = categories.map((category) {
      return '{ value: ${monthlyCategoryData[month]![category] ?? 0}, name: "$category" }';
    }).toList();

    return '''
    {
      backgroundColor: '#333344',
      graphic: {
        elements: [
          {
            type: 'text',
            left: 'center',
            top: '5%',
            style: {
              text: '${month.substring(5)}',
              font: 'bold 50px sans-serif',
              lineDash: [0, 200],
              lineDashOffset: 0,
              fill: 'transparent',
              stroke: '#FFF',
              lineWidth: 1
            },
            keyframeAnimation: {
              duration: 500,
              loop: false,
              keyframes: [
                {
                  percent: 0.8,
                  style: {
                    fill: 'transparent',
                    lineDashOffset: 200,
                    lineDash: [200, 0]
                  }
                },
                {
                  // Stop for a while.
                  percent: 0.8,
                  style: {
                    fill: 'transparent'
                  }
                },
                {
                  percent: 1,
                  style: {
                    fill: 'white'
                  }
                }
              ]
            }
          }
        ]
      },
      tooltip: {
        trigger: 'item',
        backgroundColor: 'rgba(28, 28, 30, 0.7)',
        borderColor: '#40C4FF',
        borderWidth: 1,
        textStyle: {
          color: '#FFE0E0E0',
          fontSize: 14
        }
      },
      legend: {
        top: '16%',
        left: 'center',
        textStyle: {
          color: '#FFE0E0E0'
        }
      },
      series: [{
        name: '카테고리별 지출액',
        type: 'pie',
        radius: ['30%', '70%'],
        center: ['50%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 30
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 30,
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: [${pieData.join(', ')}]
      }]
    }
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : Center(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: months.isEmpty
                      ? const Center(child: Text('No data available', style: TextStyle(color: Colors.white)))
                      : Echarts(
                    option: _currentChartType == 'radar' ? getRadarChartOption(months[_currentMonthIndex]) : getPieChartOption(months[_currentMonthIndex]),
                  ),
                ),
              ],
            ),
            Column(
              verticalDirection: VerticalDirection.up,
              children: [
                if (months.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Slider(
                          value: _currentMonthIndex.toDouble(),
                          min: 0,
                          max: 11,
                          divisions: 11,
                          label: (months[_currentMonthIndex]).substring(5), // Display only the month part
                          onChanged: (value) {
                            setState(() {
                              _currentMonthIndex = value.toInt();
                            });
                          },
                          activeColor: Colors.lightBlueAccent,
                          inactiveColor: const Color(0xFF3A3A3C),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 150,
                          child: CustomSlidingSegmentedControl<String>(
                            children: const {
                              'radar': Text('Radar'),
                              'pie': Text('Pie'),
                            },
                            padding: 10,
                            isStretch: true,
                            customSegmentSettings: CustomSegmentSettings(),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 67, 67, 69),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            thumbDecoration: BoxDecoration(
                              color: const Color.fromARGB(255, 64, 196, 255),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.3),
                                  blurRadius: 4.0,
                                  spreadRadius: 1.0,
                                  offset: const Offset(
                                    0.0,
                                    2.0,
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInToLinear,
                            onValueChanged: (value) {
                              setState(() {
                                _currentChartType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ]
        ),
      );
  }
}
