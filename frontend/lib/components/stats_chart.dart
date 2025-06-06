import 'package:charts_flutter/flutter.dart' as charts;
import 'package:wordle/utils/chart_series.dart';
import 'package:provider/provider.dart';
import 'package:wordle/models/chart_model.dart';
import 'package:wordle/providers/theme_provider.dart';

import 'package:flutter/material.dart';

class StatsChart extends StatelessWidget {
  const StatsChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: FutureBuilder(
          future: getSeries(),
          builder: (context, snapshot) {
            final List<charts.Series<ChartModel, String>> series;
            if (snapshot.hasData) {
              series = snapshot.data as List<charts.Series<ChartModel, String>>;
              return Consumer<ThemeProvider>(
                builder: (_, notifier, __) {
                  charts.Color color;
                  if (notifier.isDark) {
                    color = charts.MaterialPalette.white;
                  } else {
                    color = charts.MaterialPalette.black;
                  }

                  return charts.BarChart(
                    series,
                    vertical: false,
                    animate: false,
                    domainAxis: charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(
                            lineStyle: charts.LineStyleSpec(
                                color: charts.MaterialPalette.transparent),
                            labelStyle: charts.TextStyleSpec(
                              fontSize: 14,
                              color: color,
                            ))),
                    primaryMeasureAxis: charts.NumericAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                            lineStyle: charts.LineStyleSpec(
                              color: charts.MaterialPalette.transparent,
                            ),
                            labelStyle: charts.TextStyleSpec(
                              color: charts.MaterialPalette.transparent,
                            ))),
                    barRendererDecorator: charts.BarLabelDecorator(
                        labelAnchor: charts.BarLabelAnchor.end,
                        outsideLabelStyleSpec: charts.TextStyleSpec(
                          color: color,
                        )),
                    behaviors: [charts.ChartTitle("Guess Distribution")],
                  );
                },
              );
            } else {
              return SizedBox();
            }
          }),
    );
  }
}
